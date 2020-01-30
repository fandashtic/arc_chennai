CREATE procedure [dbo].[spr_list_cancelled_collections](@fromdate datetime, @todate datetime)  
as  

Declare @CASH As NVarchar(50)
Declare @CHEQUE As NVarchar(50)
Declare @DD As NVarchar(50)
Declare @CANCELLED As NVarchar(50)
Declare @AMENDED As NVarchar(50)

Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default)
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)

select DocumentID, "Collection ID" = FullDocID, "Document Ref" = DocReference, "Date" = DocumentDate,  
"Customer Name" = Customer.Company_Name,   
"Payment Mode" = case PaymentMode  
when 0 then @CASH  
when 1 then @CHEQUE 
when 2 then @DD 
end,  
"Value" = Collections.Value, "Current Balance" = Collections.Balance,  
"Cheque Number" = Collections.ChequeNumber,   
"Cheque Date" = 
Case PaymentMode      
When 0 then NULL    
Else Collections.ChequeDate    
End,   
"Bank" = BankMaster.BankName,  
"Branch" = BranchMaster.BranchName,  
"Status" = case(Status)   
when 128 then     
@AMENDED  
else  
@CANCELLED   
end  
from Collections, Customer, BankMaster, BranchMaster  
where  
Customer.CustomerID = Collections.CustomerID and 
--(Status & 64) <> 0 
(IsNull(Collections.Status,0) & 128) <> 0 and  
Collections.DocumentDate between @FromDate and @ToDate And  
Collections.BankCode *= BankMaster.BankCode And  
Collections.BranchCode *= BranchMaster.BranchCode And  
Collections.BankCode *= BranchMaster.BankCode
