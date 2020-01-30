Create Procedure spr_list_cancelled_PurchaseReturn (	@FromDate datetime,
							@ToDate datetime)
As
Select "Doc Serial" = AdjustmentReturnAbstract.AdjustmentID,
"Adjustment ID" = VoucherPrefix.Prefix + Cast(AdjustmentReturnAbstract.DocumentID as nvarchar),
"Date" = AdjustmentReturnAbstract.AdjustmentDate,
"Vendor" = Vendors.Vendor_Name, "Value" = AdjustmentReturnAbstract.Value,
"Balance" = AdjustmentReturnAbstract.Balance
From AdjustmentReturnAbstract, Vendors, VoucherPrefix
Where AdjustmentReturnAbstract.AdjustmentDate Between @FromDate And @ToDate And
AdjustmentReturnAbstract.VendorID = Vendors.VendorID And
(IsNull(AdjustmentReturnAbstract.Status, 0) & 192) = 192 And
VoucherPrefix.TranID = 'STOCK ADJUSTMENT PURCHASE RETURN'

