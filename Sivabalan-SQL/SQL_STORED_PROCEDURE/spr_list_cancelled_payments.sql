CREATE procedure [dbo].[spr_list_cancelled_payments](@fromdate datetime, @todate datetime)  
as  

Declare @CASH nVarchar(50)
Declare @CHEQUE nVarchar(50)
Declare @DD nVarchar(50)
Declare @AMENDED nVarchar(50)
Declare @CANCELLED nVarchar(50)

SElect @CASH = dbo.LookupDictionaryItem(N'Cash',Default)
SElect @CHEQUE = dbo.LookupDictionaryItem(N'Cheque',Default)
SElect @DD = dbo.LookupDictionaryItem(N'DD',Default)
SElect @AMENDED = dbo.LookupDictionaryItem(N'Amended',Default)
SElect @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled',Default)

select DocumentID, "Payment ID" = FullDocID, "Date" = DocumentDate,  
"Vendor Name" = Vendors.Vendor_Name,  
"Payment Mode" = case PaymentMode  
when 0 then @CASH  
when 1 then @CHEQUE  
when 2 then @DD
end,  
"Status" = case status & 64  
when 0 then @AMENDED 
Else @CANCELLED 
end,  
"Value" = Payments.Value, "Balance" = Payments.Balance,  
"Bank" = BankMaster.BankName,   
"Branch" =BranchMaster.BranchName,  
"Account Name" = Bank.Account_Name,   
"Account No" = Bank.Account_Number, 
"Cheque Number" = case paymentmode when 0 then Null else Payments.Cheque_Number end,
"Cheque Date" =  case paymentmode when 0 then Null else Payments.Cheque_Date end
from Payments
Left Outer Join Bank On Payments.BankID = Bank.BankID  
Inner Join Vendors On Payments.VendorID = Vendors.VendorID
Left Outer Join BranchMaster On BranchMaster.BranchCode = Bank.BranchCode And BranchMaster.BankCode = Bank.BankCode
Left Outer Join BankMaster On BankMaster.BankCode = Bank.BankCode
where (isnull(payments.Status,0)& 128) <> 0 and  
Payments.DocumentDate between @FromDate and @ToDate
