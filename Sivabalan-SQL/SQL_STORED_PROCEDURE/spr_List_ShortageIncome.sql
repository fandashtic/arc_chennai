CREATE Procedure spr_List_ShortageIncome (@FromDate datetime,
					  @ToDate datetime)
As
Select 1, 
"Write Off (Rs)" = Sum(Adjustment),
"Addln. Adj (Rs)" = Sum(ExtraCol),
"Net Value (Rs)" = Sum(Adjustment) - Sum(ExtraCol)
From Payments, PaymentDetail
Where Payments.DocumentID = PaymentDetail.PaymentID And
Payments.DocumentDate Between @FromDate And @ToDate And
(IsNull(PaymentDetail.ExtraCol, 0) <> 0 Or 
IsNull(PaymentDetail.Adjustment, 0) <> 0) And
IsNull(Payments.Status, 0) & 128 = 0

