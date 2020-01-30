CREATE Procedure spr_Stock_Adj(@FromDate DateTime, @ToDate DateTime)    
As    
Declare @Prefix nvarchar(10)    
Declare @G nvarchar(1)    
Declare @D nvarchar(1)    
Declare @STKTFRIN NvARCHAR(10)  
Declare @STKTFROUT NvARCHAR(10)  
Set @G = dbo.LookupDictionaryItem('G', Default)    
Set @D = dbo.LookupDictionaryItem('D', Default)    
Set @STKTFRIN = dbo.LookupDictionaryItem('Stk-IN', Default)    
Set @STKTFROUT = dbo.LookupDictionaryItem('Stk-OUT', Default)    
--Select @Prefix = Prefix From Voucherprefix Where TranID = N'Stock Adjustment'    
Select "RECID" = case When Sum(std.Quantity - std.OldQty) >= 0  Then @STKTFRIN Else  @STKTFROUT end,
"RECID" = case When Sum(std.Quantity - std.OldQty) >= 0  Then @STKTFRIN Else  @STKTFROUT end,
"StockType" = Case IsNull(bp.Damage, 0) When 0 Then @G Else @D End,     
"CACode" = IsNull((Select Top 1 IsNull(DL20, N'') From Setup), N''),     
"ItemCode" = ic.Category_Name, "LOT" = IsNull(std.Batch_Number, N''),    
"PKM" = IsNull(bp.PKD, N''),     
"QTYKGS" = Sum((std.Quantity - std.OldQty) * 1000 / (Case IsNull(Items.ReportingUnit, 1)     
   When 0 Then 1 Else IsNull(Items.ReportingUnit, 1) End)),     
"QTYCASES" = Sum(std.Quantity - std.OldQty),     
"QTYUNITS" = Sum((std.Quantity - std.OldQty) * (Case IsNull(Items.ConversionFactor, 1)     
   When 0 Then 1 Else IsNull(Items.ConversionFactor, 1) End)),     
"ItemValue" = Sum(std.Rate - std.OldValue),    
"ItemDescription" = Items.ProductName,     
"Reason" = IsNull((select IsNull(Message, '') From StockAdjustmentReason Where MessageID = std.ReasonID), ''),    
"ADJDate" = sta.AdjustmentDate, "UserID" = IsNull(sta.UserName, '') From     
StockAdjustmentAbstract sta, StockAdjustment std, batch_products bp,     
--StockAdjustmentReason star,     
Items, ItemCategories ic     
Where sta.AdjustmentID = std.SerialNo And    
bp.batch_code = std.Batch_Code And     
std.Product_Code = Items.Product_Code And Items.CategoryID = ic.CategoryID    
And sta.AdjustmentType = 1 And sta.AdjustmentDate Between @FromDate And @ToDate    
Group By sta.DocumentID, bp.Damage, ic.Category_Name, std.Batch_Number,    
bp.PKD, Items.ProductName, sta.AdjustmentDate, sta.UserName, std.ReasonID  
