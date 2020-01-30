CREATE Procedure spr_list_Cancelled_GR (@FromDate datetime,
					@ToDate datetime)
As
Select GRNAbstract.GRNID, 
"GRN ID" = VoucherPrefix.Prefix + Cast(GRNAbstract.DocumentID as nvarchar),
"Date" = GRNAbstract.GRNDate, "Vendor" = Vendors.Vendor_Name,
"PO Ref" = PONumbers, "Doc Ref" = DocRef,"Remarks" = Remarks
From GRNAbstract, VoucherPrefix, Vendors
Where GRNAbstract.GRNDate Between @FromDate And @ToDate And
GRNAbstract.VendorID = Vendors.VendorID And
(GRNAbstract.GRNStatus & 64) <> 0 And
VoucherPrefix.TranID = 'GOODS RECEIVED NOTE'

