CREATE procedure [dbo].[spr_salesmanwise_packing_list_Gillete](@SALESMAN nvarchar(256), 
						@UOM nvarchar(100), 
						@FromNo nvarchar(20), @ToNo nvarchar(20),
					        @FROMDATE datetime,
						@TODATE datetime)
AS
DECLARE @SQL nvarchar(1000)
DECLARE @FirstLevel nvarchar(100)  
DECLARE @LastLevel nvarchar(100)  
DECLARE @UOMColumnName nvarchar(100)  
DECLARE @TableName nvarchar(100)  
DECLARE @QtyTableName nvarchar(100)  
Declare @MLOthers NVarchar(50)
Set @MLOthers = dbo.LookupDictionaryItem(N'Others', Default)
  
 SET @FirstLevel = dbo.GetHierarchyColumn('FIRST')
 SET @LastLevel= dbo.GetHierarchyColumn('LAST')
IF @SALESMAN = @MLOthers
BEGIN
IF @FromNo = '%' OR @ToNo = '%'
	BEGIN
		SET @QtyTableName = 'SaleQty'
		Select  "Salesman" = IsNull(Salesman.Salesman_Name, @MLOthers),
		"Product_Code" = InvoiceDetail.Product_Code,
		"Batch" = InvoiceDetail.Batch_Number,
		"Quantity" = Case InvoiceType WHEN 4 THEN 0 - Sum(InvoiceDetail.Quantity) ELSE Sum(InvoiceDetail.Quantity) END 
		INTO #SaleQty
		From	InvoiceAbstract, Salesman, InvoiceDetail
		Where	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
			(InvoiceAbstract.Status & 128) = 0 And 
			InvoiceDetail.InvoiceId = InvoiceAbstract.InvoiceID And
			InvoiceAbstract.InvoiceType in (1, 3, 4) And
			InvoiceAbstract.SalesmanID = 0 
			Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name, InvoiceType, InvoiceDetail.Quantity, InvoiceDetail.Product_Code, InvoiceDetail.Batch_Number	
	END
	ELSE
	BEGIN
		SET @QtyTableName = 'SaleQty1'
		Select  "Salesman" = IsNull(Salesman.Salesman_Name, @MLOthers),
		"Product_Code" = Product_Code,
		"Batch" = InvoiceDetail.Batch_Number,
		"Quantity" = Case InvoiceType WHEN 4 THEN 0 - Sum(Quantity) ELSE Sum(Quantity) END
		INTO #SaleQty1
		From	InvoiceAbstract, Salesman, InvoiceDetail
		Where	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
			(InvoiceAbstract.Status & 128) = 0 And 
			InvoiceDetail.InvoiceId = InvoiceAbstract.InvoiceID And
			InvoiceAbstract.InvoiceType in (1, 3, 4) And
			InvoiceAbstract.SalesmanID = 0 And
			InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)
			Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name, InvoiceType, InvoiceDetail.Quantity, InvoiceDetail.Product_Code, InvoiceDetail.Batch_Number	
	END
END
ELSE
BEGIN
	IF @FromNo = '%' OR @ToNo = '%'
	BEGIN
		SET @QtyTableName = 'SalesQty2'
		Select  "Salesman" = IsNull(Salesman.Salesman_Name, @MLOthers),
		"Product_Code" = InvoiceDetail.Product_Code,
		"Batch" = InvoiceDetail.Batch_Number,
		"Quantity" = Case InvoiceType WHEN 4 THEN 0 - Sum(InvoiceDetail.Quantity) ELSE Sum(InvoiceDetail.Quantity) END 
		INTO #SaleQty2
		From	InvoiceAbstract, Salesman, InvoiceDetail
		Where	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
			(InvoiceAbstract.Status & 128) = 0 And 
			InvoiceDetail.InvoiceId = InvoiceAbstract.InvoiceID And
			InvoiceAbstract.InvoiceType in (1, 3, 4) And
			InvoiceAbstract.SalesmanID = Salesman.SalesmanID And
			Salesman.Salesman_Name Like @SALESMAN
			Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name, InvoiceType, InvoiceDetail.Product_Code, InvoiceDetail.Batch_Number	

	END
	ELSE
	BEGIN
		SET @QtyTableName = 'SaleQty3'
		Select  "Salesman" = IsNull(Salesman.Salesman_Name, @MLOthers),
		"Product_Code" = Product_Code,
		"Batch" = InvoiceDetail.Batch_Number,
		"Quantity" = Case InvoiceType WHEN 4 THEN 0 - Sum(Quantity) ELSE Sum(Quantity) END
		INTO #SaleQty3
		From	InvoiceAbstract, Salesman, InvoiceDetail
		Where	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
			(InvoiceAbstract.Status & 128) = 0 And 
			InvoiceDetail.InvoiceId = InvoiceAbstract.InvoiceID And
			InvoiceAbstract.InvoiceType in (1, 3, 4) And
			InvoiceAbstract.SalesmanID = Salesman.SalesmanID And
			Salesman.Salesman_Name Like @SALESMAN And
			InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)
			Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name, InvoiceType, InvoiceDetail.Product_Code, InvoiceDetail.Batch_Number	
	END
END
	

IF @SALESMAN = @MLOthers
BEGIN
	IF @FromNo = '%' OR @ToNo = '%'
	BEGIN
		IF @UOM = 'Sales UOM'
		BEGIN
			SET @UOMColumnName = 'Sales UOM'
			SET @TableName = '#Temp1'
			Select  Manufacturer.Manufacturer_Name,
				"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),
		  		"Product Hierarchy Last Level" = ItemCategories.Category_Name,
				"Sales UOM" = UOM.Description,
				"Item Code" = InvoiceDetail.Product_Code,
				"Item Name" = Items.ProductName,
				"Batch" = InvoiceDetail.Batch_Number, 
		                "Quantity" = (SELECT Sum(#SaleQty.Quantity) FROM #SaleQty 
 		                WHERE #SaleQty.Product_Code = InvoiceDetail.Product_Code And Batch = InvoiceDetail.Batch_Number GROUP BY #SaleQty.Product_Code, #SaleQty.Batch) INTO #temp1
			From	InvoiceDetail, InvoiceAbstract, UOM, Manufacturer, Items, ItemCategories
			Where	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
				InvoiceDetail.Product_code = Items.Product_Code And
				Items.UOM = UOM.UOM And
				ItemCategories.CategoryID = Items.CategoryID And
				Items.ManufacturerID = Manufacturer.ManufacturerID And
				(InvoiceAbstract.Status & 128) = 0 And 
				InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
				InvoiceAbstract.SalesManID = 0 And
				InvoiceType In (1, 3, 4)
			Group	By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, ItemCategories.Category_Name, Items.CategoryID, UOM.Description, InvoiceDetail.Batch_Number
			Order 	By Manufacturer.Manufacturer_Name
 
		END
		ELSE IF @UOM = 'Conversion Factor'
		BEGIN
			SET @UOMColumnName = 'Conversion UOM'
			SET @TableName = '#Temp2'
			Select  Manufacturer.Manufacturer_Name,
				"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),
		  		"Product Hierarchy Last Level" = ItemCategories.Category_Name,
				"Conversion UOM" = ConversionTable.ConversionUnit,
				"Item Code" = InvoiceDetail.Product_Code,
				"Item Name" = Items.ProductName,
				"Batch" = InvoiceDetail.Batch_Number, 
				"Quantity" = Cast((SELECT Sum(#SaleQty.Quantity) FROM #SaleQty WHERE #SaleQty.Product_Code = InvoiceDetail.Product_Code AND Batch = InvoiceDetail.Batch_Number GROUP BY #SaleQty.Product_Code, #SaleQty.Batch) 
				* (SELECT CASE Isnull(Item.ConversionFactor,0) WHEN 0 THEN 1 ELSE Isnull(Item.ConversionFactor,0) end FROM Items Item WHERE Item.Product_Code = InvoiceDetail.Product_Code) As nvarchar)
				INTO #temp2
			From	InvoiceDetail, ConversionTable, InvoiceAbstract, Manufacturer, Items, ItemCategories
			Where	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
				InvoiceDetail.Product_code = Items.Product_Code And
				ItemCategories.CategoryID = Items.CategoryID And
				Items.ManufacturerID = Manufacturer.ManufacturerID And
				ConversionTable.ConversionID = Items.ConversionUnit And
				(InvoiceAbstract.Status & 128) = 0 And 
				InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
				InvoiceAbstract.SalesManID = 0 And
				InvoiceType In (1, 3, 4)
			Group	By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, ItemCategories.Category_Name, Items.CategoryID, ConversionTable.ConversionUnit, InvoiceDetail.Batch_Number
			Order 	By Manufacturer.Manufacturer_Name
		END
		ELSE
		BEGIN
			SET @UOMColumnName = 'Reporting UOM'
			SET @TableName = '#Temp3'
			Select  Manufacturer.Manufacturer_Name,
				"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),
		  		"Product Hierarchy Last Level" = ItemCategories.Category_Name,
				"Reporting UOM" = UOM.Description,
				"Item Code" = InvoiceDetail.Product_Code,
				"Item Name" = Items.ProductName,
				"Batch" = InvoiceDetail.Batch_Number, 
		                "Quantity" = Cast((SELECT Sum(#SaleQty.Quantity) FROM #SaleQty WHERE #SaleQty.Product_Code = InvoiceDetail.Product_Code AND Batch = InvoiceDetail.Batch_Number GROUP BY #SaleQty.Product_Code, #SaleQty.Batch) 
				 / (SELECT CASE Isnull(Item.ReportingUnit,0) WHEN 0 THEN 1 ELSE Isnull(Item.ReportingUnit,0) end FROM Items Item WHERE Item.Product_Code = InvoiceDetail.Product_Code) As nvarchar)
				INTO #Temp3
			From	InvoiceDetail, InvoiceAbstract, UOM, Manufacturer, Items, ItemCategories
			Where	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
				InvoiceDetail.Product_code = Items.Product_Code And
				Items.ReportingUOM = UOM.UOM And
				ItemCategories.CategoryID = Items.CategoryID And
				Items.ManufacturerID = Manufacturer.ManufacturerID And
				(InvoiceAbstract.Status & 128) = 0 And 
				InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
				InvoiceAbstract.SalesManID = 0 And
				InvoiceType In (1, 3, 4)
			Group	By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, ItemCategories.Category_Name, Items.CategoryID, UOM.Description, InvoiceDetail.Batch_Number
			Order 	By Manufacturer.Manufacturer_Name
		END
	END
	ELSE
	BEGIN
		IF @UOM = 'Sales UOM'
		BEGIN
			SET @UOMColumnName = 'Sales UOM'
			SET @TableName = '#Temp4'
			Select  Manufacturer.Manufacturer_Name,
				"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),
		  		"Product Hierarchy Last Level" = ItemCategories.Category_Name,
				"Sales UOM" = UOM.Description,
				"Item Code" = InvoiceDetail.Product_Code,
				"Item Name" = Items.ProductName,
				"Batch" = InvoiceDetail.Batch_Number, 
		                "Quantity" = (SELECT Sum(#SaleQty1.Quantity) FROM #SaleQty1 WHERE #SaleQty1.Product_Code = InvoiceDetail.Product_Code AND Batch = InvoiceDetail.Batch_Number GROUP BY #SaleQty1.Product_Code, #SaleQty1.Batch)
				INTO #Temp4
			From	InvoiceDetail, InvoiceAbstract, UOM, Manufacturer, Items, ItemCategories
			Where	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
				InvoiceDetail.Product_code = Items.Product_Code And
				Items.UOM = UOM.UOM And
				ItemCategories.CategoryID = Items.CategoryID And
				Items.ManufacturerID = Manufacturer.ManufacturerID And
				(InvoiceAbstract.Status & 128) = 0 And 
				InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
				InvoiceAbstract.SalesManID = 0 And
				InvoiceType In (1, 3, 4) And InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)
			Group	By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, ItemCategories.Category_Name, Items.CategoryID, UOM.Description, InvoiceDetail.Batch_Number
			Order 	By Manufacturer.Manufacturer_Name
		END
		ELSE IF @UOM = 'Conversion Factor'
		BEGIN
			SET @UOMColumnName = 'Conversion UOM'
			SET @TableName = '#Temp5'
			Select  Manufacturer.Manufacturer_Name,
				"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),
		  		"Product Hierarchy Last Level" = ItemCategories.Category_Name,
				"Conversion UOM" = ConversionTable.ConversionUnit,
				"Item Code" = InvoiceDetail.Product_Code,
				"Item Name" = Items.ProductName,
				"Batch" = InvoiceDetail.Batch_Number, 
		                "Quantity" = Cast((SELECT Sum(#SaleQty1.Quantity) FROM #SaleQty1 WHERE #SaleQty1.Product_Code = InvoiceDetail.Product_Code AND Batch = InvoiceDetail.Batch_Number GROUP BY #SaleQty1.Product_Code, #SaleQty1.Batch)
				* (SELECT CASE Isnull(Item.ConversionFactor,0) WHEN 0 THEN 1 ELSE Isnull(Item.ConversionFactor,0) end FROM Items Item WHERE Item.Product_Code = InvoiceDetail.Product_Code) As nvarchar)
				INTO #Temp5
			From	InvoiceDetail, ConversionTable, InvoiceAbstract, Manufacturer, Items, ItemCategories
			Where	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
				InvoiceDetail.Product_code = Items.Product_Code And
				ItemCategories.CategoryID = Items.CategoryID And
				Items.ManufacturerID = Manufacturer.ManufacturerID And
				ConversionTable.ConversionID = Items.ConversionUnit And
				(InvoiceAbstract.Status & 128) = 0 And 
				InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
				InvoiceAbstract.SalesManID = 0 And
				InvoiceType In (1, 3, 4) And InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)
			Group	By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, ItemCategories.Category_Name, Items.CategoryID, ConversionTable.ConversionUnit, InvoiceDetail.Batch_Number
			Order 	By Manufacturer.Manufacturer_Name
		END
		ELSE
		BEGIN
			SET @UOMColumnName = 'Reporting UOM'
			SET @TableName = '#Temp6'
			Select  Manufacturer.Manufacturer_Name,
				"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),
		  		"Product Hierarchy Last Level" = ItemCategories.Category_Name,
				"Reporting UOM" = UOM.Description,
				"Item Code" = InvoiceDetail.Product_Code,
				"Item Name" = Items.ProductName,
				"Batch" = InvoiceDetail.Batch_Number, 
		                "Quantity" = Cast((SELECT Sum(#SaleQty1.Quantity) FROM #SaleQty1 WHERE #SaleQty1.Product_Code = InvoiceDetail.Product_Code AND Batch = InvoiceDetail.Batch_Number GROUP BY #SaleQty1.Product_Code, #SaleQty1.Batch)
				/ (SELECT CASE Isnull(Item.ReportingUnit,0) WHEN 0 THEN 1 ELSE Isnull(Item.ReportingUnit,0) end FROM Items Item WHERE Item.Product_Code = InvoiceDetail.Product_Code) As nvarchar)				
				INTO #temp6
			From	InvoiceDetail, InvoiceAbstract, UOM, Manufacturer, Items, ItemCategories
			Where	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
				InvoiceDetail.Product_code = Items.Product_Code And
				Items.ReportingUOM = UOM.UOM And
				ItemCategories.CategoryID = Items.CategoryID And
				Items.ManufacturerID = Manufacturer.ManufacturerID And
				(InvoiceAbstract.Status & 128) = 0 And 
				InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
				InvoiceAbstract.SalesManID = 0 And
				InvoiceType In (1, 3, 4) And InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)
			Group	By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, ItemCategories.Category_Name, Items.CategoryID, UOM.Description, InvoiceDetail.Batch_Number
			Order 	By Manufacturer.Manufacturer_Name
		END
	END
END
ELSE
BEGIN
	IF @FromNo = '%' OR @ToNo = '%'
	BEGIN
		IF @UOM = 'Sales UOM'
		BEGIN
			SET @UOMColumnName = 'Sales UOM'
			SET @TableName = '#Temp7'
			Select  Manufacturer.Manufacturer_Name,
				"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),
		  		"Product Hierarchy Last Level" = ItemCategories.Category_Name,
				"Sales UOM" = UOM.Description,
				"Item Code" = InvoiceDetail.Product_Code,
				"Item Name" = Items.ProductName,
				"Batch" = InvoiceDetail.Batch_Number, 
		                "Quantity" = (SELECT Sum(#SaleQty2.Quantity) FROM #SaleQty2 WHERE #SaleQty2.Product_Code = InvoiceDetail.Product_Code AND Batch = InvoiceDetail.Batch_Number GROUP BY #SaleQty2.Product_Code, #SaleQty2.Batch)
				INTO #Temp7
			From	InvoiceDetail, InvoiceAbstract, UOM, Manufacturer, Items, ItemCategories, SalesMan
			Where	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
				InvoiceDetail.Product_code = Items.Product_Code And
				Items.UOM = UOM.UOM And
				ItemCategories.CategoryID = Items.CategoryID And
				Items.ManufacturerID = Manufacturer.ManufacturerID And
				(InvoiceAbstract.Status & 128) = 0 And 
				InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
				InvoiceAbstract.SalesmanID  = SalesMan.SalesManID And
				InvoiceAbstract.SalesManID <> 0 And
		                SalesMan.SalesMan_Name like @SALESMAN And
				InvoiceType In (1, 3, 4)
			Group	By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, ItemCategories.Category_Name, Items.CategoryID, UOM.Description, InvoiceDetail.Batch_Number
			Order 	By Manufacturer.Manufacturer_Name
		END
		ELSE IF @UOM = 'Conversion Factor'
		BEGIN
			SET @UOMColumnName = 'Conversion UOM'
			SET @TableName = '#Temp8'
			Select  Manufacturer.Manufacturer_Name,
				"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),
		  		"Product Hierarchy Last Level" = ItemCategories.Category_Name,
				"Conversion UOM" = ConversionTable.ConversionUnit,
				"Item Code" = InvoiceDetail.Product_Code,
				"Item Name" = Items.ProductName,
				"Batch" = InvoiceDetail.Batch_Number, 
	                	"Quantity" = Cast((SELECT Sum(#SaleQty2.Quantity) FROM #SaleQty2 WHERE #SaleQty2.Product_Code = InvoiceDetail.Product_Code AND Batch = InvoiceDetail.Batch_Number GROUP BY #SaleQty2.Product_Code, #SaleQty2.Batch)
				* (SELECT CASE Isnull(Item.ConversionFactor,0) WHEN 0 THEN 1 ELSE Isnull(Item.ConversionFactor,0) end FROM Items Item WHERE Item.Product_Code = InvoiceDetail.Product_Code) As nvarchar)
				INTO #Temp8
			From	InvoiceDetail, ConversionTable, InvoiceAbstract, UOM, Manufacturer, Items, ItemCategories, SalesMan
			Where	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
				InvoiceDetail.Product_code = Items.Product_Code And
				Items.UOM = UOM.UOM And
				ItemCategories.CategoryID = Items.CategoryID And
				Items.ManufacturerID = Manufacturer.ManufacturerID And
				ConversionTable.ConversionID = Items.ConversionUnit And
				(InvoiceAbstract.Status & 128) = 0 And 
				InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
				InvoiceAbstract.SalesManID <> 0 And
				InvoiceAbstract.SalesmanID  *= SalesMan.SalesManID And
		                SalesMan.SalesMan_Name like @SALESMAN And
				InvoiceType In (1, 3, 4)
			Group	By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, ItemCategories.Category_Name, Items.CategoryID, ConversionTable.ConversionUnit, InvoiceDetail.Batch_Number
			Order 	By Manufacturer.Manufacturer_Name
		END
		ELSE
		BEGIN
			SET @UOMColumnName = 'Reporting UOM'
			SET @TableName = '#Temp9'
			Select  Manufacturer.Manufacturer_Name,
				"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),
		  		"Product Hierarchy Last Level" = ItemCategories.Category_Name,
				"Reporting UOM" = UOM.Description,
				"Item Code" = InvoiceDetail.Product_Code,
				"Item Name" = Items.ProductName,
				"Batch" = InvoiceDetail.Batch_Number, 
		                "Quantity" = Cast((SELECT Sum(#SaleQty2.Quantity) FROM #SaleQty2 WHERE #SaleQty2.Product_Code = InvoiceDetail.Product_Code AND Batch = InvoiceDetail.Batch_Number GROUP BY #SaleQty2.Product_Code, #SaleQty2.Batch)
				/ (SELECT CASE Isnull(Item.ReportingUnit,0) WHEN 0 THEN 1 ELSE Isnull(Item.ReportingUnit,0) end FROM Items Item WHERE Item.Product_Code = InvoiceDetail.Product_Code) As nvarchar)
				INTO #Temp9
			From	InvoiceDetail, InvoiceAbstract, UOM, Manufacturer, Items, ItemCategories, SalesMan
			Where	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
				InvoiceDetail.Product_code = Items.Product_Code And
				Items.ReportingUOM = UOM.UOM And
				ItemCategories.CategoryID = Items.CategoryID And
				Items.ManufacturerID = Manufacturer.ManufacturerID And
				(InvoiceAbstract.Status & 128) = 0 And 
				InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
				InvoiceAbstract.SalesmanID  *= SalesMan.SalesManID And
				InvoiceAbstract.SalesManID <> 0 And
		                SalesMan.SalesMan_Name like @SALESMAN And
				InvoiceType In (1, 3, 4) 
			Group	By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, ItemCategories.Category_Name, Items.CategoryID, UOM.Description, InvoiceDetail.Batch_Number
			Order 	By Manufacturer.Manufacturer_Name
		END
	END
	ELSE
	BEGIN
		IF @UOM = 'Sales UOM'
		BEGIN
			SET @UOMColumnName = 'Sales UOM'
			SET @TableName = '#Temp10'
			Select  Manufacturer.Manufacturer_Name,
				"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),
		  		"Product Hierarchy Last Level" = ItemCategories.Category_Name,
				"Sales UOM" = UOM.Description,
				"Item Code" = InvoiceDetail.Product_Code,
				"Item Name" = Items.ProductName,
				"Batch" = InvoiceDetail.Batch_Number, 
		                "Quantity" = (SELECT Sum(#SaleQty3.Quantity) FROM #SaleQty3 WHERE #SaleQty3.Product_Code = InvoiceDetail.Product_Code AND Batch = InvoiceDetail.Batch_Number GROUP BY #SaleQty3.Product_Code, #SaleQty3.Batch)
				INTO #Temp10
			From	InvoiceDetail, InvoiceAbstract, UOM, Manufacturer, Items, ItemCategories, SalesMan
			Where	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
				InvoiceDetail.Product_code = Items.Product_Code And
				Items.UOM = UOM.UOM And
				ItemCategories.CategoryID = Items.CategoryID And
				Items.ManufacturerID = Manufacturer.ManufacturerID And
				(InvoiceAbstract.Status & 128) = 0 And 
				InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
				InvoiceAbstract.SalesmanID  *= SalesMan.SalesManID And
				InvoiceAbstract.SalesmanID <> 0 And
		                SalesMan.SalesMan_Name like @SALESMAN And
				InvoiceType In (1, 3, 4) And InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)
			Group	By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, ItemCategories.Category_Name, Items.CategoryID, UOM.Description, InvoiceDetail.Batch_Number
			Order 	By Manufacturer.Manufacturer_Name
		END
		ELSE IF @UOM = 'Conversion Factor'
		BEGIN
			SET @UOMColumnName = 'Conversion UOM'
			SET @TableName = '#Temp11'
			Select  Manufacturer.Manufacturer_Name,
				"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),
		  		"Product Hierarchy Last Level" = ItemCategories.Category_Name,
				"Conversion UOM" = ConversionTable.ConversionUnit,
				"Item Code" = InvoiceDetail.Product_Code,
				"Item Name" = Items.ProductName,
				"Batch" = InvoiceDetail.Batch_Number, 
		                "Quantity" = Cast((SELECT Sum(#SaleQty3.Quantity) FROM #SaleQty3 WHERE #SaleQty3.Product_Code = InvoiceDetail.Product_Code AND Batch = InvoiceDetail.Batch_Number GROUP BY #SaleQty3.Product_Code, #SaleQty3.Batch)
				* (SELECT CASE Isnull(Item.ConversionFactor,0) WHEN 0 THEN 1 ELSE Isnull(Item.ConversionFactor,0) end FROM Items Item WHERE Item.Product_Code = InvoiceDetail.Product_Code) As nvarchar)				
				INTO #Temp11
			From	InvoiceDetail, ConversionTable, InvoiceAbstract, UOM, Manufacturer, Items, ItemCategories, SalesMan
			Where	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
				InvoiceDetail.Product_code = Items.Product_Code And
				Items.UOM = UOM.UOM And
				ItemCategories.CategoryID = Items.CategoryID And
				Items.ManufacturerID = Manufacturer.ManufacturerID And
				ConversionTable.ConversionID = Items.ConversionUnit And
				(InvoiceAbstract.Status & 128) = 0 And 
				InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
				InvoiceAbstract.SalesmanID  *= SalesMan.SalesManID And
				InvoiceAbstract.SalesmanID <> 0 And
		                SalesMan.SalesMan_Name like @SALESMAN And
				InvoiceType In (1, 3, 4) And InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)
			Group	By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, ItemCategories.Category_Name, Items.CategoryID, ConversionTable.ConversionUnit, InvoiceDetail.Batch_Number
			Order 	By Manufacturer.Manufacturer_Name
		END
		ELSE
		BEGIN
			SET @UOMColumnName = 'Reporting UOM'
			SET @TableName = '#Temp12'
			Select  Manufacturer.Manufacturer_Name,
				"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),
		  		"Product Hierarchy Last Level" = ItemCategories.Category_Name,
				"Reporting UOM" = UOM.Description,
				"Item Code" = InvoiceDetail.Product_Code,
				"Item Name" = Items.ProductName,
				"Batch" = InvoiceDetail.Batch_Number, 
		                "Quantity" = Cast((SELECT Sum(#SaleQty3.Quantity) FROM #SaleQty3 WHERE #SaleQty3.Product_Code = InvoiceDetail.Product_Code AND Batch = InvoiceDetail.Batch_Number GROUP BY #SaleQty3.Product_Code, #SaleQty3.Batch)
				/ (SELECT CASE Isnull(Item.ReportingUnit,0) WHEN 0 THEN 1 ELSE Isnull(Item.ReportingUnit,0) end FROM Items Item WHERE Item.Product_Code = InvoiceDetail.Product_Code) As nvarchar)
				INTO #Temp12
			From	InvoiceDetail, InvoiceAbstract, UOM, Manufacturer, Items, ItemCategories, SalesMan
			Where	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
				InvoiceDetail.Product_code = Items.Product_Code And
				Items.ReportingUOM = UOM.UOM And
				ItemCategories.CategoryID = Items.CategoryID And
				Items.ManufacturerID = Manufacturer.ManufacturerID And
				(InvoiceAbstract.Status & 128) = 0 And 
				InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
				InvoiceAbstract.SalesmanID  *= SalesMan.SalesManID And
				InvoiceAbstract.SalesmanID <> 0 And
		                SalesMan.SalesMan_Name like @SALESMAN And
				InvoiceType In (1, 3, 4) And InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)
			Group	By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, ItemCategories.Category_Name, Items.CategoryID, UOM.Description, InvoiceDetail.Batch_Number
			Order 	By Manufacturer.Manufacturer_Name
		END
	END
END

SET @SQL = 'SELECT [Manufacturer_Name], [Product Hierarchy First Level] As "' + @FirstLevel +  
	   '", [Product Hierarchy Last Level] As "' + @LastLevel + '", [' +  @UOMColumnName + '],' +
	   '[Item Code], [Item Name], [Batch], [Quantity] FROM ' + @TableName 
EXEC(@SQL)
EXEC('DROP TABLE ' + @TableName)
--EXEC('DROP TABLE ' + @QtyTableName)
