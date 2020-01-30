CREATE procedure [dbo].[sp_print_IssueGVAbstract](@CollectionID int)        
as   
Set dateformat dmy     
select "FullDocID" = FullDocID, "DocumentDate" = dbo.StripDateFromTime(DocumentDate),      
"CustomerID" = Collections.CustomerID, "PaymentMode" = PaymentMode, "ChequeDetails" = ChequeDetails,      
"ChequeNumber" = Case ChequeNumber when 0 then null else ChequeNumber end, "ChequeDate" = dbo.StripDateFromTime(ChequeDate), "Value" = Collections.Value, "Balance" = Balance,      
"BankCode" = BankMaster.BankCode, "BranchCode" = BranchMaster.BranchCode, "BankName" = BankMaster.BankName,       
"BranchName" = BranchMaster.BranchName, "Salesman_Name" = Salesman.Salesman_Name, "Status" = Status,      
"DocReference " = DocReference,     
"DocID" = Collections.DocumentReference,      
"DocType" = Collections.DocSerialType,      
"Holder Name" = CardHolder,      
"Card Number" = CreditCardNumber,       
"Expiry Date" = (case paymentmode when 3 then substring(convert(nvarchar(10), ChequeDate, 103), 4, 10) else N'' end),        
"Credit Card" = Isnull(ccPaymentmode.value, N''),       
"Bank Account" = isnull((select isnull(Bank.Account_Number + N' - ' + ccaccBankMaster.BankName, N'') BankAccount      
from Bank, BankMaster ccaccBankMaster       
Where Bank.BankCode = ccaccBankMaster.BankCode and Bank.BankID = Collections.BankID), N''),       
"Issuing Bank" = isnull(ccissBankMaster.BankName, N''),       
"Service Charge%" =  (case isnull(Collections.Value, 0) when 0 then 0 else ((isnull(CustomerServiceCharge, 0) * 100) / Collections.Value) end),      
"Service Charge" = isnull(CustomerServiceCharge, 0),      
"Total Charge" = collections.Value + isnull(CustomerServiceCharge, 0)      
from Collections, BankMaster, BranchMaster, Salesman,      
BankMaster ccissBankMaster, Paymentmode ccPaymentmode      
where Collections.DocumentID = @CollectionID and    
Collections.CustomerID = N'GIFT VOUCHER' and         
Collections.BankCode *= BankMaster.BankCode and        
Collections.BranchCode *= BranchMaster.BranchCode And        
Collections.SalesmanID *= Salesman.SalesmanID        
and isnull(Collections.ChequeDetails, N'') *= ccissBankMaster.BankCode       
and Collections.PaymentModeID *= ccPaymentmode.Mode
