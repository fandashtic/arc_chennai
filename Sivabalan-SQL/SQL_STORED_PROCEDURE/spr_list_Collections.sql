CREATE procedure [dbo].[spr_list_Collections] (@Customer nvarchar(30),        
     @FromDate datetime,        
     @ToDate datetime)        
as        

Declare @CASH NVarchar(50)
Declare @CHEQUE NVarchar(50)
Declare @DD NVarchar(50)
Declare @UNDEPOSIT NVarchar(50)
Declare @REALISED Nvarchar(50)
Declare @BOUNCE NVarchar(50)
Declare @BOUNCEANDREP NVarchar(50)
Declare @DEPOSIT NVarchar(50)
Declare @CANCELLED NVarchar(50)

Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default) 
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default) 
Set @DD = dbo.LookupDictionaryItem(N'DD', Default) 
Set @UNDEPOSIT = dbo.LookupDictionaryItem(N'Un-Deposited', Default)
Set @REALISED = dbo.LookupDictionaryItem(N'Realised', Default)
Set @BOUNCE = dbo.LookupDictionaryItem(N'Bounced', Default)
Set @BOUNCEANDREP = dbo.LookupDictionaryItem(N'Bounced & Represented', Default)
Set @DEPOSIT = dbo.LookupDictionaryItem(N'Deposited', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)


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
"Status" = Case paymentmode   
 When 1 then  
     Case IsNull(Deposit_To,0)
     when 0 then  	   
      	@UNDEPOSIT
     else
	Case Realised  
      	when 1 then  
  	@REALISED
      	when 2 then  
		@BOUNCE
  	when 3 then  
  	@BOUNCEANDREP
  	else  
       	@DEPOSIT
     	end  
     end  
 else  
     case (IsNull(Collections.Status, 0) & 64)     
     when 0 then       
     N''      
     else      
     @CANCELLED
     end    
 End  
from Collections, Customer, BankMaster, BranchMaster        
where        
Customer.CustomerID = Collections.CustomerID and        
Customer.Company_Name like @Customer and        
Collections.DocumentDate between @FromDate and @ToDate and        
Collections.BankCode *=  BankMaster.BankCode and        
Collections.BranchCode *= BranchMaster.BranchCode and        
Collections.BankCode *= BranchMaster.BankCode And    
(IsNull(Collections.Status,0) & 64) = 0 And  
(IsNull(Collections.Status,0) & 128) = 0
