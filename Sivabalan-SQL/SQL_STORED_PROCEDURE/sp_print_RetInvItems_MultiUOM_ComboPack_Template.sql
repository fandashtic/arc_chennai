CREATE Procedure [dbo].[sp_print_RetInvItems_MultiUOM_ComboPack_Template](@INVNO INT)    
AS    
/*  
DECLARE @ItemCode nvarchar(500)  
DECLARE @BatchNumber nvarchar(500)  
DECLARE @SQL nvarchar(2000)  
  
SET @SQL = N''  
SET @ItemCode = N''  
SET @BatchNumber = N''  
  
SELECT "Item Code" = InvoiceDetail.Product_Code, "Item Name" = Items.ProductName,     
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(InvoiceDetail.Product_Code, Sum(InvoiceDetail.Quantity)),      
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  InvoiceDetail.Product_Code )),      
"UOM2Price" =  Isnull(Max(UOM2_Conversion),0) *  
 (Case ItemCategories.Price_Option   
  When 1 Then  
  Max((Case CustomerCategory When 1 Then InvoiceDetail.PTS When 2 Then InvoiceDetail.PTR ELSE InvoiceDetail.MRP END))   
   Else  
  Max((Case CustomerCategory When 1 Then Items.PTS When 2 Then Items.PTR ELSE Items.ECP END))   
   End),  
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(InvoiceDetail.Product_Code, Sum(InvoiceDetail.Quantity)),      
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  InvoiceDetail.Product_Code )),      
"UOM1Price" =  Isnull(Max(UOM1_Conversion),0) *  
 (Case ItemCategories.Price_Option   
  When 1 Then  
  Max((Case CustomerCategory When 1 Then InvoiceDetail.PTS When 2 Then InvoiceDetail.PTR ELSE InvoiceDetail.MRP END))   
   Else  
  Max((Case CustomerCategory When 1 Then Items.PTS When 2 Then Items.PTR ELSE Items.ECP END))   
   End),   
"UOMQuantity" = dbo.GetLastLevelUOMQty(InvoiceDetail.Product_Code, Sum(InvoiceDetail.Quantity)),      
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  InvoiceDetail.Product_Code )),        
"UOMPrice" =   
     (Case ItemCategories.Price_Option   
  When 1 Then  
  Max((Case CustomerCategory When 1 Then InvoiceDetail.PTS When 2 Then InvoiceDetail.PTR ELSE InvoiceDetail.MRP END))   
   Else  
  Max((Case CustomerCategory When 1 Then Items.PTS When 2 Then Items.PTR ELSE Items.ECP END))   
   End),   
"Batch" = InvoiceDetail.Batch_Number,     
"Sale Price" = Case InvoiceDetail.SalePrice    
When 0 then    
N'Free'    
Else    
Cast(InvoiceDetail.SalePrice as nvarchar)    
End,     
"Tax%" = (ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0)),     
"Discount%" = Max(InvoiceDetail.DiscountPercentage),     
"Discount Value" = SUM(InvoiceDetail.DiscountValue),     
"Amount" = Cast(case MAX(InvoiceAbstract.Flags)    
WHEN 0 THEN     
 Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
 (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
 Max(InvoiceDetail.DiscountPercentage) / 100) +     
 (((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)     
 - (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
 Max(InvoiceDetail.DiscountPercentage) / 100))     
 * Max(InvoiceDetail.TaxCode) / 100), 2))    
 When 0 then    
 N''    
 Else    
 Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
 (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
 Max(InvoiceDetail.DiscountPercentage) / 100) +     
 (((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)     
 - (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
 Max(InvoiceDetail.DiscountPercentage) / 100))     
 * Max(InvoiceDetail.TaxCode) / 100), 2) as nvarchar)    
 End    
ELSE    
 Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
 (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
 Max(InvoiceDetail.DiscountPercentage) / 100), 2))    
 When 0 then    
 N''    
 Else    
 Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
 (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
 Max(InvoiceDetail.DiscountPercentage) / 100), 2) as nvarchar)    
 End    
END As Decimal(18,6)),    
"Expiry" = CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'\'    
+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),    
--"MRP" = InvoiceDetail.MRP, "PTS" = InvoiceDetail.PTS, "PTR" = InvoiceDetail.PTR,    
"MRP" = Max(InvoiceDetail.MRP), "PTS" = Max(InvoiceDetail.PTS), "PTR" = Max(InvoiceDetail.PTR),    
"Type" = CASE     
 WHEN InvoiceDetail.SaleID = 1 THEN N'F'    
 WHEN InvoiceDetail.SaleID = 2 THEN N'S'    
 WHEN InvoiceDetail.SaleID = 0 AND SUM(STPAYABLE) <> 0 THEN N'F'    
 ELSE N' '    
 END,    
"Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0),    
"Mfr" = Manufacturer.ManufacturerCode, "Description" = Items.Description,    
"Category" = ItemCategories.Category_Name,    
"Item Gross Value" = Case Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice)    
When 0 then    
N''    
Else    
Cast(Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice) as nvarchar)    
End,    
"Amount Before Tax" = Sum (InvoiceDetail.Amount - (InvoiceDetail.STPayable + InvoiceDetail.CSTPayable)),    
"Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),    
"Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),    
"Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),    
"Reporting Unit Qty" = (Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),    
"Conversion Unit Qty" = (Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),    
"Rounded Reporting Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),    
"Rounded Conversion Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),    
"Mfr Name" = Manufacturer.Manufacturer_Name,    
"Divison" = Brand.BrandName,    
"Tax Applicable Value" = Sum(IsNull(InvoiceDetail.STPayable, 0) + IsNull(InvoiceDetail.CSTPayable, 0)),    
"Tax Suffered Value" = IsNull(Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.TaxSuffered / 100), 0),    
"Reporting UOM" = RUOM.Description,    
"Conversion Unit" = ConversionTable.ConversionUnit,    
"Reporting Factor" = Items.ReportingUnit,    
"Conversion Factor" = Items.ConversionFactor,  
"PKD" = CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'\'  
+ SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2),   
"Net Rate" = Cast((case MAX(InvoiceAbstract.Flags)    
WHEN 0 THEN     
 Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
 (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
 Max(InvoiceDetail.DiscountPercentage) / 100) +     
 (((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)     
 - (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
 Max(InvoiceDetail.DiscountPercentage) / 100))     
 * Max(InvoiceDetail.TaxCode) / 100), 2))    
 When 0 then    
 N''    
 Else    
 Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
 (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
 Max(InvoiceDetail.DiscountPercentage) / 100) +     
 (((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)     
 - (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
 Max(InvoiceDetail.DiscountPercentage) / 100))     
 * Max(InvoiceDetail.TaxCode) / 100), 2) as nvarchar)    
 End    
ELSE    
 Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
 (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
 Max(InvoiceDetail.DiscountPercentage) / 100), 2))    
 When 0 then    
 N''    
 Else    
 Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
 (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
 Max(InvoiceDetail.DiscountPercentage) / 100), 2) as nvarchar)    
 End    
END) / Sum(InvoiceDetail.Quantity) As Decimal(18,6))      
INTO #temp1 FROM InvoiceDetail  
Inner Join InvoiceAbstract On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceId  
Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code    
Left Outer Join UOM On Items.UOM = UOM.UOM    
Left Outer Join Batch_Products On InvoiceDetail.Batch_Code = Batch_Products.Batch_Code    
Left Outer Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID     
Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID    
Inner Join Brand On Items.BrandID = Brand.BrandID    
Left Outer Join UOM As RUOM On Items.ReportingUOM = RUOM.UOM    
Left Outer Join ConversionTable On  Items.ConversionUnit = ConversionTable.ConversionID    
Inner Join  Customer On InvoiceAbstract.CustomerID = Customer.CustomerID   
WHERE InvoiceDetail.InvoiceID = @INVNO    
  
  
GROUP BY InvoiceDetail.Product_code, Items.ProductName, InvoiceDetail.Batch_Number,     
InvoiceDetail.SalePrice, CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'\'     
+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),    
CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'\'  
+ SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2),  
--InvoiceDetail.MRP, InvoiceDetail.PTS, InvoiceDetail.PTR,     
InvoiceDetail.SaleID,    
Manufacturer.ManufacturerCode, Items.Description, ItemCategories.Category_Name,    
Items.ReportingUnit, Items.ConversionFactor, Manufacturer.Manufacturer_Name,    
Brand.BrandName, RUOM.Description, ConversionTable.ConversionID,     
ConversionTable.ConversionUnit, ItemCategories.Price_Option  
Order By InvoiceDetail.Product_Code, InvoiceDetail.SalePrice Desc    
  
SELECT "Pack" = Invoice_Combo_Components.Combo_Item_Code, "Item Code" = Invoice_Combo_Components.Component_Item_Code,  
"Item Name" = Items.ProductName,  
"UOM2Quantity" = 0,        
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  Invoice_Combo_Components.Component_Item_Code)),        
"UOM2Price" =  Isnull(Max(UOM2_Conversion),0) *  
 (Case ItemCategories.Price_Option   
  When 1 Then  
  Max((Case CustomerCategory When 1 Then Invoice_Combo_Components.PTS When 2 Then Invoice_Combo_Components.PTR ELSE Invoice_Combo_Components.ECP END))   
   Else  
  Max((Case CustomerCategory When 1 Then Items.PTS When 2 Then Items.PTR ELSE Items.ECP END))   
   End),  
"UOM1Quantity" = 0,  
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  Invoice_Combo_Components.Component_Item_Code)),        
"UOM1Price" =  Isnull(Max(UOM1_Conversion),0) *  
 (Case ItemCategories.Price_Option   
  When 1 Then  
  Max((Case CustomerCategory When 1 Then Invoice_Combo_Components.PTS When 2 Then Invoice_Combo_Components.PTR ELSE Invoice_Combo_Components.ECP END))   
   Else  
  Max((Case CustomerCategory When 1 Then Items.PTS When 2 Then Items.PTR ELSE Items.ECP END))   
   End),  
"UOMQuantity" = SUM(Invoice_Combo_Components.Quantity),    
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  Invoice_Combo_Components.Component_Item_Code )),  
"UOMPrice" =    
 (Case ItemCategories.Price_Option   
  When 1 Then  
  Max((Case CustomerCategory When 1 Then Invoice_Combo_Components.PTS When 2 Then Invoice_Combo_Components.PTR ELSE Invoice_Combo_Components.ECP END))   
   Else  
  Max((Case CustomerCategory When 1 Then Items.PTS When 2 Then Items.PTR ELSE Items.ECP END))   
   End),  
"Batch" = InvoiceDetail.Batch_Number,  
"Sale Price" = Case IsNull(Invoice_Combo_Components.SalePrice, 0) When 0 Then N'Free' Else Cast(Invoice_Combo_Components.SalePrice As nvarchar) End,  
"Tax%" = (ISNULL(Max(Invoice_Combo_Components.TaxCode), 0) + ISNULL(Max(Invoice_Combo_Components.TaxCode2), 0)),     
"Discount%" = MAX(Invoice_Combo_Components.DiscountPercentage),  
"Discount Value" = SUM(Invoice_Combo_Components.DiscountValue),     
"Amount" = Cast(case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = @INVNO)  
WHEN 0 THEN     
 Case (Round((SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice) -     
 (SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice *     
 Max(Invoice_Combo_Components.DiscountPercentage) / 100) +     
 (((SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice)     
 - (SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice *   
Max(Invoice_Combo_Components.DiscountPercentage) / 100))     
 * IsNull(Max(Invoice_Combo_Components.TaxCode),0) / 100), 2))    
 When 0 then    
 NULL    
 Else    
 Cast(Round((SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice) -     
 (SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice *     
 Max(Invoice_Combo_Components.DiscountPercentage) / 100) +     
 (((SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice)     
 - (SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice *     
 Max(Invoice_Combo_Components.DiscountPercentage) / 100))     
 * IsNull(Max(Invoice_Combo_Components.TaxCode),0) / 100), 2) As Decimal(18,6))    
 End    
ELSE    
 Case (Round((SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice) -     
 (SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice *     
 Max(Invoice_Combo_Components.DiscountPercentage) / 100), 2))    
 When 0 then    
 NULL    
 Else    
 Cast(Round((SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice) -     
 (SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice *     
 Max(Invoice_Combo_Components.DiscountPercentage) / 100), 2) As Decimal(18,6))    
 End    
END As Decimal(18,6)),    
"Expiry" = (SELECT TOP 1 CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'\'    
+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2) FROM Batch_Products WHERE   
Product_Code = Combo_Item_Code And Batch_Number = InvoiceDetail.Batch_Number),    
"MRP" = Max(Invoice_Combo_Components.ECP), "PTS" = Max(Invoice_Combo_Components.PTS), "PTR" = Max(Invoice_Combo_Components.PTR),    
"Type" = CASE     
 WHEN Invoice_Combo_Components.SaleID = 1 THEN N'F'    
 WHEN Invoice_Combo_Components.SaleID = 2 THEN N'S'    
 WHEN Invoice_Combo_Components.SaleID = 0 AND SUM(Invoice_Combo_Components.STPAYABLE) <> 0 THEN N'F'    
 ELSE N' '    
 END,  
"Tax Suffered" = ISNULL(Max(Invoice_Combo_Components.TaxSuffered), 0),    
"Mfr" = Manufacturer.ManufacturerCode, "Description" = Items.Description,    
"Category" = ItemCategories.Category_Name,    
"Item Gross Value" = Case Sum(Invoice_Combo_Components.Quantity * Invoice_Combo_Components.SalePrice)    
When 0 then    
N''    
Else    
Cast(Sum(Invoice_Combo_Components.Quantity * Invoice_Combo_Components.SalePrice) as nvarchar)    
End,  
"Amount Before Tax" = Sum (Invoice_Combo_Components.Amount - (Invoice_Combo_Components.STPayable + Invoice_Combo_Components.CSTPayable)),    
"Property1" = dbo.GetProperty(Invoice_Combo_Components.Component_Item_Code, 1),    
"Property2" = dbo.GetProperty(Invoice_Combo_Components.Component_Item_Code, 2),    
"Property3" = dbo.GetProperty(Invoice_Combo_Components.Component_Item_Code, 3),    
"Reporting Unit Qty" = (Sum(Invoice_Combo_Components.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),    
"Conversion Unit Qty" = (Sum(Invoice_Combo_Components.Quantity) * Items.ConversionFactor),  
"Rounded Reporting Unit Qty" = Ceiling(Sum(Invoice_Combo_Components.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),    
"Rounded Conversion Unit Qty" = Ceiling(Sum(Invoice_Combo_Components.Quantity) * Items.ConversionFactor),    
"Mfr Name" = Manufacturer.Manufacturer_Name,    
"Division" = Brand.BrandName,    
"Tax Applicable Value" = Sum(IsNull(Invoice_Combo_Components.STPayable, 0) + IsNull(Invoice_Combo_Components.CSTPayable, 0)),    
"Tax Suffered Value" = IsNull(Sum(Invoice_Combo_Components.Quantity * Invoice_Combo_Components.SalePrice * Invoice_Combo_Components.TaxSuffered / 100), 0),    
"Reporting UOM" = RUOM.Description,    
"Conversion Unit" = ConversionTable.ConversionUnit,    
"Reporting Factor" = Items.ReportingUnit,    
"Conversion Factor" = Items.ConversionFactor,  
"PKD" = (SELECT TOP 1 CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'\'    
+ SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2) FROM Batch_Products WHERE   
Product_Code = Combo_Item_Code And Batch_Number = InvoiceDetail.Batch_Number),  
"Net Rate" = Cast((case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = @INVNO)  
WHEN 0 THEN     
 Case (Round((SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice) -     
 (SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice *     
 Max(Invoice_Combo_Components.DiscountPercentage) / 100) +     
 (((SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice)     
 - (SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice *     
 Max(Invoice_Combo_Components.DiscountPercentage) / 100))     
 * IsNull(Max(Invoice_Combo_Components.TaxCode),0) / 100), 2))    
 When 0 then    
 NULL    
 Else    
 Cast(Round((SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice) -     
 (SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice *     
 Max(Invoice_Combo_Components.DiscountPercentage) / 100) +     
 (((SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice)     
 - (SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice *     
 Max(Invoice_Combo_Components.DiscountPercentage) / 100))     
 * IsNull(Max(Invoice_Combo_Components.TaxCode),0) / 100), 2) As Decimal(18,6))    
 End    
ELSE    
 Case (Round((SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice) -     
 (SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice *     
 Max(Invoice_Combo_Components.DiscountPercentage) / 100), 2))    
 When 0 then    
 NULL    
 Else    
 Cast(Round((SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice) -     
 (SUM(Invoice_Combo_Components.Quantity) * Invoice_Combo_Components.SalePrice *     
 Max(Invoice_Combo_Components.DiscountPercentage) / 100), 2) As Decimal(18,6))    
 End    
END) / SUM(Invoice_Combo_Components.Quantity) As Decimal(18,6))    
INTO #temp2 FROM Invoice_Combo_Components  
Inner Join InvoiceDetail On Invoice_Combo_Components.ComboID = InvoiceDetail.ComboID   
Inner Join InvoiceAbstract On InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
Inner Join Items On Items.Product_Code = Invoice_Combo_Components.Component_Item_Code   
Inner Join Brand On Brand.BrandID = Items.BrandID   
Left Outer Join ConversionTable On ConversionTable.ConversionID = Items.ConversionUnit   
Inner Join Manufacturer On Manufacturer.ManufacturerID = Items.ManufacturerID   
Inner Join ItemCategories On ItemCategories.CategoryID = Items.CategoryID   
Left Outer Join UOM RUOM On RUOM.UOM = Items.ReportingUnit   
Inner Join Customer On InvoiceAbstract.CustomerId = Customer.CustomerID   
 WHERE   
InvoiceAbstract.InvoiceID = @INVNO  
GROUP BY Invoice_Combo_Components.Component_Item_Code, Items.ProductName, InvoiceDetail.Batch_Number,     
Invoice_Combo_Components.SalePrice, Invoice_Combo_Components.SaleID, Manufacturer.ManufacturerCode, ItemCategories.Category_Name,  
Items.Description, Items.ReportingUnit, Items.ConversionFactor, RUOM.Description,  
Brand.BrandName, Manufacturer.Manufacturer_Name, ConversionTable.ConversionUnit,  
Invoice_Combo_Components.Combo_Item_Code, ItemCategories.Price_Option  
Order By Invoice_Combo_Components.Component_Item_Code, Invoice_Combo_Components.SalePrice Desc    
  
SELECT * INTO #Temp3 FROM #Temp1 WHERE 1 < 0   
  
DECLARE S1 CURSOR FOR Select [Item Code], [Batch] FROM #Temp1  
OPEN S1  
FETCH NEXT FROM S1 INTO @ItemCode, @BatchNumber  
 WHILE @@FETCH_STATUS = 0   
 BEGIN  
  INSERT INTO #Temp3 SELECT * FROM #Temp1 Where [Item Code] = @ItemCode And [Batch] = @BatchNumber   
  INSERT INTO #Temp3 SELECT N'   ' + [Item Code],N'   ' + [Item Name], [UOM2Quantity], [UOM2Description],  
  [UOM1Quantity], [UOM1Description], [UOMQuantity], [UOMDescription], N'', [Sale Price],  
  [Tax%], [DisCount%], [Discount Value], [Amount], [Expiry], [MRP], [PTS], [PTR], [Type], [Tax Suffered],  
  [Mfr], [Description], [Category], [Item Gross Value], [Amount Before Tax], [Property1], [Property2],   
  [Property3], [Reporting Unit Qty], [Conversion Unit Qty], [Rounded Reporting Unit Qty], [Rounded Conversion Unit Qty],  
  [Mfr Name], [Division], [Tax Applicable Value], [Tax Suffered Value], [Reporting UOM], [Conversion Unit],   
  [Reporting Factor], [Conversion Factor], [PKD], [Net Rate] FROM #Temp2   
  WHERE Pack = @ItemCode AND [Batch] = @BatchNumber  
 FETCH NEXT FROM S1 INTO @ItemCode, @BatchNumber  
 END  
CLOSE S1  
DEALLOCATE S1  
  
SELECT *, 'TaxComponents' FROM #TEMP3  
  
DROP TABLE #TEMP1  
DROP TABLE #TEMP2  
DROP TABLE #TEMP3  
  
*/ 
  
