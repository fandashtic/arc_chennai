Create Procedure mERP_spr_SKUWiseStock(
@FromDate Datetime,
@ShowItems nvarchar(100) ,
@StockVal nvarchar(100),
@UOM nVarchar(20),
@CatLevel nVarchar(255),
@CateName nVarchar(4000),
@ItemCode nvarchar(2550))
As
Begin
	/*	openingdetails.Free_opening_Quantity   -  This column value is Inclusive of Damage free and saleable free
		openingdetails.Free_Saleable_Quantity  - This column value is Saleable free alone
	*/
	
	Declare @SQL nVarchar(4000)
	Declare @OpeningDetails Int
	Declare @Delimeter as Char(1)  
	Set @Delimeter=Char(15)  

	Declare @CatName As nVarchar(255)
	Declare @CatID As Int	
	Declare @PTSTAX as nvarchar(25)
	Set @PTSTAX = 'PTS with Tax'
	
	If @CatLevel = '%'
		Select @CatLevel = HierarchyName From ItemHierarchy Where HierarchyID = 1
	If @UOM = '%' Or @UOM = ''
		Set @UOM = 'Base UOM'

	--This table is to display the categories in the Order
	Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)  
	Exec sp_CatLevelwise_ItemSorting 
	
	Create Table #tempCategoryList(CategoryId Int)
	Create table #tempCategory (CategoryID Int, Status Int)  
	Create Table #tmpCategories(CatLevel Int, CatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, LeafLevelCat Int)
	Create Table #tmpItems(Product_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpStockItems(ProdCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpAvailableStock([ItemCode] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
									[Item Code] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
									[Item Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 


	Set @SQL = 'Alter Table #tmpAvailableStock Add ['  +  @CatLevel  + '] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS '
	Exec sp_ExecuteSql @SQL
	Set @SQL = 'Alter Table #tmpAvailableStock Add 
									UOM nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
									[Saleable Stock(Qty)] Decimal(18,6),
									[Free Stock(Qty)] Decimal(18,6),
									[Damage Stock(Qty)] Decimal(18,6),
									[SIT Quantity]  Decimal(18,6),	
									[Stock in VAN]  Decimal(18,6),	
									[Stock in Dispatch]  Decimal(18,6),
									[Total Stock on Hand(Qty)] Decimal(18,6),
									[Saleable Stock Value without Tax] Decimal(18,6),
									[Damage Stock Value without Tax] Decimal(18,6),
									[SIT Value without Tax] Decimal(18,6),
									[VAN Stock Value without Tax] Decimal(18,6),
									[Stock in Dispatch Value with Out Tax] Decimal(18,6),
									[Total Stock on Hand Value without Tax] Decimal(18,6),
									[Saleable Stock Tax Value] Decimal(18,6),
									[Damage Stock Tax Value] Decimal(18,6),
									[SIT Stock Tax Value]  Decimal(18,6), 
									[VAN Stock Tax Value] Decimal(18,6), 
									[Stock in Dispatch Tax Value]  Decimal(18,6),
									[Total Tax Value] Decimal(18,6),
									[Saleable Stock Value With Tax] Decimal(18,6),
									[Damage Stock Value With tax] Decimal(18,6),
									[SIT Value With Tax] Decimal(18,6), 
									[VAN Stock Value With Tax] Decimal(18,6), 
									[Stock in Dispatch Value With Tax] Decimal(18,6),
									[Total Stock on Hand Value With Tax] Decimal(18,6) '
	Exec sp_ExecuteSql @SQL


IF @StockVal = @PTSTAX
Begin
	IF (DATEPART(dy, @FromDate) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FromDate) = DATEPART(yyyy, GETDATE())) OR DATEPART(yyyy, @FromDate) < DATEPART(yyyy, GETDATE())    
	Begin
		Set @OpeningDetails = 1
		IF @ShowItems = 'Items With Stock'
			Begin
				Insert Into #tmpStockItems
				Select Product_Code From OpeningDetails Where (isNull(Opening_Quantity,0) - isnull(Damage_Opening_Quantity,0)) > 0
				And Opening_Date = DATEADD(d, 1, @FromDate) 
			End
		Else IF @ShowItems = 'Items Without Stock'
			Begin
				Insert Into #tmpStockItems
				Select Product_Code From OpeningDetails Where (isNull(Opening_Quantity,0) - isnull(Damage_Opening_Quantity,0)) = 0
				And Opening_Date = DATEADD(d, 1, @FromDate) 
			End
		Else
			Begin		
				Insert Into #tmpStockItems
				Select Product_Code From Items 
			End
	End 
	Else				
	Begin
		IF @ShowItems = 'Items With Stock'
			Begin
				Insert Into #tmpStockItems
				Select Product_Code From Batch_Products Where isnull(Damage, 0) = 0 Group By Product_Code having Sum(Quantity) > 0
	--			union
	--			select distinct vd.Product_Code as Product_Code from vanstatementabstract vsa, vanstatementdetail vd 
	--				where vsa.docserial = vd.docserial and vsa.Status & 128 = 0 
	--				Group By Product_Code having Sum(pending) > 0
			End
		Else IF @ShowItems = 'Items Without Stock'
			Begin
				Insert Into #tmpStockItems Select Product_Code From Items
				Delete From #tmpStockItems Where ProdCode in 
				(	Select Product_Code From Batch_Products Where isnull(Damage, 0) = 0 Group By Product_Code having Sum(Quantity) > 0
	--				union
	--				select distinct vd.Product_Code as Product_Code from vanstatementabstract vsa, vanstatementdetail vd 
	--					where vsa.docserial = vd.docserial and vsa.Status & 128 = 0 
	--					Group By Product_Code having Sum(pending) > 0
				)
			End
		Else
			Begin
				Insert Into #tmpStockItems
				Select Product_Code From Items
			End
	End		
End
Else
Begin
	IF (DATEPART(dy, @FromDate) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FromDate) = DATEPART(yyyy, GETDATE())) OR DATEPART(yyyy, @FromDate) < DATEPART(yyyy, GETDATE())    
	Begin
		Set @OpeningDetails = 1
		IF @ShowItems = 'Items With Stock'
			Begin
				Insert Into #tmpStockItems
				Select Product_Code From OpeningDetails Where isNull(Opening_Quantity,0) > 0
				And Opening_Date = DATEADD(d, 1, @FromDate) 
			End
		Else IF @ShowItems = 'Items Without Stock'
			Begin
				Insert Into #tmpStockItems
				Select Product_Code From OpeningDetails Where isNull(Opening_Quantity,0) = 0
				And Opening_Date = DATEADD(d, 1, @FromDate) 
			
			End
		Else
			Begin		
				Insert Into #tmpStockItems
				Select Product_Code From Items 
			End
	End 
	Else				
	Begin
		IF @ShowItems = 'Items With Stock'
			Begin
				Insert Into #tmpStockItems
				Select Product_Code From Batch_Products Group By Product_Code having Sum(Quantity) > 0
				Union
				Select Distinct vd.Product_Code as Product_Code from vanstatementabstract vsa, vanstatementdetail vd 
					Where vsa.docserial = vd.docserial and vsa.Status & 128 = 0 
					Group By Product_Code having Sum(pending) > 0
			End
		Else IF @ShowItems = 'Items Without Stock'
			Begin
				Insert Into #tmpStockItems Select Product_Code From Items
				Delete From #tmpStockItems where ProdCode in 
				(	Select Product_Code From Batch_Products Group By Product_Code having Sum(Quantity) > 0
					Union
					Select Distinct vd.Product_Code as Product_Code from vanstatementabstract vsa, vanstatementdetail vd 
						Where vsa.docserial = vd.docserial and vsa.Status & 128 = 0 
						Group By Product_Code having Sum(pending) > 0
				)
			End
		Else
			Begin
				Insert Into #tmpStockItems
				Select Product_Code From Items
			End
	End		
End

	If @CateName = '%'
		Insert Into #tempCategoryList 
		Select CategoryID From ItemCategories
		Where [Level] In (Select HierarchyID From ItemHierarchy
		Where HierarchyName = @CatLevel )
	Else 
		Insert Into #tempCategoryList Select CategoryID From ItemCategories Where Category_Name In( 
		Select * From dbo.sp_SplitIn2Rows(@CateName, @Delimeter))

	
	--Get leaflevel categories of given hierarchy level
	Declare Category Cursor  For  
	Select ItemCategories.Category_Name, ItemCategories.CategoryID
	From ItemCategories Where ItemCategories.CategoryID In (select CategoryID from #tempCategoryList)
	Open Category  
	Fetch From Category Into @CatName, @CatID  
	While @@Fetch_Status = 0  
	Begin  
		Exec GetLeafCategories @CatLevel , @CatName
		Insert Into #tmpCategories Select @CatID, @CatName, CategoryID From #tempCategory
		Delete From #tempCategory
	Fetch From Category Into @CatName, @CatID  
	End	
	Close Category
	Deallocate Category

	if @ItemCode = '%'
		Insert InTo #tmpItems Select Product_code From Items Where CategoryID In
		(Select LeafLevelCat From #tmpCategories)
	Else
		Insert into #tmpItems select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)

	create table #tmpSalable_van_qty(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
	,van_qty decimal(18, 6)	)

	Insert Into #tmpSalable_van_qty
	select tmp.product_code, isnull(sum(van.pending), 0)
	from #tmpItems tmp left outer join
	( select vd.product_code as product_code, ISNULL(sum(pending), 0) as pending  
		from vanstatementabstract vsa join vanstatementdetail vd on vsa.docserial = vd.docserial 
		join batch_products bp on vd.batch_code = bp.batch_code
		where vsa.status & 128 = 0 --and vsa.documentdate < dateadd(d, 1, @FROMDATE)
		and ISNULL(bp.Damage, 0) = 0 and ISNULL(bp.Free, 0) = 0
		group by vd.product_code
	) van on van.product_code = tmp.product_code
	group by tmp.product_code

	create table #tmpFree_van_qty(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
	,van_qty decimal(18, 6))

	Insert Into #tmpFree_van_qty
	select tmp.product_code, isnull(sum(van.pending), 0)
	from #tmpItems tmp left outer join
	( select vd.product_code as product_code, ISNULL(sum(pending), 0) as pending  
		from vanstatementabstract vsa join vanstatementdetail vd on vsa.docserial = vd.docserial 
		join batch_products bp on vd.batch_code = bp.batch_code
		where vsa.status & 128 = 0 --and vsa.documentdate < dateadd(d, 1, @FROMDATE)
		and ISNULL(bp.Damage, 0) = 0 and ISNULL(bp.Free, 0) = 1
		group by vd.product_code
	) van on van.product_code = tmp.product_code
	group by tmp.product_code
	--total_van_qty

	--total_dispatch_qty
	create table #tmpSaleable_dispatch_qty(	product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
	, dispatch_qty decimal(18, 6))

	Insert Into #tmpSaleable_dispatch_qty
	select tmp.product_code, isnull(sum(d.quantity), 0)
	from #tmpItems tmp left outer join
	( select product_code, sum(quantity) as quantity from dispatchdetail 
		where dispatchid in 
		(	
			select distinct dispatchid from dispatchabstract da 
			left outer join invoiceabstract invabs on da.invoiceid = invabs.invoiceid and da.status & 192 = 0   and invabs.status & 192 = 0 
			where da.status & 3 <> 0 and dispatchdate < dateadd(d, 1, @FROMDATE) and 
			( (isnull(da.invoiceid, 0)=0 and da.status & 448=0 ) or 
			( isnull(da.invoiceid, 0)<>0 and da.status & 320=0 and 
			dbo.StripDateFromTime(dispatchdate) < dbo.StripDateFromTime(invoicedate)) )
		) and isnull(saleprice, 0) > 0 
--		(	select distinct dispatchid from dispatchabstract da, invoiceabstract invabs 
--			where da.invoiceid *= invabs.invoiceid and da.status & 3 <> 0 and da.status & 64 = 0 
--			and dispatchdate < dateadd(d, 1, @FROMDATE) and 
--			convert(datetime, dbo.StripDateFromTime(dispatchdate), 103) 
--			< convert(datetime, dbo.StripDateFromTime(isnull(invoicedate, getdate() + 1000 )), 103) 
--		) and isnull(saleprice, 0) > 0 
		group by product_code
	) d on d.product_code = tmp.product_code
	group by tmp.product_code

	create table #tmpFree_dispatch_qty(	product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
	, dispatch_qty decimal(18, 6))

	Insert Into #tmpFree_dispatch_qty
	select tmp.product_code, isnull(sum(d.quantity), 0)
	from #tmpItems tmp left outer join
	( select product_code, sum(quantity) as quantity from dispatchdetail 
		where dispatchid in 
		(	
			select distinct dispatchid from dispatchabstract da 
			left outer join invoiceabstract invabs on da.invoiceid = invabs.invoiceid and da.status & 192 = 0   and invabs.status & 192 = 0 
			where da.status & 3 <> 0 and dispatchdate < dateadd(d, 1, @FROMDATE) and 
			( (isnull(da.invoiceid, 0)=0 and da.status & 448=0 ) or 
			( isnull(da.invoiceid, 0)<>0 and da.status & 320=0 and 
			dbo.StripDateFromTime(dispatchdate) < dbo.StripDateFromTime(invoicedate)) )
--			select distinct dispatchid from dispatchabstract da 
--			left outer join invoiceabstract invabs on da.invoiceid = invabs.invoiceid and da.status & 192 = 0  
--			where da.status & 3 <> 0 and dispatchdate < dateadd(d, 1, @FROMDATE) and 
--			( (isnull(da.invoiceid, 0)=0 and da.status & 192=0 and da.status & 384=0 ) or 
--				( isnull(da.invoiceid, 0)<>0 and dbo.StripDateFromTime(dispatchdate) < 
--								dbo.StripDateFromTime(isnull(invoicedate, dateadd(d, 1, dispatchdate)))))
		) and isnull(saleprice, 0) = 0 
		group by product_code
	) d on d.product_code = tmp.product_code
	group by tmp.product_code
	--total_dispatch_qty

	create table #tmptotal_Invd_qty(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
	, Invoiced_qty decimal(18, 6))

	create table #tmptotal_rcvd_qty(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
	, rcvdqty decimal(18, 6), freeqty decimal(18, 6))

IF @StockVal = @PTSTAX
/* PTS and Tax Start */
Begin
	IF @OpeningDetails = 1   
	Begin
		print ('previous date')
--		----

		--total_Invoiced_qty(Saleable+Free)
		Insert Into #tmptotal_Invd_qty
		select tmp.product_code, isnull(sum(IDR.quantity), 0)
		from #tmpItems tmp left outer join
		( select IDR.product_code as product_code, idr.quantity as quantity
		from InvoiceDetailReceived IDR join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
		where IAR.Status & 64 = 0 and IAR.Status & 1 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FROMDATE)
		and IAR.Invoicetype = 0
		) idr on IDR.product_code = tmp.product_code
		group by tmp.product_code

		--total_received_qty(Saleable), total_received_qty(Free)
		Insert Into #tmptotal_rcvd_qty
		select tmp.product_code, isnull(sum(gdt.quantityreceived),0), isnull(sum(gdt.Freeqty),0)
		from #tmpItems tmp left outer join
		( select IsNull(gdt.quantityreceived, 0) as quantityreceived,
		IsNull(gdt.freeqty, 0) as freeqty, gdt.product_code as product_code
		from grndetail gdt
		join grnabstract gab on gab.grnId = gdt.grnId 
			and gab.grnstatus & 64 = 0 and gab.grnstatus & 32 = 0 and gab.RecdInvoiceId in
		( select InvoiceId from Invoiceabstractreceived IAR
		where IAR.Status & 64 = 0 and IAR.Status & 1 = 0 And IAR.InvoiceDate < dateadd(d, 1, @FROMDATE)
		and IAR.Invoicetype = 0
		)
		where gab.GrnDate < dateadd(d, 1, @FROMDATE)
		) gdt on gdt.product_code = tmp.product_code
		group by tmp.product_code
--

		Insert Into #tmpAvailableStock
		Select Items.Product_Code,Items.Product_Code,Items.ProductName,T.CatName,
		(Case @UOM When 'Base Uom' Then (Select Description From Uom Where UOM = Items.uom )
				   When 'UOM 1' Then (Select Description From Uom Where UOM = Items.uom1)
				   When 'UOM 2' Then (Select Description From Uom Where UOM = Items.uom2)
		End),
		
		--[Saleable Stock(Qty)]
		(Case @UOM When 'Base UOM' Then 
						IsNull(openingdetails.Opening_Quantity,0) - IsNull(openingdetails.Free_Saleable_Quantity,0) - 
						IsNull(openingdetails.Damage_Opening_Quantity,0) --- 
--						IsNull(tmpSalevanqty.van_qty, 0) - IsNull(tmpFreevanqty.van_qty, 0) - 
--						IsNull(tmpSaleDispatchqty.dispatch_qty, 0) - ISNULL(tmpFreedispatchqty.dispatch_qty, 0)						
					When 'UOM 1' Then 
						(IsNull(openingdetails.Opening_Quantity, 0)-IsNull(openingdetails.Free_Saleable_Quantity,0) - 
						IsNull(openingdetails.Damage_Opening_Quantity, 0))/ --- 
--						IsNull(tmpSalevanqty.van_qty, 0) - IsNull(tmpFreevanqty.van_qty, 0) - 
--						IsNull(tmpSaleDispatchqty.dispatch_qty, 0) - ISNULL(tmpFreedispatchqty.dispatch_qty, 0) )/
						(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)        
					When 'UOM 2' Then 
						(IsNull(openingdetails.Opening_Quantity, 0)-IsNull(openingdetails.Free_Saleable_Quantity,0) - 
						IsNull(openingdetails.Damage_Opening_Quantity,0))/ --- 
--						IsNull(tmpSalevanqty.van_qty, 0) - IsNull(tmpFreevanqty.van_qty, 0) - 
--						IsNull(tmpSaleDispatchqty.dispatch_qty, 0) - ISNULL(tmpFreedispatchqty.dispatch_qty, 0) )/
						(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End) 
		End),						 

		--[Free Stock(Qty)]
		(Case @UOM When 'Base UOM' Then 
						 isnull(openingdetails.Free_Saleable_Quantity, 0)
				   When 'UOM 1' Then
						 isnull(openingdetails.Free_Saleable_Quantity, 0)/
						 (Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
	
				   When 'UOM 2' Then
						 isnull(openingdetails.Free_Saleable_Quantity, 0)/
						 (Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
		End),
		
		--[Damage Stock(Qty)]
		(Case @UOM When 'Base UOM' Then 
						 isnull(openingdetails.Damage_Opening_Quantity,0)
				   When 'UOM 1' Then
						 isnull(openingdetails.Damage_Opening_Quantity,0)/
						 (Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
	
				   When 'UOM 2' Then
						 isnull(openingdetails.Damage_Opening_Quantity,0)/
						 (Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
		End),

		----SIT Qty
		"SIT Qty" = --CAST( tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty AS nvarchar)
			--+ ' ' +  CAST(UOM.Description AS nvarchar) ,
			(Case @UOM When 'Base UOM' Then 
							 CAST(ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0) AS nvarchar)
					   When 'UOM 1' Then
							 CAST(ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0) AS nvarchar)/
							 (Case isNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else Items.UOM1_Conversion End)
					   When 'UOM 2' Then
							 CAST(ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0) AS nvarchar)/
							 (Case isNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else Items.UOM2_Conversion End)
			End) , 
		----SIT Qty

		----Stock In VAN
		"Stock In VAN" = 0,
		----Stock In VAN

		----Stock In Dispatch
		"Stock In Dispatch" = --CAST( tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty AS nvarchar)
			--+ ' ' +  CAST(UOM.Description AS nvarchar) ,
			(Case @UOM When 'Base UOM' Then 
							 ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0)
					   When 'UOM 1' Then
							 (ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0))/
							 (Case isNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else Items.UOM1_Conversion End)
					   When 'UOM 2' Then
							 (ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0))/
							 (Case isNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else Items.UOM2_Conversion End)
			End) , 
		----Stock In Dispatch
		
		--[Total Stock on Hand(Qty)]
		isnull((Case @UOM When 'Base UOM' Then 
						 ISNULL(OpeningDetails.Opening_Quantity, 0) - IsNull(openingdetails.Damage_Opening_Quantity,0)
				   When 'UOM 1' Then
						 (ISNULL(OpeningDetails.Opening_Quantity, 0) - IsNull(openingdetails.Damage_Opening_Quantity,0)) /
						 (Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
	
				   When 'UOM 2' Then
						 (ISNULL(OpeningDetails.Opening_Quantity, 0) - IsNull(openingdetails.Damage_Opening_Quantity,0)) /
						 (Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
		End),0) , 

		--[Saleable Stock Value without Tax]
		((Case @StockVal When @PTSTAX Then (isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0)) 
			  Else 
				(Case @UOM When 'Base UOM' Then 
								ISNULL(openingdetails.Opening_Quantity, 0) 
							When 'UOM 1' Then 
								ISNULL(openingdetails.Opening_Quantity, 0)
							When 'UOM 2' Then 
								ISNULL(openingdetails.Opening_Quantity, 0)
				  End)* (Case @StockVal When @PTSTAX Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) End) -
				(Case @UOM When 'Base UOM' Then 
								  isnull(openingdetails.Damage_Opening_Quantity,0) 
							When 'UOM 1' Then 
								  isnull(openingdetails.Damage_Opening_Quantity,0)
							When 'UOM 2' Then 
								  isnull(openingdetails.Damage_Opening_Quantity,0)
				 End)* (Case @StockVal When @PTSTAX Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) End) - 
				(Case @UOM When 'Base UOM' Then 
								 IsNull(openingdetails.Free_Saleable_Quantity,0) 
							When 'UOM 1' Then 
								  IsNull(openingdetails.Free_Saleable_Quantity,0)
							When 'UOM 2' Then 
								  IsNull(openingdetails.Free_Saleable_Quantity,0)
				 End)* (Case @StockVal When @PTSTAX Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) End)
		  End)
		),
		
		--[Damage Stock Value without Tax]
		((Case @StockVal When '%' Then isnull((openingdetails.Damage_Opening_Value), 0) 
			  Else
				(Case @UOM When 'Base UOM' Then 
							isnull(openingdetails.Damage_Opening_Quantity, 0) 
						When 'UOM 1' Then 
							isnull(openingdetails.Damage_Opening_Quantity, 0)
						When 'UOM 2' Then 
							isnull(openingdetails.Damage_Opening_Quantity, 0)
			  End)* (Case @StockVal When @PTSTAX Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) End) 
		  End)
		),

		--[SIT Value without Tax]
		ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0)
		* (Case @StockVal When @PTSTAX Then Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) 
			Else Isnull(Items.Purchase_Price, 0) End) ,

		--[VAN Stock Value without Tax]
		0, 

		--[Stock in Dispatch Value with Out Tax]
		(ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0))
		* (Case @StockVal When @PTSTAX Then Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) 
			Else Isnull(Items.Purchase_Price, 0) End) ,
	  		
		--[Total Stock on Hand Value without Tax]
		((Case @StockVal When @PTSTAX Then (isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))
			   Else
				(Case @UOM When 'Base UOM' Then 
								ISNULL(openingdetails.Opening_Quantity, 0) 
							When 'UOM 1' Then 
								ISNULL(openingdetails.Opening_Quantity, 0)
							When 'UOM 2' Then 
								ISNULL(openingdetails.Opening_Quantity, 0)
				  End)* (Case @StockVal When @PTSTAX Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) End) -
				(Case @UOM When 'Base UOM' Then 
								  ISNULL(openingdetails.Free_opening_Quantity, 0) 
							When 'UOM 1' Then 
								  ISNULL(openingdetails.Free_opening_Quantity, 0)
							When 'UOM 2' Then 
								  ISNULL(openingdetails.Free_opening_Quantity, 0)
				 End)* (Case @StockVal When @PTSTAX Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) End)
		 End)
		),
		
		--[Saleable Stock Tax Value] - GST Changes
		Case When isnull(Tax.CS_TaxCode,0) > 0 Then
			isnull(dbo.Fn_Openingbal_TaxCompCalc(Items.Product_Code, Tax.Tax_Code, 1,
				(isnull(OpeningDetails.Opening_Value,0) - isnull(OpeningDetails.Damage_Opening_Value,0)),			
--				(Case @StockVal When @PTSTAX Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) 
--						Else Isnull(Items.Purchase_Price, 0) End) * (ISNULL(OpeningDetails.Opening_Quantity, 0) -  isnull(OpeningDetails.Damage_Opening_Quantity,0) - IsNull(OpeningDetails.Free_Saleable_Quantity,0)),
				(ISNULL(OpeningDetails.Opening_Quantity, 0) -  isnull(OpeningDetails.Damage_Opening_Quantity,0)
					- IsNull(OpeningDetails.Free_Saleable_Quantity,0))
			,1,0),0)	
		Else
			Case When IsNull(Items.TOQ_Purchase,0) = 1 Then
			(
				 (Case @UOM When 'Base UOM' Then 
								ISNULL(openingdetails.Opening_Quantity, 0) 
							When 'UOM 1' Then 
								ISNULL(openingdetails.Opening_Quantity, 0)
							When 'UOM 2' Then 
								ISNULL(openingdetails.Opening_Quantity, 0)
				  End) -
				(Case @UOM When 'Base UOM' Then 
								  isnull(openingdetails.Damage_Opening_Quantity,0) 
							When 'UOM 1' Then 
								  isnull(openingdetails.Damage_Opening_Quantity,0)
							When 'UOM 2' Then 
								  isnull(openingdetails.Damage_Opening_Quantity,0)
				 End) -
				(Case @UOM When 'Base UOM' Then 
								  IsNull(openingdetails.Free_Saleable_Quantity,0) 
							When 'UOM 1' Then 
								  IsNull(openingdetails.Free_Saleable_Quantity,0)
							When 'UOM 2' Then 
								  IsNull(openingdetails.Free_Saleable_Quantity,0)
				 End)	
			
				) * (Select isnull(Percentage,0) From Tax Where Tax_code = Items.Taxsuffered)

			Else 
			(
				isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0)
			) * (Select isnull(Percentage,0) From Tax Where Tax_code = Items.Taxsuffered)/100 End
		End,

		--[Damage Stock Tax Value] - GST Changes
		Case When isnull(Tax.CS_TaxCode,0) > 0 Then
			isnull(dbo.Fn_Openingbal_TaxCompCalc(Items.Product_Code, Tax.Tax_Code, 1,
				(Case @StockVal When @PTSTAX Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) 
						Else Isnull(Items.Purchase_Price, 0) End) * isnull(openingdetails.Damage_Opening_Quantity, 0),
				isnull(openingdetails.Damage_Opening_Quantity, 0),1,0),0)	
		Else
			Case When IsNull(Items.TOQ_Purchase,0) = 1 Then
				(Case @UOM When 'Base UOM' Then 
								isnull(openingdetails.Damage_Opening_Quantity, 0) 
							When 'UOM 1' Then 
								isnull(openingdetails.Damage_Opening_Quantity, 0)
							When 'UOM 2' Then 
								isnull(openingdetails.Damage_Opening_Quantity, 0)
				  End) * (Select isnull(Percentage,0) From Tax Where Tax_code = Items.Taxsuffered)

			Else
			(
				(Case @UOM When 'Base UOM' Then 
								isnull(openingdetails.Damage_Opening_Quantity, 0) 
							When 'UOM 1' Then 
								isnull(openingdetails.Damage_Opening_Quantity, 0)
							When 'UOM 2' Then 
								isnull(openingdetails.Damage_Opening_Quantity, 0)
				  End)* (Case @StockVal When @PTSTAX Then  Isnull(Items.PTS, 0) 
										When 'PTR' Then Isnull(Items.PTR, 0) 
										Else Isnull(Items.Purchase_Price, 0)
						End) 		
			--) * isNull(TaxSuffered_Value,0) /100 End,
			) * (Select isnull(Percentage,0) From Tax Where Tax_code = Items.Taxsuffered)/100 End
		End,

		--[SIT Stock Tax Value] - GST Changes
		Case When isnull(Tax.CS_TaxCode,0) > 0 Then
			isnull(dbo.Fn_Openingbal_TaxCompCalc(Items.Product_Code, Tax.Tax_Code, 1,
				(Case @StockVal When @PTSTAX Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) 
						Else Isnull(Items.Purchase_Price, 0) End) * ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0),
				ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0),1,0),0)	
		Else
			Case When IsNull(Items.TOQ_Purchase,0) = 1 Then
				ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0)
				* (Select isnull(Percentage,0) From Tax Where Tax_code = Items.Taxsuffered) 
			Else
				ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0)
				* (Case @StockVal When @PTSTAX Then Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) 
					Else Isnull(Items.Purchase_Price, 0) End)
				* (Select isnull(Percentage,0) From Tax Where Tax_code = Items.Taxsuffered) / 100 End
		End,

		--[VAN Stock Tax Value]
		0, 

		--[Stock in Dispatch Tax Value] - GST Changes
		Case When isnull(Tax.CS_TaxCode,0) > 0 Then
			isnull(dbo.Fn_Openingbal_TaxCompCalc(Items.Product_Code, Tax.Tax_Code, 1,
				(Case @StockVal When @PTSTAX Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) 
						Else Isnull(Items.Purchase_Price, 0) End) * (ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0)),
				(ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0)),1,0),0)	
		Else

			Case When IsNull(Items.TOQ_Purchase,0) = 1 Then
				(ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0))
				* (Select isnull(Percentage,0) From Tax Where Tax_code = Items.Taxsuffered) 
			Else
				(ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0))
				* (Case @StockVal When @PTSTAX Then Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) 
					Else Isnull(Items.Purchase_Price, 0) End)
				* (Select isnull(Percentage,0) From Tax Where Tax_code = Items.Taxsuffered)/ 100 End
		End,

		--[Total Tax Value] - GST Changes
		Case When isnull(Tax.CS_TaxCode,0) > 0 Then
			isnull(dbo.Fn_Openingbal_TaxCompCalc(Items.Product_Code, Tax.Tax_Code, 1,
				(isnull(OpeningDetails.Opening_Value,0) - isnull(OpeningDetails.Damage_Opening_Value,0)),			
				(ISNULL(OpeningDetails.Opening_Quantity, 0) -  isnull(OpeningDetails.Damage_Opening_Quantity,0)
					- IsNull(OpeningDetails.Free_Saleable_Quantity,0))
			,1,0),0)	
		Else
			Case When IsNull(Items.TOQ_Purchase,0) = 1 Then
			(
				(Case @UOM When 'Base UOM' Then 
								ISNULL(openingdetails.Opening_Quantity, 0) 
							When 'UOM 1' Then 
								ISNULL(openingdetails.Opening_Quantity, 0)
							When 'UOM 2' Then 
								ISNULL(openingdetails.Opening_Quantity, 0)
				  End) -
				(Case @UOM When 'Base UOM' Then 
								  isnull(openingdetails.Damage_Opening_Quantity,0) 
							When 'UOM 1' Then 
								  isnull(openingdetails.Damage_Opening_Quantity,0)
							When 'UOM 2' Then 
								  isnull(openingdetails.Damage_Opening_Quantity,0)
				 End) -
				(Case @UOM When 'Base UOM' Then 
								  ISNULL(openingdetails.Free_opening_Quantity, 0) 
							When 'UOM 1' Then 
								  ISNULL(openingdetails.Free_opening_Quantity, 0)
							When 'UOM 2' Then 
								  ISNULL(openingdetails.Free_opening_Quantity, 0)
				 End)

			) * (Select isnull(Percentage,0) From Tax Where Tax_code = Items.Taxsuffered)
			Else
			(
				isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0)
			) * (Select isnull(Percentage,0) From Tax Where Tax_code = Items.Taxsuffered)/100 End
		End,
		0,0,0,0,0,0	
		
		From  Items
		 Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code 
		 Inner Join ItemCategories On Items.categoryID = ItemCategories.CategoryID 
		 Inner Join  #tmpCategories T On Items.categoryID = T.LeafLevelCat
		 Inner Join #tempCategory1 T1 On Items.categoryID = T1.CategoryID 
		----link temp tables
		Left Outer Join #tmptotal_Invd_qty tmpInvqty On Items.Product_Code = tmpInvqty.Product_Code
		Left Outer Join  #tmptotal_rcvd_qty tmprcvdqty On Items.Product_Code = tmprcvdqty.Product_Code
--		--,#tmptotal_Invd_Saleonly_qty tmpInvdSaleqty
		Left Outer Join #tmpSalable_van_qty tmpSalevanqty On Items.Product_Code = tmpSalevanqty.Product_Code		
		Left Outer Join  #tmpFree_van_qty tmpFreevanqty On Items.Product_Code = tmpFreevanqty.Product_Code
		Left Outer Join #tmpSaleable_dispatch_qty tmpSaleDispatchqty On Items.Product_Code = tmpSaleDispatchqty.Product_Code
		Left Outer Join  #tmpFree_dispatch_qty tmpFreedispatchqty On Items.Product_Code = tmpFreedispatchqty.Product_Code
		Left Outer Join  Tax On Items.TaxSuffered = Tax.Tax_Code
		----link temp tables
		WHERE 
		OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate) And
		Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItems) And
		Items.Product_Code In (Select  ProdCode From #tmpStockItems)
		----join temp tables
        --AND Items.Product_Code *= tmpInvdSaleqty.Product_Code	
		----join temp tables
		Order By T1.IDS
	End
	Else
	Begin		
		Insert Into #tmpAvailableStock
		Select I.Product_Code,I.Product_Code,I.ProductName,T.CatName,
		(Case @UOM When 'Base Uom' Then (Select Description From Uom Where UOM = I.uom )
				   When 'UOM 1' Then (Select Description From Uom Where UOM = I.uom1)
				   When 'UOM 2' Then (Select Description From Uom Where UOM = I.uom2)
		End),
		
		--Saleable Qty
		(	select Sum(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
						   When 'UOM 1'  Then isnull(Quantity,0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						   When 'UOM 2'  Then isnull(Quantity,0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
				End)
			from Batch_Products	,Items where  
			Batch_Products.Product_Code = I.Product_Code  And isNull(Free,0)=0 and 
			Items.Product_Code = Batch_Products.Product_Code And
			isNull(Batch_Products.Damage,0) = 0 
		),  -- - 
--		(	select sum(Case @UOM When 'Base UOM' Then isnull(van_qty, 0) 
--					When 'UOM 1' Then isnull(van_qty,0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
--					When 'UOM 2' Then isnull(van_qty,0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
--					End)
--			from #tmpSalable_van_qty, Items where  
--			#tmpSalable_van_qty.Product_Code = Items.Product_Code 
--			and #tmpSalable_van_qty.Product_Code = I.Product_Code
-- 		)  - 
--		(	select sum(Case @UOM When 'Base UOM' Then isnull(van_qty, 0) 
--					When 'UOM 1' Then isnull(van_qty,0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
--					When 'UOM 2' Then isnull(van_qty,0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
--					End)
--			from #tmpFree_van_qty, Items where  
--			#tmpSalable_van_qty.Product_Code = Items.Product_Code 
--			and #tmpSalable_van_qty.Product_Code = I.Product_Code
-- 		)  - 
--		(	select isnull(sum(dispatch_qty), 0) from #tmpSaleable_dispatch_qty, Items where  
--			#tmpSaleable_dispatch_qty.Product_Code = Items.Product_Code 
--			and #tmpSaleable_dispatch_qty.Product_Code = I.Product_Code
--		)  - 
--		(	select isnull(sum(dispatch_qty), 0) from #tmpFree_dispatch_qty, Items where  
--			#tmpFree_dispatch_qty.Product_Code = Items.Product_Code 
--			and #tmpFree_dispatch_qty.Product_Code = I.Product_Code
--		),	
		
		--Free Qty
		(select Sum(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
						   When 'UOM 1'  Then isnull(Quantity,0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						   When 'UOM 2'  Then isnull(Quantity,0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
				End)
		from Batch_Products	,Items where 
		Batch_Products.Product_Code = I.Product_Code  And isNull(Free,0) <> 0 and 
		Items.Product_Code = Batch_Products.Product_Code And
		isNull(Damage,0) <> 1  
		),   

		--Damage Qty
		(select Sum(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
						   When 'UOM 1'  Then isnull(Quantity,0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						   When 'UOM 2'  Then isnull(Quantity,0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
				End)
		from Batch_Products	,Items where 
		Batch_Products.Product_Code = I.Product_Code  and 	
		Items.Product_Code = Batch_Products.Product_Code And
		isNull(Damage,0) <> 0  
		) ,
		--[SIT Quantity] 
		CAST(	( select 
					Sum(Case @UOM When 'Base UOM' Then isnull(IDR.pending, 0) 
						When 'UOM 1'  Then isnull(IDR.pending, 0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						When 'UOM 2'  Then isnull(IDR.pending, 0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
						End)
					from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR, Items 
					where IDR.Product_code = I.Product_code and IAR.Status & 64 = 0 
					and IAR.InvoiceId = IDR.InvoiceId and IDR.Product_code = Items.Product_code 
				) AS nvarchar ),
		--[Stock in VAN] 
		CAST(	( select 
					Sum(Case @UOM When 'Base UOM' Then isnull(sv.van_qty, 0) + isnull(sf.van_qty, 0) 
						When 'UOM 1' Then (isnull(sv.van_qty, 0) + isnull(sf.van_qty, 0))/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						When 'UOM 2' Then (isnull(sv.van_qty, 0) + isnull(sf.van_qty, 0))/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
						End)
					from #tmpSalable_van_qty sv, #tmpFree_van_qty sf, Items 
					where sv.Product_code = I.Product_code and 
					sv.Product_code = sf.Product_code and sv.Product_code = Items.Product_code 
				) AS nvarchar ),
		--[Stock in Dispatch] 
		CAST(	( select 
					Sum(Case @UOM When 'Base UOM' Then isnull(d.dispatch_qty, 0) + isnull(f.dispatch_qty, 0) 
						When 'UOM 1'  Then (isnull(d.dispatch_qty, 0) + isnull(f.dispatch_qty, 0))/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						When 'UOM 2'  Then (isnull(d.dispatch_qty, 0) + isnull(f.dispatch_qty, 0))/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
						End)
					from #tmpSaleable_dispatch_qty d, #tmpFree_dispatch_qty f, Items 
					where d.Product_code = I.Product_code and 
					d.Product_code = f.Product_code and d.Product_code = Items.Product_code 
				) AS nvarchar ),

		--Total Stock On Hand Qty
		isnull((select Sum(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
						   When 'UOM 1'  Then isnull(Quantity,0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						   When 'UOM 2'  Then isnull(Quantity,0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
				End)
		from Batch_Products	,Items where 
		Batch_Products.Product_Code = I.Product_Code And
		Items.Product_Code = Batch_Products.Product_Code and  isnull(Batch_Products.Damage, 0) = 0
		),0) 
--		isnull(( select 
--			Sum(Case @UOM When 'Base UOM' Then isnull(IDR.pending, 0) 
--				When 'UOM 1'  Then isnull(IDR.pending, 0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
--				When 'UOM 2'  Then isnull(IDR.pending, 0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
--				End)
--			from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR, Items 
--			where IDR.Product_code = I.Product_code and IAR.Status & 64 = 0 
--			and IAR.InvoiceId = IDR.InvoiceId and IDR.Product_code = Items.Product_code 
--		),0) +
--		isnull(( select 
--			Sum(Case @UOM When 'Base UOM' Then isnull(sv.van_qty, 0) + isnull(sf.van_qty, 0) 
--				When 'UOM 1' Then (isnull(sv.van_qty, 0) + isnull(sf.van_qty, 0))/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
--				When 'UOM 2' Then (isnull(sv.van_qty, 0) + isnull(sf.van_qty, 0))/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
--				End)
--			from #tmpSalable_van_qty sv, #tmpFree_van_qty sf, Items 
--			where sv.Product_code = I.Product_code and 
--			sv.Product_code = sf.Product_code and sv.Product_code = Items.Product_code 
--		),0) +
--		isnull(( select 
--			Sum(Case @UOM When 'Base UOM' Then isnull(d.dispatch_qty, 0) + isnull(f.dispatch_qty, 0) 
--				When 'UOM 1'  Then (isnull(d.dispatch_qty, 0) + isnull(f.dispatch_qty, 0))/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
--				When 'UOM 2'  Then (isnull(d.dispatch_qty, 0) + isnull(f.dispatch_qty, 0))/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
--				End)
--			from #tmpSaleable_dispatch_qty d, #tmpFree_dispatch_qty f, Items 
--			where d.Product_code = I.Product_code and 
--			d.Product_code = f.Product_code and d.Product_code = Items.Product_code 
--		),0) ,
,
		--Saleable Stock Value Without Tax
		(Select     
			Sum(case @StockVal   
				 When @PTSTAX Then isnull(Quantity,0) * 
								 (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)
				  When 'PTR' Then isnull(Quantity,0) * 
								  (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)
				  Else			  (Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0)
								  End) * (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)						
			End)    
		from Batch_Products	,Items,ItemCategories IC where 
		Items.Product_Code = I.Product_Code  And isNull(Free,0)=0 and 
		Items.Product_Code = Batch_Products.Product_Code And
		isNull(Damage,0) = 0 And
		Items.CategoryID = IC.CategoryID
		),

		--Damage Stock Value Without Tax
		(Select     
			Sum(case @StockVal   
				 When @PTSTAX Then  isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)
				  When 'PTR' Then isnull(Quantity,0) 
								* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)
				  Else  (Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0)
						 End) * (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)
			End )  
		from Batch_Products	,Items,ItemCategories IC where 
		Items.Product_Code = I.Product_Code  And
		Items.Product_Code = Batch_Products.Product_Code And
		Items.CategoryID = IC.CategoryID And
		isNull(Damage,0) <> 0 
		),

		--[SIT Value without Tax]
		(Select 
		case @StockVal      
		When @PTSTAX Then     
			Sum( Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0))
					Else (Isnull(IDR.pending, 0) * Isnull(Items.PTS, 0)) End )
		When 'PTR' Then      
			Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0)) 
					Else (Isnull(IDR.pending, 0) * Isnull(Items.PTR, 0)) End )
		When 'ECP' Then 
		 --purchase_at instead of ecp	   
			Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ))
					Else (Isnull(IDR.pending, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) End )
		When 'MRP' Then      
			isnull(Sum(isnull(IDR.pending, 0) * Isnull(Items.MRP, 0)),0)            
		When 'Special Price' Then    
			Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.Company_Price, 0)) 
					Else (Isnull(IDR.pending, 0) * Isnull(Items.Company_Price, 0)) End )
		Else    
		 --pts instead of PurchasePrice
			isnull(Sum(isnull(IDR.pending, 0) * isnull(IDR.PTS, 0)), 0)  
		End    
		from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items, ItemCategories IC  
		where IAR.InvoiceId = IDR.InvoiceId and IAR.Status & 64 = 0 
		and Items.Product_Code = IDR.Product_Code and Items.CategoryID = IC.CategoryID 
		and isnull(IDR.saleprice, 0) > 0 And items.product_code = I.Product_code),

		--[VAN Stock Value without Tax]
		(Select 
		case @StockVal      
		When @PTSTAX Then     
			Sum( Case IC.Price_Option When 1 Then (Isnull(vd.pending, 0) * Isnull(vd.PTS, 0))
					Else (Isnull(vd.pending, 0) * Isnull(Items.PTS, 0)) End )
		When 'PTR' Then      
			Sum(Case IC.Price_Option When 1 Then (Isnull(vd.pending, 0) * Isnull(vd.PTR, 0)) 
					Else (Isnull(vd.pending, 0) * Isnull(Items.PTR, 0)) End )
		When 'ECP' Then 
		 --purchase_at instead of ecp	   
			Sum(Case IC.Price_Option When 1 Then (Isnull(vd.pending, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ))
					Else (Isnull(vd.pending, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) End )
		When 'MRP' Then      
			isnull(Sum(isnull(vd.pending, 0) * Isnull(Items.MRP, 0)),0)            
		When 'Special Price' Then    
			Sum(Case IC.Price_Option When 1 Then (Isnull(vd.pending, 0) * Isnull(vd.SpecialPrice, 0)) 
					Else (Isnull(vd.pending, 0) * Isnull(Items.Company_Price, 0)) End )
		Else    
		 --pts instead of PurchasePrice
			isnull(Sum(isnull(vd.pending, 0) * isnull(vd.PTS, 0)), 0)  
		End    
		from vanstatementabstract vsa, vanstatementdetail vd, batch_products bp, Items, ItemCategories IC  
		where vsa.docserial = vd.docserial and vsa.Status & 128 = 0 and vd.batch_code = bp.batch_code		
		and Items.Product_Code = vd.Product_Code and Items.CategoryID = IC.CategoryID 
		and isnull(vd.saleprice, 0) > 0 And items.product_code = I.Product_code),

		--[Stock in Dispatch Value with Out Tax]
		(Select 
		case @StockVal 
		When @PTSTAX Then 
			Sum( Case IC.Price_Option When 1 Then (Isnull(d.quantity, 0) * Isnull(bp.PTS, 0))
					Else (Isnull(d.quantity, 0) * Isnull(bp.PTS, 0)) End )
		When 'PTR' Then 
			Sum(Case IC.Price_Option When 1 Then (Isnull(d.quantity, 0) * Isnull(bp.PTR, 0)) 
					Else (Isnull(d.quantity, 0) * Isnull(bp.PTR, 0)) End )
		When 'ECP' Then 
		 --purchase_at instead of ecp
			Sum(Case IC.Price_Option When 1 Then (Isnull(d.quantity, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ))
					Else (Isnull(d.quantity, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) End )
		When 'MRP' Then
			isnull(Sum(isnull(d.quantity, 0) * Isnull(Items.MRP, 0)),0)
		When 'Special Price' Then
			Sum(Case IC.Price_Option When 1 Then (Isnull(d.quantity, 0) * Isnull(bp.company_price, 0)) 
					Else (Isnull(d.quantity, 0) * Isnull(Items.Company_Price, 0)) End )
		Else
		 --pts instead of PurchasePrice
			isnull(Sum(isnull(d.quantity, 0) * isnull(bp.PTS, 0)), 0)  
		End 
		from dispatchdetail d, batch_products bp, Items, ItemCategories IC  
			where d.dispatchid in 
			(	
				select distinct dispatchid from dispatchabstract da 
				left outer join invoiceabstract invabs on da.invoiceid = invabs.invoiceid and da.status & 192 = 0   and invabs.status & 192 = 0 
				where da.status & 3 <> 0 and dispatchdate < dateadd(d, 1, @FROMDATE) and 
				( (isnull(da.invoiceid, 0)=0 and da.status & 448=0 ) or 
				( isnull(da.invoiceid, 0)<>0 and da.status & 320=0 and 
				dbo.StripDateFromTime(dispatchdate) < dbo.StripDateFromTime(invoicedate)) )
			) and isnull(d.saleprice, 0) > 0 
			and d.batch_code = bp.batch_code 		
			and Items.Product_Code = d.Product_Code and Items.CategoryID = IC.CategoryID 
			and isnull(d.saleprice, 0) > 0 And items.product_code = I.Product_code),

		--Total Stock On Hand Value Without Tax
		(Select     
			Sum(case @StockVal   
				 When @PTSTAX Then isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else (Case [Free] When 1 Then 0 Else Isnull(Items.PTS, 0) End) End)
				  When 'PTR' Then isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else (Case [Free] When 1 Then 0 Else Isnull(Items.PTR, 0) End) End)
				 Else  (Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0)
					    End) * (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)
			End )   
		from Batch_Products	,Items,ItemCategories IC where 
		Items.Product_Code = I.Product_Code  And
		Items.Product_Code = Batch_Products.Product_Code  And
		Items.CategoryID = IC.CategoryID
		and isNull(Batch_Products.Damage,0) = 0
		),

		--[Saleable Stock Tax Value] - GST Changes
		(Select Sum(isnull(SaleableTaxValue,0)) From
			(Select Case When isnull(T.CS_TaxCode,0) > 0 and isnull(Batch_Products.GRNTaxID,0) > 0 Then

			isnull(dbo.Fn_openingbal_TaxCompCalc(I.Product_Code,T.Tax_Code,
				Case When isnull(Batch_Products.TaxType,0) = 5 Then isnull(Batch_Products.GSTTaxType,0) Else isnull(Batch_Products.TaxType,1) End,

			(Case @StockVal   
				 When @PTSTAX Then isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)
							   
				  When 'PTR' Then isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)
							  
				  Else	(Case @UOM When 'Base UOM' Then isnull(Quantity,0) When 'UOM 1'  Then isnull(Quantity,0) 
							When 'UOM 2'  Then isnull(Quantity,0)
						End) * (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)
			End ),
			isnull(Quantity,0),1,0),0)			

		Else
			(Case @StockVal   
				 When @PTSTAX Then isnull(Quantity,0) 
							* (Case Isnull(Batch_Products.TOQ,0) When 0 then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)
							   Else 1 End)	
				  When 'PTR' Then isnull(Quantity,0) 
							* (Case Isnull(Batch_Products.TOQ,0) When 0 then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)
							   Else 1 End)		
				  Else	(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0)
						 End) * (Case Isnull(Batch_Products.TOQ,0) When 0 then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)
								 Else 1 End)
				 
			End ) *  (Case Isnull(Batch_Products.TOQ,0) When 0 then ((Case isNull(Batch_Products.GRNTaxSuffered,0) When 0 Then isNull(Batch_Products.TaxSuffered,0) Else isNull(Batch_Products.GRNTaxSuffered,0) End) /100)
					  Else (Case isNull(Batch_Products.GRNTaxSuffered,0) When 0 Then isNull(Batch_Products.TaxSuffered,0) Else isNull(Batch_Products.GRNTaxSuffered,0) End) End )

		End SaleableTaxValue
		From Batch_Products	Inner Join Items ON Batch_Products.Product_Code = Items.Product_Code
			Inner Join ItemCategories IC ON Items.CategoryID = IC.CategoryID
			Left Join Tax T ON Batch_Products.GRNTaxID = T.Tax_Code
		Where			
			Batch_Products.Product_Code = I.Product_Code And isNull(Free,0)=0 and isNull(Damage,0) = 0			
		) A ), 

		--[Damage Stock Tax Value] - GST Changes
		(Select  Sum(isnull(DamageTaxValue,0)) From
			(Select Case When isnull(T.CS_TaxCode,0) > 0 and isnull(Batch_Products.GRNTaxID,0) > 0 Then
				isnull(dbo.Fn_openingbal_TaxCompCalc(I.Product_Code,T.Tax_Code,
				Case When isnull(Batch_Products.TaxType,0) = 5 Then isnull(Batch_Products.GSTTaxType,0) Else isnull(Batch_Products.TaxType,1) End,

				(Case @StockVal   
					When @PTSTAX Then isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)							  
					When 'PTR' Then isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)							  
					Else (Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0)
							End) * (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)
								 

					End),
					isnull(Quantity,0),1,0),0)	

			Else
				(Case @StockVal   
					When @PTSTAX Then isnull(Quantity,0) 
							* (Case Isnull(Batch_Products.TOQ,0) When 0 then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)
							   Else 1 End)		
				  When 'PTR' Then isnull(Quantity,0) 
							* (Case Isnull(Batch_Products.TOQ,0) When 0 then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)
							   Else 1 End)	
				  Else	(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0)
						 End) * (Case Isnull(Batch_Products.TOQ,0) When 0 then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)
								 Else 1 End)

				End ) *    (Case Isnull(Batch_Products.TOQ,0) When 0 then ((Case  isNull(Batch_Products.GRNTaxSuffered,0) When 0 Then isNull(Batch_Products.TaxSuffered,0) Else isNull(Batch_Products.GRNTaxSuffered,0) End) /100)
						 Else (Case isNull(Batch_Products.GRNTaxSuffered,0) When 0 Then isNull(Batch_Products.TaxSuffered,0) Else isNull(Batch_Products.GRNTaxSuffered,0) End) End )
			End DamageTaxValue

		From Batch_Products	Inner Join Items ON Batch_Products.Product_Code = Items.Product_Code
			Inner Join ItemCategories IC ON Items.CategoryID = IC.CategoryID
			Left Join Tax T ON Batch_Products.GRNTaxID = T.Tax_Code
		Where
			Batch_Products.Product_Code = I.Product_Code and isNull(Damage,0) <> 0		
		) A ),

		--[SIT Stock Tax Value] - GST Changes
	  (Select Sum(isnull(SITTaxValue,0)) From
		(Select Case When isnull(T.CS_TaxCode,0) > 0 Then
			isnull(dbo.Fn_openingbal_TaxCompCalc(I.Product_Code,T.Tax_Code,
				Case When IAR.TaxType = 5 Then IAR.StateType Else Cast(IAR.TaxType as int) End,

			Case @StockVal      
				When @PTSTAX Then     
					(Case IC.Price_Option When 1 Then Isnull(IDR.PTS, 0) * Isnull(IDR.pending, 0)
						Else Isnull(Items.PTS, 0) * Isnull(IDR.pending, 0) End )
				When 'PTR' Then      
					(Case IC.Price_Option When 1 Then Isnull(IDR.PTR, 0) * Isnull(IDR.pending, 0)
						Else Isnull(Items.PTR, 0) * Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0) End )
				When 'ECP' Then 			 
					(Case IC.Price_Option When 1 Then (Case When isnull(Items.Purchased_At, 0) = 1 then Isnull(Items.PTS, 0) Else Isnull(Items.PTR, 0) End) * Isnull(IDR.pending, 0)
						Else (Case When isnull(Items.Purchased_At, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) End) * Isnull(IDR.pending, 0) End )
				When 'MRP' Then      
					Isnull(Items.MRP, 0) * isnull(IDR.pending, 0)             
				When 'Special Price' Then    
					(Case IC.Price_Option When 1 Then Isnull(IDR.Company_Price, 0) * Isnull(IDR.pending, 0)
						Else Isnull(Items.Company_Price, 0) * Isnull(IDR.pending, 0) End)
			Else			 
				isnull(IDR.PTS, 0) * isnull(IDR.pending, 0)
			End,
			isnull(IDR.pending,0),1,0),0)

		Else
			Case @StockVal      
				When @PTSTAX Then     
					( Case IC.Price_Option When 1 Then (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0) * Isnull(IDR.taxcode, 0)/100  ) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End )
						Else (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(Items.PTS, 0) * Isnull(IDR.taxcode, 0)/100  )  Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End ) End )
				When 'PTR' Then      
					(Case IC.Price_Option When 1 Then (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0) * Isnull(IDR.taxcode, 0)/100) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End )
						Else (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(Items.PTR, 0) * Isnull(IDR.taxcode, 0)/100) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End) End )
				When 'ECP' Then 
				--purchase_at instead of ecp	   
					(Case IC.Price_Option When 1 Then (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)/100 * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End )
						Else (Case Isnull(IDR.TOQ,0) When 0 Then  (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)/100 *  ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End) End )
				When 'MRP' Then      
					isnull((Case (Isnull(IDR.TOQ,0)) When 0 then (isnull(IDR.pending, 0)  * Isnull(IDR.taxcode, 0)/100  * Isnull(Items.MRP, 0)) Else (isnull(IDR.pending, 0)  * Isnull(IDR.taxcode, 0)) end ),0)            
				When 'Special Price' Then    
					(Case IC.Price_Option When 1 Then (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)/100 * Isnull(IDR.Company_Price, 0)) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End )
						Else  (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)/100 * Isnull(Items.Company_Price, 0)) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End) End )
			Else    
			 --pts instead of PurchasePrice
				isnull((Case (Isnull(IDR.TOQ,0)) When 0 then (isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)/100 * isnull(IDR.PTS, 0)) Else (isnull(IDR.pending, 0)  * Isnull(IDR.taxcode, 0)) end ), 0)  
			End    
		End SITTaxValue
		From InvoiceDetailReceived IDR 
		Inner Join InvoiceAbstractReceived IAR ON IAR.InvoiceId = IDR.InvoiceId and IAR.Status & 64 = 0
		Inner Join Items ON IDR.Product_Code = Items.Product_Code 
		Inner Join ItemCategories IC ON Items.CategoryID = IC.CategoryID
		Left Join Tax T ON IDR.CS_TaxCode =  T.CS_TaxCode
		Where		 
			Items.Product_Code = I.Product_Code and isnull(IDR.SalePrice, 0) > 0 
		)A ),

		--[VAN Stock Tax Value] - GST Changes
	(Select Sum(isnull(VanTaxValue,0)) From
		(Select Case When isnull(T.CS_TaxCode,0) > 0 and isnull(bp.GRNTaxID,0) > 0 Then
			isnull(dbo.Fn_openingbal_TaxCompCalc(I.Product_Code, T.Tax_Code,
				Case When isnull(bp.TaxType,0) = 5 Then isnull(bp.GSTTaxType,0) Else isnull(bp.TaxType,1) End,

			Case @StockVal      
				When @PTSTAX Then     
					(Case IC.Price_Option When 1 Then Isnull(vd.PTS, 0) * Isnull(vd.Pending, 0)
						Else Isnull(Items.PTS, 0) * Isnull(vd.Pending, 0) End )
				When 'PTR' Then      
					(Case IC.Price_Option When 1 Then Isnull(vd.PTR, 0) * Isnull(vd.Pending, 0)
						Else Isnull(Items.PTR, 0) * Isnull(vd.Pending, 0) End )
				When 'ECP' Then 					
					(Case IC.Price_Option When 1 Then (Case When isnull(Items.Purchased_At, 0) = 1 Then Isnull(Items.PTS, 0) Else Isnull(Items.PTR, 0) End ) * Isnull(vd.Pending, 0)
						Else (Case When isnull(Items.Purchased_At, 0) = 1 Then Isnull(Items.PTS, 0) Else Isnull(Items.PTR, 0) End) * Isnull(vd.Pending, 0) End )
				When 'MRP' Then      
					Isnull(Items.MRP, 0) * isnull(vd.Pending, 0)             
				When 'Special Price' Then    
					(Case IC.Price_Option When 1 Then Isnull(vd.SpecialPrice, 0) * Isnull(vd.Pending, 0)
						Else Isnull(Items.Company_Price, 0) * Isnull(vd.Pending, 0) End )
				Else					
					isnull(vd.PTS, 0) * isnull(vd.Pending, 0)
			End,
			Isnull(vd.pending, 0),1,0),0)

		Else
			Case @StockVal      
				When @PTSTAX Then     
					( Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then  (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(vd.PTS, 0)) Else (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)) End )
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(Items.PTS, 0)) Else (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)) End )  End )
				When 'PTR' Then      
					(Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then  (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(vd.PTR, 0)) Else (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)) End )
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(Items.PTR, 0)) Else (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)) End ) End )
				When 'ECP' Then 
				--purchase_at instead of ecp	   
					(Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)/100 *  ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end )) Else (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)) End )
						Else  (Case IsNull(bp.TOQ,0) When 0 then (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)/100 * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) Else (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)) End ) End )
				When 'MRP' Then      
					isnull((Case IsNull(bp.TOQ,0) When 0 then (isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(Items.MRP, 0)) Else (isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)) End) ,0)            
				When 'Special Price' Then    
					(Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(vd.SpecialPrice, 0)) Else (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)) End)
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(Items.Company_Price, 0)) Else (Isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)) End) End )
				Else    
					--pts instead of PurchasePrice
					isnull((Case IsNull(bp.TOQ,0) When 0 then (isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)/100 * isnull(vd.PTS, 0)) Else (isnull(vd.pending, 0) * isnull(bp.taxsuffered, 0)) end) , 0)  
			End    
		
		End VanTaxValue
		From VanStatementAbstract VSA
		Inner Join VanStatementDetail VD ON VSA.DocSerial = VD.DocSerial and VSA.Status & 128 = 0
		Inner Join Batch_Products bp ON VD.batch_code = bp.batch_code
		Inner Join Items ON VD.Product_Code = Items.Product_Code
		Inner Join ItemCategories IC ON Items.CategoryID = IC.CategoryID
		Left Join Tax T ON bp.GRNTaxID = T.Tax_Code
		Where
			Items.Product_Code = I.Product_Code and isnull(VD.SalePrice, 0) > 0 
		--Group By IsNull(bp.TOQ,0) 
		) A ),

		--[Stock in Dispatch Tax Value] - GST Changes
		(Select  Sum(isnull(DispatchTaxValue,0)) From
		(Select Case When isnull(T.CS_TaxCode,0) > 0 and isnull(bp.GRNTaxID,0) > 0 Then

			isnull(dbo.Fn_openingbal_TaxCompCalc(I.Product_Code,T.Tax_Code,
				Case When isnull(bp.TaxType,0) = 5 Then isnull(bp.GSTTaxType,0) Else isnull(bp.TaxType,1) End,

			Case @StockVal 
				When @PTSTAX Then 
					(Case IC.Price_Option When 1 Then Isnull(bp.PTS, 0) * Isnull(d.quantity, 0)
						Else Isnull(bp.PTS, 0) * Isnull(d.quantity, 0) End )
				When 'PTR' Then 
					(Case IC.Price_Option When 1 Then Isnull(bp.PTR, 0) * Isnull(d.quantity, 0)
						Else Isnull(bp.PTR, 0) * Isnull(d.quantity, 0) End )
				When 'ECP' Then 				
					(Case IC.Price_Option When 1 Then (Case When isnull(Items.Purchased_At, 0) = 1 Then Isnull(Items.PTS, 0) Else Isnull(Items.PTR, 0) End) * Isnull(d.quantity, 0)
						Else (Case When isnull(Items.Purchased_At, 0) = 1 Then Isnull(Items.PTS, 0) Else Isnull(Items.PTR, 0) End) * Isnull(d.quantity, 0) End )
				When 'MRP' Then
					Isnull(Items.MRP, 0) * isnull(d.quantity, 0)
				When 'Special Price' Then
					(Case IC.Price_Option When 1 Then Isnull(bp.company_price, 0) * Isnull(d.quantity, 0)
						Else Isnull(Items.Company_Price, 0) * Isnull(d.quantity, 0) End )
			Else
				isnull(bp.PTS, 0) * isnull(d.quantity, 0)
			End ,
			isnull(d.quantity,0),1,0),0)
		Else

			Case @StockVal 
				When @PTSTAX Then 
					( Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(bp.PTS, 0)) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End)
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(bp.PTS, 0)) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End) End )
				When 'PTR' Then 
					(Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(bp.PTR, 0)) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End)
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(bp.PTR, 0)) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End) End )
				When 'ECP' Then 
				--purchase_at instead of ecp
					(Case IC.Price_Option When 1 Then  (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end )) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End )
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End) End )
				When 'MRP' Then
					isnull((Case IsNull(bp.TOQ,0) When 0 then (isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(Items.MRP, 0)) Else (isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End) ,0)
				When 'Special Price' Then
					(Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(bp.company_price, 0)) Else  (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End) 
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(Items.Company_Price, 0)) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End) End )
			Else
				--pts instead of PurchasePrice
				isnull((Case IsNull(bp.TOQ,0) When 0 then (isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * isnull(bp.PTS, 0)) Else (isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End ), 0)  
			End 		
		End DispatchTaxValue

		From DispatchDetail d
		Inner Join Batch_Products bp ON d.Batch_Code = bp.Batch_Code and isnull(d.SalePrice, 0) > 0
		Inner Join Items ON d.Product_Code = Items.Product_Code
		Inner Join ItemCategories IC ON Items.CategoryID = IC.CategoryID
		Left Join Tax T ON bp.GRNTaxID = T.Tax_Code
		Where d.DispatchID in 
			(	
				select distinct dispatchid from dispatchabstract da 
				left outer join invoiceabstract invabs on da.invoiceid = invabs.invoiceid and da.status & 192 = 0   and invabs.status & 192 = 0 
				where da.status & 3 <> 0 and dispatchdate < dateadd(d, 1, @FROMDATE) and 
				( (isnull(da.invoiceid, 0)=0 and da.status & 448=0 ) or 
				( isnull(da.invoiceid, 0)<>0 and da.status & 320=0 and 
				dbo.StripDateFromTime(dispatchdate) < dbo.StripDateFromTime(invoicedate)) )
			) 			 
			And Items.Product_Code = I.Product_Code 
			--Group by IsNull(bp.TOQ,0)
		) A ),

		--[Total Tax Value] - GST Changes
		(Select Sum(isnull(TotalTaxValue,0)) From
			(Select 
			Case When isnull(T.CS_TaxCode,0) > 0 and isnull(Batch_Products.GRNTaxID,0) > 0 Then
				isnull(dbo.Fn_openingbal_TaxCompCalc(I.Product_Code, T.Tax_Code,
				Case When isnull(Batch_Products.TaxType,0) = 5 Then isnull(Batch_Products.GSTTaxType,0) Else isnull(Batch_Products.TaxType,1) End,
				(Case @StockVal   
					When @PTSTAX Then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End) * isnull(Quantity,0)
					When 'PTR' Then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End) * isnull(Quantity,0)
					Else (Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0) End) 
						* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)

					End),
					isnull(Quantity,0),1,0),0)
			Else
				(Case @StockVal   
					When @PTSTAX Then (Case  Isnull(Batch_Products.TOQ, 0) When 0 then ( isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)) Else isnull(Quantity,0) End) 
					When 'PTR' Then (Case  Isnull(Batch_Products.TOQ, 0) When 0 then(isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)) Else isnull(Quantity,0) End )
					Else (Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0) End) 
						* (Case  Isnull(Batch_Products.TOQ, 0) When 0 then  (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End) Else 1 End)

					End ) *  (Case  Isnull(Batch_Products.TOQ, 0) When 0 then ((Case  isNull(Batch_Products.GRNTaxSuffered,0) When 0 Then isNull(Batch_Products.TaxSuffered,0) Else isNull(Batch_Products.GRNTaxSuffered,0) End) /100)
								Else (Case  isNull(Batch_Products.GRNTaxSuffered,0) When 0 Then isNull(Batch_Products.TaxSuffered,0) Else isNull(Batch_Products.GRNTaxSuffered,0) End) End)
			End TotalTaxValue

		From Batch_Products	
		Inner Join Items ON Batch_Products.Product_Code = Items.Product_Code
		Inner Join ItemCategories IC ON Items.CategoryID = IC.CategoryID
		Left Join Tax T ON Batch_Products.GRNTaxID = T.Tax_Code
		Where   
			Batch_Products.Product_Code = I.Product_Code and isNull(Free,0)=0		
		) A ),
		0,0,0,0,0,0
		From Items I Join ItemCategories on I.categoryID = ItemCategories.CategoryID
		Join #tmpCategories T on I.categoryID = T.LeafLevelCat 
		Join #tempCategory1 T1 on I.CategoryID = T1.CategoryID 
		Join #tmpItems on I.Product_Code = #tmpItems.Product_Code
		Join #tmpStockItems on I.Product_Code = #tmpStockItems.ProdCode
		Left Outer Join Batch_Products BP on I.Product_Code = BP.Product_Code 
		Group By 
		I.Product_Code,I.ProductName,T.CatName ,I.UOM,I.UOM1,I.UOM2,T1.IDS
		Order By T1.IDS
	End

	Update #tmpAvailableStock Set [Saleable Stock Value With Tax] =isNull([Saleable Stock Value without Tax],0) + isNull([Saleable Stock Tax Value],0),
		     					  [Damage Stock Value With tax] = isNull([Damage Stock Value without Tax],0) + isNull([Damage Stock Tax Value],0),
		     					  [SIT Value With Tax] = isNull([SIT Value without Tax],0) + isNull([SIT Stock Tax Value],0),
		     					  [VAN Stock Value With Tax] = isNull([VAN Stock Value without Tax],0) + isNull([VAN Stock Tax Value],0),
		     					  [Stock in Dispatch Value With Tax] = isNull([Stock in Dispatch Value with Out Tax],0) + isNull([Stock in Dispatch Tax Value],0),
								  [Total Stock on Hand Value With Tax] = isNull([Total Stock on Hand Value without Tax],0)  + isNull([Total Tax Value],0)
		

	Set @SQL = 'Select [ItemCode],[Item Code],[Item Name], [' + @CatLevel + 
		'] ,UOM ,(Case isNull([Saleable Stock(Qty)],0) When 0 Then 0 Else  [Saleable Stock(Qty)] End) As [Saleable Stock(Qty)], 
		(Case isNull([Free Stock(Qty)],0) When 0 Then 0 Else [Free Stock(Qty)] End)  As  [Free Stock(Qty)],
		--(Case isNull([Damage Stock(Qty)],0) When 0 Then 0 Else [Damage Stock(Qty)] End) As [Damage Stock(Qty)],

		--(Case isNull([SIT Quantity], 0) When 0 Then 0 Else [SIT Quantity] End) As [SIT Quantity], 
		--(Case isNull([Stock in VAN], 0) When 0 Then 0 Else [Stock in VAN] End)  As [Stock in VAN],
		--(Case isNull([Stock in Dispatch], 0) When 0 Then 0 Else [Stock in Dispatch] End) As [Stock in Dispatch],

		(Case isNull([Total Stock on Hand(Qty)],0)When 0 Then 0 Else [Total Stock on Hand(Qty)] End) As [Total Stock on Hand(Qty)] ,
		(Case isNull([Saleable Stock Value without Tax],0) When 0 Then 0 Else [Saleable Stock Value without Tax] End) As [Saleable Stock Value without Tax] ,
		--(Case isNull([Damage Stock Value without Tax],0) When 0 Then 0 Else [Damage Stock Value without Tax] End) As [Damage Stock Value without Tax] ,

		--(Case isNull([SIT Value without Tax], 0) When 0 Then 0 Else [SIT Value without Tax] End) As [SIT Value without Tax],
		--(Case isNull([VAN Stock Value without Tax], 0) When 0 Then 0 Else [VAN Stock Value without Tax] End) As [VAN Stock Value without Tax],
		--(Case isNull([Stock in Dispatch Value with Out Tax], 0) When 0 Then 0 Else [Stock in Dispatch Value with Out Tax] End) As [Stock in Dispatch Value with Out Tax],

		--(Case isNull([Total Stock on Hand Value without Tax],0) When 0 Then 0 Else  [Total Stock on Hand Value without Tax] End) As	[Total Stock on Hand Value without Tax] ,
		(Case isNull([Saleable Stock Tax Value],0) When 0 Then 0 Else  [Saleable Stock Tax Value] End) As [Saleable Stock Tax Value] ,
		--(Case isNull([Damage Stock Tax Value],0) When 0 Then 0 Else  [Damage Stock Tax Value] End) As   [Damage Stock Tax Value] ,

		--(Case isNull([SIT Stock Tax Value], 0) When 0 Then 0 Else [SIT Stock Tax Value] End) As [SIT Stock Tax Value],
		--(Case isNull([VAN Stock Tax Value], 0) When 0 Then 0 Else [VAN Stock Tax Value] End) As [VAN Stock Tax Value],
		--(Case isNull([Stock in Dispatch Tax Value], 0) When 0 Then 0 Else [Stock in Dispatch Tax Value] End) As [Stock in Dispatch Tax Value],

		--(Case isNull([Total Tax Value],0) When 0 Then 0 Else [Total Tax Value] End) As [Total Tax Value] ,
		(Case isNull([Saleable Stock Value With Tax],0) When 0 Then 0 Else  [Saleable Stock Value With Tax] End) As	[Saleable Stock Value With Tax] --,
		--(Case isNull([Damage Stock Value With tax],0) When 0 Then 0 Else  [Damage Stock Value With tax] End) As  [Damage Stock Value With tax] ,

		--(Case isNull([SIT Value With Tax], 0) When 0 Then 0 Else [SIT Value With Tax] End) As [SIT Value With Tax],
		--(Case isNull([VAN Stock Value With Tax], 0) When 0 Then 0 Else [VAN Stock Value With Tax] End) As [VAN Stock Value With Tax],
		--(Case isNull([Stock in Dispatch Value With Tax], 0) When 0 Then 0 Else [Stock in Dispatch Value With Tax] End) As [Stock in Dispatch Value With Tax],

		--(Case isNull([Total Stock on Hand Value With Tax],0) When 0 Then 0 Else [Total Stock on Hand Value With Tax] End) As [Total Stock on Hand Value With Tax] 
		From #tmpAvailableStock' 

End
/* PTS and Tax End */
Else
Begin
	IF @OpeningDetails = 1   
	Begin
		print ('previous date')
--		----

		--total_Invoiced_qty(Saleable+Free)
		Insert Into #tmptotal_Invd_qty
		select tmp.product_code, isnull(sum(IDR.quantity), 0)
		from #tmpItems tmp left outer join
		( select IDR.product_code as product_code, idr.quantity as quantity
		from InvoiceDetailReceived IDR join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
		where IAR.Status & 64 = 0 and IAR.Status & 1 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FROMDATE)
		and IAR.Invoicetype = 0
		) idr on IDR.product_code = tmp.product_code
		group by tmp.product_code

		--total_received_qty(Saleable), total_received_qty(Free)
		Insert Into #tmptotal_rcvd_qty
		select tmp.product_code, isnull(sum(gdt.quantityreceived),0), isnull(sum(gdt.Freeqty),0)
		from #tmpItems tmp left outer join
		( select IsNull(gdt.quantityreceived, 0) as quantityreceived,
		IsNull(gdt.freeqty, 0) as freeqty, gdt.product_code as product_code
		from grndetail gdt
		join grnabstract gab on gab.grnId = gdt.grnId 
			and gab.grnstatus & 64 = 0 and gab.grnstatus & 32 = 0 and gab.RecdInvoiceId in
		( select InvoiceId from Invoiceabstractreceived IAR
		where IAR.Status & 64 = 0 and IAR.Status & 1 = 0 And IAR.InvoiceDate < dateadd(d, 1, @FROMDATE)
		and IAR.Invoicetype = 0
		)
		where gab.GrnDate < dateadd(d, 1, @FROMDATE)
		) gdt on gdt.product_code = tmp.product_code
		group by tmp.product_code
--

		Insert Into #tmpAvailableStock
		Select Items.Product_Code,Items.Product_Code,Items.ProductName,T.CatName,
		(Case @UOM When 'Base Uom' Then (Select Description From Uom Where UOM = Items.uom )
				   When 'UOM 1' Then (Select Description From Uom Where UOM = Items.uom1)
				   When 'UOM 2' Then (Select Description From Uom Where UOM = Items.uom2)
		End),
		
		--[Saleable Stock(Qty)]
		(Case @UOM When 'Base UOM' Then 
						IsNull(openingdetails.Opening_Quantity,0) - IsNull(openingdetails.Free_Saleable_Quantity,0) - 
						IsNull(openingdetails.Damage_Opening_Quantity,0) --- 
--						IsNull(tmpSalevanqty.van_qty, 0) - IsNull(tmpFreevanqty.van_qty, 0) - 
--						IsNull(tmpSaleDispatchqty.dispatch_qty, 0) - ISNULL(tmpFreedispatchqty.dispatch_qty, 0)						
					When 'UOM 1' Then 
						(IsNull(openingdetails.Opening_Quantity, 0)-IsNull(openingdetails.Free_Saleable_Quantity,0) - 
						IsNull(openingdetails.Damage_Opening_Quantity, 0))/ --- 
--						IsNull(tmpSalevanqty.van_qty, 0) - IsNull(tmpFreevanqty.van_qty, 0) - 
--						IsNull(tmpSaleDispatchqty.dispatch_qty, 0) - ISNULL(tmpFreedispatchqty.dispatch_qty, 0) )/
						(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)        
					When 'UOM 2' Then 
						(IsNull(openingdetails.Opening_Quantity, 0)-IsNull(openingdetails.Free_Saleable_Quantity,0) - 
						IsNull(openingdetails.Damage_Opening_Quantity,0))/ --- 
--						IsNull(tmpSalevanqty.van_qty, 0) - IsNull(tmpFreevanqty.van_qty, 0) - 
--						IsNull(tmpSaleDispatchqty.dispatch_qty, 0) - ISNULL(tmpFreedispatchqty.dispatch_qty, 0) )/
						(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End) 
		End),
						 
		--[Free Stock(Qty)]
		(Case @UOM When 'Base UOM' Then 
						 isnull(openingdetails.Free_Saleable_Quantity, 0)
				   When 'UOM 1' Then
						 isnull(openingdetails.Free_Saleable_Quantity, 0)/
						 (Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
	
				   When 'UOM 2' Then
						 isnull(openingdetails.Free_Saleable_Quantity, 0)/
						 (Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
		End),
		
		--[Damage Stock(Qty)]
		(Case @UOM When 'Base UOM' Then 
						 isnull(openingdetails.Damage_Opening_Quantity,0)
				   When 'UOM 1' Then
						 isnull(openingdetails.Damage_Opening_Quantity,0)/
						 (Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
	
				   When 'UOM 2' Then
						 isnull(openingdetails.Damage_Opening_Quantity,0)/
						 (Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
		End),

		----SIT Qty
		"SIT Qty" = --CAST( tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty AS nvarchar)
			--+ ' ' +  CAST(UOM.Description AS nvarchar) ,
			(Case @UOM When 'Base UOM' Then 
							 CAST(ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0) AS nvarchar)
					   When 'UOM 1' Then
							 CAST(ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0) AS nvarchar)/
							 (Case isNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else Items.UOM1_Conversion End)
					   When 'UOM 2' Then
							 CAST(ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0) AS nvarchar)/
							 (Case isNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else Items.UOM2_Conversion End)
			End) , 
		----SIT Qty

		----Stock In VAN
		"Stock In VAN" = 0,
		----Stock In VAN

		----Stock In Dispatch
		"Stock In Dispatch" = --CAST( tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty AS nvarchar)
			--+ ' ' +  CAST(UOM.Description AS nvarchar) ,
			(Case @UOM When 'Base UOM' Then 
							 ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0)
					   When 'UOM 1' Then
							 (ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0))/
							 (Case isNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else Items.UOM1_Conversion End)
					   When 'UOM 2' Then
							 (ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0))/
							 (Case isNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else Items.UOM2_Conversion End)
			End) , 
		----Stock In Dispatch
		
		--[Total Stock on Hand(Qty)]
		isnull((Case @UOM When 'Base UOM' Then 
						 ISNULL(OpeningDetails.Opening_Quantity, 0) 
				   When 'UOM 1' Then
						 ISNULL(OpeningDetails.Opening_Quantity, 0) /
						 (Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
	
				   When 'UOM 2' Then
						 ISNULL(OpeningDetails.Opening_Quantity, 0) /
						 (Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
		End),0) + 
		isnull((Case @UOM When 'Base UOM' Then 
						 ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0)
				   When 'UOM 1' Then
						 ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0) /
						 (Case isNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else Items.UOM1_Conversion End)
				   When 'UOM 2' Then
						 ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0)/
						 (Case isNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else Items.UOM2_Conversion End)
		End),0) +
		isnull((Case @UOM When 'Base UOM' Then 
						 ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0)
				   When 'UOM 1' Then
						 (ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0))/
						 (Case isNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else Items.UOM1_Conversion End)
				   When 'UOM 2' Then
						 (ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0))/
						 (Case isNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else Items.UOM2_Conversion End)
		End),0) , 

		--[Saleable Stock Value without Tax]
		((Case @StockVal When '%' Then (isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0)) 
			  Else 
				(Case @UOM When 'Base UOM' Then 
								ISNULL(openingdetails.Opening_Quantity, 0) 
							When 'UOM 1' Then 
								ISNULL(openingdetails.Opening_Quantity, 0)
							When 'UOM 2' Then 
								ISNULL(openingdetails.Opening_Quantity, 0)
				  End)* (Case @StockVal When 'PTS' Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) End) -
				(Case @UOM When 'Base UOM' Then 
								  isnull(openingdetails.Damage_Opening_Quantity,0) 
							When 'UOM 1' Then 
								  isnull(openingdetails.Damage_Opening_Quantity,0)
							When 'UOM 2' Then 
								  isnull(openingdetails.Damage_Opening_Quantity,0)
				 End)* (Case @StockVal When 'PTS' Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) End) - 
				(Case @UOM When 'Base UOM' Then 
								 IsNull(openingdetails.Free_Saleable_Quantity,0) 
							When 'UOM 1' Then 
								  IsNull(openingdetails.Free_Saleable_Quantity,0)
							When 'UOM 2' Then 
								  IsNull(openingdetails.Free_Saleable_Quantity,0)
				 End)* (Case @StockVal When 'PTS' Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) End)
		  End)
		),		

		--[Damage Stock Value without Tax]
		((Case @StockVal When '%' Then isnull((openingdetails.Damage_Opening_Value), 0) 
			  Else
				(Case @UOM When 'Base UOM' Then 
							isnull(openingdetails.Damage_Opening_Quantity, 0) 
						When 'UOM 1' Then 
							isnull(openingdetails.Damage_Opening_Quantity, 0)
						When 'UOM 2' Then 
							isnull(openingdetails.Damage_Opening_Quantity, 0)
			  End)* (Case @StockVal When 'PTS' Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) End) 
		  End)
		),

		--[SIT Value without Tax]
		ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0)
		* (Case @StockVal When 'PTS' Then Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) 
			Else Isnull(Items.Purchase_Price, 0) End) ,
		--[VAN Stock Value without Tax]
		0, 
		--[Stock in Dispatch Value with Out Tax]
		(ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0))
		* (Case @StockVal When 'PTS' Then Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) 
			Else Isnull(Items.Purchase_Price, 0) End) ,
	  		
		--[Total Stock on Hand Value without Tax]
		((Case @StockVal When '%' Then (ISNULL(OpeningDetails.Opening_Value, 0))
			   Else
				(Case @UOM When 'Base UOM' Then 
								ISNULL(openingdetails.Opening_Quantity, 0) 
							When 'UOM 1' Then 
								ISNULL(openingdetails.Opening_Quantity, 0)
							When 'UOM 2' Then 
								ISNULL(openingdetails.Opening_Quantity, 0)
				  End)* (Case @StockVal When 'PTS' Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) End) -
				(Case @UOM When 'Base UOM' Then 
								  ISNULL(openingdetails.Free_opening_Quantity, 0) 
							When 'UOM 1' Then 
								  ISNULL(openingdetails.Free_opening_Quantity, 0)
							When 'UOM 2' Then 
								  ISNULL(openingdetails.Free_opening_Quantity, 0)
				 End)* (Case @StockVal When 'PTS' Then  Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) End)
		 End)
		),
		
		--[Saleable Stock Tax Value]
		(
			 (Case @UOM When 'Base UOM' Then 
							ISNULL(openingdetails.Opening_Quantity, 0) 
						When 'UOM 1' Then 
							ISNULL(openingdetails.Opening_Quantity, 0)
						When 'UOM 2' Then 
							ISNULL(openingdetails.Opening_Quantity, 0)
			  End)* (Case @StockVal When 'PTS' Then  Isnull(Items.PTS, 0) 
									When 'PTR' Then Isnull(Items.PTR, 0) 
									Else Isnull(Items.Purchase_Price, 0) 
					End) -
			(Case @UOM When 'Base UOM' Then 
							  isnull(openingdetails.Damage_Opening_Quantity,0) 
						When 'UOM 1' Then 
							  isnull(openingdetails.Damage_Opening_Quantity,0)
						When 'UOM 2' Then 
							  isnull(openingdetails.Damage_Opening_Quantity,0)
			 End)* (Case @StockVal When 'PTS' Then  Isnull(Items.PTS, 0) 
								   When 'PTR' Then Isnull(Items.PTR, 0) 
								   Else Isnull(Items.Purchase_Price, 0) 
					End) -
			(Case @UOM When 'Base UOM' Then 
							  IsNull(openingdetails.Free_Saleable_Quantity,0) 
						When 'UOM 1' Then 
							  IsNull(openingdetails.Free_Saleable_Quantity,0)
						When 'UOM 2' Then 
							  IsNull(openingdetails.Free_Saleable_Quantity,0)
			 End)* (Case @StockVal When 'PTS' Then  Isnull(Items.PTS, 0) 
								   When 'PTR' Then Isnull(Items.PTR, 0) 
								   Else Isnull(Items.Purchase_Price, 0) 
					End)
		) * isNull(TaxSuffered_Value,0) /100,

		--[Damage Stock Tax Value]
		(
			(Case @UOM When 'Base UOM' Then 
							isnull(openingdetails.Damage_Opening_Quantity, 0) 
						When 'UOM 1' Then 
							isnull(openingdetails.Damage_Opening_Quantity, 0)
						When 'UOM 2' Then 
							isnull(openingdetails.Damage_Opening_Quantity, 0)
			  End)* (Case @StockVal When 'PTS' Then  Isnull(Items.PTS, 0) 
									When 'PTR' Then Isnull(Items.PTR, 0) 
									Else Isnull(Items.Purchase_Price, 0)
					End) 		
		) * isNull(TaxSuffered_Value,0) /100 ,

		--[SIT Stock Tax Value]
		ISNULL(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0)
		* (Case @StockVal When 'PTS' Then Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) 
			Else Isnull(Items.Purchase_Price, 0) End)* isNull(TaxSuffered_Value,0) /100 , 
		--[VAN Stock Tax Value]
		0, 
		--[Stock in Dispatch Tax Value]
		(ISNULL(tmpSaleDispatchqty.dispatch_qty, 0) + ISNULL(tmpFreedispatchqty.dispatch_qty, 0))
		* (Case @StockVal When 'PTS' Then Isnull(Items.PTS, 0) When 'PTR' Then Isnull(Items.PTR, 0) 
			Else Isnull(Items.Purchase_Price, 0) End)* isNull(TaxSuffered_Value,0) /100 ,		

		--[Total Tax Value]
		(
			(Case @UOM When 'Base UOM' Then 
							ISNULL(openingdetails.Opening_Quantity, 0) 
						When 'UOM 1' Then 
							ISNULL(openingdetails.Opening_Quantity, 0)
						When 'UOM 2' Then 
							ISNULL(openingdetails.Opening_Quantity, 0)
			  End)* (Case @StockVal When 'PTS' Then  Isnull(Items.PTS, 0) 
									When 'PTR' Then Isnull(Items.PTR, 0) 
									Else Isnull(Items.Purchase_Price, 0)
					End) -
			(Case @UOM When 'Base UOM' Then 
							  ISNULL(openingdetails.Free_opening_Quantity, 0) 
						When 'UOM 1' Then 
							  ISNULL(openingdetails.Free_opening_Quantity, 0)
						When 'UOM 2' Then 
							  ISNULL(openingdetails.Free_opening_Quantity, 0)
			 End)* (Case @StockVal When 'PTS' Then  Isnull(Items.PTS, 0) 
								   When 'PTR' Then Isnull(Items.PTR, 0) 
								   Else Isnull(Items.Purchase_Price, 0)	
					End)
		) * isNull(TaxSuffered_Value,0) /100 ,0,0,0,0,0,0	
		
		From  Items 
		Left Outer Join  OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
		Inner Join ItemCategories On Items.categoryID = ItemCategories.CategoryID 
		Inner Join #tmpCategories T On Items.categoryID = T.LeafLevelCat 
		Inner Join #tempCategory1 T1 On Items.categoryID = T1.CategoryID 
		----link temp tables
		Left Outer Join #tmptotal_Invd_qty tmpInvqty On Items.Product_Code = tmpInvqty.Product_Code
		Left Outer Join  #tmptotal_rcvd_qty tmprcvdqty On Items.Product_Code = tmprcvdqty.Product_Code
--		--,#tmptotal_Invd_Saleonly_qty tmpInvdSaleqty
		Left Outer Join #tmpSalable_van_qty tmpSalevanqty On Items.Product_Code = tmpSalevanqty.Product_Code		
		Left Outer Join  #tmpFree_van_qty tmpFreevanqty On Items.Product_Code = tmpFreevanqty.Product_Code
		Left Outer Join #tmpSaleable_dispatch_qty tmpSaleDispatchqty On Items.Product_Code = tmpSaleDispatchqty.Product_Code
		Left Outer Join  #tmpFree_dispatch_qty tmpFreedispatchqty On Items.Product_Code = tmpFreedispatchqty.Product_Code
		----link temp tables
		WHERE 
		OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate) And
		Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItems) And
		Items.Product_Code In (Select  ProdCode From #tmpStockItems)
		----join temp tables
		--AND Items.Product_Code *= tmpInvdSaleqty.Product_Code	
		----join temp tables
		Order By T1.IDS
	End
	Else
	Begin		

		Insert Into #tmpAvailableStock
		Select I.Product_Code,I.Product_Code,I.ProductName,T.CatName,
		(Case @UOM When 'Base Uom' Then (Select Description From Uom Where UOM = I.uom )
				   When 'UOM 1' Then (Select Description From Uom Where UOM = I.uom1)
				   When 'UOM 2' Then (Select Description From Uom Where UOM = I.uom2)
		End),
		
		--Saleable Qty
		(	select Sum(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
						   When 'UOM 1'  Then isnull(Quantity,0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						   When 'UOM 2'  Then isnull(Quantity,0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
				End)
			from Batch_Products	,Items where  
			Batch_Products.Product_Code = I.Product_Code  And isNull(Free,0)=0 and 
			Items.Product_Code = Batch_Products.Product_Code And
			isNull(Damage,0) = 0 
		),  -- - 
--		(	select sum(Case @UOM When 'Base UOM' Then isnull(van_qty, 0) 
--					When 'UOM 1' Then isnull(van_qty,0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
--					When 'UOM 2' Then isnull(van_qty,0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
--					End)
--			from #tmpSalable_van_qty, Items where  
--			#tmpSalable_van_qty.Product_Code = Items.Product_Code 
--			and #tmpSalable_van_qty.Product_Code = I.Product_Code
-- 		)  - 
--		(	select sum(Case @UOM When 'Base UOM' Then isnull(van_qty, 0) 
--					When 'UOM 1' Then isnull(van_qty,0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
--					When 'UOM 2' Then isnull(van_qty,0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
--					End)
--			from #tmpFree_van_qty, Items where  
--			#tmpSalable_van_qty.Product_Code = Items.Product_Code 
--			and #tmpSalable_van_qty.Product_Code = I.Product_Code
-- 		)  - 
--		(	select isnull(sum(dispatch_qty), 0) from #tmpSaleable_dispatch_qty, Items where  
--			#tmpSaleable_dispatch_qty.Product_Code = Items.Product_Code 
--			and #tmpSaleable_dispatch_qty.Product_Code = I.Product_Code
--		)  - 
--		(	select isnull(sum(dispatch_qty), 0) from #tmpFree_dispatch_qty, Items where  
--			#tmpFree_dispatch_qty.Product_Code = Items.Product_Code 
--			and #tmpFree_dispatch_qty.Product_Code = I.Product_Code
--		),			

		--Free Qty
		(select Sum(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
						   When 'UOM 1'  Then isnull(Quantity,0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						   When 'UOM 2'  Then isnull(Quantity,0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
				End)
		from Batch_Products	,Items where 
		Batch_Products.Product_Code = I.Product_Code  And isNull(Free,0) <> 0 and 
		Items.Product_Code = Batch_Products.Product_Code And
		isNull(Damage,0) <> 1  
		),   

		--Damage Qty
		(select Sum(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
						   When 'UOM 1'  Then isnull(Quantity,0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						   When 'UOM 2'  Then isnull(Quantity,0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
				End)
		from Batch_Products	,Items where 
		Batch_Products.Product_Code = I.Product_Code  and 	
		Items.Product_Code = Batch_Products.Product_Code And
		isNull(Damage,0) <> 0  
		) ,
		--[SIT Quantity] 
		CAST(	( select 
					Sum(Case @UOM When 'Base UOM' Then isnull(IDR.pending, 0) 
						When 'UOM 1'  Then isnull(IDR.pending, 0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						When 'UOM 2'  Then isnull(IDR.pending, 0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
						End)
					from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR, Items 
					where IDR.Product_code = I.Product_code and IAR.Status & 64 = 0 
					and IAR.InvoiceId = IDR.InvoiceId and IDR.Product_code = Items.Product_code 
				) AS nvarchar ),
		--[Stock in VAN] 
		CAST(	( select 
					Sum(Case @UOM When 'Base UOM' Then isnull(sv.van_qty, 0) + isnull(sf.van_qty, 0) 
						When 'UOM 1' Then (isnull(sv.van_qty, 0) + isnull(sf.van_qty, 0))/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						When 'UOM 2' Then (isnull(sv.van_qty, 0) + isnull(sf.van_qty, 0))/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
						End)
					from #tmpSalable_van_qty sv, #tmpFree_van_qty sf, Items 
					where sv.Product_code = I.Product_code and 
					sv.Product_code = sf.Product_code and sv.Product_code = Items.Product_code 
				) AS nvarchar ),
		--[Stock in Dispatch] 
		CAST(	( select 
					Sum(Case @UOM When 'Base UOM' Then isnull(d.dispatch_qty, 0) + isnull(f.dispatch_qty, 0) 
						When 'UOM 1'  Then (isnull(d.dispatch_qty, 0) + isnull(f.dispatch_qty, 0))/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						When 'UOM 2'  Then (isnull(d.dispatch_qty, 0) + isnull(f.dispatch_qty, 0))/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
						End)
					from #tmpSaleable_dispatch_qty d, #tmpFree_dispatch_qty f, Items 
					where d.Product_code = I.Product_code and 
					d.Product_code = f.Product_code and d.Product_code = Items.Product_code 
				) AS nvarchar ),

		--Total Stock On Hand Qty
		isnull((select Sum(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
						   When 'UOM 1'  Then isnull(Quantity,0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
						   When 'UOM 2'  Then isnull(Quantity,0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
				End)
		from Batch_Products	,Items where 
		Batch_Products.Product_Code = I.Product_Code And
		Items.Product_Code = Batch_Products.Product_Code 
		),0) + 
		isnull(( select 
			Sum(Case @UOM When 'Base UOM' Then isnull(IDR.pending, 0) 
				When 'UOM 1'  Then isnull(IDR.pending, 0)/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
				When 'UOM 2'  Then isnull(IDR.pending, 0)/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
				End)
			from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR, Items 
			where IDR.Product_code = I.Product_code and IAR.Status & 64 = 0 
			and IAR.InvoiceId = IDR.InvoiceId and IDR.Product_code = Items.Product_code 
		),0) +
		isnull(( select 
			Sum(Case @UOM When 'Base UOM' Then isnull(sv.van_qty, 0) + isnull(sf.van_qty, 0) 
				When 'UOM 1' Then (isnull(sv.van_qty, 0) + isnull(sf.van_qty, 0))/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
				When 'UOM 2' Then (isnull(sv.van_qty, 0) + isnull(sf.van_qty, 0))/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
				End)
			from #tmpSalable_van_qty sv, #tmpFree_van_qty sf, Items 
			where sv.Product_code = I.Product_code and 
			sv.Product_code = sf.Product_code and sv.Product_code = Items.Product_code 
		),0) +
		isnull(( select 
			Sum(Case @UOM When 'Base UOM' Then isnull(d.dispatch_qty, 0) + isnull(f.dispatch_qty, 0) 
				When 'UOM 1'  Then (isnull(d.dispatch_qty, 0) + isnull(f.dispatch_qty, 0))/(Case isNull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End)
				When 'UOM 2'  Then (isnull(d.dispatch_qty, 0) + isnull(f.dispatch_qty, 0))/(Case isNull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End)
				End)
			from #tmpSaleable_dispatch_qty d, #tmpFree_dispatch_qty f, Items 
			where d.Product_code = I.Product_code and 
			d.Product_code = f.Product_code and d.Product_code = Items.Product_code 
		),0) ,

		--Saleable Stock Value Without Tax
		(Select     
			Sum(case @StockVal   
				 When 'PTS' Then isnull(Quantity,0) * 
								 (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)
				  When 'PTR' Then isnull(Quantity,0) * 
								  (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)
				  Else			  (Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0)
								  End) * (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)
						
			End)    
		from Batch_Products	,Items,ItemCategories IC where 
		Items.Product_Code = I.Product_Code  And isNull(Free,0)=0 and 
		Items.Product_Code = Batch_Products.Product_Code And
		isNull(Damage,0) = 0 And
		Items.CategoryID = IC.CategoryID
		),

		--Damage Stock Value Without Tax
		(Select     
			Sum(case @StockVal   
				 When 'PTS' Then  isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)
				  When 'PTR' Then isnull(Quantity,0) 
								* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)
				  Else  (Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0)
						 End) * (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)
			End )  
		from Batch_Products	,Items,ItemCategories IC where 
		Items.Product_Code = I.Product_Code  And
		Items.Product_Code = Batch_Products.Product_Code And
		Items.CategoryID = IC.CategoryID And
		isNull(Damage,0) <> 0 
		),

		--[SIT Value without Tax]
		(Select 
		case @StockVal      
		When 'PTS' Then     
			Sum( Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0))
					Else (Isnull(IDR.pending, 0) * Isnull(Items.PTS, 0)) End )
		When 'PTR' Then      
			Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0)) 
					Else (Isnull(IDR.pending, 0) * Isnull(Items.PTR, 0)) End )
		When 'ECP' Then 
		 --purchase_at instead of ecp	   
			Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ))
					Else (Isnull(IDR.pending, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) End )
		When 'MRP' Then      
			isnull(Sum(isnull(IDR.pending, 0) * Isnull(Items.MRP, 0)),0)            
		When 'Special Price' Then    
			Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.Company_Price, 0)) 
					Else (Isnull(IDR.pending, 0) * Isnull(Items.Company_Price, 0)) End )
		Else    
		 --pts instead of PurchasePrice
			isnull(Sum(isnull(IDR.pending, 0) * isnull(IDR.PTS, 0)), 0)  
		End    
		from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items, ItemCategories IC  
		where IAR.InvoiceId = IDR.InvoiceId and IAR.Status & 64 = 0 
		and Items.Product_Code = IDR.Product_Code and Items.CategoryID = IC.CategoryID 
		and isnull(IDR.saleprice, 0) > 0 And items.product_code = I.Product_code),

		--[VAN Stock Value without Tax]
		(Select 
		case @StockVal      
		When 'PTS' Then     
			Sum( Case IC.Price_Option When 1 Then (Isnull(vd.pending, 0) * Isnull(vd.PTS, 0))
					Else (Isnull(vd.pending, 0) * Isnull(Items.PTS, 0)) End )
		When 'PTR' Then      
			Sum(Case IC.Price_Option When 1 Then (Isnull(vd.pending, 0) * Isnull(vd.PTR, 0)) 
					Else (Isnull(vd.pending, 0) * Isnull(Items.PTR, 0)) End )
		When 'ECP' Then 
		 --purchase_at instead of ecp	   
			Sum(Case IC.Price_Option When 1 Then (Isnull(vd.pending, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ))
					Else (Isnull(vd.pending, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) End )
		When 'MRP' Then      
			isnull(Sum(isnull(vd.pending, 0) * Isnull(Items.MRP, 0)),0)            
		When 'Special Price' Then    
			Sum(Case IC.Price_Option When 1 Then (Isnull(vd.pending, 0) * Isnull(vd.SpecialPrice, 0)) 
					Else (Isnull(vd.pending, 0) * Isnull(Items.Company_Price, 0)) End )
		Else    
		 --pts instead of PurchasePrice
			isnull(Sum(isnull(vd.pending, 0) * isnull(vd.PTS, 0)), 0)  
		End    
		from vanstatementabstract vsa, vanstatementdetail vd, batch_products bp, Items, ItemCategories IC  
		where vsa.docserial = vd.docserial and vsa.Status & 128 = 0 and vd.batch_code = bp.batch_code		
		and Items.Product_Code = vd.Product_Code and Items.CategoryID = IC.CategoryID 
		and isnull(vd.saleprice, 0) > 0 And items.product_code = I.Product_code),

		--[Stock in Dispatch Value with Out Tax]
		(Select 
		case @StockVal 
		When 'PTS' Then 
			Sum( Case IC.Price_Option When 1 Then (Isnull(d.quantity, 0) * Isnull(bp.PTS, 0))
					Else (Isnull(d.quantity, 0) * Isnull(bp.PTS, 0)) End )
		When 'PTR' Then 
			Sum(Case IC.Price_Option When 1 Then (Isnull(d.quantity, 0) * Isnull(bp.PTR, 0)) 
					Else (Isnull(d.quantity, 0) * Isnull(bp.PTR, 0)) End )
		When 'ECP' Then 
		 --purchase_at instead of ecp
			Sum(Case IC.Price_Option When 1 Then (Isnull(d.quantity, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ))
					Else (Isnull(d.quantity, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) End )
		When 'MRP' Then
			isnull(Sum(isnull(d.quantity, 0) * Isnull(Items.MRP, 0)),0)
		When 'Special Price' Then
			Sum(Case IC.Price_Option When 1 Then (Isnull(d.quantity, 0) * Isnull(bp.company_price, 0)) 
					Else (Isnull(d.quantity, 0) * Isnull(Items.Company_Price, 0)) End )
		Else
		 --pts instead of PurchasePrice
			isnull(Sum(isnull(d.quantity, 0) * isnull(bp.PTS, 0)), 0)  
		End 
		from dispatchdetail d, batch_products bp, Items, ItemCategories IC  
			where d.dispatchid in 
			(	
				select distinct dispatchid from dispatchabstract da 
				left outer join invoiceabstract invabs on da.invoiceid = invabs.invoiceid and da.status & 192 = 0   and invabs.status & 192 = 0 
				where da.status & 3 <> 0 and dispatchdate < dateadd(d, 1, @FROMDATE) and 
				( (isnull(da.invoiceid, 0)=0 and da.status & 448=0 ) or 
				( isnull(da.invoiceid, 0)<>0 and da.status & 320=0 and 
				dbo.StripDateFromTime(dispatchdate) < dbo.StripDateFromTime(invoicedate)) )
			) and isnull(d.saleprice, 0) > 0 
			and d.batch_code = bp.batch_code 		
			and Items.Product_Code = d.Product_Code and Items.CategoryID = IC.CategoryID 
			and isnull(d.saleprice, 0) > 0 And items.product_code = I.Product_code),

		--Total Stock On Hand Value Without Tax
		(Select     
			Sum(case @StockVal   
				 When 'PTS' Then isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else (Case [Free] When 1 Then 0 Else Isnull(Items.PTS, 0) End) End)
				  When 'PTR' Then isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else (Case [Free] When 1 Then 0 Else Isnull(Items.PTR, 0) End) End)
				 Else  (Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0)
					    End) * (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)
			End )   
		from Batch_Products	,Items,ItemCategories IC where 
		Items.Product_Code = I.Product_Code  And
		Items.Product_Code = Batch_Products.Product_Code  And
		Items.CategoryID = IC.CategoryID
		),

		--[Saleable Stock Tax Value] - GST Changes
		(Select Sum(isnull(SaleableTaxValue,0)) From
			(Select Case When isnull(T.CS_TaxCode,0) > 0 and isnull(Batch_Products.GRNTaxID,0) > 0 Then

			isnull(dbo.Fn_openingbal_TaxCompCalc(I.Product_Code,T.Tax_Code,
				Case When isnull(Batch_Products.TaxType,0) = 5 Then isnull(Batch_Products.GSTTaxType,0) Else isnull(Batch_Products.TaxType,1) End,
				(Case @StockVal   
					When 'PTS' Then isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)
					When 'PTR' Then isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)
					Else	(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0) End) 
						* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)				 
				End), 
				isnull(Quantity,0),1,0),0)			

			Else
				(Case @StockVal   
					 When 'PTS' Then isnull(Quantity,0) 
							* (Case Isnull(Batch_Products.TOQ,0) When 0 then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)
							   Else 1 End)	
					When 'PTR' Then isnull(Quantity,0) 
							* (Case Isnull(Batch_Products.TOQ,0) When 0 then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)
							   Else 1 End)		
					Else	(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0) End) 
								* (Case Isnull(Batch_Products.TOQ,0) When 0 then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)
								 Else 1 End)
				 
					End ) 
						*  (Case Isnull(Batch_Products.TOQ,0) When 0 then ((Case isNull(Batch_Products.GRNTaxSuffered,0) When 0 Then isNull(Batch_Products.TaxSuffered,0) Else isNull(Batch_Products.GRNTaxSuffered,0) End) /100)
							Else (Case isNull(Batch_Products.GRNTaxSuffered,0) When 0 Then isNull(Batch_Products.TaxSuffered,0) Else isNull(Batch_Products.GRNTaxSuffered,0) End) End )

			End SaleableTaxValue
		From Batch_Products	Inner Join Items ON Batch_Products.Product_Code = Items.Product_Code
			Inner Join ItemCategories IC ON Items.CategoryID = IC.CategoryID
			Left Join Tax T ON Batch_Products.GRNTaxID = T.Tax_Code
		Where			
			Batch_Products.Product_Code = I.Product_Code And isNull(Free,0)=0 and isNull(Damage,0) = 0			
		) A ), 

		--[Damage Stock Tax Value]  - GST Changes

		(Select  Sum(isnull(DamageTaxValue,0)) From
			(Select Case When isnull(T.CS_TaxCode,0) > 0 and isnull(Batch_Products.GRNTaxID,0) > 0 Then

			isnull(dbo.Fn_openingbal_TaxCompCalc(I.Product_Code,T.Tax_Code,
				Case When isnull(Batch_Products.TaxType,0) = 5 Then isnull(Batch_Products.GSTTaxType,0) Else isnull(Batch_Products.TaxType,1) End,
					(Case @StockVal   
						When 'PTS' Then isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)							   
						When 'PTR' Then isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)							  
						Else (Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0)
						End) * (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)								 

					End),
				isnull(Quantity,0),1,0),0)	
		Else		   
			(Case @StockVal   
				 When 'PTS' Then isnull(Quantity,0) 
							* (Case Isnull(Batch_Products.TOQ,0) When 0 then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)
							   Else 1 End)		
				  When 'PTR' Then isnull(Quantity,0) 
							* (Case Isnull(Batch_Products.TOQ,0) When 0 then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)
							   Else 1 End)	
				  Else	(Case @UOM When 'Base UOM' Then isnull(Quantity,0) 
											When 'UOM 1'  Then isnull(Quantity,0)
											When 'UOM 2'  Then isnull(Quantity,0)
						 End) * (Case Isnull(Batch_Products.TOQ,0) When 0 then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)
								 Else 1 End)
			End ) *  (Case Isnull(Batch_Products.TOQ,0) When 0 then ((Case  isNull(Batch_Products.GRNTaxSuffered,0) When 0 Then isNull(Batch_Products.TaxSuffered,0) Else isNull(Batch_Products.GRNTaxSuffered,0) End) /100)
						 Else (Case isNull(Batch_Products.GRNTaxSuffered,0) When 0 Then isNull(Batch_Products.TaxSuffered,0) Else isNull(Batch_Products.GRNTaxSuffered,0) End) End )

		End DamageTaxValue
		From Batch_Products	Inner Join Items ON Batch_Products.Product_Code = Items.Product_Code
			Inner Join ItemCategories IC ON Items.CategoryID = IC.CategoryID
			Left Join Tax T ON Batch_Products.GRNTaxID = T.Tax_Code
		Where
			Batch_Products.Product_Code = I.Product_Code and isNull(Damage,0) <> 0		
		) A ),

		--[SIT Stock Tax Value] - GST Changes
	  (Select Sum(isnull(SITTaxValue,0)) From
		(Select Case When isnull(T.CS_TaxCode,0) > 0 Then
			isnull(dbo.Fn_openingbal_TaxCompCalc(I.Product_Code,T.Tax_Code,
				Case When IAR.TaxType = 5 Then IAR.StateType Else Cast(IAR.TaxType as int) End,
			Case @StockVal      
				When 'PTS' Then Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0))
									Else (Isnull(IDR.pending, 0) * Isnull(Items.PTS, 0)) End		

				When 'PTR' Then Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0))
									Else (Isnull(IDR.pending, 0) * Isnull(Items.PTR, 0)) End
				When 'ECP' Then 
						Case IC.Price_Option When 1 Then (Case When isnull(Items.Purchased_At, 0) = 1 Then Isnull(Items.PTS, 0) Else Isnull(Items.PTR, 0) End) * (Isnull(IDR.pending, 0))
							Else (Case When isnull(Items.Purchased_At, 0) = 1 then Isnull(Items.PTS, 0) Else Isnull(Items.PTR, 0) End) * (Isnull(IDR.pending, 0)) End
						   
				When 'MRP' Then isnull(IDR.Pending, 0) * Isnull(Items.MRP, 0)

				When 'Special Price' Then    
					Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.Company_Price, 0))
						Else (Isnull(IDR.pending, 0) * Isnull(Items.Company_Price, 0)) End
			Else
				isnull(IDR.pending, 0) * isnull(IDR.PTS, 0)  
			End,   			
			isnull(IDR.pending,0),1,0),0)
		Else
			Case @StockVal      
			When 'PTS' Then  
					Case IC.Price_Option When 1 Then (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0) * Isnull(IDR.taxcode, 0)/100  ) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End )
						Else (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(Items.PTS, 0) * Isnull(IDR.taxcode, 0)/100  )  Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End ) End		

			When 'PTR' Then      
				(Case IC.Price_Option When 1 Then (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0) * Isnull(IDR.taxcode, 0)/100) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End )
						Else (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(Items.PTR, 0) * Isnull(IDR.taxcode, 0)/100) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End) End )
			When 'ECP' Then 
			 --purchase_at instead of ecp	   
				(Case IC.Price_Option When 1 Then (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)/100 * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End )
						Else (Case Isnull(IDR.TOQ,0) When 0 Then  (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)/100 *  ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End) End )
			When 'MRP' Then      
				isnull((Case (Isnull(IDR.TOQ,0)) When 0 then (isnull(IDR.pending, 0)  * Isnull(IDR.taxcode, 0)/100  * Isnull(Items.MRP, 0)) Else (isnull(IDR.pending, 0)  * Isnull(IDR.taxcode, 0)) end ),0)            
			When 'Special Price' Then    
				(Case IC.Price_Option When 1 Then (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)/100 * Isnull(IDR.Company_Price, 0)) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End )
						Else  (Case Isnull(IDR.TOQ,0) When 0 then (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)/100 * Isnull(Items.Company_Price, 0)) Else (Isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)) End) End )
			Else    
			 --pts instead of PurchasePrice
				isnull((Case (Isnull(IDR.TOQ,0)) When 0 then (isnull(IDR.pending, 0) * Isnull(IDR.taxcode, 0)/100 * isnull(IDR.PTS, 0)) Else (isnull(IDR.pending, 0)  * Isnull(IDR.taxcode, 0)) end ), 0)  
			End    
		End SITTaxValue
		From InvoiceDetailReceived IDR 
		Inner Join InvoiceAbstractReceived IAR ON IAR.InvoiceId = IDR.InvoiceId and IAR.Status & 64 = 0
		Inner Join Items ON IDR.Product_Code = Items.Product_Code 
		Inner Join ItemCategories IC ON Items.CategoryID = IC.CategoryID
		Left Join Tax T ON IDR.CS_TaxCode =  T.CS_TaxCode
		Where		 
			Items.Product_Code = I.Product_Code and isnull(IDR.SalePrice, 0) > 0 
		)A ),

		-- [VAN Stock Tax Value] - GST Changes
	(Select Sum(isnull(VanTaxValue,0)) From

		(Select Case When isnull(T.CS_TaxCode,0) > 0 and isnull(bp.GRNTaxID,0) > 0 Then
			isnull(dbo.Fn_openingbal_TaxCompCalc(I.Product_Code, T.Tax_Code,
				Case When isnull(bp.TaxType,0) = 5 Then isnull(bp.GSTTaxType,0) Else isnull(bp.TaxType,1) End,

			Case @StockVal 
				When 'PTS' Then Case IC.Price_Option When 1 Then Isnull(VD.PTS, 0) * Isnull(VD.Pending, 0)
								Else Isnull(Items.PTS, 0) * Isnull(VD.pending, 0) End
				When 'PTR' Then Case IC.Price_Option When 1 Then Isnull(VD.PTR, 0) * Isnull(VD.pending, 0)
								Else Isnull(Items.PTR, 0) * Isnull(VD.pending, 0) End
				When 'ECP' Then 
					Case IC.Price_Option When 1 Then (Case When isnull(Items.Purchased_At, 0) = 1 then Isnull(Items.PTS, 0) Else Isnull(Items.PTR, 0) End) * Isnull(VD.pending, 0)
						Else (Case When isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) Else Isnull(Items.PTR, 0) End) * Isnull(VD.pending, 0) End
				When 'MRP' Then      
					isnull(VD.pending, 0) * Isnull(Items.MRP, 0)            
				When 'Special Price' Then    
					Case IC.Price_Option When 1 Then Isnull(VD.SpecialPrice, 0) * Isnull(VD.pending, 0)
						Else Isnull(Items.Company_Price, 0) * Isnull(VD.pending, 0) End
				Else
					isnull(VD.PTS, 0) * isnull(VD.pending, 0)
			End,
			Isnull(VD.pending, 0),1,0),0)
		Else
			Case @StockVal      
				When 'PTS' Then     
					(Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then  (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(VD.PTS, 0)) Else (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)) End )
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(Items.PTS, 0)) Else (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)) End )  End )
				When 'PTR' Then      
					(Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then  (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(VD.PTR, 0)) Else (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)) End )
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(Items.PTR, 0)) Else (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)) End ) End )
				When 'ECP' Then 
				--purchase_at instead of ecp	   
					(Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)/100 *  ( Case When isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end )) Else (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)) End )
						Else  (Case IsNull(bp.TOQ,0) When 0 then (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)/100 * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) Else (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)) End ) End )
				When 'MRP' Then      
					isnull((Case IsNull(bp.TOQ,0) When 0 then (isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(Items.MRP, 0)) Else (isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)) End) ,0)            
				When 'Special Price' Then    
					(Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(VD.SpecialPrice, 0)) Else (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)) End)
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)/100 * Isnull(Items.Company_Price, 0)) Else (Isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)) End) End )
			Else    
			 --pts instead of PurchasePrice
				isnull((Case IsNull(bp.TOQ,0) When 0 then (isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)/100 * isnull(VD.PTS, 0)) Else (isnull(VD.pending, 0) * isnull(bp.taxsuffered, 0)) End) , 0)  
			End    
		End VanTaxValue
		From VanStatementAbstract VSA
		Inner Join VanStatementDetail VD ON VSA.DocSerial = VD.DocSerial and VSA.Status & 128 = 0
		Inner Join Batch_Products bp ON VD.batch_code = bp.batch_code
		Inner Join Items ON VD.Product_Code = Items.Product_Code
		Inner Join ItemCategories IC ON Items.CategoryID = IC.CategoryID
		Left Join Tax T ON bp.GRNTaxID = T.Tax_Code
		Where
			Items.Product_Code = I.Product_Code and isnull(VD.SalePrice, 0) > 0 
		--Group By IsNull(bp.TOQ,0) 
		) A ),

		--[Stock in Dispatch Tax Value] - GST Changes
	(Select  Sum(isnull(DispatchTaxValue,0)) From
		(Select Case When isnull(T.CS_TaxCode,0) > 0 and isnull(bp.GRNTaxID,0) > 0 Then

			isnull(dbo.Fn_openingbal_TaxCompCalc(I.Product_Code,T.Tax_Code,
				Case When isnull(bp.TaxType,0) = 5 Then isnull(bp.GSTTaxType,0) Else isnull(bp.TaxType,1) End,

			Case @StockVal 
				When 'PTS' Then (Case IC.Price_Option When 1 Then Isnull(bp.PTS, 0) * Isnull(d.quantity, 0)
									Else Isnull(bp.PTS, 0) * Isnull(d.quantity, 0) End)
				When 'PTR' Then (Case IC.Price_Option When 1 Then Isnull(bp.PTR, 0) * Isnull(d.quantity, 0)
									Else Isnull(bp.PTR, 0) * Isnull(d.quantity, 0) End )
				When 'ECP' Then 			 
					(Case IC.Price_Option When 1 Then (Case When isnull(Items.Purchased_At, 0) = 1 Then Isnull(Items.PTS, 0) Else Isnull(Items.PTR, 0) End ) * Isnull(d.quantity, 0)
						Else (Case When isnull(Items.Purchased_At, 0) = 1 then Isnull(Items.PTS, 0) Else Isnull(Items.PTR, 0) End) * Isnull(d.quantity, 0) End)
				When 'MRP' Then
					Isnull(Items.MRP, 0) * isnull(d.quantity, 0)
				When 'Special Price' Then
					(Case IC.Price_Option When 1 Then Isnull(bp.company_price, 0) *  Isnull(d.quantity, 0)
						Else Isnull(Items.Company_Price, 0) * Isnull(d.quantity, 0) End)
			Else			 
				isnull(bp.PTS, 0) * isnull(d.quantity, 0)
			End,
			isnull(d.quantity,0),1,0),0)

		Else
			Case @StockVal 
				When 'PTS' Then 
					( Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(bp.PTS, 0)) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End)
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(bp.PTS, 0)) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End) End )
				When 'PTR' Then 
					(Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(bp.PTR, 0)) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End)
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(bp.PTR, 0)) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End) End )
				When 'ECP' Then 
				--purchase_at instead of ecp
					(Case IC.Price_Option When 1 Then  (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end )) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End )
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End) End )
				When 'MRP' Then
					isnull((Case IsNull(bp.TOQ,0) When 0 then (isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(Items.MRP, 0)) Else (isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End) ,0)
				When 'Special Price' Then
					(Case IC.Price_Option When 1 Then (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(bp.company_price, 0)) Else  (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End) 
						Else (Case IsNull(bp.TOQ,0) When 0 then (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * Isnull(Items.Company_Price, 0)) Else (Isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End) End )
			Else
			 --pts instead of PurchasePrice
				isnull((Case IsNull(bp.TOQ,0) When 0 then (isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)/100 * isnull(bp.PTS, 0)) Else (isnull(d.quantity, 0) * Isnull(bp.taxsuffered, 0)) End ), 0)  
			End 
		End DispatchTaxValue

		From DispatchDetail d
		Inner Join Batch_Products bp ON d.Batch_Code = bp.Batch_Code and isnull(d.SalePrice, 0) > 0
		Inner Join Items ON d.Product_Code = Items.Product_Code
		Inner Join ItemCategories IC ON Items.CategoryID = IC.CategoryID
		Left Join Tax T ON bp.GRNTaxID = T.Tax_Code
		Where d.DispatchID in 
				(	
					Select Distinct DispatchID From DispatchAbstract da 
					Left Outer Join InvoiceAbstract invabs ON da.InvoiceID = invabs.InvoiceID and da.Status & 192 = 0 
																and invabs.Status & 192 = 0 
					Where da.Status & 3 <> 0 and DispatchDate < DateAdd(d, 1, @FROMDATE) and 
					( (isnull(da.InvoiceID, 0)=0 and da.Status & 448=0 ) or 
					( isnull(da.InvoiceID, 0)<>0 and da.Status & 320=0 and 
					dbo.StripDateFromTime(DispatchDate) < dbo.StripDateFromTime(InvoiceDate)) )
				)			
			 And Items.Product_Code = I.Product_Code 
		--Group by IsNull(bp.TOQ,0)
		) A ),

		--[Total Tax Value] - GST Changes
		(Select Sum(isnull(TotalTaxValue,0)) From
			(Select 
			Case When isnull(T.CS_TaxCode,0) > 0 and isnull(Batch_Products.GRNTaxID,0) > 0 Then
				isnull(dbo.Fn_openingbal_TaxCompCalc(I.Product_Code, T.Tax_Code,
				Case When isnull(Batch_Products.TaxType,0) = 5 Then isnull(Batch_Products.GSTTaxType,0) Else isnull(Batch_Products.TaxType,1) End,
				(Case @StockVal   
					When 'PTS' Then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End) * isnull(Quantity,0) 
					When 'PTR' Then (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End) * isnull(Quantity,0)
					Else (Case @UOM When 'Base UOM' Then isnull(Quantity,0) When 'UOM 1'  Then isnull(Quantity,0)
								When 'UOM 2'  Then isnull(Quantity,0) End) 
						* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End)
					End),					
					isnull(Quantity,0),1,0),0)
			Else
				(Case @StockVal   
					When 'PTS' Then (Case  Isnull(Batch_Products.TOQ, 0) When 0 then ( isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTS, 0) Else Isnull(Items.PTS, 0) End)) Else isnull(Quantity,0) End) 
					When 'PTR' Then (Case  Isnull(Batch_Products.TOQ, 0) When 0 then(isnull(Quantity,0) 
							* (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PTR, 0) Else Isnull(Items.PTR, 0) End)) Else isnull(Quantity,0) End )
					Else (Case @UOM When 'Base UOM' Then isnull(Quantity,0) When 'UOM 1'  Then isnull(Quantity,0)
										When 'UOM 2'  Then isnull(Quantity,0) End) 
						* (Case  Isnull(Batch_Products.TOQ, 0) When 0 then  (Case IC.Price_Option When 1 Then Isnull(Batch_Products.PurchasePrice,0) Else Isnull(Items.Purchase_Price,0) End) Else 1 End)

					End) 
						* (Case  Isnull(Batch_Products.TOQ, 0) When 0 then ((Case  isNull(Batch_Products.GRNTaxSuffered,0) When 0 Then isNull(Batch_Products.TaxSuffered,0) Else isNull(Batch_Products.GRNTaxSuffered,0) End) /100)
								Else (Case  isNull(Batch_Products.GRNTaxSuffered,0) When 0 Then isNull(Batch_Products.TaxSuffered,0) Else isNull(Batch_Products.GRNTaxSuffered,0) End) End)
			End TotalTaxValue

		From Batch_Products	
		Inner Join Items ON Batch_Products.Product_Code = Items.Product_Code
		Inner Join ItemCategories IC ON Items.CategoryID = IC.CategoryID
		Left Join Tax T ON Batch_Products.GRNTaxID = T.Tax_Code
		Where   
			Batch_Products.Product_Code = I.Product_Code and isNull(Free,0)=0
		
		) A ),  
		0,0,0,0,0,0
		From Items I Join ItemCategories on I.categoryID = ItemCategories.CategoryID
		Join #tmpCategories T on I.categoryID = T.LeafLevelCat 
		Join #tempCategory1 T1 on I.CategoryID = T1.CategoryID 
		Join #tmpItems on I.Product_Code = #tmpItems.Product_Code
		Join #tmpStockItems on I.Product_Code = #tmpStockItems.ProdCode
		Left Outer Join Batch_Products BP on I.Product_Code = BP.Product_Code 
		Group By 
		I.Product_Code,I.ProductName,T.CatName ,I.UOM,I.UOM1,I.UOM2,T1.IDS
		Order By T1.IDS

	End

	Update #tmpAvailableStock Set [Saleable Stock Value With Tax] =isNull([Saleable Stock Value without Tax],0) + isNull([Saleable Stock Tax Value],0),
		     					  [Damage Stock Value With tax] = isNull([Damage Stock Value without Tax],0) + isNull([Damage Stock Tax Value],0),
		     					  [SIT Value With Tax] = isNull([SIT Value without Tax],0) + isNull([SIT Stock Tax Value],0),
		     					  [VAN Stock Value With Tax] = isNull([VAN Stock Value without Tax],0) + isNull([VAN Stock Tax Value],0),
		     					  [Stock in Dispatch Value With Tax] = isNull([Stock in Dispatch Value with Out Tax],0) + isNull([Stock in Dispatch Tax Value],0),
								  [Total Stock on Hand Value With Tax] = isNull([Total Stock on Hand Value without Tax],0)  + isNull([Total Tax Value],0)
		

	Set @SQL = 'Select [ItemCode],[Item Code],[Item Name], [' + @CatLevel + 
		'] ,UOM ,(Case isNull([Saleable Stock(Qty)],0) When 0 Then 0 Else  [Saleable Stock(Qty)] End) As [Saleable Stock(Qty)], 
		(Case isNull([Free Stock(Qty)],0) When 0 Then 0 Else [Free Stock(Qty)] End)  As  [Free Stock(Qty)],
		(Case isNull([Damage Stock(Qty)],0) When 0 Then 0 Else [Damage Stock(Qty)] End) As [Damage Stock(Qty)],

		(Case isNull([SIT Quantity], 0) When 0 Then 0 Else [SIT Quantity] End) As [SIT Quantity], 
		(Case isNull([Stock in VAN], 0) When 0 Then 0 Else [Stock in VAN] End)  As [Stock in VAN],
		(Case isNull([Stock in Dispatch], 0) When 0 Then 0 Else [Stock in Dispatch] End) As [Stock in Dispatch],

		(Case isNull([Total Stock on Hand(Qty)],0)When 0 Then 0 Else [Total Stock on Hand(Qty)] End) As [Total Stock on Hand(Qty)] ,
		(Case isNull([Saleable Stock Value without Tax],0) When 0 Then 0 Else [Saleable Stock Value without Tax] End) As [Saleable Stock Value without Tax] ,
		(Case isNull([Damage Stock Value without Tax],0) When 0 Then 0 Else [Damage Stock Value without Tax] End) As [Damage Stock Value without Tax] ,

		(Case isNull([SIT Value without Tax], 0) When 0 Then 0 Else [SIT Value without Tax] End) As [SIT Value without Tax],
		(Case isNull([VAN Stock Value without Tax], 0) When 0 Then 0 Else [VAN Stock Value without Tax] End) As [VAN Stock Value without Tax],
		(Case isNull([Stock in Dispatch Value with Out Tax], 0) When 0 Then 0 Else [Stock in Dispatch Value with Out Tax] End) As [Stock in Dispatch Value with Out Tax],

		(Case isNull([Total Stock on Hand Value without Tax],0) When 0 Then 0 Else  [Total Stock on Hand Value without Tax] End) As	[Total Stock on Hand Value without Tax] ,
		(Case isNull([Saleable Stock Tax Value],0) When 0 Then 0 Else  [Saleable Stock Tax Value] End) As [Saleable Stock Tax Value] ,
		(Case isNull([Damage Stock Tax Value],0) When 0 Then 0 Else  [Damage Stock Tax Value] End) As   [Damage Stock Tax Value] ,

		(Case isNull([SIT Stock Tax Value], 0) When 0 Then 0 Else [SIT Stock Tax Value] End) As [SIT Stock Tax Value],
		(Case isNull([VAN Stock Tax Value], 0) When 0 Then 0 Else [VAN Stock Tax Value] End) As [VAN Stock Tax Value],
		(Case isNull([Stock in Dispatch Tax Value], 0) When 0 Then 0 Else [Stock in Dispatch Tax Value] End) As [Stock in Dispatch Tax Value],

		(Case isNull([Total Tax Value],0) When 0 Then 0 Else [Total Tax Value] End) As [Total Tax Value] ,
		(Case isNull([Saleable Stock Value With Tax],0) When 0 Then 0 Else  [Saleable Stock Value With Tax] End) As	[Saleable Stock Value With Tax] ,
		(Case isNull([Damage Stock Value With tax],0) When 0 Then 0 Else  [Damage Stock Value With tax] End) As  [Damage Stock Value With tax] ,

		(Case isNull([SIT Value With Tax], 0) When 0 Then 0 Else [SIT Value With Tax] End) As [SIT Value With Tax],
		(Case isNull([VAN Stock Value With Tax], 0) When 0 Then 0 Else [VAN Stock Value With Tax] End) As [VAN Stock Value With Tax],
		(Case isNull([Stock in Dispatch Value With Tax], 0) When 0 Then 0 Else [Stock in Dispatch Value With Tax] End) As [Stock in Dispatch Value With Tax],

		(Case isNull([Total Stock on Hand Value With Tax],0) When 0 Then 0 Else [Total Stock on Hand Value With Tax] End) As [Total Stock on Hand Value With Tax] 
		From #tmpAvailableStock' 
End

	Exec sp_ExecuteSql @SQL

	Drop Table #tempCategoryList
	Drop table #tempCategory 
	Drop Table #tmpCategories
	Drop Table #tmpAvailableStock
	Drop Table #tmpItems
	Drop table #tmpStockItems
	Drop table #tmptotal_Invd_qty
	Drop table #tmptotal_rcvd_qty	
End
