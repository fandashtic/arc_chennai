CREATE procedure [dbo].[spr_list_Invoicewise_Collections_ARU_Chevron] (@FromDate datetime,  
         @ToDate datetime)  
As

Declare @CREDIT As NVarchar(50)
Declare @CASH As NVarchar(50)
Declare @CHEQUE As NVarchar(50)
Declare @DD As NVarchar(50)
Declare @OTHERS As NVarchar(50)
Declare @INVOICE As NVarchar(50)
Declare @RETAILINVOICE As NVarchar(50)
Declare @SALESRETURNSALEABLE As NVarchar(50)
Declare @SALESRETURNDAMAGES As NVarchar(50)
Declare @SALESRETURN As NVarchar(50)
Declare @INVOICEAMENDMENT As NVarchar(50)

Set @CREDIT = dbo.LookupDictionaryItem(N'Credit', Default)
Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default)
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)
Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice' , Default)
Set @SALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'Sales Return - Saleable', Default)
Set @SALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'Sales Return - Damages', Default)
Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)
Set @INVOICEAMENDMENT = dbo.LookupDictionaryItem(N'Invoice Amendment', Default)
  
Select InvoiceID, "InvoiceID" = VoucherPrefix.Prefix +   
Cast(InvoiceAbstract.DocumentID as nvarchar),  
"Doc Ref" = InvoiceAbstract.DocReference,  
"Invoice Date" = InvoiceAbstract.InvoiceDate,   
"Customer" = Customer.Company_Name,  
"Salesman" = Salesman.Salesman_Name,   
"Payment Mode" = case IsNull(PaymentMode,0)  
When 0 Then @CREDIT  
When 1 Then @CASH  
When 2 Then @CHEQUE  
When 3 Then @DD  
Else @CREDIT
End,  
"Net Value" =  Case InvoiceType  
When 4 then  
0 - InvoiceAbstract.NetValue  
Else  
InvoiceAbstract.NetValue  
End,   
"Balance" = Case InvoiceType
when 4 then
0-(InvoiceAbstract.Balance)
else
InvoiceAbstract.Balance
end,
"Type" = Case InvoiceType  
When 1 then  
@INVOICE
When 3 Then  
@INVOICEAMENDMENT
When 4 Then  
@SALESRETURN
End,
"Rounded Net Value"  = NetValue + RoundOffAmount
From InvoiceAbstract, Customer, Salesman, VoucherPrefix  
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
InvoiceAbstract.InvoiceType in (1, 3, 4) And  
IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
InvoiceAbstract.CustomerID = Customer.CustomerID And  
InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And  
VoucherPrefix.TranID = 'INVOICE'  
  
Union All  
  
Select InvoiceID, "InvoiceID" = VoucherPrefix.Prefix +   
Cast(InvoiceAbstract.DocumentID as nvarchar),  
"Doc Ref" = InvoiceAbstract.DocReference,  
"Invoice Date" = InvoiceAbstract.InvoiceDate,   
"Customer" = Customer.Company_Name,  
"Salesman" = Salesman.Salesman_Name,
"Payment Mode" = case IsNull(PaymentMode,0)  
When 0 Then @CREDIT
When 1 Then @OTHERS
End,  
"Net Value" = Case InvoiceType  
When 5 then  
0 - IsNull(InvoiceAbstract.NetValue, 0)
When 6 then  
0 - IsNull(InvoiceAbstract.NetValue, 0)
Else  
IsNull(InvoiceAbstract.NetValue, 0)
End,   
"Balance" = Case InvoiceType  
When 5 then  
0 - IsNull(InvoiceAbstract.Balance, 0)
When 6 then  
0 - IsNull(InvoiceAbstract.Balance, 0)
Else  
IsNull(InvoiceAbstract.Balance, 0)
End,   
"Type" = Case InvoiceType  
When 5 then  
@SALESRETURNSALEABLE
When 6 then  
@SALESRETURNDAMAGES
Else  
@RETAILINVOICE
End,
"Rounded Net Value"  = NetValue + RoundOffAmount
From InvoiceAbstract, Customer, Salesman, VoucherPrefix  
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
InvoiceAbstract.InvoiceType In (2, 5, 6) And  
IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
InvoiceAbstract.CustomerID *= Customer.CustomerID And  
InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And  
VoucherPrefix.TranID = 'INVOICE'  
Order By "Type", "InvoiceID"
