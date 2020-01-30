Create procedure spr_Customerwise_Categorywise_Detail( @Customer nvarchar(2550),    
       @FromDate datetime,      
       @ToDate datetime)      
as  
  
Declare @INVOICE NVarchar(50)  
Declare @SALESRETURN NVarchar(50)  
Declare @RETAILINVOICE NVarchar(50)  
Declare @INVOICEAMENDMENT NVarchar(50)  
Declare @SALESRETURNSALEABLE NVarchar(50)  
Declare @SALESRETURNDAMAGE NVarchar(50)  
Declare @CREDITNOTE NVarchar(50)  
Declare @DEBITNOTE NVarchar(50)  
Declare @ADVANCE NVarchar(50)  
Declare @CustID NVarchar(250)  
Declare @CatID NVarchar(250)  
Declare @Loc Int  
  
Set @Loc = CharIndex(Char(15), @Customer, 1)  
Set @CustID = Substring(@Customer, 1, @Loc - 1)  
Set @CatID = Substring(@Customer, @Loc + 1, Len(@Customer))  
  
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)  
Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)  
Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice', Default)  
Set @INVOICEAMENDMENT = dbo.LookupDictionaryItem(N'Invoice Amendment', Default)  
Set @SALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'Sales Return Saleable', Default)  
Set @SALESRETURNDAMAGE = dbo.LookupDictionaryItem(N'Sales Return Damages', Default)  
Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)  
Set @DEBITNOTE = dbo.LookupDictionaryItem(N'Debit Note', Default)  
Set @ADVANCE = dbo.LookupDictionaryItem(N'Advance', Default)  
  
Create Table #tempCategory(CategoryID int, Status int)            
Exec dbo.GetLeafCategories '%', @CatID  
  
declare @invtype nvarchar(100)      
  
Create Table #temp1 (InvoiceID Int, DocumentID nVarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS, DocReference nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,   
[Date] DateTime, Amount Decimal(18, 6), Balance Decimal(18, 6), DueDays Int,ChequeInhand decimal(18,6),   
DocType nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  
Insert InTo #temp1  
select InvoiceAbstract.InvoiceID,       
"Documentid" =       
case IsNull(InvoiceAbstract.GSTFlag,0) when 0 then InvPrefix.Prefix      
+ cast(InvoiceAbstract.DocumentID as nvarchar)else ISNULL(InvoiceAbstract.GSTFullDocID,'')end,      
"Doc Reference"=DocReference,      
"Date" = InvoiceAbstract.InvoiceDate,   
"Amount" = (case InvoiceType      
when 4 then 0 - InvoiceDetail.Amount when 5 then 0 - InvoiceDetail.Amount   
when 6 then 0 - InvoiceDetail.Amount else InvoiceDetail.Amount end),      
"Balance" =   
(IsNull(InvoiceDetail.Amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))   
From InvoiceDetail ids Where ids.InvoiceId = InvoiceAbstract.InvoiceID), 1) When 0 Then 1 Else   
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail ids  
Where ids.InvoiceId = InvoiceAbstract.InvoiceID), 1) End) *   
(Case InvoiceAbstract.InvoiceType When 4 Then 0 - Isnull(InvoiceAbstract.Balance,0)  
                    When 5 Then 0 - Isnull(InvoiceAbstract.Balance,0)   
      When 6 Then 0 - Isnull(InvoiceAbstract.Balance,0)  
      Else IsNull(InvoiceAbstract.Balance,0) End),  
  
"Due Days" = datediff(dd, InvoiceAbstract.InvoiceDate, GetDate()),
"ChequeInHand"= (IsNull(InvoiceDetail.Amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))   
From InvoiceDetail ids Where ids.InvoiceId = InvoiceAbstract.InvoiceID), 1) When 0 Then 1 Else   
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail ids  
Where ids.InvoiceId = InvoiceAbstract.InvoiceID), 1) End) 
 *   
--(Select   
--Case When MAx(isnull(C.Realised,0)) =3 Then  
--(dbo.mERP_fn_getCollBalance_ITC_Rpt(MAx(CD.DocumentID), MAx(CD.DocumentType),@Todate))  
--Else  
--	(Case When Max(isnull(CCd.ChqStatus,0)) = 1 And dbo.stripdatefromtime(@todate) < isnull(Max(dbo.stripdatefromtime(CCD.Realisedate)),getdate()) Then
--	(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))
--	When isnull(Max(CCd.ChqStatus),0) = 1 And dbo.stripdatefromtime(@todate) = isnull(Max(dbo.stripdatefromtime(CCD.Realisedate)),getdate()) Then 0
--	Else
--	(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end)
--End  
--from Collections C, CollectionDetail CD,ChequeCollDetails CCD
--Where CD.Documenttype = 4 and CD.DocumentID = invoiceabstract.InvoiceID And C.customerID = invoiceabstract.CustomerID And C.documentID = CD.CollectionID 
--And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1
--And CCD.CollectionID = C.Documentid
--And C.Documentdate between @fromdate and @todate
--and IsNull(c.Realised, 0) Not In (2))

(Select Sum( 
Case When isnull(C.Realised,0) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC_Rpt(CD.DocumentID, CD.DocumentType,@Todate,C.Documentid,GetDate()))  
Else  
	(Case When isnull(CCd.ChqStatus,0) = 1 And dbo.stripdatefromtime(@todate) < isnull(dbo.stripdatefromtime(CCD.Realisedate),getdate()) Then
	(isnull(isnull(AdjustedAmount,0),0)-isnull(isnull(DocAdjustAmount,0),0))
	When isnull(CCd.ChqStatus,0) = 1 And dbo.stripdatefromtime(@todate) >= isnull(dbo.stripdatefromtime(CCD.Realisedate),getdate()) Then 0
	Else
	(isnull(isnull(AdjustedAmount,0),0)-isnull(isnull(DocAdjustAmount,0),0))end)
End ) 
--from Collections C, CollectionDetail CD,ChequecollDetails CCD  
--Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
--And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
--And C.DocumentDate between @fromdate and @todate
--And CCD.CollectionID = C.Documentid
--and IsNull(c.Realised, 0) Not In (2)) 
from Collections C, CollectionDetail CD,ChequeCollDetails CCD
Where CD.Documenttype = 4 and CD.DocumentID = invoiceabstract.InvoiceID And C.customerID = invoiceabstract.CustomerID And C.documentID = CD.CollectionID 
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1
And CD.Documentid = CCd.Documentid
And CCD.CollectionID = C.Documentid
And C.Documentdate between @fromdate and @todate
and IsNull(c.Realised, 0) Not In (2))
,
"Doc Type" = case InvoiceAbstract.InvoiceType      
when 1 then @INVOICE when 2 then @RETAILINVOICE when 3 then @INVOICEAMENDMENT  
when 4 then @SALESRETURN when 5 then @SALESRETURNSALEABLE when 6 then @SALESRETURNDAMAGE else N'' end  
from InvoiceAbstract, InvoiceDetail, Items, --ItemCategories,   
VoucherPrefix as InvPrefix      
where 
InvoiceAbstract.Status & 192 = 0 and 
InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) and 
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and 
InvoiceAbstract.Balance >= 0 and 
InvoiceAbstract.CustomerID = @CustID and 
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And 
InvoiceDetail.Product_Code = Items.Product_Code And   
--Items.CategoryID = ItemCategories.CategoryID And  
--ItemCategories.CategoryID = @CatID And   
Items.CategoryID In (Select CategoryID From #tempCategory) And  
InvPrefix.TranID = N'INVOICE'   
  
Select "InvoiceID" = InvoiceID, "DocumentID" = DocumentID, "Doc Reference" = DocReference,  
"Date" = [Date], "Amount" = Sum(Amount), "Balance" = Sum(Balance), "Due Days" = DueDays,"Cheque in Hand" = Sum(ChequeinHand),  
"Doc Type" = DocType From #temp1 Group By  
InvoiceID, DocumentID, DocReference, [Date], DueDays, DocType  
      
Drop Table #tempCategory  
Drop Table #temp1

