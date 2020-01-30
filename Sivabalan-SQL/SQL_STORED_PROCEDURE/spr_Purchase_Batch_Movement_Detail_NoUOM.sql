CREATE Procedure spr_Purchase_Batch_Movement_Detail_NoUOM (@ProductCode nvarchar(255), @BatchNumber    
nvarchar(255), @FromDate DateTime, @ToDate DateTime)    
As    
    
Declare @GPrefix nvarchar(50)    
Declare @PRPrefix nvarchar(50)    
Declare @PurchaseReturn nvarchar(50)
Declare @GRN nvarchar(50)

set @PurchaseReturn = dbo.LookupDictionaryItem(N'Purchase Return',default)
set @GRN = dbo.LookupDictionaryItem(N'GRN',default)

Select @GPrefix = Prefix From VoucherPrefix Where TranID = N'GOODS RECEIVED NOTE'    
Select @PRPrefix = Prefix From VoucherPrefix Where TranID = N'PURCHASE RETURN'    
 
Select g.DocumentID,   
  "GRN ID/Purchase Return ID" = @GPrefix + Cast(g.DocumentID As nvarchar),     
  "Doc Type" = @GRN, "Doc Number" = g.DocumentReference, "Date" = g.GRNDate,    
  "Vendor ID" = v.VendorID,   
  "Vendor Name" = v.Vendor_Name,   
  "Quantity" = Sum(bp.QuantityReceived),    
  "UOM Description" = IsNull((Select IsNull(UOM.[Description], N'') From Items, UOM Where   
    Items.UOM = UOM.UOM And Product_Code = i.Product_code), N''),  
  "Reporting Unit" = dbo.sp_Get_ReportingQty(Sum(bp.QuantityReceived), i.ReportingUnit),  
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
Case When gd.TOQ=1 and bp.PurchasePrice > 0 Then (select sum(Taxamount) from billdetail where billid in (select billid from billabstract ba where ba.GRNID=convert(nvarchar,gd.GRNID) and ba.status=0) and product_code=@ProductCode) Else ((Sum(bp.QuantityReceived) * bp.PurchasePrice) * bp.TaxSuffered)/100 End   
From GRNAbstract g, GRNDetail gd, Batch_Products bp, Items i, Vendors v 
Where g.GRNID = gd.GRNID And    
  g.GRNID = bp.GRN_ID And gd.Product_Code = bp.Product_Code And g.VendorID = v.VendorID And gd.Product_Code = i.Product_Code And     
  i.Product_Code = @ProductCode    
  And bp.Batch_Number Like @BatchNumber And g.GRNDate Between @FromDate And @ToDate  
  And IsNull(g.GRNStatus, 0) & 96 = 0  
Group By g.DocumentID, g.DocumentReference, g.GRNDate, v.VendorID, v.Vendor_Name,    
  i.ReportingUnit, i.ReportingUOM,    
  i.ConversionFactor, i.ConversionUnit, i.Product_Code,    
  bp.Batch_Number, bp.PKD, bp.Expiry, bp.PurchasePrice, bp.TaxSuffered,gd.TOQ,gd.GRNID 
    
Union    
    
Select a.DocumentID,   
  "GRN ID/Purchase Return ID" = 
  Case ISNULL(a.GSTFlag,0) When 0 then @PRPrefix + Cast(a.DocumentID As nvarchar) ELSE ISNULL(a.GSTFullDocID,'') END,      
  --"GRN ID/Purchase Return ID" = @PRPrefix + Cast(a.DocumentID As nvarchar),   
  "Doc Type" = @PurchaseReturn,     
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
  "Net Value" = Sum(ad.Quantity * ad.Rate) + Sum(ad.TaxAmount)
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
  bp.Batch_Number, bp.PKD, bp.Expiry, bp.PurchasePrice, ad.Tax,a.GSTFlag,a.GSTFullDocID 
