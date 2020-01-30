Create Procedure spr_RetailSalesSummary_PaymentMode(@FromDate DateTime,
													@ToDate DateTime)
As
Select "Date" = N'', "Date " = [Date], 
"Cash" = Sum(Case When [Mode] In (1) Then [Value] End), 
"Credit Card" = Sum(Case When [Mode] In (3) Then [Value] End), 
"Cheque" = Sum(Case When [Mode] In (2) Then [Value] End), 
"Coupons" = Sum(Case When [Mode] In (4) Then [Value] End), 
"Gift Voucher Redemption" = Sum(Case When [Mode] In (7) Then [Value] End), 
"Credit Note Adjusted" = Sum(Case When [Mode] In (6) Then [Value] End), 
"Credit Note Issued(Sales Return)" = Sum(Case When [Mode] In (8) Then [Value] End), 
"Credit Note Issued(FA)" = Sum(Case When [Mode] In (9) Then [Value] End),
"Gift Voucher Issued" = Sum(Case When [Mode] In (10) Then [Value] End) From (
Select [Date] = Convert(nVarChar, DatePart(DD, ia.InvoiceDate)) 
+ N'/' + Convert(nVarChar, DatePart(MM, ia.InvoiceDate)) + N'/' + 
Convert(nVarChar, DatePart(YYYY, ia.InvoiceDate)), 
[Value] = Sum(rpd.NetRecieved), [Mode] = pm.PaymentType
From InvoiceAbstract ia, 
RetailPaymentDetails rpd, PaymentMode pm Where ia.InvoiceID = rpd.RetailInvoiceID 
And rpd.PaymentMode = pm.Mode
And (IsNull(ia.status, 0) & 192) = 0 And ia.InvoiceDate Between @FromDate And @ToDate
Group By ia.InvoiceDate, rpd.PaymentMode, pm.PaymentType
Union
Select [Date] = Convert(nVarChar, DatePart(DD, ia.InvoiceDate)) 
+ N'/' + Convert(nVarChar, DatePart(MM, ia.InvoiceDate)) + N'/' + 
Convert(nVarChar, DatePart(YYYY, ia.InvoiceDate)), 
[Value] = Sum(ia.Balance), [Mode] = 8 From InvoiceAbstract ia
Where ia.InvoiceDate Between @FromDate And @ToDate And 
(IsNull(ia.status, 0) & 192) = 0 And InvoiceType In (5, 6) Group By ia.InvoiceDate
Union
Select [Date] = Convert(nVarChar, DatePart(DD, cn.DocumentDate)) 
+ N'/' + Convert(nVarChar, DatePart(MM, cn.DocumentDate)) + N'/' + 
Convert(nVarChar, DatePart(YYYY, cn.DocumentDate)), 
[Value] = Sum(cn.Balance), [Mode] = 9 From CreditNote cn 
Where cn.DocumentDate Between @FromDate And @ToDate
Group By cn.DocumentDate
Union
Select [Date] = Convert(nVarChar, DatePart(DD, cl.DocumentDate)) 
+ N'/' + Convert(nVarChar, DatePart(MM, cl.DocumentDate)) + N'/' + 
Convert(nVarChar, DatePart(YYYY, cl.DocumentDate)), 
[Value] = Sum(cl.Balance), [Mode] = 10 From Collections cl Where
cl.DocumentDate Between @FromDate And @ToDate And
IsNull(cl.CustomerID, N'') = N'GIFT VOUCHER' And (IsNull(cl.status, 0) & 192) = 0
Group By cl.DocumentDate) summ
Group By [Date]

