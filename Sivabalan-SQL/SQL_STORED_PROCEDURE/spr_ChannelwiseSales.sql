Create Procedure spr_ChannelwiseSales (@PRODUCT_HIERARCHY Varchar(255),@CATEGORY NVARCHAR(255),@PRODUCTCODE NVARCHAR(400),@FROMDATE DATETIME,@TODATE DATETIME,@Sales Varchar(20),@UOM NVarchar(20))       
As  
Begin  
--Declaration    
	Declare @ChannelType Int    
	Declare @ProdCode nVarchar(255)  
	Declare @ChannelDesc Nvarchar(255)        
	Declare @StrPivotSql nVarChar(4000)  
	Declare @UOMTYPE nVarChar(200)      
	Declare @Delimeter as Char(1)  
	Declare @CatID As Int          
	Set @Delimeter=Char(15)        
	create table #tempProduct(ProdCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
	Create Table #tempCategory(CategoryID int, Status int)                  
	Exec GetLeafCategories @PRODUCT_HIERARCHY, @CATEGORY    
	Create Table #tmpCategories(CatLevel Int, CatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, LeafLevelCat Int)  
	Create table #tmpProdDetails(ProdCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CompanyID int, DivisionID int, SubCategoryID int,MSKUID int, Company nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, MSKU nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	if @productcode='%' or @productcode=''           
		 insert into #tempProduct select product_code from items        
	Else          
		Insert into #tempProduct select * from dbo.sp_SplitIn2Rows(@productcode,@Delimeter) 
	If @PRODUCT_HIERARCHY = '%'
		Set @PRODUCT_HIERARCHY = N'Company'
	If @PRODUCT_HIERARCHY = 'Sub-Category' or @PRODUCT_HIERARCHY = 'Sub Category'
		Set @PRODUCT_HIERARCHY = N'Sub_Category'
	If @PRODUCT_HIERARCHY = 'MarketSKU' or @PRODUCT_HIERARCHY = 'Market-SKU' or @PRODUCT_HIERARCHY = 'Market SKU'
		Set @PRODUCT_HIERARCHY = N'Market_SKU' 
	If @PRODUCT_HIERARCHY = 'System_SKU'or @PRODUCT_HIERARCHY = 'System-SKU' or @PRODUCT_HIERARCHY = 'SystemSKU'
		set @PRODUCT_HIERARCHY = 'System SKU'  
	If @Sales = '%'
		Set @Sales = N'Value'
	If @UOM = '%'
		Set @UOMTYPE = N'Base UOM'
	else if @UOM = 'UOM 1'
		Set @UOMTYPE = N'UOM1'
	else if @UOM = 'UOM 2'
		Set @UOMTYPE = N'UOM1'
	else
		set @UOMTYPE = @UOM
	If @Sales = 'Volume' And @UOM = 'N/A'
		Set @UOM = N'Base UOM'
	IF @PRODUCT_HIERARCHY = 'System SKU'  
	Begin  
		If @CATEGORY = '%'  
			Insert Into #tmpCategories(CatLevel , CatName , LeafLevelCat)  
			Select Distinct IT.CategoryID, Category_Name,IT.CategoryID  
			From Items IT,ItemCategories ITC  
			Where IT.CategoryID = ITC.CategoryID  
		Else  
			Insert Into  #tmpCategories(CatLevel , CatName , LeafLevelCat)  
			Select Distinct IT.CategoryID, Category_Name,IT.CategoryID  
			From Items IT,ItemCategories ITC  
			Where IT.CategoryID = ITC.CategoryID  
			And IT.ProductName In  
			(Select * From dbo.sp_SplitIn2Rows(@CATEGORY, @Delimeter))  
	End  
	Create Table #ChannelWiseItemSales    
	(    
	ChannelID Int,    
	ItemCode nvarChar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,    
	Qty Decimal(18,6),Amount Decimal(18,6)    
	)  
	if @PRODUCT_HIERARCHY = 'System SKU'   
	Begin  
		 Insert Into #ChannelWiseItemSales (ChannelID,ItemCode,Qty,Amount)    
		 select tmo.Channel_Type_code ,IT.Product_Code, Sum(Case IA.InvoiceType  
		When 4 Then 0 - (IDT.Quantity)Else IDT.Quantity End),Sum(Case IA.InvoiceType  
		When 4 Then 0 - (IDT.Amount)Else IDT.Amount End)     
		 From InvoiceAbstract IA, InvoiceDetail IDT,Items IT, tbl_merp_olclassmapping tmol,tbl_merp_olclass tmo    
		 Where     
		 IsNull(IA.Status,0) & 128 = 0    
		 And IA.InvoiceType IN (1,3,4)    
		 And IA.InvoiceDate Between @FromDate And @ToDate    
		 And IDT.Product_Code IN (Select ProdCode From #tempProduct)    
		 --And IT.CategoryID IN (select categoryID From #tempCategory)    
		 And IA.InvoiceID = IDT.InvoiceID    
		 And IDT.Product_Code = IT.Product_Code    
		 And IA.CustomerID = tmol.CustomerID    
		 and tmol.olclassid = tmo.id  
		 Group By tmo.Channel_Type_code, IT.Product_Code   
		 Declare ProdCur Cursor For  
		 Select Distinct ItemCode from #ChannelWiseItemSales  
		 Open ProdCur  
		 Fetch From ProdCur Into @ProdCode  
		 While @@Fetch_Status = 0  
		 Begin  
			 Insert Into #tmpProdDetails (ProdCode, CompanyId, DivisionID, SubCategoryID, MSKUID, Company, Division, SubCategory, MSKU)  
			 Select @ProdCode, A.CategoryID As CompanyID, B.CategoryID As DivisionID, C.CategoryID as SubCategoryID, D.CategoryID as MSKUID,  
			 A.Category_Name As Company, B.Category_Name As Division, C.Category_Name As SubCategory, D.Category_name  As MarketSku  
			 from ItemCategories A, ItemCategories B,ItemCategories C, ItemCategories D  
			 where A.CategoryID = B.ParentID and  
			 B.CategoryID = C.parentID  
			 and C.CategoryID = D.ParentID  
			 and D.CategoryID in  
			 (Select CategoryID from Items Where Product_code = @ProdCode)  
			 Fetch Next From ProdCur Into @ProdCode  
		 End  
		 Close ProdCur  
		 Deallocate ProdCur   
		 if @Sales = 'Volume'  
		 Begin  
			 Set @StrPivotSql = 'Select 1, t1.ItemCode As "Item Code",     
			 Max(IT.ProductName) As "Item Name", Max(U.[Description]) As "UOM" '    
			 DECLARE Channel_Cursor CURSOR FOR    
			 SELECT  Distinct Channel_Type_code,Channel_type_Desc FROM tbl_merp_olclass     
			 OPEN Channel_Cursor    
			 FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
			 WHILE @@FETCH_STATUS = 0    
			 BEGIN    
			  Set @StrPivotSql = @StrPivotSql + ', Sum(Case t1.ChannelID When ' + Cast(@ChannelType As nVarChar) + ' Then (Case ''' + @UOMTYPE +''' when ''Base UOM'' then t1.Qty when ''UOM1'' then t1.Qty/IT.Uom1_Conversion when ''UOM2'' then t1.Qty/IT.Uom2_Conversion
			 end) Else 0 End) As "' + @ChannelDesc + '"'    
			  FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
			 END    
			 CLOSE Channel_Cursor    
			 DEALLOCATE Channel_Cursor   
			 Set @StrPivotSql = @StrPivotSql + ',(Case ''' + @UOMTYPE +''' when ''Base UOM'' then Sum(t1.Qty) when ''UOM1'' then Sum(t1.Qty)/IT.Uom1_Conversion when ''UOM2'' then Sum(t1.Qty)/IT.Uom2_Conversion end) As TotalQtySold '+' , '+' T2.Company As [Company] '+
			' , '+ 'T2.Division As [Division]' +' , '+' T2.SubCategory As [Sub_Category]'+' , '+' T2.MSKU As [MarketSKU]  
			 From Itemcategories IC, Items IT, UOM U , #tmpProdDetails T2, #ChannelWiseItemSales T1    
			 Where t1.ItemCode = IT.Product_Code And IT.CategoryID = IC.CategoryID And IT.UOM2= U.UOM and T1.ItemCode = T2.prodcode    
			 Group By t1.ItemCode,T2.Company,T2.Division,T2.SubCategory,T2.MSKU,it.uom2_conversion,it.uom1_conversion'  
		End  
		else if @Sales = 'Value'    
		Begin  
			 Set @StrPivotSql = 'Select 1, t1.ItemCode As "Item Code",     
			 Max(IT.ProductName) As "Item Name"'    
			 DECLARE Channel_Cursor CURSOR FOR    
			 SELECT  Distinct Channel_Type_code,Channel_type_Desc FROM tbl_merp_olclass     
			 OPEN Channel_Cursor    
			 FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
			 WHILE @@FETCH_STATUS = 0    
			 BEGIN    
				Set @StrPivotSql = @StrPivotSql + ', Sum(Case t1.ChannelID When ' + Cast(@ChannelType As nVarChar) + ' Then t1.Amount Else 0 End) As "' + @ChannelDesc + '"'    
				FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
			 END    
			 CLOSE Channel_Cursor    
			 DEALLOCATE Channel_Cursor   
			 Set @StrPivotSql = @StrPivotSql + ', Sum(t1.Amount) As TotalValue '+' , '+' T2.Company As [Company] '+' , '+ 'T2.Division As [Division]' +' , '+' T2.SubCategory As [Sub_Category] '+' , '+' T2.MSKU As [MarketSKU]  
			 From Itemcategories IC, Items IT, UOM U , #tmpProdDetails T2, #ChannelWiseItemSales T1    
			 Where t1.ItemCode = IT.Product_Code And IT.CategoryID = IC.CategoryID And IT.UOM = U.UOM and T1.ItemCode = T2.prodcode    
			 Group By t1.ItemCode,T2.Company,T2.Division,T2.SubCategory,T2.MSKU'  
		End  
		End  
	Else  
	Begin  
		Insert Into #ChannelWiseItemSales (ChannelID,ItemCode,Qty,Amount)    
		 select tmo.Channel_Type_code ,IT.Product_Code, sum(Case IA.InvoiceType  
		When 4 Then (0 - IDT.Quantity) Else IDT.Quantity End)/(Case  @UOMTYPE  when 'Base UOM' then 1 when 'UOM1' then IT.Uom1_Conversion when 'UOM2' then IT.Uom2_Conversion end) ,Sum(Case IA.InvoiceType  
		When 4 Then (0 - IDT.Amount)Else IDT.Amount End)       
		 From InvoiceAbstract IA, InvoiceDetail IDT,Items IT, tbl_merp_olclassmapping tmol,tbl_merp_olclass tmo    
		 Where IsNull(IA.Status,0) & 128 = 0    
		 And IA.InvoiceType IN (1,3,4)    
		 And IA.InvoiceDate Between @FromDate And @ToDate    
		 And IDT.Product_Code IN (Select ProdCode From #tempProduct)    
		 And IT.CategoryID IN (select categoryID From #tempCategory)    
		 And IA.InvoiceID = IDT.InvoiceID    
		 And IDT.Product_Code = IT.Product_Code    
		 And IA.CustomerID = tmol.CustomerID    
		 and tmol.olclassid = tmo.id  
		 Group By tmo.Channel_Type_code, IT.Product_Code ,IT.Uom1_Conversion,IT.Uom2_Conversion   
		 Begin  
			 Declare ProdCur Cursor For  
			 Select Distinct ItemCode from #ChannelWiseItemSales  
			 Open ProdCur  
			 Fetch From ProdCur Into @ProdCode  
			 While @@Fetch_Status = 0  
			 Begin  
				 Insert Into #tmpProdDetails (ProdCode, CompanyId, DivisionID, SubCategoryID, MSKUID, Company, Division, SubCategory, MSKU)  
				 Select @ProdCode, A.CategoryID As CompanyID, B.CategoryID As DivisionID, C.CategoryID as SubCategoryID, D.CategoryID as MSKUID,  
				 A.Category_Name As Company, B.Category_Name As Division, C.Category_Name As SubCategory, D.Category_name  As MarketSku  
				 from ItemCategories A, ItemCategories B,ItemCategories C, ItemCategories D  
				 where A.CategoryID = B.ParentID and  
				 B.CategoryID = C.parentID  
				 and C.CategoryID = D.ParentID  
				 and D.CategoryID in  
				 (Select CategoryID from Items Where Product_code = @ProdCode)  
				 Fetch Next From ProdCur Into @ProdCode  
			 End  
			 Close ProdCur  
			 Deallocate ProdCur  
			 if @PRODUCT_HIERARCHY = 'Market_SKU' and @Sales = 'Volume'   
			 Begin  
				  Set @StrPivotSql = 'Select 1, IC.Category_Name As "Category"'    
				  DECLARE Channel_Cursor CURSOR FOR    
				  SELECT  Distinct Channel_Type_code,Channel_type_Desc FROM tbl_merp_olclass     
				  OPEN Channel_Cursor    
				  FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  WHILE @@FETCH_STATUS = 0    
				  BEGIN    
					   Set @StrPivotSql = @StrPivotSql + ', Sum(Case t1.ChannelID When ' + Cast(@ChannelType As nVarChar) + ' Then t1.Qty Else 0 End) As "' + @ChannelDesc + '"'    
					   FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  END    
				  CLOSE Channel_Cursor    
				  DEALLOCATE Channel_Cursor    
				  Set @StrPivotSql = @StrPivotSql + ', Sum(t1.Qty) As TotalQtySold '+' , '+' T2.Company As [Company] '+' , '+ 'T2.Division As [Division]' +' , '+' T2.SubCategory As [Sub_Category]  
				  From Itemcategories IC, Items IT, UOM U , #tmpProdDetails T2, #ChannelWiseItemSales T1    
				  Where t1.ItemCode = IT.Product_Code And IT.CategoryID = IC.CategoryID And IT.UOM = U.UOM and T1.ItemCode = T2.prodcode    
				  Group By T2.Company,T2.Division,T2.SubCategory, IC.Category_Name'    
			 End  
			else if @PRODUCT_HIERARCHY = 'Market_SKU' and @Sales = 'Value'   
			Begin  
				  Set @StrPivotSql = 'Select 1, IC.Category_Name As "Category"'    
				  DECLARE Channel_Cursor CURSOR FOR    
				  SELECT  Distinct Channel_Type_code,Channel_type_Desc FROM tbl_merp_olclass     
				  OPEN Channel_Cursor    
				  FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  WHILE @@FETCH_STATUS = 0    
				  BEGIN    
				   Set @StrPivotSql = @StrPivotSql + ', Sum(Case t1.ChannelID When ' + Cast(@ChannelType As nVarChar) + ' Then t1.Amount Else 0 End) As "' + @ChannelDesc + '"'    
				   FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  END    
				  CLOSE Channel_Cursor    
				  DEALLOCATE Channel_Cursor    
				  Set @StrPivotSql = @StrPivotSql + ', Sum(t1.Amount) As TotalValue '+' , '+' T2.Company As [Company] '+' , '+ 'T2.Division As [Division]' +' , '+' T2.SubCategory As [Sub_Category]  
				  From Itemcategories IC, Items IT, UOM U , #tmpProdDetails T2, #ChannelWiseItemSales T1    
				  Where t1.ItemCode = IT.Product_Code And IT.CategoryID = IC.CategoryID And IT.UOM = U.UOM and T1.ItemCode = T2.prodcode    
				  Group By T2.Company,T2.Division,T2.SubCategory, IC.Category_Name'    
			 End  
			 Else if @PRODUCT_HIERARCHY = 'Sub_category' and @Sales = 'Volume'   
			 Begin  
				  Set @StrPivotSql = 'Select 1, Max(T2.SubCategory) As "Category"'    
				  DECLARE Channel_Cursor CURSOR FOR    
				  SELECT  Distinct Channel_Type_code,Channel_type_Desc FROM tbl_merp_olclass     
				  OPEN Channel_Cursor    
				  FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  WHILE @@FETCH_STATUS = 0    
				  BEGIN    
				   Set @StrPivotSql = @StrPivotSql + ', Sum(Case t1.ChannelID When ' + Cast(@ChannelType As nVarChar) + ' Then t1.Qty Else 0 End) As "' + @ChannelDesc + '"'    
				   FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  END    
				  CLOSE Channel_Cursor    
				  DEALLOCATE Channel_Cursor    
				  Set @StrPivotSql = @StrPivotSql + ', Sum(t1.Qty) As TotalQtySold '+' , '+' T2.Company As [Company] '+' , '+ 'T2.Division As [Division]  
				  From Itemcategories IC, Items IT, UOM U , #tmpProdDetails T2, #ChannelWiseItemSales T1    
				  Where t1.ItemCode = IT.Product_Code And IT.CategoryID = IC.CategoryID And IT.UOM = U.UOM and T1.ItemCode = T2.prodcode    
				  Group By T2.Company,T2.Division,T2.SubCategory'    
			 End  
			Else if @PRODUCT_HIERARCHY = 'Sub_category' and @Sales = 'Value'   
			 Begin  
				  Set @StrPivotSql = 'Select 1, Max(T2.SubCategory) As "Category"'    
				  DECLARE Channel_Cursor CURSOR FOR    
				  SELECT  Distinct Channel_Type_code,Channel_type_Desc FROM tbl_merp_olclass     
				  OPEN Channel_Cursor    
				  FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  WHILE @@FETCH_STATUS = 0    
				  BEGIN    
				   Set @StrPivotSql = @StrPivotSql + ', Sum(Case t1.ChannelID When ' + Cast(@ChannelType As nVarChar) + ' Then t1.Amount Else 0 End) As "' + @ChannelDesc + '"'    
				   FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  END    
				  CLOSE Channel_Cursor    
				  DEALLOCATE Channel_Cursor    
				  Set @StrPivotSql = @StrPivotSql + ', Sum(t1.Amount) As TotalValue '+' , '+' T2.Company As [Company] '+' , '+ 'T2.Division As [Division]  
				  From Itemcategories IC, Items IT, UOM U , #tmpProdDetails T2, #ChannelWiseItemSales T1    
				  Where t1.ItemCode = IT.Product_Code And IT.CategoryID = IC.CategoryID And IT.UOM = U.UOM and T1.ItemCode = T2.prodcode    
				  Group By T2.Company,T2.Division,T2.SubCategory'    
			 End  
			Else if @PRODUCT_HIERARCHY = 'Division' and @Sales = 'Volume'  
			 Begin  
				  Set @StrPivotSql = 'Select 1, Max(T2.Division) As "Category"'    
				  DECLARE Channel_Cursor CURSOR FOR    
				  SELECT  Distinct Channel_Type_code,Channel_type_Desc FROM tbl_merp_olclass     
				  OPEN Channel_Cursor    
				  FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  WHILE @@FETCH_STATUS = 0    
				  BEGIN    
				   Set @StrPivotSql = @StrPivotSql + ', Sum(Case t1.ChannelID When ' + Cast(@ChannelType As nVarChar) + ' Then t1.Qty Else 0 End) As "' + @ChannelDesc + '"'    
				   FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  END    
				  CLOSE Channel_Cursor    
				  DEALLOCATE Channel_Cursor    
				  Set @StrPivotSql = @StrPivotSql + ', Sum(t1.Qty) As TotalQtySold '+' , '+' T2.Company As [Company]  
				  From Itemcategories IC, Items IT, UOM U , #tmpProdDetails T2, #ChannelWiseItemSales T1    
				  Where t1.ItemCode = IT.Product_Code And IT.CategoryID = IC.CategoryID And IT.UOM = U.UOM and T1.ItemCode = T2.prodcode    
				  Group By T2.Company,T2.Division'    
			 End  
			Else if @PRODUCT_HIERARCHY = 'Division' and @Sales = 'Value'  
			 Begin  
				  Set @StrPivotSql = 'Select 1, Max(T2.Division) As "Category"'    
				  DECLARE Channel_Cursor CURSOR FOR    
				  SELECT  Distinct Channel_Type_code,Channel_type_Desc FROM tbl_merp_olclass     
				  OPEN Channel_Cursor    
				  FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  WHILE @@FETCH_STATUS = 0    
				  BEGIN    
				   Set @StrPivotSql = @StrPivotSql + ', Sum(Case t1.ChannelID When ' + Cast(@ChannelType As nVarChar) + ' Then t1.Amount Else 0 End) As "' + @ChannelDesc + '"'    
				   FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  END    
				  CLOSE Channel_Cursor    
				  DEALLOCATE Channel_Cursor    
				  Set @StrPivotSql = @StrPivotSql + ', Sum(t1.Amount) As TotalValue '+' , '+' T2.Company As [Company]  
				  From Itemcategories IC, Items IT, UOM U , #tmpProdDetails T2, #ChannelWiseItemSales T1    
				  Where t1.ItemCode = IT.Product_Code And IT.CategoryID = IC.CategoryID And IT.UOM = U.UOM and T1.ItemCode = T2.prodcode    
				  Group By T2.Company,T2.Division'    
			 End  
			Else if @PRODUCT_HIERARCHY = 'Company' or @PRODUCT_HIERARCHY = '%' or @PRODUCT_HIERARCHY =  ''   
			 Begin  
				If @Sales = 'Volume'  
				Begin  
				  Set @StrPivotSql = 'Select 1, Max(T2.Company) As "Category"'    
				  DECLARE Channel_Cursor CURSOR FOR    
				  SELECT  Distinct Channel_Type_code,Channel_type_Desc FROM tbl_merp_olclass     
				  OPEN Channel_Cursor    
				  FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  WHILE @@FETCH_STATUS = 0    
				  BEGIN    
				   Set @StrPivotSql = @StrPivotSql + ', Sum(Case t1.ChannelID When ' + Cast(@ChannelType As nVarChar) + ' Then t1.Qty Else 0 End) As "' + @ChannelDesc + '"'    
				   FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  END    
				  CLOSE Channel_Cursor    
				  DEALLOCATE Channel_Cursor    
				  Set @StrPivotSql = @StrPivotSql + ', Sum(t1.Qty) As TotalQtySold  
				  From Itemcategories IC, Items IT, UOM U , #tmpProdDetails T2, #ChannelWiseItemSales T1    
				  Where t1.ItemCode = IT.Product_Code And IT.CategoryID = IC.CategoryID And IT.UOM = U.UOM and T1.ItemCode = T2.prodcode    
				  Group By T2.Company'    
				End  
				Else   
				Begin  
				  Set @StrPivotSql = 'Select 1, Max(T2.Company) As "Category"'    
				  DECLARE Channel_Cursor CURSOR FOR    
				  SELECT  Distinct Channel_Type_code,Channel_type_Desc FROM tbl_merp_olclass     
				  OPEN Channel_Cursor    
				  FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  WHILE @@FETCH_STATUS = 0    
				  BEGIN    
				   Set @StrPivotSql = @StrPivotSql + ', Sum(Case t1.ChannelID When ' + Cast(@ChannelType As nVarChar) + ' Then t1.Amount Else 0 End) As "' + @ChannelDesc + '"'    
				   FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc    
				  END    
				  CLOSE Channel_Cursor    
				  DEALLOCATE Channel_Cursor    
				  Set @StrPivotSql = @StrPivotSql + ', Sum(t1.Amount) As TotalValue   
				From Itemcategories IC, Items IT, UOM U , #tmpProdDetails T2, #ChannelWiseItemSales T1    
				  Where t1.ItemCode = IT.Product_Code And IT.CategoryID = IC.CategoryID And IT.UOM = U.UOM and T1.ItemCode = T2.prodcode    
				  Group By T2.Company'    
				End  
			End  
		End   
	End  
	Exec sp_executesql @StrPivotSql
End
Drop Table #tmpProdDetails    
Drop Table #ChannelWiseItemSales    
Drop Table #tempProduct    
Drop Table #tempCategory   
