
CREATE Procedure spr_list_Invoicewise_Collections_ITC (@FromDate datetime,    
         @ToDate datetime)    
As  

Set DateFormat DMY 
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
Declare @AllCG as nVarchar(100)
  
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
set @AllCG =dbo.LookupDictionaryItem(N'All Category Groups',Default)
    
Select InvoiceID As "InvoiceID1", 
"InvoiceID" = Case ISNULL(InvoiceAbstract.GSTFlag,0)  
When 0 then VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID as nvarchar)
Else ISNULL(InvoiceAbstract.GSTFullDocID,'') End,    
"Doc Ref" = InvoiceAbstract.DocReference,    
"Invoice Date" = InvoiceAbstract.InvoiceDate,     
"Customer" = Customer.Company_Name,    
"Salesman" = Case IsNull(Salesman.Salesman_Name, N'') When N'' Then @OTHERS 
		Else IsNull(Salesman.Salesman_Name, N'') End,     
"Category Group" = dbo.Fn_GetCG_ITC(InvoiceAbstract.InvoiceID),
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
"Rounded Net Value"  = 
Case InvoiceType    
When 4 then    
0-(NetValue + RoundOffAmount)
Else    
(NetValue + RoundOffAmount)
End
From InvoiceAbstract With(Nolock)
Inner Join  Customer On InvoiceAbstract.CustomerID = Customer.CustomerID     
Left Outer Join Salesman On InvoiceAbstract.SalesmanID = Salesman.SalesmanID 
Inner Join  VoucherPrefix  On VoucherPrefix.TranID = 'INVOICE' 
Where 
IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And    
InvoiceAbstract.InvoiceType in (1, 3, 4) And    
Convert(Nvarchar(10),InvoiceAbstract.InvoiceDate ,103) Between @FromDate And @ToDate 
  
Union All    
    
Select InvoiceID As "InvoiceID1", "InvoiceID" =  Case ISNULL(InvoiceAbstract.GSTFlag,0) 
When 0 then VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID as nvarchar)
Else ISNULL(InvoiceAbstract.GSTFullDocID,'') END,    
"Doc Ref" = InvoiceAbstract.DocReference,    
"Invoice Date" = InvoiceAbstract.InvoiceDate,     
"Customer" = Customer.Company_Name,    
"Salesman" = Case IsNull(Salesman.Salesman_Name, N'') When N'' Then @Others
		Else IsNull(Salesman.Salesman_Name, N'') End,     

"Category Group" = dbo.Fn_GetCG_ITC(InvoiceAbstract.InvoiceID),
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
"Rounded Net Value"  = 
Case InvoiceType    
When 5 then    
0-(NetValue + RoundOffAmount)
When 6 then    
0-(NetValue + RoundOffAmount)
Else    
(NetValue + RoundOffAmount)
End
From InvoiceAbstract With(Nolock)
Left Outer Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
Left Outer Join Salesman On InvoiceAbstract.SalesmanID = Salesman.SalesmanID
Inner Join VoucherPrefix On VoucherPrefix.TranID = 'INVOICE' 
Where 
IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And    
InvoiceAbstract.InvoiceType In (2, 5, 6) And    
Convert(Nvarchar(10),InvoiceAbstract.InvoiceDate ,103) Between @FromDate And @ToDate
Order By [Type] , [InvoiceID]  

