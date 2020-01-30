CREATE procedure [dbo].[spr_list_Payments](@Vendor nvarchar(30),    
       @FromDate datetime,    
       @ToDate datetime)    
as    
select DocumentID, "Payment ID" = FullDocID, "Date" = DocumentDate,    
"Vendor Name" = Vendors.Vendor_Name,    
"Payment Mode" = case PaymentMode    
when 0 then    
'Cash'    
when 1 then    
'Cheque'    
when 2 then
'DD'
end,  
"Amount Paid" = Payments.Value, "Excess Payment" = Payments.Balance,    
"Account Number" = Bank.Account_Number,
"Account Name" = Bank.Account_Name,
"Cheque Number" = Payments.Cheque_Number,
"Cheque Date" = 
Case PaymentMode 
When 0 then
''
Else
convert(nvarchar, Payments.Cheque_Date, 103)
End,    
"Bank" = BankMaster.BankName, 
"Branch" = BranchMaster.BranchName 
from Payments
Left Outer Join Bank On payments.bankid = bank.bankid 
Inner Join Vendors On Payments.VendorID = Vendors.VendorID 
Left Outer Join BankMaster On BankMaster.BankCode = Bank.BankCode
Left Outer Join BranchMaster On BranchMaster.BankCode = Bank.BankCode And BranchMaster.BranchCode = Bank.BranchCode 
where Vendors.Vendor_Name like @Vendor and    
Payments.DocumentDate between @FromDate and @ToDate And (IsNull(Status,0) & 64) = 0
