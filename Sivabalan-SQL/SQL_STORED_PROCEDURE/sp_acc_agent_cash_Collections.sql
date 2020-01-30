CREATE PROCEDURE [dbo].[sp_acc_agent_cash_Collections](@SManName nVarChar(30),@FROMDATE DateTime,@TODATE DateTime)
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
		Coltype Integer
	)

if(@SManName=N'%')
	Begin
		Insert Into #Temp1
		Select Collections.DocumentID,Collectiondetail.DocumentID,Collections.SalesManID,"Salesman Name"=IsNull(Salesman.SalesMan_Name,dbo.lookupdictionaryitem('Others',Default)), 
		"Cash Collected" = Case Collectiondetail.Documenttype 
		When 4 then Sum(Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)
		When 5 then Sum(Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)
		When 6 then Sum(Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)
		Else 0-Sum(Collectiondetail.AdjustedAmount + Collectiondetail.Extracollection) End,
		"Extra Collection"=Case Collectiondetail.Documenttype 
		When 4 then Sum(CollectionDetail.ExtraCollection)
		When 5 then Sum(CollectionDetail.ExtraCollection)
		When 6 then Sum(CollectionDetail.ExtraCollection)
		Else 0-Sum(Collectiondetail.Extracollection) End,
		"Write Off Amount"=Sum(Isnull(Adjustment,0)),
		"Coltype"=Collectiondetail.DocumentType
		From	Collections 
		Left Join Salesman on Collections.SalesManID = Salesman.SalesManID
		Join Collectiondetail on Collectiondetail.CollectionID=Collections.DocumentID
--		, Salesman,Collectiondetail
		Where	
--		Collections.SalesManID *= Salesman.SalesManID And 
		Collections.DocumentDate Between @FROMDATE And @TODATE 
		And PaymentMode = 0 
		And (IsNull(Collections.Status,0) & 192) = 0 And
		(IsNull(Collections.Status,0) & 64) = 0 And
		Collections.CustomerID is Not Null
--		And Collectiondetail.CollectionID=Collections.DocumentID
		Group By Collections.DocumentID,Collectiondetail.DocumentID,Collections.SalesManID, Salesman.SalesMan_Name,Collections.Value,Collections.Balance,Collectiondetail.DocumentType
	
		Insert Into #Temp1
		Select DocumentID,0,Collections.SalesManID,IsNull(Salesman.SalesMan_Name,dbo.lookupdictionaryitem('Others',Default)),
		Sum(Isnull(Value,0)),0,0,0
		from Collections
		Left Join SalesMan on Collections.SalesManID = Salesman.SalesManID
		Inner Join VoucherPrefix on VoucherPrefix.TranID = N'Collections'
		Where	
		--	Collections.SalesManID *= Salesman.SalesManID And 
		Collections.DocumentDate Between @FROMDATE And @TODATE And PaymentMode = 0 And 
		Collections.CustomerID is Not Null And
		(IsNull(Status, 0) & 192) = 0 And 
		(IsNull(Status, 0) & 64) = 0 And
		--VoucherPrefix.TranID = N'Collections'
		 DocumentID Not in (Select Collid from #Temp1)
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
		"Write Off Amount"=Sum(Isnull(Adjustment,0)),
		"Coltype"=Collectiondetail.DocumentType
		From	Collections, Salesman,Collectiondetail
		Where	Collections.SalesManID = Salesman.SalesManID And 
		Salesman.SalesMan_Name=@SManName And
		Collections.DocumentDate Between @FROMDATE And @TODATE 
		And PaymentMode = 0 
		And (IsNull(Collections.Status,0) & 64) = 0 And
		(IsNull(Collections.Status,0) & 192) = 0 And
		Collections.CustomerID is Not Null
		And Collectiondetail.CollectionID=Collections.DocumentID
		Group By Collections.DocumentID,Collectiondetail.DocumentID,Collections.SalesManID, Salesman.SalesMan_Name,Collections.Value,Collections.balance,Collectiondetail.DocumentType
	
		Insert Into #Temp1
		Select DocumentID,0,Collections.SalesManID,IsNull(Salesman.SalesMan_Name, dbo.lookupdictionaryitem('Others',Default)),
		Sum(Isnull(Value,0)),0,0,0
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

Select  SManid,"SalesMan Name"=SManName,
"Cash Collected (%c)"=Sum(Isnull(CashColl,0)),
"Extra Collection"=Sum(Isnull(XtraCol,0)),
"Write Off (%c)"=Sum(ISnull(WriteOffCol,0)),
"Invoice Adjustments"=(Select  Sum(Isnull(Invoiceabstract.AdjustedAmount,0)) From Invoiceabstract
where Invoiceabstract.Invoiceid in (Select Distinct(t2.collectionid) From #Temp1 t2 
Where t2.Coltype In (4, 6) And t2.SManid=#Temp1.SManid)),
"Total Discount Amount"=(Select  Sum(Isnull(AddlDiscountValue,0) + ISnull(DiscountValue,0)) From Invoiceabstract
where Invoiceabstract.Invoiceid in (Select Distinct(t2.collectionid) From #Temp1 t2 
Where t2.Coltype In (4, 6) And t2.SManid=#Temp1.SManid))
from #Temp1 Group By SManid,SManName

Drop table #Temp1
