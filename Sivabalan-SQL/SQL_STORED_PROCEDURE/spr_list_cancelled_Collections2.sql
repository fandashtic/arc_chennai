CREATE procedure [dbo].[spr_list_cancelled_Collections2] (@Customer nvarchar(15),      
     @FromDate datetime,      
     @ToDate datetime)      
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


select DocumentID, "Collection ID" = FullDocID, "Document Ref" = DocReference, "Date" = DocumentDate,      
"Customer Name" = Customer.Company_Name,       
"Payment Mode" = case PaymentMode      
when 0 then      
@CASH     
when 1 then      
@CHEQUE      
when 2 then      
@DD  
end,      
"Amount Recd" = Collections.Value, "Current Balance" = Collections.Balance,      
"Cheque Number" = Collections.ChequeNumber,       
"Cheque Date" = Case PaymentMode  
When 0 then  
N''  
Else  
Cast(Collections.ChequeDate as nVarchar)  
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
Customer.Company_Name like @Customer and      
Collections.DocumentDate between @FromDate and @ToDate and      
Collections.BankCode *=  BankMaster.BankCode and      
Collections.BranchCode *= BranchMaster.BranchCode and      
Collections.BankCode *= BranchMaster.BankCode And  
--(IsNull(Collections.Status,0) & 64) <> 0  
(IsNull(Collections.Status,0) & 128) <> 0
