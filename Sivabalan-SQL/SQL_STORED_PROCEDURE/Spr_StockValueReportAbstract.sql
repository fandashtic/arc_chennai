CREATE PROCEDURE [dbo].[Spr_StockValueReportAbstract]  
(
	@Mfr nVarchar(4000),
	@CATEGORYGROUP nVarchar(4000),
	@CATEGORYLevel nVarchar(4000),
	@Division NVARCHAR(4000),
	@ItemCode NVARCHAR(4000),
	@WithStock NVARCHAR(4000),
	@UOM NVARCHAR(4000)
)
AS
Begin

	Declare @Delimeter Char(1) 
	Set @Delimeter = Char(15) 
	Declare @nWithStock as Int

	Create Table #tmpMfr(Manufacturer nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
	Create Table #tmpDiv(Division nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
	Create Table #tmpProd(Product_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 
   	Create Table #tmpGRP(GroupName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 

	Create Table #Tmp (Batch_Code Int,
	Batch_Number Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	Product_Code Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	ProductName Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	UOM Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	SalebleQuantity Decimal(18,6),
	SalebleStockValue Decimal(18,6),
	DamageQuantity Decimal(18,6),
	DamageStockValue Decimal(18,6),
	FreeQuantity Decimal(18,6),
	FreeStockValue Decimal(18,6),
	NetStockValueWithTax Decimal(18,6))

	Create Table #TmpCat (
	Product_Code Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	Division Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	SubCategory Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	MarketSKU Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	GroupName Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS)

	If @Mfr = N'%' 
	   Insert InTo #tmpMfr Select Manufacturer_Name From Manufacturer 
	Else          
	   Insert InTo #tmpMfr Select * From dbo.sp_SplitIn2Rows(@Mfr, @Delimeter)  

	If @CATEGORYGROUP = N'%' 
	   Insert InTo #tmpGRP Select GroupName From ProductCategoryGroupAbstract 
	Else          
	   Insert InTo #tmpGRP Select * From dbo.sp_SplitIn2Rows(@CATEGORYGROUP, @Delimeter)  

	If @Division = N'%' 
	   Insert InTo #tmpDiv Select BrandName From Brand 
	Else          
	   Insert InTo #tmpDiv Select * From dbo.sp_SplitIn2Rows(@Division, @Delimeter) 
	    
	If @ItemCode = N'%' 
	 Insert InTo #tmpProd Select Product_code From Items    
	Else    
	 Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)   

	If @WithStock = N'Items With Stock'
		Set @nWithStock = 1
	Else
		Set @nWithStock = 0

	Insert Into #Tmp(Batch_Code,Batch_Number,Product_Code,ProductName,SalebleQuantity,SalebleStockValue,NetStockValueWithTax) 
	select Distinct Batch_Code,Batch_Number,batch_products.Product_Code,Null,
	Isnull((Case 
		When @UOM = 'UOM2' Then (cast((Quantity / Isnull(Items.UOM2_Conversion,1)) as Decimal(18,6)))
		When @UOM = 'UOM1' Then (cast((Quantity / Isnull(Items.UOM1_Conversion,1)) as Decimal(18,6)))
		Else  (Quantity) End),0) Quantity,
	cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) ,
	cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) + (cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) * (Isnull(batch_products.TaxSuffered,0) / 100))  NetStockValueWithTax  
	from  batch_products,Items Where Isnull(Damage,0) = 0 And Isnull(Free,0) = 0 and Items.Product_Code = batch_products.Product_Code
	And batch_products.Product_Code In (Select Distinct Product_Code From #tmpProd)

	Insert Into #Tmp(Batch_Code,Batch_Number,Product_Code,ProductName,DamageQuantity,DamageStockValue,NetStockValueWithTax) 
	select Distinct Batch_Code,Batch_Number,batch_products.Product_Code,Null,
	Isnull((Case 
		When @UOM = 'UOM2' Then (cast((Quantity / Isnull(Items.UOM2_Conversion,1)) as Decimal(18,6)))
		When @UOM = 'UOM1' Then (cast((Quantity / Isnull(Items.UOM1_Conversion,1)) as Decimal(18,6)))
		Else  (Quantity) End),0) Quantity,
	cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) ,
	cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) + (cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) * (Isnull(batch_products.TaxSuffered,0) / 100))  NetStockValueWithTax  
	from  batch_products,Items Where Isnull(Damage,0) <> 0 and Items.Product_Code = batch_products.Product_Code
	And batch_products.Product_Code In (Select Distinct Product_Code From #tmpProd)

	Insert Into #Tmp(Batch_Code,Batch_Number,Product_Code,ProductName,FreeQuantity,FreeStockValue,NetStockValueWithTax) 
	select Distinct Batch_Code,Batch_Number,batch_products.Product_Code,Null,
	Isnull((Case 
		When @UOM = 'UOM2' Then (cast((Quantity / Isnull(Items.UOM2_Conversion,1)) as Decimal(18,6)))
		When @UOM = 'UOM1' Then (cast((Quantity / Isnull(Items.UOM1_Conversion,1)) as Decimal(18,6)))
		Else  (Quantity) End),0) Quantity,
	cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) ,
	cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) + (cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) * (Isnull(batch_products.TaxSuffered,0) / 100))  NetStockValueWithTax  
	from  batch_products,Items Where Isnull(Free,0) <> 0 and Items.Product_Code = batch_products.Product_Code
	And batch_products.Product_Code In (Select Distinct Product_Code From #tmpProd)

	if Isnull(@nWithStock,0) = 1
	Delete from #Tmp Where (Isnull(SalebleQuantity,0) + Isnull(DamageQuantity,0) + Isnull(FreeQuantity,0)) = 0

	Delete From #TmpCat Where GroupName Not In (Select Distinct GroupName From #tmpGrp)
	Delete From #TmpCat Where Product_Code Not In (Select Distinct Product_Code From #tmpProd)
	Delete From #TmpCat Where Division Not In (Select Distinct Division From #tmpDiv)
	Delete From #TmpCat Where Product_Code Not In (Select Distinct Product_Code From Items Where ManufacturerID in (Select Distinct ManufacturerID From Manufacturer Where Manufacturer_Name in (Select Manufacturer From #tmpMfr)))

	Update T Set T.UOM = (Case When @UOM = 'UOM2' Then U.UOM2 When @UOM = 'UOM1' Then U.UOM1 Else U.UOM End) From #Tmp T,
	(Select Distinct I.Product_Code,U.Description UOM,U1.Description UOM1,U2.Description UOM2 From Items I,UOM U,UOM U1,UOM U2
	Where I.UOM = U.UOM
	And I.UOM1 = U1.UOM
	And I.UOM2 = U2.UOM) U
	Where T.Product_Code = U.Product_Code

	Update T set T.ProductName = T1.ProductName From #Tmp t,Items T1
	Where T.Product_Code = T1.Product_Code

	IF (select Isnull(Flag,0) from Tbl_Merp_Configabstract Where Screencode = 'OCGDS') = 0
	Begin
		insert Into #TmpCat
		select I.Product_code, IC2.Category_Name,IC3.Category_Name, IC4.Category_Name, GR.Categorygroup 
		from items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 where
		IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
		and IC2.Category_Name = GR.Division
	End
	Else
	Begin
		insert Into #TmpCat
		Select Distinct SystemSKU,Division,SubCategory,MarketSKU,GroupName from OCGItemMaster Where isnull(Exclusion,0) = 0
	End

	Select (T.Product_code + ',' +  cast(@nWithStock as Nvarchar(10)) + ',' + @UOM) Details,C.GroupName,C.Division,C.SubCategory,C.MarketSKU,T.Product_code [Item Code],T.ProductName [Item Name],T.UOM,
	Sum(Isnull(T.SalebleQuantity,0))SalebleQuantity,
	Sum(Isnull(T.SalebleStockValue,0)) SalebleStockValue,
	Sum(Isnull(T.DamageQuantity,0))DamageQuantity,
	Sum(Isnull(T.DamageStockValue,0)) DamageStockValue,
	Sum(Isnull(T.FreeQuantity,0))FreeQuantity,
	Sum(Isnull(T.FreeStockValue,0)) FreeStockValue,
	(Case When C.Division = 'CG' Then Sum(Isnull(T.NetStockValueWithTax,0)) Else 0 End) NetStockValueWithTax,
	(Convert(Nvarchar(10),Getdate(),103) + ' ' + Convert(Nvarchar(10),Getdate(),108)) ReportGenerationDate
	From #Tmp t,#TmpCat C
	Where T.Product_code = C.Product_code
	Group By C.GroupName,C.Division,C.SubCategory,C.MarketSKU,T.Product_code,T.ProductName,T.UOM

	Drop Table #Tmp 
	Drop Table #TmpCat
	Drop Table #tmpMfr
	Drop Table #tmpDiv
	Drop Table #tmpProd
	Drop Table #tmpGRP

End
