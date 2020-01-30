Create Procedure spr_list_SalesPaymentMode_ITC
(
 @FromDate DateTime,
 @ToDate DateTime,
 @Base nVarchar(50)
)
As
Declare @Opt As nVarchar

If @Base = 'CustomerWise'
	Set @Opt = '0'
Else
	Set @Opt = '1'


Select "Base" = Cast(Ia.PaymentMode As nVarchar) + ','  +  @Opt,
"Payment Mode" =  (Case  Ia.PaymentMode 
When 0 Then N'Credit Sales'
When 3 Then N'DD Sales'
Else
(Select Value From PaymentMode Where Mode  = Ia.PaymentMode) + Cast(' Sales' As nVarchar)
End),
 "Total" = Sum(NetValue)
From  InvoiceAbstract Ia
Where 
(Ia.Status & 128) = 0 
And InvoiceType In (1, 3) 
And InvoiceDate Between @FromDate  And  @ToDate
Group By Ia.PaymentMode


