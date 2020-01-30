CREATE Procedure [dbo].[sp_view_CollectionAbstract](@CollectionID int)        
as        

Declare @CASH As NVarchar(50) 
Declare @CHEQUE As NVarchar(50)
Declare @DD As NVarchar(50)
Declare @CREDITCARD As NVarchar(50)
Declare @BANKTRANSFER As NVarchar(50)
Declare @COUPON As NVarchar(50)

Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default)
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)
Set @CREDITCARD = dbo.LookupDictionaryItem(N'Credit Card', Default)
Set @BANKTRANSFER = dbo.LookupDictionaryItem(N'Bank Transfer', Default)
Set @COUPON = dbo.LookupDictionaryItem(N'Coupon', Default)

Select "FullDocID" = FullDocID, "DocumentDate" = DocumentDate, "Company_Name" = Customer.Company_Name,        
"CustomerID" = Collections.CustomerID,         
-- This field is for view collections screen        
PaymentMode,        
"ChequeDetails" = ChequeDetails,        
"ChequeNumber" = ChequeNumber, "ChequeDate" = dbo.StripDateFromTime(ChequeDate), "Value" = Collections.Value, "Balance" = Balance,        
"BankCode" = BankMaster.BankCode, "BranchCode" = BranchMaster.BranchCode, "BankName" = BankMaster.BankName,         
"BranchName" = BranchMaster.BranchName, "Salesman_Name" = Salesman.Salesman_Name, "Status" = isnull(Status,0),        
"DocReference " = DocReference, "AdjAmount" = Collections.Value - Balance,        
"DocID" = Collections.DocumentReference,        
"DocType" = Collections.DocSerialType,        
"TIN Number" = TIN_Number, "Alternate Name" = Alternate_Name,        
"Billing Address" = BillingAddress,         
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
"Total Charge" = collections.Value + isnull(CustomerServiceCharge, 0),        
-- This field is for collection printing        
"PaymentMode" = case PaymentMode            
when 0 then            
@CASH           
when 1 then            
@CHEQUE          
when 2 then            
@DD          
When 3 then        
@CREDITCARD        
When 4 then        
@BANKTRANSFER        
When 5 then        
@COUPON        
end,  
"CustomerCategory" = Customer.Customercategory, 
Collections.BeatId, "Beat" = Beat.Description
from Collections
Inner Join Customer on Collections.CustomerID = Customer.CustomerID
Left Outer Join BankMaster on Collections.BankCode = BankMaster.BankCode
Left Outer Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode
Left Outer Join Salesman on Collections.SalesmanID = Salesman.SalesmanID
Left Outer Join Beat on Collections.BeatID = Beat.BeatID 
Left Outer Join BankMaster ccissBankMaster on  isnull(Collections.ChequeDetails, N'') = ccissBankMaster.BankCode 
Left Outer Join Paymentmode ccPaymentmode on Collections.PaymentModeID = ccPaymentmode.Mode 
  
where 
--Collections.CustomerID = Customer.CustomerID and          
Collections.DocumentID = @CollectionID 
--and          
--Collections.BankCode *= BankMaster.BankCode and          
--Collections.BranchCode *= BranchMaster.BranchCode And          
--Collections.SalesmanID *= Salesman.SalesmanID And      
--Collections.BeatID *= Beat.BeatID          
--and isnull(Collections.ChequeDetails, N'') *= ccissBankMaster.BankCode         
--and Collections.PaymentModeID *= ccPaymentmode.Mode    
