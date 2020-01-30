Create Procedure dbo.sp_load_InvoicewiseCollection (@CollectionID Int)                  
As                  
Begin
Declare @DebID Int, @DocBal Decimal(18,6), @ColAmt Decimal(18,6), @ChqCollDocID Int, @ChqCollDocType Int
Declare @OrigRef nVarchar(128), @DocRef nVarchar(128), @DocDate Datetime, @DocVal Decimal(18,6)

Select iwc.CollectionID,iwc.CollectionDate,iwc.DocumentID,iwc.DocReference,iwc.DocSerialType,iwc.ReferenceNumber as RefNo,                      
"DocType"=case when iwcd.DocumentType=1 then dbo.LookUpDictionaryItem(N'Invoice',Default) when iwcd.DocumentType=2 then dbo.LookUpDictionaryItem(N'Debit Note',Default) end,iwcd.CollectionID as ColID,                  
((case cld.DocumentType     
when 4 then (Select Isnull(sum(Balance),0) From InvoiceAbstract where InvoiceID=cld.DocumentID)     
when 5 then (Select Isnull(sum(Balance),0) From DebitNote where DebitID=cld.DocumentID) end)    
+ IsNull(cld.AdjustedAmount,0)+ IsNull(cld.Adjustment,0)) as DocBalance,    
IsNull(cld.AdjustedAmount,0) as ColAmt, "PayMode"=case cl.PaymentMode when 0 then dbo.LookUpDictionaryItem(N'Cash',Default)                   
when 1 then dbo.LookUpDictionaryItem(N'Cheque',Default) when 2 then dbo.LookUpDictionaryItem(N'DD',Default) end,cl.Balance as OutVal,cl.FullDocID as ColFullDocID,                  
cl.CustomerID,c.Company_Name as CompName,cl.ChequeNumber,cl.ChequeDate,cl.BankCode,cl.BranchCode,                 
cl.DocReference as ColDocRef,cl.DocSerialType as ColDSType,cl.DocumentReference as ColDocuRef,                 
"DocTag"=case cld.DocumentType when 4 then dbo.LookUpDictionaryItem(N'I',Default)+ Convert(Nvarchar,cld.DocumentID) when 5 then dbo.LookUpDictionaryItem(N'D',Default)+ Convert(Nvarchar,cld.DocumentID) end,                  
cld.OriginalID as FullDocID,cld.DocRef as FullDocRef,cld.DocumentDate as DocDate,cld.DocumentValue as DocValue,                      
cld.AdjustedAmount,cld.Discount,cld.Adjustment,cld.PaymentDate,cld.ExtraCollection,    
"AddlDiscount"=(case cld.DocumentType     
when 4 then (Select Isnull(sum(AdditionalDiscount),0) From InvoiceAbstract where InvoiceID=cld.DocumentID) else 0 end),
cl.DocumentID as AmendedDocID,
IsNull((case cld.DocumentType       
when 4 then (Select Isnull(DocSerialType,'') From InvoiceAbstract where InvoiceID=cld.DocumentID)       
when 5 then (Select Isnull(DocSerialType,'') From DebitNote where DebitID=cld.DocumentID) end),'') as TranSrlName,
(Case cld.DocumentType When 4 Then 0 Else (Select Flag From DebitNote Where DebitID = cld.DocumentID) End) as DebitFlag,
cld.DocumentID as InvDebID, cld.DocumentType as InvDebType, 0 as ChqCollDebitFlag, 0 as ChqAmt Into #tmpInvoiceDebit
From InvoiceWiseCollectionAbstract iwc, InvoiceWiseCollectionDetail iwcd,                      
Collections cl, CollectionDetail cld, Customer c                       
Where iwc.CollectionID = @CollectionID And iwc.CollectionID=iwcd.CollectionID And iwcd.DocumentID=cl.DocumentID And                       
cl.DocumentID=cld.CollectionID And cl.Customerid=c.CustomerID And cld.DocumentType in (4,5)  

Update tmp1 Set tmp1.DocBalance = tmp1.DocBalance + tmp2.ColAmt, tmp1.ColAmt = tmp1.ColAmt + tmp2.ColAmt 
From #tmpInvoiceDebit tmp1, (Select Sum(tmp.ColAmt) as ColAmt, ccd.DocumentID, ccd.DocumentType 
From #tmpInvoiceDebit tmp, ChequeCollDetails ccd Where tmp.DebitFlag = 2 And 
tmp.InvDebID = IsNull(ccd.DebitID, 0) Group By ccd.DocumentID, ccd.DocumentType)tmp2
Where tmp1.InvDebID = tmp2.DocumentID And tmp1.InvDebType = tmp2.DocumentType

-- To update the document balance from bounced cheque debit note balance
Update tmp1 Set tmp1.DocBalance = tmp1.DocBalance + tmp2.DebitBal, tmp1.ChqCollDebitFlag = 1 
From #tmpInvoiceDebit tmp1, (Select Sum(dn.Balance) as DebitBal, tmp.InvDebID, tmp.InvDebType 
From #tmpInvoiceDebit tmp, ChequeCollDetails ccd, DebitNote dn Where tmp.DebitFlag <> 2 And 
IsNull(ccd.DocumentID, 0) = tmp.InvDebID  And (ccd.DocumentType = tmp.InvDebType) And 
(IsNull(ccd.DebitID, 0) = dn.DebitID) And dn.Balance > 0 
Group By tmp.InvDebID, tmp.InvDebType)tmp2
Where tmp1.InvDebID = tmp2.InvDebID And tmp1.InvDebType = tmp2.InvDebType And tmp1.DebitFlag <> 2

If Exists(Select * From #tmpInvoiceDebit Where DebitFlag = 2)
Begin
	Select * Into #tmpTable From #tmpInvoiceDebit Where DebitFlag = 2
	Declare CurDebID Cursor For Select InvDebID, DocBalance, ColAmt From #tmpInvoiceDebit Where DebitFlag = 2
	Open CurDebID
	Fetch From CurDebID Into @DebID, @DocBal, @ColAmt
	While @@Fetch_Status = 0
	Begin
		Select @ChqCollDocID = DocumentID, @ChqCollDocType = DocumentType From ChequeCollDetails Where IsNull(DebitID, 0) = @DebID
		If Not Exists(Select * From #tmpInvoiceDebit Where InvDebID = @ChqCollDocID And InvDebType = @ChqCollDocType)
		Begin
			If @ChqCollDocType = 4
				Select @OrigRef=Case IsNULL(GSTFlag ,0) When 0 then (vp.Prefix+convert(Nvarchar,DocumentID)) Else IsNULL(GSTFullDocID,'''') End ,
				@DocRef=(Case IsNull(DocSerialType,'') when '' then vp.Prefix+'-'+DocReference else DocSerialType+'-'+DocReference End),
				@DocDate = InvoiceDate, @DocVal = (NetValue + RoundOffAmount)
				From InvoiceAbstract, VoucherPrefix vp, VoucherPrefix ivp where InvoiceID=@ChqCollDocID And vp.TranID='INVOICE' And ivp.TranID='INVOICE AMENDMENT'
			Else
				Select @OrigRef=(dvp.Prefix+convert(Nvarchar,DocumentID)), @DocRef=(Case IsNull(DocSerialType,'') when '' then DocumentReference else DocSerialType+'-'+DocumentReference End),
				@DocDate = DocumentDate, @DocVal = NoteValue
				From DebitNote, VoucherPrefix dvp where DebitID=@ChqCollDocID And dvp.TranID='DEBIT NOTE'    

			Update #tmpTable Set DocTag = (Case @ChqCollDocType When 4 Then dbo.LookUpDictionaryItem(N'I',Default)+ Convert(Nvarchar,@ChqCollDocID) When 5 Then dbo.LookUpDictionaryItem(N'D',Default)+ Convert(Nvarchar,@ChqCollDocID) End),
			FullDocID = @OrigRef, FullDocRef = @DocRef, DocDate = @DocDate, DocValue = @DocVal, DebitFlag = 0,
			ChqCollDebitFlag = 1
			Where InvDebID = @DebID And InvDebType = 5 And DebitFlag = 2

			Update #tmpTable Set DocBalance = DocBalance + (Select Sum(Balance) as Balance From DebitNote Where DebitID In 
			(Select Distinct IsNull(DebitID, 0) From ChequeCollDetails Where DocumentID = @ChqCollDocID And 
			DocumentType = @ChqCollDocType And IsNull(DebitID, 0) <> @DebID) And Balance > 0) Where InvDebID = @DebID
			And InvDebType = 5 And DebitFlag = 0

			Insert Into #tmpInvoiceDebit
			Select * From #tmpTable Where InvDebID = @DebID And InvDebType = 5 And DebitFlag = 0
		End
		Fetch Next From CurDebID Into @DebID, @DocBal, @ColAmt
	End
	Close CurDebID
	Deallocate CurDebID
	Drop Table #tmpTable
End

-- To update doctype description as 'Inv Chq Bounced' for bounced cheque of cheque invoice only
Update tmp1 Set tmp1.DocType = dbo.LookUpDictionaryItem(N'Inv Chq Bounced', Default) From #tmpInvoiceDebit tmp1, InvoiceAbstract iva
Where iva.InvoiceID = tmp1.InvDebID And tmp1.InvDebType = 4 And tmp1.DebitFlag <> 2 And IsNull(iva.PaymentMode, 0) = 2

-- To update the unrealised/unbounced cheque amount 
Update tmp1 Set tmp1.ChqAmt = tmp2.ChqAmt From #tmpInvoiceDebit tmp1, 
(Select InvDebID, InvDebType, (Case When isnull(Max(cl.realised),0) = 3 then dbo.mERP_fn_getCollBalance_ITC(Max(ClD.DocumentID), Max(ClD.DocumentType)) else (IsNull(Sum(cld.AdjustedAmount), 0) - IsNull(Sum(cld.DocAdjustAmount), 0)) End) as ChqAmt 
From Collections cl, CollectionDetail cld, #tmpInvoiceDebit rs
Where cld.DocumentID = rs.InvDebID And cld.DocumentType = rs.InvDebType 
And cl.DocumentID = cld.CollectionID And IsNull(cl.Status, 0) & 192 = 0 And IsNull(cl.PaymentMode, 0) = 1
And IsNull(cl.Realised, 0) Not In (1, 2)
Group By InvDebID, InvDebType)tmp2 
Where tmp1.InvDebID = tmp2.InvDebID And tmp1.InvDebType = tmp2.InvDebType

Select * From #tmpInvoiceDebit Where DebitFlag <> 2
Drop Table #tmpInvoiceDebit
End    
