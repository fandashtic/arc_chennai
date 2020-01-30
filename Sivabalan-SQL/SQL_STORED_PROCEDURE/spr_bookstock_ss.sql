CREATE procedure [dbo].[spr_bookstock_ss](@PRODUCT_CODE nvarchar(15))  
AS  
DECLARE @PriceOption int  
Declare @FREE As NVarchar(50) 
Declare @STOCKADJUSTMENTDAMAGES As NVarchar(50)
Declare @SALESRETURNDAMAGES As NVarchar(50)
Set @FREE = dbo.LookupDictionaryItem(N'Free',Default)
Set @STOCKADJUSTMENTDAMAGES = dbo.LookupDictionaryItem(N'Stock Adjustment Damages',Default)
Set @SALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'Sales Return Damages',Default)

SELECT @PriceOption = Price_Option FROM ItemCategories WHERE CategoryID = (Select CategoryID From Items where Product_Code = @PRODUCT_CODE)  
  
IF @PriceOption = 1  
BEGIN  
SELECT  Batch_Number, "Batch" = Batch_Number, PKD, Expiry,   
 "Remarks" = CASE ISNULL(Damage, 0)  
   WHEN  1 THEN @STOCKADJUSTMENTDAMAGES
   WHEN  2 then @SALESRETURNDAMAGES
             ELSE   
   case WHEN ISNULL(Free, 0) >= 1 THEN @FREE END  
      END,
 "Available Quantity" =  cast(ISNULL(SUM(Quantity), 0) as nvarchar)  + ' ' +  CAST(SalesUOM.Description AS nvarchar),  
 "Conversion Unit" = CAST(CAST(Items.ConversionFactor * ISNULL(SUM(Quantity), 0) as Decimal(18,6)) AS nvarchar)   
 + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),  
 "Reporting UOM" =  CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) as Decimal(18,6)) AS nvarchar)    
 + ' ' + CAST((select Description From UOM where UOM = Items.ReportingUOM) AS nvarchar),  
 "Purchase Price" = ISNULL(Batch_Products.PurchasePrice, 0),  
 "PTSS" = ISNULL(Batch_Products.PTS, 0),   
 "PTS" = ISNULL(Batch_Products.PTR, 0),   
 "PTR" = ISNULL(Batch_Products.Company_Price, 0),
 "ECP" = ISNULL(Batch_Products.SalePrice, 0)
FROM Batch_Products, Items, UOM as SalesUOM, ConversionTable  
WHERE Batch_Products.Product_Code = @PRODUCT_CODE AND   
Items.Product_Code = Batch_Products.Product_Code AND  
Batch_Products.Quantity > 0 AND  
Items.UOM *= SalesUOM.UOM AND  
Items.ConversionUnit *= ConversionTable.ConversionID  
GROUP BY Batch_Products.Batch_Number, Batch_Products.PKD,   
 Batch_Products.Expiry, Batch_Products.SalePrice, Batch_Products.PTS,   
 Batch_Products.PurchasePrice, Batch_Products.PTR, Batch_Products.Company_Price, ISNULL(Free, 0),  
 ISNULL(Damage, 0), SalesUOM.Description, Items.ConversionFactor, Items.ConversionUnit,   
 Items.ReportingUnit, Items.ReportingUOM, ConversionTable.ConversionUnit  
END  
ELSE  
BEGIN  
SELECT  Batch_Number, "Batch" = Batch_Number, PKD, Expiry,   
 "Remarks" = CASE ISNULL(Damage, 0)  
   WHEN  1 THEN @STOCKADJUSTMENTDAMAGES
   WHEN  2 then @SALESRETURNDAMAGES
             ELSE   
   case WHEN ISNULL(Free, 0) >= 1 THEN @FREE END  
      END,
 "Available Quantity" =  cast(ISNULL(SUM(Quantity), 0) as nvarchar)  + ' ' +  CAST(SalesUOM.Description AS nvarchar),  
 "Conversion Unit" = CAST(CAST(Items.ConversionFactor * ISNULL(SUM(Quantity), 0) as Decimal(18,6)) AS nvarchar)   
 + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),  
 "Reporting UOM" =  CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) as Decimal(18,6)) AS nvarchar)    
 + ' ' + CAST((select Description From UOM where UOM = Items.ReportingUOM) AS nvarchar),  
 "Purchase Price" = ISNULL(Items.Purchase_Price, 0),  
 "PTSS" = ISNULL(Items.PTS, 0),   
 "PTS" = ISNULL(Items.PTR, 0),   
 "PTR" = ISNULL(Items.Company_Price, 0),
 "ECP" = ISNULL(Items.Sale_Price, 0)
FROM Batch_Products, Items, UOM as SalesUOM, ConversionTable  
WHERE Batch_Products.Product_Code = @PRODUCT_CODE AND   
Items.Product_Code = Batch_Products.Product_Code AND  
Batch_Products.Quantity > 0 AND  
Items.UOM *= SalesUOM.UOM AND  
Items.ConversionUnit *= ConversionTable.ConversionID  
GROUP BY Batch_Products.Batch_Number, Batch_Products.PKD,   
 Batch_Products.Expiry, Items.Sale_Price,   
 Items.Purchase_Price, Items.PTS, Items.PTR, Items.Company_Price, ISNULL(Free, 0), ISNULL(Damage, 0),   
 SalesUOM.Description, Items.ConversionFactor, Items.ConversionUnit, Items.ReportingUnit,   
 Items.ReportingUOM, ConversionTable.ConversionUnit  
END
