CREATE Procedure spr_List_ShortageIncome_Detail (@Unused int,
						@FromDate datetime,
						@ToDate datetime)
As
Select PaymentDetail.DocumentID,
"Doc ID" = PaymentDetail.OriginalID,
"Doc Date" = PaymentDetail.DocumentDate,
"Doc Ref" = IsNull(PaymentDetail.DocumentReference, N''),
"Vendor ID" = Payments.VendorID,
"Vendor" = Vendors.Vendor_Name,
"Payment ID" = Payments.FullDocID,
"Extra Payment" = IsNull(PaymentDetail.ExtraCol, 0),
"Write Off" = IsNull(PaymentDetail.Adjustment, 0)
From PaymentDetail, Payments, Vendors
Where PaymentDetail.PaymentID = Payments.DocumentID And
Payments.DocumentDate Between @FromDate And @ToDate And
(IsNull(PaymentDetail.ExtraCol, 0) <> 0 Or
IsNull(PaymentDetail.Adjustment, 0) <> 0) And
Payments.VendorID = Vendors.VendorID And
IsNull(Payments.Status, 0) & 128 = 0
