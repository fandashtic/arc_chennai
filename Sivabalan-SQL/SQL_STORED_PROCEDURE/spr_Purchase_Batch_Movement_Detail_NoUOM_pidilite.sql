CREATE Procedure spr_Purchase_Batch_Movement_Detail_NoUOM_pidilite (@ProductCode nvarchar(255), @BatchNumber      
nvarchar(255), @FromDate DateTime, @ToDate DateTime)      
As      
      
Declare @GPrefix nvarchar(50)      
Declare @PRPrefix nvarchar(50)      
      
Select @GPrefix = Prefix From VoucherPrefix Where TranID = N'GOODS RECEIVED NOTE'      
Select @PRPrefix = Prefix From VoucherPrefix Where TranID = N'PURCHASE RETURN'      
      
Select g.DocumentID,     
  "GRN ID/Purchase Return ID" = @GPrefix + Cast(g.DocumentID As nvarchar),       
  "Doc Type" = N'GRN', "Doc Number" = g.DocumentReference, "Date" = g.GRNDate,      
  "Vendor ID" = v.VendorID,     
  "Vendor Name" = v.Vendor_Name,     
  "Quantity" = Sum(bp.QuantityReceived),      
  "UOM Description" = IsNull((Select IsNull(UOM.[Description], N'') From Items, UOM Where     
    Items.UOM = UOM.UOM And Product_Code = i.Product_code), N''),    
  "Reporting Unit" = Sum(bp.QuantityReceived / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),  
  "UOM Description" = (Select UOM.[Description] From Items, UOM Where     
    ReportingUOM = UOM.UOM And Product_Code = i.Product_code),      
  "Conversion Factor" = Sum(bp.QuantityReceived) *     
    Case When IsNull(i.ConversionFactor, 0) < 1 Then 1 Else     
    IsNull(i.ConversionFactor, 0) End,    
  "UOM Description" = IsNull((Select       
    IsNull(ConversionTable.ConversionUnit, N'') From Items, ConversionTable Where     
    Items.ConversionUnit = ConversionID And       
    Product_Code = i.Product_Code), N''),      
  "Batch No" = bp.Batch_Number,     
  "PKD" = bp.PKD,     
  "Expiry Date" = bp.Expiry,      
  "Purchase Price" = bp.PurchasePrice,     
  "Value" = Sum(bp.QuantityReceived) * bp.PurchasePrice,      
  "Tax Suffered" = bp.TaxSuffered,       
  "Net Value" = (Sum(bp.QuantityReceived) * bp.PurchasePrice) +     
    ((Sum(bp.QuantityReceived) * bp.PurchasePrice) * bp.TaxSuffered)/100      
From GRNAbstract g, GRNDetail gd, Batch_Products bp, Items i, Vendors v       
Where g.GRNID = gd.GRNID And      
  g.GRNID = bp.GRN_ID And gd.Product_Code = bp.Product_Code And g.VendorID = v.VendorID And gd.Product_Code = i.Product_Code And       
  i.Product_Code = @ProductCode      
  And bp.Batch_Number Like @BatchNumber And g.GRNDate Between @FromDate And @ToDate    
  And IsNull(g.GRNStatus, 0) & 96 = 0    
Group By g.DocumentID, g.DocumentReference, g.GRNDate, v.VendorID, v.Vendor_Name,      
  i.ReportingUnit, i.ReportingUOM,      
  i.ConversionFactor, i.ConversionUnit, i.Product_Code,      
  bp.Batch_Number, bp.PKD, bp.Expiry, bp.PurchasePrice, bp.TaxSuffered      
      
Union      
      
Select a.DocumentID,     
  "GRN ID/Purchase Return ID" = @PRPrefix +       
    Cast(a.DocumentID As nvarchar),     
  "Doc Type" = N'Purchase Return',       
  "Doc Number" = a.Reference,     
  "Date" = a.AdjustmentDate,      
  "Vendor ID" = v.VendorID,     
  "Vendor Name" = v.Vendor_Name,     
  "Quantity" = Sum(ad.Quantity),      
  "UOM Description" = IsNull((Select IsNull(UOM.[Description], N'') From Items, UOM Where     
    Items.UOM = UOM.UOM And Product_Code = i.Product_code), N''),    
  "Reporting Unit" = dbo.sp_Get_ReportingUOMQty(i.Product_Code, Sum(ad.Quantity)),    
  "UOM Description" = (Select UOM.[Description] From Items, UOM Where     
    ReportingUOM = UOM.UOM And Product_Code = i.Product_code),      
  "Conversion Factor" = Sum(ad.Quantity) *     
    Case When IsNull(i.ConversionFactor, 0) < 1 Then 1 Else     
    IsNull(i.ConversionFactor, 0) End,    
  "UOM Description" = IsNull((Select       
    IsNull(ConversionTable.ConversionUnit, N'') From Items, ConversionTable Where     
    Items.ConversionUnit = ConversionID And       
    Product_Code = i.Product_Code), N''),      
  "Batch No" = bp.Batch_Number,     
  "PKD" = bp.PKD,     
  "Expiry Date" = bp.Expiry,      
  "Purchase Price" = bp.PurchasePrice,     
  "Value" = Sum(ad.Quantity * ad.Rate),      
  "Tax Suffered" = ad.Tax,      
  "Net Value" = Sum(ad.Quantity * ad.Rate) + (Sum(ad.Quantity * ad.Rate) * ad.Tax)/100      
From AdjustmentReturnAbstract a, AdjustmentReturnDetail ad, Batch_Products bp, Items i,     
  Vendors v       
Where a.AdjustmentID = ad.AdjustmentID And      
  ad.BatchCode = bp.Batch_Code And a.VendorID = v.VendorID And     
  ad.Product_Code = i.Product_Code And       
  i.Product_Code = @ProductCode      
  And bp.Batch_Number Like @BatchNumber And a.AdjustmentDate Between @FromDate And @ToDate    
  And IsNull(a.Status, 0) & 192 = 0    
Group By a.DocumentID, a.Reference, a.AdjustmentDate, v.VendorID, v.Vendor_Name,      
  i.ReportingUnit, i.ReportingUOM,      
  i.ConversionFactor, i.ConversionUnit, i.Product_Code,      
  bp.Batch_Number, bp.PKD, bp.Expiry, bp.PurchasePrice, ad.Tax      
      
    
    



