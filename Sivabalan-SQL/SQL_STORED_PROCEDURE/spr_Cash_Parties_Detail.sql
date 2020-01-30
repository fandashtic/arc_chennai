CREATE Procedure spr_Cash_Parties_Detail (@ChannelType int,
					  @FromDate Datetime,
					  @ToDate Datetime)
As
Select InvoiceAbstract.CustomerID,
"CustomerID" = InvoiceAbstract.CustomerID,
"Customer" = Customer.Company_Name,
"Invoice Date" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),
"Value" = Sum(IsNull(InvoiceAbstract.NetValue, 0) - IsNull(InvoiceAbstract.Freight, 0))
From InvoiceAbstract, Customer
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
InvoiceAbstract.Status & 128 = 0 And
InvoiceAbstract.CustomerID = Customer.CustomerID And
IsNull(Customer.ChannelType, 0) = @ChannelType And
InvoiceAbstract.InvoiceType in (1, 3) And
InvoiceAbstract.PaymentMode = 1
Group By InvoiceAbstract.CustomerID, 
dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),
Customer.Company_Name
