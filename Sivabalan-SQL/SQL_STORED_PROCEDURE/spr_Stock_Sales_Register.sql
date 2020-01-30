CREATE procedure [dbo].[spr_Stock_Sales_Register](@Manufacturer nvarchar(2550), @Item nvarchar(2550),    
@UOM nvarchar(50), @FROMDATE datetime,@TODATE datetime )                    
as                    
    
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Declare @MLUOM NVarchar(50)
Set @MLUOM = dbo.LookupDictionaryItem(@UOM, Default)

Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create table #tmpItem(ProductCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @Manufacturer='%'       
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer      
Else      
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Manufacturer,@Delimeter)      
      
if @Item='%'      
   Insert into #tmpItem select product_code from Items      
Else      
   Insert into #tmpItem select * from dbo.sp_SplitIn2Rows(@Item,@Delimeter)      
    
declare @NEXT_DATE datetime                    
DECLARE @CORRECTED_DATE datetime                    
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS nvarchar) + '/' + CAST(DATEPART(mm, @TODATE) as nvarchar) + '/' + cast(DATEPART(yyyy, @TODATE) AS nvarchar)                    
SET  @NEXT_DATE = CAST(DATEPART(dd, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar) + '/' + CAST(DATEPART(mm, dbo.Fn_GetOperartingDate(GETDATE())) as nvarchar) + '/' + cast(DATEPART(yyyy, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar)                   
 
if @UOM = 'Sales UOM'                                
begin                                
 SELECT  Items.Product_Code + ',' + @MLUOM + ',' + @Manufacturer + ',' + @Item ,                    
 "Item Code" = Items.Product_Code,                     
 "Item Name" = ProductName,        
 "Category Name" = ItemCategories.Category_Name,                 
 "Sales UOM" = UOM.Description,    -- changed                  
 "Total Opening Quantity" = cast (ISNULL(Opening_Quantity, 0) as Decimal(18,6)),          
 "Saleable Opening Quantity" = cast (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) as Decimal(18,6)),          
 "Free Opening Quantity" = cast (ISNULL(Free_Saleable_Quantity, 0) as Decimal(18,6)),                  
 "Damage Opening Quantity" = cast (ISNULL(Damage_Opening_Quantity, 0) as Decimal(18,6)),                   
 "(%c) Opening Value" = cast (ISNULL(Opening_Value, 0) as Decimal(18,6)),                    
             
 "Purchase" = cast(ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)                     
 FROM GRNAbstract, GRNDetail                                 
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND                     
 GRNDetail.Product_Code = Items.Product_Code AND                     
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And             
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And            
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0) as Decimal(18,6)),              
             
 "Free Purchase" = cast(ISNULL((SELECT SUM(FreeQty)                     
 FROM GRNAbstract, GRNDetail                                 
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND                     
 GRNDetail.Product_Code = Items.Product_Code AND                     
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And             
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And            
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0) as Decimal(18,6)),              
    
 "Total Sales Return" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType In (4, 5, 6))                     
 AND (InvoiceAbstract.Status & 128) = 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6)),              
      
"Sales Return Saleable" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 4)                     
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code                 
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) + 
 ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 5)                     
 AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code                 
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6)),       
      
"Sales Return Damages" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 4)                     
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) <> 0            
 AND InvoiceDetail.Product_Code = Items.Product_Code     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) + 
 ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 6)                     
 AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) <> 0            
 AND InvoiceDetail.Product_Code = Items.Product_Code     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6)),       
             
 "Total Issues" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 2)                     
 AND (InvoiceAbstract.Status & 128) = 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)                     
 + ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                     
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID                        
 AND (IsNull(DispatchAbstract.Status,0) & 320) = 0          
 AND DispatchDetail.Product_Code = Items.Product_Code                     
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0)  as Decimal(18,6)) ,                  
    
 "Saleable Issues" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND  InvoiceAbstract.InvoiceType = 2    
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0                  
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceDetail.SalePrice <> 0    
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6))    
+ ISNULL((SELECT SUM(Quantity)         
FROM DispatchDetail, DispatchAbstract         
WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
AND (DispatchAbstract.Status & 320) = 0         
AND DispatchDetail.Product_Code = Items.Product_Code         
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE        
And DispatchDetail.SalePrice > 0), 0),           
                
 "Free Issues" = cast(ISNULL((SELECT SUM(Quantity)  
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 2)                     
 AND (InvoiceAbstract.Status & 128) = 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE                     
 AND ISNULL(InvoiceDetail.SalePrice, 0) = 0), 0) as Decimal(18,6))    
+ ISNULL((SELECT SUM(Quantity)         
FROM DispatchDetail, DispatchAbstract         
WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
AND (DispatchAbstract.Status & 320) = 0         
AND DispatchDetail.Product_Code = Items.Product_Code         
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE        
And (DispatchDetail.SalePrice = 0
OR DispatchDetail.FlagWord = 1)), 0),                        
             
 "Purchase Return" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                     
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID                     
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code                     
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE     
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0    
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0) as Decimal(18,6)),              
             
 "Adjustments" = cast(ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract                   
 WHERE ISNULL(AdjustmentType,0) in (1, 3)
 And Product_Code = Items.Product_Code                   
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                    
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6)),              
             
 "Stock Transfer Out" = cast(IsNull((Select Sum(Quantity)                     
 From StockTransferOutAbstract, StockTransferOutDetail                    
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                    
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate                     
 And StockTransferOutAbstract.Status & 192 = 0            
 And StockTransferOutDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)),              
                    
 "Stock Transfer In" = cast(IsNull((Select Sum(Quantity)                     
 From StockTransferInAbstract, StockTransferInDetail                     
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                    
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate                     
 And StockTransferInAbstract.Status & 192 = 0            
 And StockTransferInDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)),                
        
"Stock Destruction" = cast(IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                     
From StockDestructionAbstract, StockDestructionDetail,ClaimsNote         
Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                    
And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID        
And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                     
And ClaimsNote.Status & 1 <> 0           
and Items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem)
And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)),    
         
"Total On Hand Qty" = cast(CASE when (@TODATE < @NEXT_DATE) THEN ISNULL((Select Opening_Quantity FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                    
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products WHERE Product_Code = Items.Product_Code), 0) +                    
 (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                     
 (VanStatementAbstract.Status & 128) = 0 And VanStatementDetail.Product_Code = Items.Product_Code))            
 end as Decimal(18,6)),                        
                 
 "On Hand Saleable Qty" = cast(CASE                   
 when (@TODATE < @NEXT_DATE) THEN                   
 ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)                  
 FROM OpeningDetails                   
 WHERE OpeningDetails.Product_Code = Items.Product_Code                   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                  
 ELSE                   
 (ISNULL((SELECT SUM(Quantity)                   
 FROM Batch_Products                   
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) + 
 (SELECT ISNULL(SUM(Pending), 0)                   
 FROM VanStatementDetail, VanStatementAbstract                   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
 AND (VanStatementAbstract.Status & 128) = 0                   
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0)) end  as Decimal(18,6)),                  
            
 "On Hand Free Qty" = cast(CASE                   
 when (@TODATE < @NEXT_DATE) THEN                   
 ISNULL((Select IsNull(Free_Saleable_Quantity, 0)                  
 FROM OpeningDetails                   
 WHERE OpeningDetails.Product_Code = Items.Product_Code               
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                  
 ELSE                   
 (ISNULL((SELECT SUM(Quantity)                   
 FROM Batch_Products                   
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +                  
 (SELECT ISNULL(SUM(Pending), 0)              
 FROM VanStatementDetail, VanStatementAbstract                   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
 AND (VanStatementAbstract.Status & 128) = 0                   
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice = 0)) end  as Decimal(18,6)),                  
           
 "On Hand Damage Qty" = cast(CASE                   
 when (@TODATE < @NEXT_DATE) THEN                   
 ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
 FROM OpeningDetails               
 WHERE OpeningDetails.Product_Code = Items.Product_Code                   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                  
 ELSE                   
 (ISNULL((SELECT SUM(Quantity)                   
 FROM Batch_Products                   
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)) end  as Decimal(18,6)),                  
             
 "(%c) On Hand Value" = cast(CASE 
 when (@TODATE < @NEXT_DATE) THEN                     
 ISNULL((Select Opening_Value                     
 FROM OpeningDetails                     
 WHERE OpeningDetails.Product_Code = Items.Product_Code                     
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                    
 ELSE                     
 ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)                     
 FROM Batch_Products                     
 WHERE Product_Code = Items.Product_Code) +                     
 (SELECT ISNULL(SUM(Pending * PurchasePrice), 0)            
 FROM VanStatementDetail, VanStatementAbstract                   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                     
 AND (VanStatementAbstract.Status & 128) = 0                     
 And VanStatementDetail.Product_Code = Items.Product_Code))                    
 END                  
  as Decimal(18,6))              
              
  FROM Items, OpeningDetails , UOM, Manufacturer ,ItemCategories                  
  WHERE  Items.Product_Code *= OpeningDetails.Product_Code AND                
  Items.ManufacturerID = Manufacturer.ManufacturerID And                  
  Manufacturer.Manufacturer_Name in (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) and 
  items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem) and
  OpeningDetails.Opening_Date = @FROMDATE                     
  AND Items.UOM *= UOM.UOM And IsNull(Items.Active,0) = 1      
  And Items.CategoryID = ItemCategories.CategoryID                      
 end                  
 -- changed                  
Else if @UOM = 'Conversion Factor'             --Conversion Factor                   
Begin                                
 SELECT  Items.Product_Code + ',' + @MLUOM + ',' + @Manufacturer + ',' + @Item ,                    
 "Item Code" = Items.Product_Code,                
 "Item Name" = ProductName,       
 "Category Name" = ItemCategories.Category_Name,                              
 "Conversion Units" = ConversionTable.ConversionUnit,         
 "Total Opening Quantity" = cast(ISNULL(Opening_Quantity, 0) *  ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
 "Saleable Opening Quantity" = cast((ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)) *  ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
 "Free Opening Quantity" = cast(ISNULL(Free_Saleable_Quantity, 0) *  ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),                  
 "Damage Opening Quantity" = cast(ISNULL(Damage_Opening_Quantity, 0) *  ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),                        
 "(%c) Opening Value" = cast(ISNULL(Opening_Value, 0) as Decimal(18,6)),                    
             
 "Purchase" = cast(ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)                     
 FROM GRNAbstract, GRNDetail                                 
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND                    
 GRNDetail.Product_Code = Items.Product_Code AND                     
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And             
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And            
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0)                  
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),              
             
 "Free Purchase" = cast(ISNULL((SELECT SUM(FreeQty)               
 FROM GRNAbstract, GRNDetail                                 
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND                     
 GRNDetail.Product_Code = Items.Product_Code AND                     
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And             
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And            
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0)                  
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),            
    
 "Total Sales Return" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType In (4, 5, 6))                     
 AND (InvoiceAbstract.Status & 128) = 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)                    
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),              
      
"Sales Return Saleable" = cast((ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0  And (InvoiceAbstract.Status & 32) = 0          
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) + 
 ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 5)                     
 AND (InvoiceAbstract.Status & 128) = 0  --And (InvoiceAbstract.Status & 32) = 0          
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0))
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),              
             
 "Sales Return Damages" = cast((ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 4)                     
 AND (InvoiceAbstract.Status & 128) = 0  And (InvoiceAbstract.Status & 32) <> 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) + 
 ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 6)                     
 AND (InvoiceAbstract.Status & 128) = 0  --And (InvoiceAbstract.Status & 32) <> 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0))                    
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),              
             
 "Total Issues" = cast((ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 2)                     
 AND (InvoiceAbstract.Status & 128) = 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)                     
 + ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                     
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID                     
 AND (IsNull(DispatchAbstract.Status,0) & 320) = 0            
 AND DispatchDetail.Product_Code = Items.Product_Code                     
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0))                  
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),               
    
 "Saleable Issues" = cast((ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND  InvoiceAbstract.InvoiceType = 2
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0                  
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceDetail.SalePrice <> 0    
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)    
 + ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                     
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID                     
 AND (IsNull(DispatchAbstract.Status,0) & 320) = 0            
 AND DispatchDetail.Product_Code = Items.Product_Code                     
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
 AND DispatchDetail.SalePrice > 0), 0)) 
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),             
             
 "Free Issues" = cast((ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 2)                     
 AND (InvoiceAbstract.Status & 128) = 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE                     
 AND ISNULL(InvoiceDetail.SalePrice, 0) = 0), 0)
 + ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                     
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID                     
 AND (IsNull(DispatchAbstract.Status,0) & 320) = 0            
 AND DispatchDetail.Product_Code = Items.Product_Code                     
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
 AND (DispatchDetail.FlagWord = 1 OR DispatchDetail.SalePrice = 0)), 0))                     
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),              
             
 "Purchase Return" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                     
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID                     
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code                     
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE                   
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0    
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)                    
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),              
             
 "Adjustments" = cast(ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract WHERE ISNULL(AdjustmentType,0) in (1, 3) And Product_Code = Items.Product_Code AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                   
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)                  
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),                    

 "Stock Transfer Out" = cast(IsNull((Select Sum(Quantity)                     
 From StockTransferOutAbstract, StockTransferOutDetail                    
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                    
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate                     
 And StockTransferOutAbstract.Status & 192 = 0            
 And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)                  
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),              
             
 "Stock Transfer In" = cast(IsNull((Select Sum(Quantity)             
 From StockTransferInAbstract, StockTransferInDetail          
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                    
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate                     
 And StockTransferInAbstract.Status & 192 = 0            
 And StockTransferInDetail.Product_Code = Items.Product_Code), 0)                    
 * ISNULL(Items.ConversionFactor, 0 )as Decimal(18,6)),              
             
        
        
"Stock Destruction" = cast(IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                     
From StockDestructionAbstract, StockDestructionDetail,ClaimsNote         
Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial               
And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID        
And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                     
And ClaimsNote.Status & 1 <> 0            
and Items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem)    
And StockDestructionDetail.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),    
        
             
 "Total On Hand Qty" = cast((CASE when (@TODATE < @NEXT_DATE) THEN ISNULL((Select Opening_Quantity FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                    
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products WHERE Product_Code = Items.Product_Code), 0) +                    
 (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                     
 (VanStatementAbstract.Status & 128) = 0 And VanStatementDetail.Product_Code = Items.Product_Code))            
 end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),                        
                 
 "On Hand Saleable Qty" = cast((CASE             
 when (@TODATE < @NEXT_DATE) THEN                   
 ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)                  
 FROM OpeningDetails                   
 WHERE OpeningDetails.Product_Code = Items.Product_Code                   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                  
 ELSE                   
 (ISNULL((SELECT SUM(Quantity)                   
 FROM Batch_Products                   
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +                  
 (SELECT ISNULL(SUM(Pending), 0)                   
 FROM VanStatementDetail, VanStatementAbstract                   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
 AND (VanStatementAbstract.Status & 128) = 0                   
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0)) end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),                  
            
 "On Hand Free Qty" = cast((CASE                   
 when (@TODATE < @NEXT_DATE) THEN                   
 ISNULL((Select IsNull(Free_Saleable_Quantity, 0)                  
 FROM OpeningDetails                   
 WHERE OpeningDetails.Product_Code = Items.Product_Code                   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                  
 ELSE                   
 (ISNULL((SELECT SUM(Quantity)                   
 FROM Batch_Products                   
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +                  
 (SELECT ISNULL(SUM(Pending), 0)              
 FROM VanStatementDetail, VanStatementAbstract                   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
 AND (VanStatementAbstract.Status & 128) = 0                   
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice = 0)) end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),                
           
 "On Hand Damage Qty" = cast((CASE                   
 when (@TODATE < @NEXT_DATE) THEN                   
 ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
 FROM OpeningDetails               
 WHERE OpeningDetails.Product_Code = Items.Product_Code                   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                  
 ELSE                   
 (ISNULL((SELECT SUM(Quantity)                   
 FROM Batch_Products                   
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)) end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),                       
             
 "(%c) On Hand Value" = cast((CASE                     
 when (@TODATE < @NEXT_DATE) THEN                     
 ISNULL((Select Opening_Value                     
 FROM OpeningDetails                     
 WHERE OpeningDetails.Product_Code = Items.Product_Code                     
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                    
 ELSE                
 ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)                     
 FROM Batch_Products                     
 WHERE Product_Code = Items.Product_Code) +                     
 (SELECT ISNULL(SUM(Pending * PurchasePrice), 0)                     
 FROM VanStatementDetail, VanStatementAbstract                     
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                     
 AND (VanStatementAbstract.Status & 128) = 0                     
 And VanStatementDetail.Product_Code = Items.Product_Code))     
 end) as Decimal(18,6))              

 FROM Items, OpeningDetails , ConversionTable , Manufacturer ,ItemCategories                  
 WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND                    
 Items.ManufacturerID = Manufacturer.ManufacturerID And                    
 Manufacturer.Manufacturer_Name in (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) and 
 items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem) and 
 OpeningDetails.Opening_Date = @FROMDATE                     
 AND Items.ConversionUnit *= ConversionTable.ConversionID And IsNull(Items.Active,0) = 1     
 And Items.CategoryID = ItemCategories.CategoryID                
end 
Else if @UOM = 'UOM1'                   --UOM1             
begin                                  
 SELECT  Items.Product_Code + ',' + @MLUOM + ',' + @Manufacturer + ',' + @Item ,                      
 "Item Code" = Items.Product_Code,                       
 "Item Name" = ProductName,          
 "Category Name" = ItemCategories.Category_Name,                   
 "Sales UOM" = UOM.Description,    -- changed                    
 "Total Opening Quantity" = (Cast(ISNULL(Opening_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),            
 "Saleable Opening Quantity" = (Cast(ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
 "Free Opening Quantity" = (Cast(ISNULL(Free_Saleable_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
 "Damage Opening Quantity" = (Cast(ISNULL(Damage_Opening_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
 "(%c) Opening Value" = cast (ISNULL(Opening_Value, 0) as Decimal(18,6)),                      
               
 "Purchase" = (Cast(ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)                       
 FROM GRNAbstract, GRNDetail                                   
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND                       
 GRNDetail.Product_Code = Items.Product_Code AND                       
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And               
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And              
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),                
               
 "Free Purchase" = (Cast(ISNULL((SELECT SUM(FreeQty)                       
 FROM GRNAbstract, GRNDetail                                   
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND                       
 GRNDetail.Product_Code = Items.Product_Code AND                       
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And               
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And              
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
      
 "Total Sales Return" = (Cast(ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType In (4, 5, 6))                       
 AND (InvoiceAbstract.Status & 128) = 0                       
 AND InvoiceDetail.Product_Code = Items.Product_Code                       
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
        
"Sales Return Saleable" = (Cast(ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType = 4)                       
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0             
 AND InvoiceDetail.Product_Code = Items.Product_Code                   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) +   
 ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType = 5)                       
 AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) = 0             
 AND InvoiceDetail.Product_Code = Items.Product_Code                   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
        
"Sales Return Damages" = (Cast(ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType = 4)                       
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) <> 0              
 AND InvoiceDetail.Product_Code = Items.Product_Code       
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) +   
 ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType = 6)                       
 AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) <> 0              
 AND InvoiceDetail.Product_Code = Items.Product_Code       
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
               
 "Total Issues" = (Cast(ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType = 2)                       
 AND (InvoiceAbstract.Status & 128) = 0                       
 AND InvoiceDetail.Product_Code = Items.Product_Code                       
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)                       
 + ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                       
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID                          
 AND (IsNull(DispatchAbstract.Status,0) & 320) = 0            
 AND DispatchDetail.Product_Code = Items.Product_Code                       
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0)  as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
      
 "Saleable Issues" = (Cast(ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND  InvoiceAbstract.InvoiceType = 2      
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0                    
 AND InvoiceDetail.Product_Code = Items.Product_Code                       
 AND InvoiceDetail.SalePrice <> 0      
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)      
+ ISNULL((SELECT SUM(Quantity)           
FROM DispatchDetail, DispatchAbstract           
WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID           
AND (DispatchAbstract.Status & 320) = 0           
AND DispatchDetail.Product_Code = Items.Product_Code           
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE          
And DispatchDetail.SalePrice > 0), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
                  
 "Free Issues" = (Cast(ISNULL((SELECT SUM(Quantity)    
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType = 2)                       
 AND (InvoiceAbstract.Status & 128) = 0                       
 AND InvoiceDetail.Product_Code = Items.Product_Code                       
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE                       
 AND ISNULL(InvoiceDetail.SalePrice, 0) = 0), 0)      
+ ISNULL((SELECT SUM(Quantity)           
FROM DispatchDetail, DispatchAbstract           
WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID           
AND (DispatchAbstract.Status & 320) = 0           
AND DispatchDetail.Product_Code = Items.Product_Code           
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE          
And (DispatchDetail.SalePrice = 0  
OR DispatchDetail.FlagWord = 1)), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
               
 "Purchase Return" = (Cast(ISNULL((SELECT SUM(Quantity)                       
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                       
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID                       
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code                       
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE       
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
               
 "Adjustments" = (Cast(ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract                     
 WHERE ISNULL(AdjustmentType,0) in (1, 3)  
 And Product_Code = Items.Product_Code                     
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                      
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
               
 "Stock Transfer Out" = (Cast(IsNull((Select Sum(Quantity)                       
 From StockTransferOutAbstract, StockTransferOutDetail                      
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                      
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate                       
 And StockTransferOutAbstract.Status & 192 = 0              
 And StockTransferOutDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
                      
 "Stock Transfer In" = (Cast(IsNull((Select Sum(Quantity)                       
 From StockTransferInAbstract, StockTransferInDetail                       
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                      
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate                       
 And StockTransferInAbstract.Status & 192 = 0              
 And StockTransferInDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
          
"Stock Destruction" = (cast(IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                       
From StockDestructionAbstract, StockDestructionDetail,ClaimsNote           
Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                      
And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID          
And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                       
And ClaimsNote.Status & 1 <> 0             
and Items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem)  
And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
           
"Total On Hand Qty" = (Cast(CASE when (@TODATE < @NEXT_DATE) THEN ISNULL((Select Opening_Quantity FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products WHERE Product_Code = Items.Product_Code), 0) +                      
 (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
 (VanStatementAbstract.Status & 128) = 0 And VanStatementDetail.Product_Code = Items.Product_Code))              
 end as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
                   
 "On Hand Saleable Qty" = (Cast(CASE                     
 when (@TODATE < @NEXT_DATE) THEN                     
 ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)                    
 FROM OpeningDetails                     
 WHERE OpeningDetails.Product_Code = Items.Product_Code                     
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                    
 ELSE                     
 (ISNULL((SELECT SUM(Quantity)                     
 FROM Batch_Products                     
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +   
 (SELECT ISNULL(SUM(Pending), 0)                     
 FROM VanStatementDetail, VanStatementAbstract                     
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                     
 AND (VanStatementAbstract.Status & 128) = 0                     
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0)) end  as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
              
 "On Hand Free Qty" = (Cast(CASE                     
 when (@TODATE < @NEXT_DATE) THEN                     
 ISNULL((Select IsNull(Free_Saleable_Quantity, 0)                    
 FROM OpeningDetails                     
 WHERE OpeningDetails.Product_Code = Items.Product_Code                 
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                    
 ELSE                     
 (ISNULL((SELECT SUM(Quantity)                     
 FROM Batch_Products                     
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +                    
 (SELECT ISNULL(SUM(Pending), 0)                
 FROM VanStatementDetail, VanStatementAbstract                     
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                     
 AND (VanStatementAbstract.Status & 128) = 0                     
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice = 0)) end  as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
             
 "On Hand Damage Qty" = (Cast(CASE                     
 when (@TODATE < @NEXT_DATE) THEN                     
 ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                    
 FROM OpeningDetails                 
 WHERE OpeningDetails.Product_Code = Items.Product_Code                     
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                    
 ELSE                     
 (ISNULL((SELECT SUM(Quantity)                     
 FROM Batch_Products                     
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)) end  as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End)),
               
 "(%c) On Hand Value" = cast ( CASE   
 when (@TODATE < @NEXT_DATE) THEN                       
 ISNULL((Select Opening_Value                       
 FROM OpeningDetails                       
 WHERE OpeningDetails.Product_Code = Items.Product_Code                       
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                      
 ELSE                       
 ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)                       
 FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code) +                       
 (SELECT ISNULL(SUM(Pending * PurchasePrice), 0)              
 FROM VanStatementDetail, VanStatementAbstract                     
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                 
 AND (VanStatementAbstract.Status & 128) = 0                       
 And VanStatementDetail.Product_Code = Items.Product_Code))                      
 END                    
  as Decimal(18,6))                
                
  FROM Items, OpeningDetails , UOM, Manufacturer ,ItemCategories                    
  WHERE  Items.Product_Code *= OpeningDetails.Product_Code AND                  
  Items.ManufacturerID = Manufacturer.ManufacturerID And                    
  Manufacturer.Manufacturer_Name in (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) and   
  items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem) and  
  OpeningDetails.Opening_Date = @FROMDATE                       
  AND Items.UOM1 *= UOM.UOM And IsNull(Items.Active,0) = 1        
  And Items.CategoryID = ItemCategories.CategoryID                        
 end
Else if @UOM = 'UOM2'                   --UOM2             
begin                                  
 SELECT  Items.Product_Code + ',' + @MLUOM + ',' + @Manufacturer + ',' + @Item ,                      
 "Item Code" = Items.Product_Code,                       
 "Item Name" = ProductName,          
 "Category Name" = ItemCategories.Category_Name,                   
 "Sales UOM" = UOM.Description,    -- changed                    
 "Total Opening Quantity" = (Cast(ISNULL(Opening_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),            
 "Saleable Opening Quantity" = (Cast(ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
 "Free Opening Quantity" = (Cast(ISNULL(Free_Saleable_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
 "Damage Opening Quantity" = (Cast(ISNULL(Damage_Opening_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
 "(%c) Opening Value" = cast (ISNULL(Opening_Value, 0) as Decimal(18,6)),                      
               
 "Purchase" = (Cast(ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)                       
 FROM GRNAbstract, GRNDetail                                   
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND                       
 GRNDetail.Product_Code = Items.Product_Code AND                       
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And               
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And              
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),                
               
 "Free Purchase" = (Cast(ISNULL((SELECT SUM(FreeQty)                       
 FROM GRNAbstract, GRNDetail                                   
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND                       
 GRNDetail.Product_Code = Items.Product_Code AND                       
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And               
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And              
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
      
 "Total Sales Return" = (Cast(ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType In (4, 5, 6))                       
 AND (InvoiceAbstract.Status & 128) = 0                       
 AND InvoiceDetail.Product_Code = Items.Product_Code                       
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
        
"Sales Return Saleable" = (Cast(ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType = 4)                       
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0             
 AND InvoiceDetail.Product_Code = Items.Product_Code                   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) +   
 ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType = 5)                       
 AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) = 0             
 AND InvoiceDetail.Product_Code = Items.Product_Code                   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
        
"Sales Return Damages" = (Cast(ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType = 4)                       
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) <> 0              
 AND InvoiceDetail.Product_Code = Items.Product_Code       
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) +   
 ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType = 6)                       
 AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) <> 0              
 AND InvoiceDetail.Product_Code = Items.Product_Code       
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
               
 "Total Issues" = (Cast(ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType = 2)                       
 AND (InvoiceAbstract.Status & 128) = 0                       
 AND InvoiceDetail.Product_Code = Items.Product_Code                       
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)                       
 + ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                       
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID                          
 AND (IsNull(DispatchAbstract.Status,0) & 320) = 0            
 AND DispatchDetail.Product_Code = Items.Product_Code                       
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0)  as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
      
 "Saleable Issues" = (Cast(ISNULL((SELECT SUM(Quantity)                       
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND  InvoiceAbstract.InvoiceType = 2      
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0                    
 AND InvoiceDetail.Product_Code = Items.Product_Code                       
 AND InvoiceDetail.SalePrice <> 0      
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)      
+ ISNULL((SELECT SUM(Quantity)           
FROM DispatchDetail, DispatchAbstract           
WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID           
AND (DispatchAbstract.Status & 320) = 0           
AND DispatchDetail.Product_Code = Items.Product_Code           
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE          
And DispatchDetail.SalePrice > 0), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
                  
 "Free Issues" = (Cast(ISNULL((SELECT SUM(Quantity)    
 FROM InvoiceDetail, InvoiceAbstract                       
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
 AND (InvoiceAbstract.InvoiceType = 2)                       
 AND (InvoiceAbstract.Status & 128) = 0                       
 AND InvoiceDetail.Product_Code = Items.Product_Code                       
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE                       
 AND ISNULL(InvoiceDetail.SalePrice, 0) = 0), 0)      
+ ISNULL((SELECT SUM(Quantity)           
FROM DispatchDetail, DispatchAbstract           
WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID           
AND (DispatchAbstract.Status & 320) = 0           
AND DispatchDetail.Product_Code = Items.Product_Code           
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE          
And (DispatchDetail.SalePrice = 0  
OR DispatchDetail.FlagWord = 1)), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
               
 "Purchase Return" = (Cast(ISNULL((SELECT SUM(Quantity)                       
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                       
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID                       
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code                       
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE       
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
               
 "Adjustments" = (Cast(ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract                     
 WHERE ISNULL(AdjustmentType,0) in (1, 3)  
 And Product_Code = Items.Product_Code                     
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                      
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
               
 "Stock Transfer Out" = (Cast(IsNull((Select Sum(Quantity)                       
 From StockTransferOutAbstract, StockTransferOutDetail                      
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                      
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate                       
 And StockTransferOutAbstract.Status & 192 = 0              
 And StockTransferOutDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
                      
 "Stock Transfer In" = (Cast(IsNull((Select Sum(Quantity)                       
 From StockTransferInAbstract, StockTransferInDetail                       
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                      
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate                       
 And StockTransferInAbstract.Status & 192 = 0              
 And StockTransferInDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
          
"Stock Destruction" = (Cast(IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                       
From StockDestructionAbstract, StockDestructionDetail,ClaimsNote           
Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                      
And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID          
And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                       
And ClaimsNote.Status & 1 <> 0             
and Items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem)  
And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
           
"Total On Hand Qty" = (Cast(CASE when (@TODATE < @NEXT_DATE) THEN ISNULL((Select Opening_Quantity FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products WHERE Product_Code = Items.Product_Code), 0) +                      
 (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
 (VanStatementAbstract.Status & 128) = 0 And VanStatementDetail.Product_Code = Items.Product_Code))              
 end as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
                   
 "On Hand Saleable Qty" = (Cast(CASE                     
 when (@TODATE < @NEXT_DATE) THEN                     
 ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)                    
 FROM OpeningDetails                     
 WHERE OpeningDetails.Product_Code = Items.Product_Code                     
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                    
 ELSE                     
 (ISNULL((SELECT SUM(Quantity)                     
 FROM Batch_Products                     
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +   
 (SELECT ISNULL(SUM(Pending), 0)                     
 FROM VanStatementDetail, VanStatementAbstract                     
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                     
 AND (VanStatementAbstract.Status & 128) = 0                     
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0)) end  as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
              
 "On Hand Free Qty" = (Cast(CASE                     
 when (@TODATE < @NEXT_DATE) THEN                     
 ISNULL((Select IsNull(Free_Saleable_Quantity, 0)                    
 FROM OpeningDetails                     
 WHERE OpeningDetails.Product_Code = Items.Product_Code                 
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                    
 ELSE                     
 (ISNULL((SELECT SUM(Quantity)                     
 FROM Batch_Products                     
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +                    
 (SELECT ISNULL(SUM(Pending), 0)                
 FROM VanStatementDetail, VanStatementAbstract                     
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                     
 AND (VanStatementAbstract.Status & 128) = 0                     
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice = 0)) end  as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
             
 "On Hand Damage Qty" = (Cast(CASE                     
 when (@TODATE < @NEXT_DATE) THEN                     
 ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                    
 FROM OpeningDetails                 
 WHERE OpeningDetails.Product_Code = Items.Product_Code                     
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                    
 ELSE                     
 (ISNULL((SELECT SUM(Quantity)                     
 FROM Batch_Products                     
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)) end  as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End)),
               
 "(%c) On Hand Value" = cast ( CASE   
 when (@TODATE < @NEXT_DATE) THEN                       
 ISNULL((Select Opening_Value                       
 FROM OpeningDetails                       
 WHERE OpeningDetails.Product_Code = Items.Product_Code                       
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                      
 ELSE                       
 ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)                       
 FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code) +                       
 (SELECT ISNULL(SUM(Pending * PurchasePrice), 0)              
 FROM VanStatementDetail, VanStatementAbstract                     
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                 
 AND (VanStatementAbstract.Status & 128) = 0                       
 And VanStatementDetail.Product_Code = Items.Product_Code))                      
 END                    
  as Decimal(18,6))                
                
  FROM Items, OpeningDetails , UOM, Manufacturer ,ItemCategories                    
  WHERE  Items.Product_Code *= OpeningDetails.Product_Code AND                  
  Items.ManufacturerID = Manufacturer.ManufacturerID And                    
  Manufacturer.Manufacturer_Name in (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) and   
  items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem) and  
  OpeningDetails.Opening_Date = @FROMDATE                       
  AND Items.UOM2 *= UOM.UOM And IsNull(Items.Active,0) = 1        
  And Items.CategoryID = ItemCategories.CategoryID                        
 end
else                                --Reporting UOM
begin                                
 SELECT Items.Product_Code + ',' + @MLUOM + ',' + @Manufacturer + ',' + @Item ,                    
 "Item Code" = Items.Product_Code,                     
 "Item Name" = ProductName,        
 "Category Name" = ItemCategories.Category_Name,                 
 "Reporting UOM" =  UOM.Description,  -- changed                  
 "Total Opening Quantity" = cast(ISNULL(Opening_Quantity, 0) /                   
 (CASE ISNULL(Items.ReportingUnit, 0)                   
 WHEN 0 THEN                   
 1                   
 ELSE                   
 ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),                  
        
 "Saleable Opening Quantity" = cast((ISNULL(Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) /                   
 (CASE ISNULL(Items.ReportingUnit, 0)                   
 WHEN 0 THEN                   
 1                   
 ELSE                   
 ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),                  
           
 "Free Opening Quantity" = cast(IsNull(Free_Saleable_Quantity, 0) /                   
 (CASE ISNULL(Items.ReportingUnit, 0)                   
 WHEN 0 THEN                   
 1                   
 ELSE                   
 ISNULL(Items.ReportingUnit, 0)                   
 END) as Decimal(18,6)),                  
           
 "Damage Opening Quantity" = cast(IsNull(Damage_Opening_Quantity, 0)                  
 / (CASE ISNULL(Items.ReportingUnit, 0)                   
 WHEN 0 THEN                   
 1                   
 ELSE ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)) ,            
                     
 "(%c) Opening Value" = cast(ISNULL(Opening_Value, 0) as Decimal(18,6)) ,                     
 "Purchase" = cast (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)                     
 FROM GRNAbstract, GRNDetail                                 
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND                     
 GRNDetail.Product_Code = Items.Product_Code AND                     
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE                    
 And (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And            
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0 ), 0)                  
 /  (CASE ISNULL(Items.ReportingUnit, 0)            
 WHEN 0 THEN                     
 1                     
 ELSE                 
 ISNULL(Items.ReportingUnit, 0)                     
 END ) as Decimal(18,6)),              
             
 "Free Purchase" = cast(ISNULL((SELECT Sum(FreeQty)                     
 FROM GRNAbstract, GRNDetail                                 
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND                     
 GRNDetail.Product_Code = Items.Product_Code AND                     
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE                    
 And (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And            
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0 ), 0)                  
 /  (CASE ISNULL(Items.ReportingUnit, 0)                     
 WHEN 0 THEN                     
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0)                     
 END ) as Decimal(18,6)),              
    
            
 "Total Sales Return" = cast(ISNULL((SELECT SUM(Quantity)           
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType In (4, 5, 6))                     
 AND (InvoiceAbstract.Status & 128) = 0                      
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) 
 / (CASE ISNULL(Items.ReportingUnit, 0)                     
 WHEN 0 THEN                     
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0)                     
 END) as Decimal(18,6)),              
       
 "Sales Return Saleable" = cast((ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 4)                     
 AND (InvoiceAbstract.Status & 128) = 0  And (InvoiceAbstract.Status & 32) = 0                    
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) + 
 ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 5)                     
 AND (InvoiceAbstract.Status & 128) = 0  --And (InvoiceAbstract.Status & 32) = 0                    
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0))                   
 / (CASE ISNULL(Items.ReportingUnit, 0)                     
 WHEN 0 THEN                     
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0)                     
 END) as Decimal(18,6)),              
      
 "Sales Return Damages" = cast((ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 4)                     
 AND (InvoiceAbstract.Status & 128) = 0  And (InvoiceAbstract.Status & 32) <> 0                    
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) + 
ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 6)                     
 AND (InvoiceAbstract.Status & 128) = 0  --And (InvoiceAbstract.Status & 32) <> 0                    
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0))                  
 / (CASE ISNULL(Items.ReportingUnit, 0)                     
 WHEN 0 THEN          
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0)                     
 END) as Decimal(18,6)),              
                          
 "Total Issues" = cast((ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 2)                     
 AND (InvoiceAbstract.Status & 128) = 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)                     
 + ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                    
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID            
 AND (IsNull(DispatchAbstract.Status,0) & 320) = 0             
 AND DispatchDetail.Product_Code = Items.Product_Code                     
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0))                  
 / (CASE ISNULL(Items.ReportingUnit, 0)                    
 WHEN 0 THEN                     
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),              
    
    
 "Saleable Quantity" = cast((ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND  InvoiceAbstract.InvoiceType = 2 
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0                  
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceDetail.SalePrice <> 0    
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)    
 + ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                     
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID                     
 AND (IsNull(DispatchAbstract.Status,0) & 320) = 0            
 AND DispatchDetail.Product_Code = Items.Product_Code                     
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
 AND DispatchDetail.SalePrice > 0), 0))

 /  (CASE ISNULL(Items.ReportingUnit, 0)                     
 WHEN 0 THEN                     
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0)                     
 END ) as Decimal(18,6)),              
             
 "Free Issues" = cast((ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 2)                     
 AND (InvoiceAbstract.Status & 128) = 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE                     
 AND ISNULL(InvoiceDetail.SalePrice, 0) = 0), 0)
 + ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                     
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID                     
 AND (IsNull(DispatchAbstract.Status,0) & 320) = 0            
 AND DispatchDetail.Product_Code = Items.Product_Code                     
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
 AND (DispatchDetail.FlagWord = 1 OR DispatchDetail.SalePrice = 0)), 0))                  
 / (CASE ISNULL(Items.ReportingUnit, 0)                     
 WHEN 0 THEN                     
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),              
             
 "Purchase Return" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                     
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID                     
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code           
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE     
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0    
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)                  
 / (CASE ISNULL(Items.ReportingUnit, 0)                     
 WHEN 0 THEN                     
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0) END)as Decimal(18,6)),              
             
 "Adjustments" = cast(ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract 
 WHERE ISNULL(AdjustmentType,0) in (1, 3) And Product_Code = Items.Product_Code AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID       
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)                  
 / (CASE ISNULL(Items.ReportingUnit, 0)                     
 WHEN 0 THEN                     
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0) END)as Decimal(18,6)),              
             
 "Stock Transfer Out" = cast(IsNull((Select Sum(Quantity)                     
 From StockTransferOutAbstract, StockTransferOutDetail                    
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                    
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate                     
 And StockTransferOutAbstract.Status & 192 = 0            
 And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)                  
 / (CASE ISNULL(Items.ReportingUnit, 0)                   
 WHEN 0 THEN                
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),              
             
 "Stock Transfer In" = cast(IsNull((Select Sum(Quantity)                     
 From StockTransferInAbstract, StockTransferInDetail                     
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                    
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate                     
 And StockTransferInAbstract.Status & 192 = 0            
 And StockTransferInDetail.Product_Code = Items.Product_Code), 0)                  
 / (CASE ISNULL(Items.ReportingUnit, 0)                     
 WHEN 0 THEN                     
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),           
        
     
        
"Stock Destruction" = cast((IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)       
From StockDestructionAbstract, StockDestructionDetail,ClaimsNote        
Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                    
And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID        
And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                     
And ClaimsNote.Status & 1 <> 0            
and Items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem)
And StockDestructionDetail.Product_Code = Items.Product_Code), 0)) / (CASE ISNULL(Items.ReportingUnit, 0)                         
 WHEN 0 THEN                         
 1                         
 ELSE                         
 ISNULL(Items.ReportingUnit, 0)                
 END) as Decimal(18,6)), 
        
"Total On Hand Qty" = cast((CASE when (@TODATE < @NEXT_DATE) THEN ISNULL((Select Opening_Quantity FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                    
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products WHERE Product_Code = Items.Product_Code), 0) +                    
 (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                     
 (VanStatementAbstract.Status & 128) = 0 And VanStatementDetail.Product_Code = Items.Product_Code))            
 end )            
 / (CASE ISNULL(Items.ReportingUnit, 0)                         
 WHEN 0 THEN                         
 1                         
 ELSE                         
 ISNULL(Items.ReportingUnit, 0)                
 END) as Decimal(18,6)),                        
                 
 "On Hand Saleable Qty" = cast((CASE            
 when (@TODATE < @NEXT_DATE) THEN                   
 ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)                  
 FROM OpeningDetails                   
 WHERE OpeningDetails.Product_Code = Items.Product_Code                   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                  
 ELSE                   
 (ISNULL((SELECT SUM(Quantity)                   
 FROM Batch_Products                   
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +                  
 (SELECT ISNULL(SUM(Pending), 0)               
 FROM VanStatementDetail, VanStatementAbstract                   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
 AND (VanStatementAbstract.Status & 128) = 0                   
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0)) end) / (CASE ISNULL(Items.ReportingUnit, 0)                         
 WHEN 0 THEN                         
 1                         
 ELSE                         
 ISNULL(Items.ReportingUnit, 0)                         
 END) as Decimal(18,6)),                  
            
 "On Hand Free Qty" = cast((CASE                   
 when (@TODATE < @NEXT_DATE) THEN                   
 ISNULL((Select IsNull(Free_Saleable_Quantity, 0)   
 FROM OpeningDetails                   
 WHERE OpeningDetails.Product_Code = Items.Product_Code                   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                  
ELSE                   
 (ISNULL((SELECT SUM(Quantity)                   
 FROM Batch_Products                   
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +                  
 (SELECT ISNULL(SUM(Pending), 0)      
 FROM VanStatementDetail, VanStatementAbstract                   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
 AND (VanStatementAbstract.Status & 128) = 0                   
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice = 0)) end) / (CASE ISNULL(Items.ReportingUnit, 0)                         
 WHEN 0 THEN                         
 1                         
 ELSE                         
 ISNULL(Items.ReportingUnit, 0)                         
 END) as Decimal(18,6)),                  
           
 "On Hand Damage Qty" = cast(CASE                   
 when (@TODATE < @NEXT_DATE) THEN                   
 ISNULL((Select IsNull(Damage_Opening_Quantity, 0)     
 FROM OpeningDetails               
 WHERE OpeningDetails.Product_Code = Items.Product_Code                   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                  
 ELSE                   
 (ISNULL((SELECT SUM(Quantity)                   
 FROM Batch_Products                   
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)) end / (CASE ISNULL(Items.ReportingUnit, 0)                         
 WHEN 0 THEN                         
 1                         
 ELSE                         
 ISNULL(Items.ReportingUnit, 0)                         
 END) as Decimal(18,6)),                  
             
 "(%c) On Hand Value" = cast(CASE when (@TODATE < @NEXT_DATE) THEN
 ISNULL((Select Opening_Value FROM OpeningDetails 
 WHERE OpeningDetails.Product_Code = Items.Product_Code                     
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                    
 ELSE                     
 ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)                     
 FROM Batch_Products                     
 WHERE Product_Code = Items.Product_Code) +                     
 (SELECT ISNULL(SUM(Pending * PurchasePrice), 0)                     
 FROM VanStatementDetail, VanStatementAbstract                     
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                     
 AND (VanStatementAbstract.Status & 128) = 0                     
 And VanStatementDetail.Product_Code = Items.Product_Code))   END   as Decimal(18,6))              
             
 FROM Items, OpeningDetails , UOM    , Manufacturer  ,ItemCategories              
 WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND                    
 Items.ManufacturerID = Manufacturer.ManufacturerID And           
 Manufacturer.Manufacturer_Name in (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) and 
 items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem) and 
 OpeningDetails.Opening_Date = @FROMDATE                     
 AND Items.ReportingUOM *= UOM.UOM And IsNull(Items.Active,0) = 1      
 And Items.CategoryID = ItemCategories.CategoryID              
end     
    
Drop table #tmpMfr    
Drop table #tmpItem
