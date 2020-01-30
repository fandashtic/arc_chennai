CREATE Procedure spr_list_DailyCollection (@FromDate datetime,
					   @ToDate datetime)
As
Select 1, "Payment Mode" = 'Cash', "Amount" = IsNull(Sum(Value), 0) 
From Collections 
Where DocumentDate Between @FromDate And @ToDate And
IsNull(Status, 0) & 128 = 0 And PaymentMode = 0 And Value > 0
Union
Select 2, "Payment Mode" = 'Cheque', "Amount" = IsNull(Sum(Value), 0) 
From Collections
Where DocumentDate Between @FromDate And @ToDate And
IsNull(Status, 0) & 128 = 0 And PaymentMode = 1 And 
dbo.StripDateFromTime(ChequeDate) = dbo.StripDateFromTime(@FromDate)
Union
Select 3, "Payment Mode" = 'PostDated Cheque', "Amount" = IsNull(Sum(Value), 0) 
From Collections
Where DocumentDate Between @FromDate And @ToDate And
IsNull(Status, 0) & 128 = 0 And PaymentMode = 1 And 
dbo.StripDateFromTime(ChequeDate) > dbo.StripDateFromTime(@FromDate)
Union
Select 4, "Payment Mode" = 'DD', "Amount" = IsNull(Sum(Value), 0) 
From Collections
Where DocumentDate Between @FromDate And @ToDate And
IsNull(Status, 0) & 128 = 0 And PaymentMode = 2
