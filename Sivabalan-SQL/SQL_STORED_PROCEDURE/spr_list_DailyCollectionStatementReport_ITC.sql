CREATE procedure spr_list_DailyCollectionStatementReport_ITC(@Fromdate Datetime,
@Todate Datetime)
As
Set dateformat dmy

Create Table #Temp1 (CollID int,DocDate datetime,Cash decimal(18,6),Cheque decimal(18,6),DD decimal(18,6),
CreditCard decimal(18,6),BankTransfer decimal(18,6),Coupon decimal(18,6),SalesReturn decimal(18,6),
CreditNote decimal(18,6),Total decimal(18,6))

Insert Into #Temp1
Select cl.DocumentID,
Dbo.StripDateFromTime(cl.DocumentDate),
Sum((Case cl.PaymentMode 
When 0 Then ISnull(cl.Value,0) Else 0 End)),
Sum((Case cl.PaymentMode 
When 1 Then ISnull(cl.Value,0) Else 0 End)),
Sum((Case cl.PaymentMode 
When 2 Then ISnull(cl.Value,0) Else 0 End)),
Sum((Case cl.PaymentMode 
When 3 Then ISnull(cl.Value,0) Else 0 End)),
Sum((Case cl.PaymentMode 
When 4 Then ISnull(cl.Value,0) Else 0 End)),
Sum((Case cl.PaymentMode 
When 5 Then ISnull(cl.Value,0) Else 0 End)), 
IsNull((Select Sum(AdjustedAmount) From CollectionDetail cld 
Where cl.DocumentID=cld.CollectionID And DocumentType = 1),0),
IsNull((Select Sum(IsNull(AdjustedAmount,0)) From CollectionDetail cld 
Where cl.DocumentID=cld.CollectionID And DocumentType = 2),0),
Sum(cl.Value)+(Select IsNull(Sum(AdjustedAmount),0) From CollectionDetail cld 
Where cl.DocumentID=cld.CollectionID And cld.DocumentType in (1,2)) 
From Collections cl Where cl.Customerid Is Not Null and (IsNull(cl.Status, 0) & 192) = 0 And 
DocumentDate Between @FromDate And @Todate And cl.PaymentMode in (0,1,2,3,4,5) 
Group By Dbo.StripDateFromTime(cl.DocumentDate), cl.DocumentID

Select 1, "Date" = DocDate, "Cash" = Sum(Cash), "Cheque" = Sum(Cheque), "DD" = Sum(DD), 
"Credit Card" = Sum(CreditCard), "Bank Transfer" = Sum(BankTransfer), "Coupon" = Sum(Coupon), 
"Sales Return" = Sum(SalesReturn), "Credit Note" = Sum(CreditNote), "Total" = Sum(Total) 
From #Temp1 Group By DocDate

Drop Table #Temp1

