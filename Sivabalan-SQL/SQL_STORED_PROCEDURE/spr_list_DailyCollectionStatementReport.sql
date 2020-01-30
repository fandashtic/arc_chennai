CREATE procedure spr_list_DailyCollectionStatementReport(@Fromdate Datetime,
@Todate Datetime)
As
Set dateformat dmy
Select 1,
"Date" = Dbo.StripDateFromTime(Collections.DocumentDate),
"Cash" = Sum((Case Collections.PaymentMode 
When 0 Then ISnull(Collections.Value,0) Else 0 End)),
"Cheque" = Sum((Case Collections.PaymentMode 
When 1 Then ISnull(Collections.Value,0) Else 0 End)),
"DD" = Sum((Case Collections.PaymentMode 
When 2 Then ISnull(Collections.Value,0) Else 0 End)),
"Credit Card" = Sum((Case Collections.PaymentMode 
When 3 Then ISnull(Collections.Value,0) Else 0 End)),
"Bank Transfer" = Sum((Case Collections.PaymentMode 
When 4 Then ISnull(Collections.Value,0) Else 0 End)),
"Coupon" = Sum((Case Collections.PaymentMode 
When 5 Then ISnull(Collections.Value,0) Else 0 End)), 
"Total" = Sum(Collections.Value) 
from Collections where
Collections.Customerid Is Not Null and
(IsNull(Collections.Status, 0) & 192) = 0 And 
DocumentDate Between @FromDate And @Todate
And Collections.PaymentMode in (0,1,2,3,4,5)
Group By Dbo.StripDateFromTime(Collections.DocumentDate)



