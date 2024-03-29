CREATE procedure [dbo].[spr_bookstock_fmcg](@PRODUCT_CODE nvarchar(15), @UOM nvarchar(50),
                                    @ItemCode nvarchar(255), @ItemName nvarchar(255))      
AS      
DECLARE @PriceOption int      
SELECT @PriceOption = Price_Option FROM ItemCategories WHERE CategoryID = (Select CategoryID From Items where Product_Code = @PRODUCT_CODE)      
If IsNull(@UOM,N'') = N'' or @UOM = N'%'     
 Set @UOM = N'Sales UOM'      
IF @PriceOption = 1      
BEGIN       
SELECT  Batch_Number, "Batch" = Batch_Number,     
"PKD" = CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'/'      
+ SubString(CAST(DATEPART(yyyy, Batch_Products.PKD) AS nvarchar), 1, 4),      
"Expiry" = CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'/'      
+ SubString(CAST(DATEPART(yyyy, Batch_Products.Expiry) AS nvarchar), 1, 4),      
 "Remarks" = CASE ISNULL(Damage, 0)      
   WHEN  1 THEN N'Stock Adjustment Damages'       
   WHEN  2 then N'Sales Return Damages'       
             ELSE       
   case WHEN ISNULL(Free, 0) >= 1 THEN N'Free' END      
      END,    
 "Available Quantity" = CAST(dbo.sp_Get_ReportingQty( ISNULL(SUM(Quantity), 0),    
 (Case @UOM When N'Sales UOM' Then 1    
 When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
 When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
 End)) AS nvarchar)  + N' ' +  CAST(    
 (Case @UOM When N'Sales UOM' Then SalesUOM.Description    
 When N'Uom1' Then (Select IsNull(Description,N'') From UOM Where UOM = Items.UOM1)    
 When N'Uom2' Then (Select IsNull(Description,N'') From UOM Where UOM = Items.UOM2)    
 End)    
 AS nvarchar),      
 "Conversion Unit" = CAST(CAST(Items.ConversionFactor * ISNULL(SUM(Quantity), 0) as Decimal(18,6)) AS nvarchar) + N' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),      
 "Reporting UOM" =  Cast(dbo.sp_Get_ReportingQty(ISNULL(SUM(Quantity), 0), Items.ReportingUnit) As nvarchar)     
-- CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) as Decimal(18,6)) AS nvarchar)      
 + N' ' + CAST((select Description From UOM where UOM = Items.ReportingUOM) AS nvarchar),      
 "Purchase Price" =   
 (Case @UOM When N'Sales UOM' Then 1    
  When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
  When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
  End) *    
 ISNULL(Batch_Products.PurchasePrice, 0),      
 "Sale Price" =   
 (Case @UOM When N'Sales UOM' Then 1    
  When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
  When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
  End) *    
 ISNULL(Batch_Products.SalePrice, 0)    
FROM Batch_Products, Items, UOM as SalesUOM, ConversionTable      
WHERE Batch_Products.Product_Code = @PRODUCT_CODE AND       
Items.Product_Code = Batch_Products.Product_Code AND      
ISNULL(Batch_Products.Quantity, 0) > 0 AND      
Items.UOM *= SalesUOM.UOM AND      
Items.ConversionUnit *= ConversionTable.ConversionID      
GROUP BY Batch_Products.Batch_Number, Batch_Products.PKD,       
Batch_Products.Expiry, Batch_Products.SalePrice,       
Batch_Products.PurchasePrice, ISNULL(Free, 0),ISNULL(Batch_Products.Damage, 0), SalesUOM.Description,       
Items.ConversionFactor, Items.ConversionUnit, Items.ReportingUnit, Items.ReportingUOM,      
ConversionTable.ConversionUnit,Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2      
END      
ELSE      
BEGIN      
SELECT  Batch_Number, "Batch" = Batch_Number,     
"PKD" = CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'/'      
+ SubString(CAST(DATEPART(yyyy, Batch_Products.PKD) AS nvarchar), 1, 4),      
"Expiry" = CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'/'      
+ SubString(CAST(DATEPART(yyyy, Batch_Products.Expiry) AS nvarchar), 1, 4),      
 "Remarks" = CASE ISNULL(Damage, 0)      
   WHEN  1 THEN N'Stock Adjustment Damages'       
   WHEN  2 then N'Sales Return Damages'       
             ELSE       
   case WHEN ISNULL(Free, 0) >= 1 THEN N'Free' END      
      END,    
 "Available Quantity" = CAST(dbo.sp_Get_ReportingQty( ISNULL(SUM(Quantity), 0),     
 (Case @UOM When N'Sales UOM' Then 1    
 When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
 When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
 End)) AS nvarchar)  + N' ' + CAST(    
 (Case @UOM When N'Sales UOM' Then SalesUOM.Description    
 When N'Uom1' Then (Select IsNull(Description,N'') From UOM Where UOM = Items.UOM1)    
 When N'Uom2' Then (Select IsNull(Description,N'') From UOM Where UOM = Items.UOM2)    
 End)    
 AS nvarchar),        
 "Conversion Unit" = CAST(CAST(Items.ConversionFactor * ISNULL(SUM(Quantity), 0) AS Decimal(18,6)) AS nvarchar)  + N' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),      
 "Reporting UOM" =  CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)  + N' ' + CAST((select Description From UOM where UOM = Items.ReportingUOM) AS nvarchar),      
 "Purchase Price" =   
 (Case @UOM When N'Sales UOM' Then 1    
  When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
  When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
  End) *    
 ISNULL(Items.Purchase_Price, 0),      
 "Sale Price" =   
 (Case @UOM When N'Sales UOM' Then 1    
  When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
  When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
  End) *    
 ISNULL(Items.Sale_Price, 0)    
FROM Batch_Products, Items, uom as SalesUOM, ConversionTable      
WHERE Batch_Products.Product_Code = @PRODUCT_CODE AND       
Items.Product_Code = Batch_Products.Product_Code AND      
ISNULL(Batch_Products.Quantity, 0) > 0 AND      
Items.UOM *= SalesUOM.UOM AND      
Items.ConversionUnit *= ConversionTable.ConversionID      
GROUP BY Batch_Products.Batch_Number, Batch_Products.PKD,       
Batch_Products.Expiry, Items.Sale_Price,       
Items.Purchase_Price, ISNULL(Free, 0), ISNULL(Batch_Products.Damage, 0) , SalesUOM.Description,       
Items.ConversionFactor, Items.ConversionUnit, Items.ReportingUnit, Items.ReportingUOM,      
ConversionTable.ConversionUnit,Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2      
END
