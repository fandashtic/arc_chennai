CREATE PROCEDURE sp_acc_agent_cash_Collections_ITC(@SManName nVarChar(30),@FROMDATE DateTime,@TODATE DateTime)
AS
CREATE Table #Temp1
( 
	Collid Integer,
	Collectionid Integer,
	SManid nVarChar(40) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SManName nVarChar(40) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CashColl Decimal(18,6),
	XtraCol Decimal(18,6),
	WriteOffCol Decimal(18,6),
	Coltype Integer,
	ColDiscAmt Decimal(18,6)
)

if(@SManName=N'%')
	Begin
		Insert Into #Temp1
		Select 		Collections.DocumentID,Collectiondetail.DocumentID,Collections.SalesManID,"Salesman Name"=IsNull(Salesman.SalesMan_Name,dbo.lookupdictionaryitem('Others',Default)), 
		"Cash Collected" = Case Collectiondetail.Documenttype 
		When 4 then Sum(Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)
		When 5 then Sum(Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)
		When 6 then Sum(Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)
		Else 0-Sum(Collectiondetail.AdjustedAmount + Collectiondetail.Extracollection) 
		End,
		"Extra Collection"=Case Collectiondetail.Documenttype 
		When 4 then Sum(CollectionDetail.ExtraCollection)
		When 5 then Sum(CollectionDetail.ExtraCollection)
		When 6 then Sum(CollectionDetail.ExtraCollection)
		Else 0-Sum(Collectiondetail.Extracollection) End,
 		"Write Off Amount"= (Case CollectionDetail.Discount When 0 Then Sum(CollectionDetail.Adjustment)
		Else Sum(CollectionDetail.Adjustment) - (Sum(CollectionDetail.Discount/100) * (Sum(DocumentValue))) End),  
--		(Select dbo.fn_GetWriteOff(CollectionDetail.CollectionID)),  
		"Coltype"=Collectiondetail.DocumentType,
		"ColDiscAmt" = (Select dbo.fn_GetCollectionDiscount(CollectionDetail.CollectionID)) 
		From	Collections
		Left Outer Join Salesman On Collections.SalesManID = Salesman.SalesManID 
		Inner Join Collectiondetail On Collectiondetail.CollectionID=Collections.DocumentID
		Where	
		Collections.DocumentDate Between @FROMDATE And @TODATE 
		And PaymentMode = 0 
		And (IsNull(Collections.Status,0) & 192) = 0 And
		(IsNull(Collections.Status,0) & 64) = 0 And
		Collections.CustomerID is Not Null
		Group By Collections.DocumentID,Collectiondetail.DocumentID,Collections.SalesManID, 
		Salesman.SalesMan_Name,
		Collections.Value,Collections.Balance,Collectiondetail.DocumentType, 
		CollectionDetail.CollectionID,Collectiondetail.Discount

		Insert Into #Temp1
		Select DocumentID,0,Collections.SalesManID,IsNull(Salesman.SalesMan_Name,dbo.lookupdictionaryitem('Others',Default)),
		Sum(Isnull(Value,0)),0,0,0,0 
		from Collections
		Left Outer Join SalesMan On Collections.SalesManID = Salesman.SalesManID
		Inner Join VoucherPrefix On VoucherPrefix.TranID = N'Collections'
		Where	
		Collections.DocumentDate Between @FROMDATE And @TODATE And PaymentMode = 0 And 
		Collections.CustomerID is Not Null And
		(IsNull(Status, 0) & 192) = 0 And 
		(IsNull(Status, 0) & 64) = 0 
		And DocumentID Not in (Select Collid from #Temp1)
		Group By Collections.SalesManID,SalesMan_Name ,DocumentID
	End
Else
	Begin
		Insert Into #Temp1
		Select Collections.DocumentID,Collectiondetail.DocumentID,Collections.SalesManID,"Salesman Name" = IsNull(Salesman.SalesMan_Name,dbo.lookupdictionaryitem('Others',Default)),
		"Cash Collected" =	Case Collectiondetail.Documenttype 
		When 4 then Sum(Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)
		When 5 then Sum(Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)
		When 6 then Sum(Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)
		Else 0-Sum(Collectiondetail.AdjustedAmount+Collectiondetail.Extracollection) End,
		"Extra Collection"=Case Collectiondetail.Documenttype 
		When 4 then Sum(CollectionDetail.ExtraCollection)
		When 5 then Sum(CollectionDetail.ExtraCollection)
		When 6 then Sum(CollectionDetail.ExtraCollection)
		Else 0-Sum(Collectiondetail.Extracollection) End,
 		"Write Off Amount"= (Case CollectionDetail.Discount When 0 Then Sum(CollectionDetail.Adjustment)
		Else Sum(CollectionDetail.Adjustment) - (Sum(CollectionDetail.Discount/100) * (Sum(DocumentValue))) End),
-- 		(Select dbo.fn_GetWriteOff(CollectionDetail.CollectionID)),  
		"Coltype"=Collectiondetail.DocumentType,
		"ColDiscAmt"= (Select dbo.fn_GetCollectionDiscount(Collectiondetail.CollectionID)) 
		From	Collections, Salesman,Collectiondetail
		Where	Collections.SalesManID = Salesman.SalesManID And 
		Salesman.SalesMan_Name=@SManName And
		Collections.DocumentDate Between @FROMDATE And @TODATE 
		And PaymentMode = 0 
		And (IsNull(Collections.Status,0) & 64) = 0 And
		(IsNull(Collections.Status,0) & 192) = 0 And
		Collections.CustomerID is Not Null
		And Collectiondetail.CollectionID=Collections.DocumentID
		Group By Collections.DocumentID,Collectiondetail.DocumentID,Collections.SalesManID, 
		Salesman.SalesMan_Name,	Collections.Value,Collections.balance,Collectiondetail.DocumentType, 
		CollectionDetail.CollectionID,Collectiondetail.Discount
	
		Insert Into #Temp1
		Select DocumentID,0,Collections.SalesManID,IsNull(Salesman.SalesMan_Name, 
		dbo.lookupdictionaryitem('Others',Default)),
		Sum(Isnull(Value,0)),0,0,0,0 
		from Collections, VoucherPrefix,SalesMan
		Where Collections.SalesManID = Salesman.SalesManID And  
		Salesman.SalesMan_Name=@SManName And
		Collections.DocumentDate Between @FROMDATE And @TODATE And PaymentMode = 0 And 
		Collections.CustomerID is Not Null And
		(IsNull(Status, 0) & 192) = 0 And 
		(IsNull(Status, 0) & 64) = 0 And
		VoucherPrefix.TranID = N'Collections'
		And DocumentID Not in (Select Collid from #Temp1)
		Group By Collections.SalesManID,SalesMan_Name ,DocumentID
	End

Select  "ColID" = collid, SManid,"SalesMan Name"=SManName,
"Cash Collected"= Sum(Isnull(CashColl,0)),

"Extra Collection"= Sum(Isnull(XtraCol,0)),
"Write Off" = ISnull(WriteOffCol,0),
"Invoice Adjustments"= (Select  Sum(Isnull(Invoiceabstract.AdjustedAmount,0)) From Invoiceabstract
where Invoiceabstract.InvoiceID in (Select Distinct(t2.collectionid) From #Temp1 t2 
Where t2.Coltype In (4, 6) And t2.SManid=#Temp1.SManid)),

"Total Discount Amount"=(Select  Sum(Isnull(AddlDiscountValue,0) + ISnull(DiscountValue,0)) From Invoiceabstract
where Invoiceabstract.Invoiceid in (Select Distinct(t2.collectionid) From #Temp1 t2 
Where t2.Coltype In (4, 6) And t2.SManid=#Temp1.SManid)),

"Collection Discount" = Sum(IsNull(#Temp1.ColDiscAmt,0)) 
into #temptot1
from #Temp1 Group By SManid,SManName , collid,WriteOffCol

-------------------------------------------------------------
--
--Select [Invoice Adjustments]  = (Select Distinct [Invoice Adjustments]  from #temptot1 t1 
--where t1.[Smanid] = t2.[Smanid] ),
--[Total Discount Amount] = (Select Distinct [Total Discount Amount] from #temptot1 t1 
--where t1.[Smanid] = t2.[Smanid] )
--From #temptot1 t2 group by t2.[Smanid]

-------------------------------------------------------------
select 
"Smanid" = [Smanid],
"SalesMan Name" = [SalesMan Name],
"Cash Collected (%c)"=Sum(Isnull([Cash Collected],0)),  
"Extra Collection"=Sum(Isnull([Extra Collection],0)),  
"Write Off (%c)"= Sum(IsNull([Write Off],0)),
"Invoice Adjustments" = (Select Distinct [Invoice Adjustments]  from #temptot1 t1 
where t1.[Smanid] = #temptot1.[Smanid] ),
"Total Discount Amount" = (Select Distinct [Total Discount Amount] from #temptot1 t1 
where t1.[Smanid] = #temptot1.[Smanid] ),
--sum([Total Discount Amount]),  
"Collection Discount" = Sum(IsNull([Collection Discount],0))   

--from #Temp1 Group By SManid,SManName , collid

from #temptot1
Group By [Smanid], [SalesMan Name]

Drop table #temptot1
Drop table #Temp1
