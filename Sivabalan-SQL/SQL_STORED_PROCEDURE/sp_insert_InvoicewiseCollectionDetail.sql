CREATE Procedure dbo.sp_insert_InvoicewiseCollectionDetail 
(                  
	@InvColID integer,                  
	@ICL_DocDate datetime,        
	@ICLG_PayDate datetime,            
	@ICLG_ColID integer,          
	@ICLG_ColAmt decimal(18,6),                  
	@ICLG_OutValue decimal(18,6),                  
	@ICLG_PayMode integer,                  
	@ICLG_ChequeNo integer,                  
	@ICLG_ChequeDate datetime,                  
	@ChequeDetails nvarchar(128),                  
	@ICLG_CustID nvarchar(15),                  
	@DocPrefix nvarchar(50),                  
	@ICLG_BankCode nvarchar(10),                  
	@ICLG_BankBrCode nvarchar(10),                  
	@SalesmanID integer,                  
	@ICL_DocRef nvarchar(128) = N'',                  
	@FlagAmendment integer = 0,                  
	@AmendmentDocID nvarchar(50) = N'',  
                
	@ICLG_InvDebID integer,                  

	@ICLG_DocType nvarchar(20),                  
	@ICLG_DocDate datetime,                  
	@ICLG_AdjAmt decimal(18,6),      
	@ICLG_ExtraAmt decimal(18,6),                  
	@ICLG_SerialNo nvarchar(255),                  
	@ICLG_DocValue decimal(18,6),                  
	@ICLG_FullyAdjust integer,                  
	@ICLG_Adjustment decimal(18,6),      
	@ICLG_DocNo nvarchar(125)=N'',                  
	@ICLG_AddlDiscount decimal(18,6),          
	@ICLG_ColDocRef nvarchar(255),          
	@ICLG_ColDSType nvarchar(100),          
	@ICLG_ColDocuRef nvarchar(510),    
	@ICLG_CrAdj decimal(18,6) = 0,
	@netaddr as nVarchar(100) = N'',
	@ICLG_AmendedDocID as integer = 0
)                  
As                  
Begin                  
	Declare @nIdty as integer,@szDocID as nvarchar(50), @nDocType as integer,@szDocPrefixCol as nvarchar(50)                  
	Declare @szDType as varchar(100),@nTemp as decimal(18,6), @BtID as int         
	Declare @Adj_DocID as nvarchar(50),@Adj_DocDate as datetime,@Adj_Netval as decimal(18,6),@Adj_TranID as int    
	Declare @Adj_TranType as int,@Adj_TranName as nvarchar(50),@Adj_Adjusted as decimal(18,6),@Adj_DocRef as nvarchar(20)    
	Declare @Str as nVarchar(1000), @Bal as Decimal(18,6), @ICLG_PInvDebID as Int, @ICLG_PSerialNo as nVarchar(128)
	Declare @ChqCollDebitBal as Decimal(18,6)

	Create Table #Temp (tmpIdentity integer,tmpDocID nvarchar(50))    
	Create Table #Tmp1 (TableID int)  
	Create Table #Tmp2 (DocID nvarchar(50),DocDate datetime,Netval decimal(18,6),TranID int,TranType int,TranName nvarchar(50),Adjusted decimal(18,6),DocRef nvarchar(255))  
	Create Table #TmpRet1 (TableID int) 
	Create Table #TmpRet2 (TableID nVarchar(128)) 
	Create Table #ResultTable (ResultID Int, ResDocType1 nVarchar(20), ResDocNum1 nvarchar(255), ResDocType2 nVarchar(20), ResDocNum2 nvarchar(128))
	       
	Select @szDocPrefixCol=Prefix From VoucherPrefix where TranID=dbo.LookUpDictionaryItem(N'COLLECTIONS',Default)    
	
	-- If condn for collections table           
	If @ICLG_DocType=dbo.LookUpDictionaryItem(N'Invoice',Default) Or @ICLG_DocType=dbo.LookUpDictionaryItem(N'Inv Chq Bounced',Default)
	Begin    
		Set @nDocType=4                  
		Select @ICLG_SerialNo= Case IsNULL(GSTFlag ,0) When 0 then (vp.Prefix+convert(Nvarchar,DocumentID)) Else IsNULL(GSTFullDocID,'')End,
		@ICLG_DocNo=case IsNull(DocSerialType,'') when '' then vp.Prefix+'-'+DocReference else DocSerialType+'-'+DocReference end     
		From InvoiceAbstract, VoucherPrefix vp, VoucherPrefix ivp where InvoiceID=@ICLG_InvDebID And vp.TranID='INVOICE' And ivp.TranID='INVOICE AMENDMENT'    
		
		If Exists ( Select MappedBeatID from tbl_merp_DSOStransfer where InvoiceID =@ICLG_InvDebID)				
			Select @BtID=IsNull(MappedBeatID,0) from tbl_merp_DSOStransfer where InvoiceID =@ICLG_InvDebID
		Else
			Select @BtID=IsNull(BeatID,0) From InvoiceAbstract Where InvoiceID=@ICLG_InvDebID  
	End    
	Else                  
	Begin    
		Set @nDocType=5                  
		Select @ICLG_SerialNo=(dvp.Prefix+convert(Nvarchar,DocumentID)), @ICLG_DocNo=case IsNull(DocSerialType,'') when '' then DocumentReference else DocSerialType+'-'+DocumentReference end     
		From DebitNote, VoucherPrefix dvp where DebitID=@ICLG_InvDebID And dvp.TranID='DEBIT NOTE'    
		
		Set @BtID=0  
	End    
	
	If @AmendmentDocID = N''
		Set @FlagAmendment = 0
	
	-- Insert Collections                  
	Insert INTO #Temp                  
	Exec sp_insert_collections @ICL_DocDate,@ICLG_ColAmt,0,@ICLG_PayMode,@ICLG_ChequeNo,@ICLG_ChequeDate,                  
	@ChequeDetails,@ICLG_CustID,@szDocPrefixCol,@ICLG_BankCode,@ICLG_BankBrCode,@SalesmanID,N'',@FlagAmendment,                  
	@AmendmentDocID,null,0,null,null,0,0,0,@BtID                  
             
	Select @nIdty=tmpIdentity,@szDocID=tmpDocID From #Temp            

	-- To update transaction series for collections          
	If @FlagAmendment=1          
	Begin
		If @AmendmentDocID <> N''
		Begin
			Update Collections Set OriginalRef = @AmendmentDocID, RefDocID = @ICLG_AmendedDocID, DocReference=@ICLG_ColDocRef, DocSerialType=@ICLG_ColDSType,DocumentReference=@ICLG_ColDocuRef          
			where DocumentID=Convert(Nvarchar,@nIdty)          
		End
		Else
		Begin
			Update Collections Set DocReference=@ICLG_ColDocRef, DocSerialType=@ICLG_ColDSType,DocumentReference=@ICLG_ColDocuRef          
			where DocumentID=Convert(Nvarchar,@nIdty)          
		End
	End
	Else
	Begin
		Update Collections Set DocumentReference = FullDocID, DocSerialType = '' Where DocumentID = @nIdty
	End

	Set @Bal = 0
	If @nDocType = 4
		Select @Bal=IsNull(Balance,0) From InvoiceAbstract Where InvoiceID = @ICLG_InvDebID  
	Else If @nDocType = 5
		Select @Bal=IsNull(Balance,0) From DebitNote Where DebitID = @ICLG_InvDebID 

	--If the debit document is already adjusted by another user and the current doc value is greater than available 
	--balance, then the transaction should not get saved. This has been handled in the following conditional statement.
	If @Bal < (@ICLG_AdjAmt + @ICLG_Adjustment)
	Begin
		Select @ChqCollDebitBal=IsNull(Sum(dn.Balance),0) 
		From Collections cl, ChequeCollDetails ccd, DebitNote dn 
		Where ccd.DocumentID = @ICLG_InvDebID And ccd.DocumentType = @nDocType And ccd.CollectionID = cl.DocumentID 
		And IsNull(cl.Status, 0) & 192 = 0 And ccd.DebitID = dn.DebitID

		If @ChqCollDebitBal > 0 And @ChqCollDebitBal < ((@ICLG_AdjAmt + @ICLG_Adjustment)-@Bal)
		Begin		
	--		Delete From Collections Where DocumentID = @nIdty
	--		Delete From InvoicewiseCollectionAbstract Where CollectionID = @InvColID
			Insert Into #ResultTable
			Select -1, (Case @nDocType When 4 Then N'Invoice' When 5 Then N'Debit Note' End), @ICLG_SerialNo, N'', N'0'
			Goto ZeroBal
		End
	End

	-- Insert CollectionDetail     
	Set @ICLG_PayDate=GetDate() 

	Insert Into #TmpRet1 
	Exec sp_insert_collectiondetail @nIdty,@ICLG_InvDebID,@nDocType,@ICLG_DocDate,@ICLG_PayDate,@ICLG_AdjAmt,@ICLG_SerialNo,                  
	@ICLG_DocValue,@ICLG_ExtraAmt,@ICLG_FullyAdjust,@ICLG_Adjustment,@ICLG_DocNo,@ICLG_AddlDiscount,1                  

    Set @ICLG_PInvDebID = @ICLG_InvDebID
	Set @ICLG_PSerialNo = @ICLG_SerialNo

	-- If condn for invoice wise collections table                  
	If @ICLG_DocType=dbo.LookUpDictionaryItem(N'Invoice',Default) Or @ICLG_DocType=dbo.LookUpDictionaryItem(N'Inv Chq Bounced',Default)
		Set @nDocType=1                  
	Else                  
		Set @nDocType=2                  
                   
	-- Insert InvoicewiseCollectionDetail                  
	Insert INTO InvoiceWiseCollectionDetail (CollectionID, CollectedAmount, DocumentID, DocumentType)   
	Values (@InvColID, @ICLG_ColAmt, @nIdty, @nDocType) 	

	Set @Str='Insert Into #Tmp1 Select TableID From ##' + @netaddr + ' Where CustID = '''+ @ICLG_CustID + ''' And ParentTranID = ''' + @ICLG_SerialNo + ''''  
	  
	Exec sp_executesql @Str  
	
	-- Insert adjusted credit documents in CollectionDetail - for ITC    
	If Exists(Select * From #Tmp1)    
	Begin    
		Set @Str = 'Insert Into #Tmp2 Select DocID,DocDate,Netval,TranID,TranType,TranName,Adjusted,DocRef From ##' + @netaddr + ' Where CustID = ''' + @ICLG_CustID + ''' And ParentTranID = ''' + @ICLG_SerialNo + ''' And Adjusted > 0   '  
   
		Exec sp_executesql @Str  
		
		Declare ADJ_CURSOR CURSOR STATIC FOR      
		Select DocID,DocDate,Netval,TranID,TranType,TranName,Adjusted,DocRef From #Tmp2  
		Open ADJ_CURSOR      
		Fetch From ADJ_CURSOR INTO @Adj_DocID,@Adj_DocDate,@Adj_Netval,@Adj_TranID,@Adj_TranType,@Adj_TranName,@Adj_Adjusted,@Adj_DocRef    
		While @@FETCH_STATUS = 0      
		Begin      
			Set @ICLG_InvDebID=@Adj_TranID    
			Set @nDocType=@Adj_TranType    
			Set @ICLG_DocDate=@Adj_DocDate    
			Set @ICLG_AdjAmt=@Adj_Adjusted    
			Set @ICLG_SerialNo=@Adj_DocID    
			Set @ICLG_DocValue=@Adj_Netval    
			Set @ICLG_ExtraAmt=0    
			Set @ICLG_FullyAdjust=0    
			Set @ICLG_Adjustment=0    
			Set @ICLG_DocNo=@Adj_DocRef    
			Set @ICLG_AddlDiscount=0    
       		Set @Bal = 0
	
			If @nDocType = 1  
				Select @Bal=IsNull(Balance,0) From InvoiceAbstract Where InvoiceID = @ICLG_InvDebID  
			Else If @nDocType = 2
				Select @Bal=IsNull(Balance,0) From CreditNote Where CreditID = @ICLG_InvDebID  
			Else 
				Select @Bal=IsNull(AdjustedAmount,0) From CollectionDetail Where CollectionID = @ICLG_InvDebID And DocumentType = 3

			If @Bal < @ICLG_AdjAmt   
			Begin
				If @ICLG_DocType=dbo.LookUpDictionaryItem(N'Invoice',Default) Or @ICLG_DocType=dbo.LookUpDictionaryItem(N'Inv Chq Bounced',Default)
				Begin
					Insert Into #ResultTable
					Select -1, (Case @nDocType When 1 Then N'Sales Return' When 2 Then N'Credit Note' Else N'Advance Collection' End), @ICLG_SerialNo, N'Invoice', @ICLG_PSerialNo
					Close ADJ_CURSOR    
					Deallocate ADJ_CURSOR 
					Goto ZeroBal
-- 	 				Update CollectionDetail Set AdjustedAmount = (AdjustedAmount - @ICLG_AdjAmt) Where CollectionID = @nIdty And DocumentType = 4
-- 					Update InvoiceAbstract Set Balance = (Balance + @ICLG_AdjAmt) Where InvoiceID = @ICLG_PInvDebID					
				End
				Else
				Begin
					Insert Into #ResultTable
					Select -1, (Case @nDocType When 1 Then N'Sales Return' When 2 Then N'Credit Note' Else N'Advance Collection' End), @ICLG_SerialNo, N'Debit Note', @ICLG_PSerialNo
					Close ADJ_CURSOR    
					Deallocate ADJ_CURSOR    
					Goto ZeroBal
-- 	 				Update CollectionDetail Set AdjustedAmount = (AdjustedAmount - @ICLG_AdjAmt) Where CollectionID = @nIdty And DocumentType = 5
-- 					Update DebitNote Set Balance = (Balance + @ICLG_AdjAmt) Where DebitID = @ICLG_PInvDebID					
				End
			End
			Else
			Begin
				Insert Into #TmpRet1
				Exec sp_insert_collectiondetail @nIdty,@ICLG_InvDebID,@nDocType,@ICLG_DocDate,@ICLG_PayDate,@ICLG_AdjAmt,@ICLG_SerialNo,                  
				@ICLG_DocValue,@ICLG_ExtraAmt,@ICLG_FullyAdjust,@ICLG_Adjustment,@ICLG_DocNo,@ICLG_AddlDiscount,1                  
     		End
			FETCH NEXT FROM ADJ_CURSOR INTO @Adj_DocID,@Adj_DocDate,@Adj_Netval,@Adj_TranID,@Adj_TranType,@Adj_TranName,@Adj_Adjusted,@Adj_DocRef    
		End  
		Close ADJ_CURSOR    
		Deallocate ADJ_CURSOR    
	End    
	
ZeroBal:
	Select * From #ResultTable
	Drop Table #ResultTable
	Drop Table #Temp
	Drop Table #Tmp1  
	Drop Table #Tmp2  
	Drop Table #TmpRet1  
	Drop Table #TmpRet2
End                  
