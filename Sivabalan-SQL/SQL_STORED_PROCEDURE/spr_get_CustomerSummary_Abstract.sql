
CREATE Procedure spr_get_CustomerSummary_Abstract
(
	@Customer nvarchar(2550),
	@Merchandise nvarchar(2550),
	@FromDate DateTime,
	@ToDate DateTime
)
AS      
BEGIN
	DECLARE @Delimeter as Char(1), @Query as nVarchar(4000)
	DECLARE @CustID as NVarchar(15)
	DECLARE @Sal Decimal(18,6)
	
	SET @Delimeter=Char(15)

	Create table #tmpCustomer(Customer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tempCusSummary(CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, Customer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Total Qty] Decimal(18, 6), [Total Sale Value] Decimal(18, 6))
	Create table #tmpMerchandise(Merchandise nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpMerchandise1(Merchandise nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Set @Query = N'Alter Table #tempCusSummary Add '

	If @Customer=N'%'
		Insert into #tmpCustomer select Company_Name from Customer
	Else
		Insert into #tmpCustomer select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)

	If @Merchandise = N'%' or @Merchandise = N''
		Insert into #tmpMerchandise select Merchandise from Merchandise Order By Merchandise
	Else
		Insert into #tmpMerchandise select * from dbo.sp_SplitIn2Rows(@Merchandise,@Delimeter)

	If @Merchandise = N'%' or @Merchandise = N''
		Insert InTo #tmpMerchandise1
		Select Merchandise.Merchandise,Isnull(CustMerchandise.CustomerID,'') From Merchandise
		Left Outer Join CustMerchandise On Merchandise.MerchandiseID = CustMerchandise.MerchandiseID
		Union
		Select '', Customer.CustomerID From customer
		Where CustomerID not in (Select customerID from CustMerchandise)
	Else
		Insert into #tmpMerchandise1
		Select Merchandise.Merchandise,Isnull(CustMerchandise.CustomerID,'') From Merchandise,CustMerchandise
		Where Merchandise.MerchandiseID = CustMerchandise.MerchandiseID
		and Merchandise.merchandise in (select * from dbo.sp_SplitIn2Rows(@Merchandise, @Delimeter))

	Declare CurResult Cursor For
	Select Merchandise From #tmpMerchandise
	Open CurResult
	Fetch From CurResult Into @Merchandise
	While @@Fetch_Status = 0
	Begin
		Set @Query = @Query + N'[' + @Merchandise + N'] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, '
		Fetch From CurResult Into @Merchandise
	End
	Close CurResult
	Deallocate CurResult

	Set @query = substring(@query,1,len(@query)-1)

	--Set @Query = @Query + N'[Total Qty] Decimal(18, 6), [Total Sale Value] Decimal(18, 6)'
	Exec sp_executesql @Query
	Set @Query = N'Insert into #tempCusSummary(CustomerID, Customer, [Total Qty])
	Select Cus.CustomerID,Cus.Company_Name,
	Sum( case IA.InvoiceType
	when 4 then -Invd.Quantity  
	when 5 then -Invd.Quantity
	when 6 then -Invd.Quantity  
	else Invd.Quantity end)
	From
	Customer Cus, InvoiceAbstract IA, InvoiceDetail Invd
	Where
	(IA.Status & 192) = 0 And
	IA.InvoiceDate between ''' + Cast(@FromDate as nVarchar) + ''' and ''' + Cast(@ToDate as nVarchar) + ''' And 
	Cus.Company_Name IN (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer) And
	IA.CustomerID In (Select CustomerID From #tmpMerchandise1) And
	IA.CustomerID = Cus.CustomerID And
	IA.InvoiceId = Invd.InvoiceId
	Group by Cus.CustomerID, Cus.Company_Name'
	Exec sp_executesql @Query

	Declare InvVal Cursor For Select Distinct CustomerID From #tempCusSummary
	Open InvVal
	Fetch from InvVal into @CustID 
	While @@fetch_status=0
	BEGIN
		Select @Sal = Sum(case IA.InvoiceType
		When 4 then -IA.NetValue
		When 5 then -IA.NetValue  
		When 6 then -IA.NetValue   
		Else IA.NetValue End) From InvoiceAbstract ia Where IA.CustomerID=@CustID
		AND IA.InvoiceDate Between @FromDate And @ToDate
		And (IA.Status & 192) = 0

		Set @Query = 'Update #tempCusSummary Set [Total Sale Value] = ' + Cast(@Sal as nVarchar) + ' Where CustomerID = ''' + @CustID + ''''
		Exec sp_executesql @Query
		Fetch next from InvVal into @CustID
	END
	Close InvVal
	Deallocate InvVal

	Declare CurResult Cursor For
	Select Merchandise From #tmpMerchandise
	Open CurResult
	Fetch From CurResult Into @Merchandise
 	While @@Fetch_Status = 0
	Begin
		Set @Query = N'Update #tempCusSummary Set [' + @Merchandise + '] = ''No'''
		Exec sp_executesql @Query
		Set @Query = N'Update rs Set rs.[' + @Merchandise + '] = ''Yes'' From #tempCusSummary rs, Merchandise m, CustMerchandise cm 
		Where rs.CustomerID = cm.CustomerID And m.Merchandise = ''' + @Merchandise + ''' And m.MerchandiseID = cm.MerchandiseID'
		Exec sp_executesql @Query
		Fetch Next From CurResult Into @Merchandise
	End
	Close CurResult
	Deallocate CurResult

	Select * from #tempCusSummary

	Drop Table #tempCusSummary
	Drop Table #tmpCustomer
	Drop Table #tmpMerchandise
	Drop Table #tmpMerchandise1
END
