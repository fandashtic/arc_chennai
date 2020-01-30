CREATE procedure [dbo].[spr_ser_list_Invoicewise_Collections] (@FromDate datetime,  
         @ToDate datetime)  
As  

Select "InvID" = (cast(InvAbs.InvoiceID  as nvarchar(20)) + char(2) + '1') , 
"Invoice ID" = VoucherPrefix.Prefix + Cast(InvAbs.DocumentID as nvarchar),  
"Doc Ref" = InvAbs.DocReference,  
"Invoice Date" = InvAbs.InvoiceDate,   
"Customer" = Customer.Company_Name,  
"Salesman" = Salesman.Salesman_Name,   
"Payment Mode" = case IsNull(PaymentMode,0)  
When 0 Then 'Credit'  
When 1 Then 'Cash'  
When 2 Then 'Cheque'  
When 3 Then 'DD'  
Else 'Credit'  
End,  
"Net Value" =  Case InvoiceType  
When 4 then  
0 - InvAbs.NetValue  
Else  
InvAbs.NetValue  
End,   
"Balance" = Case InvoiceType
when 4 then
0-(InvAbs.Balance)
else
InvAbs.Balance
end,
"Type" = Case InvoiceType  
When 1 then  
'Invoice'  
When 3 Then  
'Invoice Amendment'  
When 4 Then  
'Sales Return'  
End,
"Rounded Net Value"  = NetValue + RoundOffAmount
From InvoiceAbstract InvAbs, Customer, Salesman, VoucherPrefix  
Where InvAbs.InvoiceDate Between @FromDate And @ToDate And  
InvAbs.InvoiceType in (1, 3, 4) And  
IsNull(InvAbs.Status, 0) & 128 = 0 And  
InvAbs.CustomerID = Customer.CustomerID And  
InvAbs.SalesmanID *= Salesman.SalesmanID And  
VoucherPrefix.TranID = 'INVOICE'  
  
Union All  
  
Select "InvID" = (cast(InvAbs.InvoiceID  as nvarchar(20)) + char(2) + '1'), 
"Invoice ID" = VoucherPrefix.Prefix + Cast(InvAbs.DocumentID as nvarchar),  
"Doc Ref" = InvAbs.DocReference,  
"Invoice Date" = InvAbs.InvoiceDate,   
"Customer" = Customer.Company_Name,  
"Salesman" = Salesman.Salesman_Name,
"Payment Mode" = case IsNull(PaymentMode,0)  
When 0 Then 'Credit'  
When 1 Then 'Others'
End,  
"Net Value" = Case InvoiceType  
When 5 then  
0 - IsNull(InvAbs.NetValue, 0)
When 6 then  
0 - IsNull(InvAbs.NetValue, 0)
Else  
IsNull(InvAbs.NetValue, 0)
End,   
"Balance" = Case InvoiceType  
When 5 then  
0 - IsNull(InvAbs.Balance, 0)
When 6 then  
0 - IsNull(InvAbs.Balance, 0)
Else  
IsNull(InvAbs.Balance, 0)
End,   
"Type" = Case InvoiceType  
When 5 then  
'Sales Return - Saleable'
When 6 then  
'Sales Return - Damages'
Else  
'Retail Invoice'
End,
"Rounded Net Value"  = NetValue + RoundOffAmount
From InvoiceAbstract InvAbs, Customer, Salesman, VoucherPrefix  
Where InvAbs.InvoiceDate Between @FromDate And @ToDate And  
InvAbs.InvoiceType In (2, 5, 6) And  
IsNull(InvAbs.Status, 0) & 128 = 0 And  
InvAbs.CustomerID *= Customer.CustomerID And  
InvAbs.SalesmanID *= Salesman.SalesmanID And  
VoucherPrefix.TranID = 'INVOICE'  

Union All

Select "InvID" = (cast(SerAbs.ServiceInvoiceID as nvarchar(20)) + char(2) + '2'),
"Invoice ID" = VoucherPrefix.Prefix + Cast(SerAbs.DocumentID as nvarchar),  
"Doc Ref" = SerAbs.DocReference,  
"Invoice Date" = SerAbs.ServiceInvoiceDate,   
"Customer" = Customer.Company_name,
"Salesman" = '',
"Payment Mode" = case IsNull(PaymentMode,0)  
When 0 Then 'Credit'  
When 1 Then 'Cash'  
When 2 Then 'Cheque'  
When 3 Then 'DD'  
when 4 Then 'Credit Card'
when 5 Then 'Coupon'  
End,  
"Net Value" =  SerAbs.NetValue,  
"Balance" =SerAbs.Balance,
"Type" = 'Service Invoice',  
"Rounded Net Value"  = NetValue + RoundOffAmount
From ServiceInvoiceAbstract SerAbs, Customer, VoucherPrefix  
Where  SerAbs.ServiceInvoiceDate Between @FromDate And @ToDate AND
SerAbs.ServiceInvoiceType  = 1 and 
IsNull(SerAbs.Status, 0) & 192 = 0 And  
SerAbs.CustomerID = Customer.CustomerID And  
VoucherPrefix.TranID = 'SERVICEINVOICE' 

Order By "Type", "Invoice ID"
