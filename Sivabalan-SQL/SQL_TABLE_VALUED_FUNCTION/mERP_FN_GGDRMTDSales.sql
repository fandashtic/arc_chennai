Create Function dbo.mERP_FN_GGDRMTDSales()
Returns
@FData Table (SalesManId Int,
	CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ProdDefnID Int,
	CategoryGroup nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	OutletStatus nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CurrentStatus nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
BEGIN
	Declare @GGDRmonth Nvarchar(10)
	Set @GGDRmonth=Substring(DateName(mm, Getdate()), 1, 3) + '-' + DateName(YYYY, Getdate())

	Declare @Data Table (SalesManId Int,
	CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ProdDefnID Int,
	CategoryGroup nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	OutletStatus nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CurrentStatus nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Target Decimal(18,6),
	Actual Decimal(18,6))

	Declare @TData Table (SalesManId Int,
	CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Cnt Int)

	Insert Into @FData
	Select Distinct DSID,CustomerID,ProdDefnID,
	(Case When (Select Top 1 Flag From Tbl_MERP_Configabstract Where ScreenCode ='OCGDS') = 0 Then CatGRP Else OCG End) CatGRP,Status,CurrentStatus from GGRRFinalData
	Where cast('01-' + [Month] as dateTime) = cast('01-'+ @GGDRmonth as DateTime)

	Insert into @Data
	Select Distinct DSID,CustomerID,ProdDefnID,
	(Case When (Select Top 1 Flag From Tbl_MERP_Configabstract Where ScreenCode ='OCGDS') = 0 Then CatGRP Else OCG End) CatGRP,Status,CurrentStatus,Target,Actual
	from GGRRFinalData
	Where cast('01-' + [Month] as dateTime) = cast('01-'+ @GGDRmonth as DateTime)
	--And Status = 'Red' And CurrentStatus = 'Neutral'
	And CustomerID In (
	Select Distinct CustomerID from GGRRFinalData
	Where cast('01-' + [Month] as dateTime) = cast('01-'+ @GGDRmonth as DateTime))
	--And Status = 'Red' And CurrentStatus = 'Neutral'
	--And Actual < Target)

	Declare @ProdDefnID as Int
	Declare @SalesManId as Int
	Declare @CustomerID as Nvarchar(255)
	Declare @CatGroup as Nvarchar(4000)
	Declare @NewCatGroup as Nvarchar(4000)

	Delete From @TData
	Insert into @TData(SalesmanID,CustomerID)
	select Distinct SalesmanID,CustomerID From @Data Group By SalesManId,CustomerID,CategoryGroup

	Update T Set T.Cnt = T1.Cnt From @TData T,
	(Select SalesmanID,CustomerID,Count(CategoryGroup) Cnt from @Data Group By SalesmanID,CustomerID) T1
	Where T.SalesmanID= T1.SalesmanID
	And T.CustomerID= T1.CustomerID

	Declare Cur Cursor for
	Select T.SalesManId,T.CustomerID,T.ProdDefnID From @Data T,@TData T1
	Where T.Target > T.Actual 
	And T.CustomerID = T1.CustomerID
	And T.SalesManId = T1.SalesManId
	And T1.Cnt > 1
	Open Cur
	Fetch from Cur into @SalesManId,@CustomerID,@ProdDefnID
	While @@fetch_status =0
		Begin	
			Set @NewCatGroup = ''
			Declare Cur_Join Cursor for
			Select Distinct CategoryGroup From @Data Where SalesManId = @SalesManId And CustomerID = @CustomerID Order By CategoryGroup Asc
			Open Cur_Join
			Fetch from Cur_Join into @CatGroup
			While @@fetch_status =0
				Begin			
					If Isnull(@NewCatGroup,'') <> ''
					Begin
						Set @NewCatGroup = @NewCatGroup + '|' + @CatGroup
					End
					Else
					Begin
						Set @NewCatGroup = @CatGroup
					End
					Fetch Next from Cur_Join into @CatGroup
				End
			Close Cur_Join
			Deallocate Cur_Join

			Update @FData Set CategoryGroup = @NewCatGroup Where SalesManId = @SalesManId And CustomerID = @CustomerID And ProdDefnID = @ProdDefnID

			Fetch Next from Cur into @SalesManId,@CustomerID,@ProdDefnID
		End
	Close Cur
	Deallocate Cur

Return
END
