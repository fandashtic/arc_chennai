Create Procedure Sp_GGDRDataPost(@GGDRFromDate nvarchar(8),@GGDRToDate nvarchar(8),@FromDate DateTime,@ToDate DateTime,@OutletID nvarchar(15))
As
Begin
	Set DateFormat DMY
	
	CREATE TABLE #tmp(
		[Month] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Date] [datetime] NULL,
		[RetailerCode] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DSID] [int] NULL,
		[DSTypeID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CategoryGroup] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SystemSKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SalesVolume] [decimal](18, 6) NULL,
		[SalesValue] [decimal](18, 6) NULL)

	Declare @Date as DateTime

	Declare @count as int
	Declare @n as int
	Set @count = DateDiff(D,@Fromdate,@Todate)
	Set @n = 0
	while @n <= @count
		Begin
			Set @Date = DateAdd(D,@n,@Fromdate)
			Set @Date = Convert(Nvarchar(10),@Date,103)
			Truncate Table #tmp
			Insert Into #tmp
			Select 
			cast((Left((datename(m,IA.Invoicedate)),3))as Nvarchar) + '-' + cast(Year(IA.Invoicedate) as Nvarchar),
			Convert(Nvarchar(10),IA.Invoicedate,103),
			IA.CustomerID,
			IA.SalesmanID,
			IA.DSTypeID,
			(Case 
			When (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS') = 0 Then
			(Select Distinct GR.Categorygroup from items I ,tblCGDivMapping GR,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 
				where IC4.categoryid = i.categoryid 
				And IC4.ParentId = IC3.categoryid 
				And IC3.ParentId = IC2.categoryid 
				And IC2.Category_Name = GR.Division 
				And I.Product_code = ID.Product_Code)
			Else 
				(select Distinct GroupName from OCGItemMaster Where SystemSKU = ID.Product_Code) 
			End) Categorygroup,
			ID.Product_Code,
			(Case When Isnull(InvoiceType,0) = 4 Then (-1 * ID.Quantity) Else ID.Quantity End) Quantity,
			(Case When Isnull(InvoiceType,0) = 4 Then (-1 * ID.Amount) Else ID.Amount End) Amount
			from InvoiceAbstract IA, InvoiceDetail ID 
			Where IA.customerID = @OutletID 
			And	Convert(Nvarchar(10),IA.Invoicedate,103) = @Date
			And Isnull(InvoiceType,0) in (1,3,4)
			And Isnull(Status,0) & 128 = 0
			And IA.Invoiceid = ID.Invoiceid

			--Delete From GGDRData Where Date >= @Date

			Insert Into GGDRData
			select T.Date,T.RetailerCode,T.DSID,DS.DSTypeValue,T.CategoryGroup ,T.SystemSKU,Sum(T.SalesVolume),Sum(T.SalesValue) 
			From #tmp T,DSType_Master DS Where T.DSTypeID = DS.DSTypeID
			Group By T.Month,T.Date,T.RetailerCode,T.DSID,DS.DSTypeValue,T.CategoryGroup ,T.SystemSKU
			
		Set @n = @n +1
	End

	/* Update the trace table finally*/
	update GGDRTrace set ProcessedDate = @Date where 
	FromDate=@GGDRFromDate and ToDate=@GGDRToDate and OutletID=@OutletID

	Drop table #tmp
End
