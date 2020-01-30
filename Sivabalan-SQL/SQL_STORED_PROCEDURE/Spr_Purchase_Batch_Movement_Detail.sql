CREATE Procedure Spr_Purchase_Batch_Movement_Detail (@ProductCode nvarchar(255), @BatchNumber    
nvarchar(255), @FromDate DateTime, @ToDate DateTime)    
As    
    
Declare @GPrefix nvarchar(50)    
Declare @PRPrefix nvarchar(50)    
    
Select @GPrefix = Prefix From VoucherPrefix Where TranID = 'GOODS RECEIVED NOTE'    
Select @PRPrefix = Prefix From VoucherPrefix Where TranID = 'PURCHASE RETURN'    
    
Select g.DocumentID, "GRN ID/Purchase Return ID" = @GPrefix + Cast(g.DocumentID As nvarchar),     
"Doc Type" = 'GRN', "Doc Number" = g.DocumentReference, "Date" = g.GRNDate,    
"Vendor ID" = v.VendorID, "Vendor Name" = v.Vendor_Name, "Quantity" = Sum(gd.QuantityReceived),    
"UOM1" = Case When IsNull(i.UOM1, 0) < 1 or IsNull(i.UOM1_Conversion, 0) < 1 Then ' ' Else    
Cast((Sum(gd.QuantityReceived) / i.UOM1_Conversion) As nvarchar) + ' ' + (Select     
UOM.[Description] From Items, UOM Where UOM1 = UOM.UOM And Product_Code = i.Product_code) End,    
"UOM2" = Case When IsNull(i.UOM2, 0) < 1 or IsNull(i.UOM2_Conversion, 0) < 1 Then ' ' Else     
Cast((Sum(gd.QuantityReceived) / i.UOM2_Conversion) As nvarchar) + ' ' + (Select     
UOM.[Description] From Items, UOM Where UOM2 = UOM.UOM And Product_Code = i.Product_code)End,    
"Reporting Unit" = Case When IsNull(i.ReportingUOM, 0) < 1 or    
IsNull(i.ReportingUnit, 0) < 1  Then ' ' Else     
Cast( (Sum(gd.QuantityReceived) / i.ReportingUnit) As nvarchar) + ' ' + (Select     
UOM.[Description] From Items, UOM Where ReportingUOM = UOM.UOM And Product_Code = i.Product_code) End,    
"Conversion Factor" = Case When IsNull(i.ConversionFactor, 0) < 1 or    
IsNull(i.ConversionUnit, 0) < 1 Then ' ' Else     
Cast((Sum(gd.QuantityReceived) * i.ConversionFactor) As nvarchar) + ' ' + (Select     
ConversionTable.ConversionUnit From Items, ConversionTable Where Items.ConversionUnit = ConversionID And     
Product_Code = i.Product_Code) End,    
"Batch No" = bp.Batch_Number, "PKD" = bp.PKD, "Expiry Date" = bp.Expiry,    
"Purchase Price" = bp.PurchasePrice, "Value" = Sum(gd.QuantityReceived) * bp.PurchasePrice,    
"Tax Suffered" = bp.TaxSuffered,     
"Net Value" = (Sum(gd.QuantityReceived) * bp.PurchasePrice) + ((Sum(gd.QuantityReceived) * bp.PurchasePrice) * bp.TaxSuffered)/100    
From GRNAbstract g, GRNDetail gd, Batch_Products bp, Items i, Vendors v     
Where g.GRNID = gd.GRNID And    
g.GRNID = bp.GRN_ID And g.VendorID = v.VendorID And gd.Product_Code = i.Product_Code And     
i.Product_Code = @ProductCode    
And bp.Batch_Number Like @BatchNumber And g.GRNDate Between @FromDate And @ToDate    
Group By g.DocumentID, g.DocumentReference, g.GRNDate, v.VendorID, v.Vendor_Name,    
i.UOM1, i.UOM1_Conversion, i.UOM2, i.UOM2_Conversion, i.ReportingUnit, i.ReportingUOM,    
i.ConversionFactor, i.ConversionUnit, i.Product_Code,    
bp.Batch_Number, bp.PKD, bp.Expiry, bp.PurchasePrice, bp.TaxSuffered    
    
Union    
    
Select a.DocumentID, "GRN ID/Purchase Return ID" = @PRPrefix +     
Cast(a.DocumentID As nvarchar), "Doc Type" = 'Purchase Return',     
"Doc Number" = a.Reference, "Date" = a.AdjustmentDate,    
"Vendor ID" = v.VendorID, "Vendor Name" = v.Vendor_Name, "Quantity" = Sum(ad.Quantity),    
"UOM1" = Case When IsNull(i.UOM1, 0) < 1 or IsNull(i.UOM1_Conversion, 0) < 1 Then ' ' Else    
Cast((Sum(ad.Quantity) / i.UOM1_Conversion) As nvarchar) + ' ' + (Select     
UOM.[Description] From Items, UOM Where UOM1 = UOM.UOM And Product_Code = i.Product_code) End,    
"UOM2" = Case When IsNull(i.UOM2, 0) < 1 or IsNull(i.UOM2_Conversion, 0) < 1 Then ' ' Else     
Cast((Sum(ad.Quantity) / i.UOM2_Conversion) As nvarchar) + ' ' + (Select     
UOM.[Description] From Items, UOM Where UOM2 = UOM.UOM And Product_Code = i.Product_code)End,    
"Reporting Unit" = Case When IsNull(i.ReportingUOM, 0) < 1 or    
IsNull(i.ReportingUnit, 0) < 1  Then ' ' Else     
Cast( (Sum(ad.Quantity) / i.ReportingUnit) As nvarchar) + ' ' + (Select  
UOM.[Description] From Items, UOM Where ReportingUOM = UOM.UOM And Product_Code = i.Product_code) End,    
"Conversion Factor" = Case When IsNull(i.ConversionFactor, 0) < 1 or    
IsNull(i.ConversionUnit, 0) < 1 Then ' ' Else     
Cast((Sum(ad.Quantity) * i.ConversionFactor) As nvarchar) + ' ' + (Select     
ConversionTable.ConversionUnit From Items, ConversionTable Where Items.ConversionUnit = ConversionID And     
Product_Code = i.Product_Code) End,    
"Batch No" = bp.Batch_Number, "PKD" = bp.PKD, "Expiry Date" = bp.Expiry,    
"Purchase Price" = bp.PurchasePrice, "Value" = Sum(ad.Quantity * ad.Rate),    
"Tax Suffered" = ad.Tax,    
"Net Value" = Sum(ad.Quantity * ad.Rate) + (Sum(ad.Quantity * ad.Rate) * ad.Tax)/100    
From AdjustmentReturnAbstract a, AdjustmentReturnDetail ad, Batch_Products bp, Items i, Vendors v     
Where a.AdjustmentID = a.AdjustmentID And    
ad.BatchCode = bp.Batch_Code And a.VendorID = v.VendorID And ad.Product_Code = i.Product_Code And     
i.Product_Code = @ProductCode    
And bp.Batch_Number Like @BatchNumber And a.AdjustmentDate Between @FromDate And @ToDate    
Group By a.DocumentID, a.Reference, a.AdjustmentDate, v.VendorID, v.Vendor_Name,    
i.UOM1, i.UOM1_Conversion, i.UOM2, i.UOM2_Conversion, i.ReportingUnit, i.ReportingUOM,    
i.ConversionFactor, i.ConversionUnit, i.Product_Code,    
bp.Batch_Number, bp.PKD, bp.Expiry, bp.PurchasePrice, ad.Tax    
  
  


