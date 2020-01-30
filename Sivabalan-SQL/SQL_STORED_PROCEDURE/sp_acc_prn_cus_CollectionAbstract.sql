CREATE Procedure [dbo].[sp_acc_prn_cus_CollectionAbstract](@CollectionID int)        
as      
SET DATEFORMAT DMY
Select "FullDocID" = FullDocID, "DocumentDate" = DocumentDate, "Customer Name" = Customer.Company_Name,      
"CustomerID" = Collections.CustomerID,       
-- This field is for view collections screen      
PaymentMode,      
"ChequeDetails" = ChequeDetails,      
"ChequeNumber" = ChequeNumber, "ChequeDate" = dbo.StripDateFromTime(ChequeDate), "Value" = Collections.Value, "Balance" = Balance,      
"BankCode" = BankMaster.BankCode, "BranchCode" = BranchMaster.BranchCode, "BankName" = BankMaster.BankName,       
"BranchName" = BranchMaster.BranchName, "Salesman_Name" = Salesman.Salesman_Name, "Status" = Status,      
"DocReference " = DocReference, "AdjAmount" = Collections.Value - Balance,      
"DocID" = Collections.DocumentReference,      
"DocType" = Collections.DocSerialType,      
"TIN Number" = TIN_Number, "Alternate Name" = Alternate_Name,      
"Billing Address" = BillingAddress,       
"Holder Name" = CardHolder,      
"Card Number" = CreditCardNumber,       
"Expiry Date" = (case paymentmode when 3 then substring(convert(nvarchar(10), ChequeDate, 103), 4, 10) else '' end),        
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
dbo.LookupDictionaryItem('Cash',Default)          
when 1 then          
dbo.LookupDictionaryItem('Cheque',Default)          
when 2 then          
dbo.LookupDictionaryItem('DD',Default)          
When 3 then      
dbo.LookupDictionaryItem('Credit Card',Default)      
When 4 then      
dbo.LookupDictionaryItem('Bank Transfer',Default)      
When 5 then      
dbo.LookupDictionaryItem('Coupon',Default)      
end    ,  
"Collection Mode" =  
Case PaymentMode  
 When 0 Then dbo.LookupDictionaryItem('Cash',Default)  
 When 1 Then dbo.LookupDictionaryItem('Cheque',Default)  
 When 2 Then dbo.LookupDictionaryItem('DD',Default)  
 When 3 Then dbo.LookupDictionaryItem('Credit Card',Default)  
 When 4 Then dbo.LookupDictionaryItem('Bank Transfer',Default)  
End,  
"Account Number" = (Select Account_Number from Bank where Bank.BankID = Collections.BankID),  
"Collection Description" =       
case      
 when PaymentMode in (1,0) then dbo.LookupDictionaryItem('Cheque No:',Default)  
 when PaymentMode in (2) then dbo.LookupDictionaryItem('DD No:',Default)  
 when PaymentMode in (3) then dbo.LookupDictionaryItem('Credit Card Number:',Default)  
 when PaymentMode in (4) then dbo.LookupDictionaryItem('Transaction Code:',Default)  
end,  
"Collection Details" =  
Case   
 When PaymentMode in (0)   Then ''  
 When PaymentMode in (1,2) Then Cast(ChequeNumber as nVarchar(255))  
 when PaymentMode in (3)   Then Cast(CreditCardNumber as nVarchar(255))  
 when PaymentMode in (4)   Then Cast(Memo as nVarchar(255))  
End,  
"Collection Description1" =  
Case   
 When PaymentMode in (0,1) Then dbo.LookupDictionaryItem('Cheque Date:',Default)  
 When PaymentMode in (2)   Then dbo.LookupDictionaryItem('DD Date:',Default)  
 When PaymentMode in (3,4) Then Null  
End,  
"Collection Details1" =  
Case   
 When PaymentMode in (0,3,4) Then Null  
 When PaymentMode in (1,2)   Then dbo.StripDateFromTime(ChequeDate)  
End,  
"Transaction Code" = Memo  
from 
Collections
Inner Join Customer on Collections.CustomerID = Customer.CustomerID
Left Join BankMaster on Collections.BankCode = BankMaster.BankCode
Left Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode 
Left Join Salesman on Collections.SalesmanID = Salesman.SalesmanID 
--BankMaster
Left Join BankMaster ccissBankMaster on isnull(Collections.ChequeDetails, N'') = ccissBankMaster.BankCode 
left Join Paymentmode ccPaymentmode on Collections.PaymentModeID = ccPaymentmode.Mode  
--ccPaymentmode      

--Collections, Customer, BankMaster, BranchMaster, Salesman,      
--BankMaster ccissBankMaster, Paymentmode ccPaymentmode      
where 
--Collections.CustomerID = Customer.CustomerID and        
Collections.DocumentID = @CollectionID 
--and        
--Collections.BankCode *= BankMaster.BankCode and        
--Collections.BranchCode *= BranchMaster.BranchCode And        
--Collections.SalesmanID *= Salesman.SalesmanID        
--and isnull(Collections.ChequeDetails, N'') *= ccissBankMaster.BankCode       
--and Collections.PaymentModeID *= ccPaymentmode.Mode  
  
  


