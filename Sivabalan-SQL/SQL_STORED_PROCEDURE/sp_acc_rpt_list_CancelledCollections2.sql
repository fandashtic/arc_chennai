CREATE procedure [dbo].[sp_acc_rpt_list_CancelledCollections2] (@Account nvarchar(50),          
     @FromDate datetime,          
     @ToDate datetime)          
as          
If @Account = N'%'      
Begin      
 select DocumentID, "Collection ID" = FullDocID, "Date" = DocumentDate,      
 "Type"= case when Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,          
 "Account Name" = Case when others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID)       
 else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,           
 "Payment Mode" = case PaymentMode          
 when 0 then dbo.LookupDictionaryItem('Cash',Default)          
 when 1 then dbo.LookupDictionaryItem('Cheque',Default)          
 when 2 then dbo.LookupDictionaryItem('DD',Default)          
 when 3 then dbo.LookupDictionaryItem('Credit Card',Default)          
 when 4 then dbo.LookupDictionaryItem('Bank Transfer',Default)    
 when 5 then dbo.LookupDictionaryItem('Coupon',Default)      
 when 6 then dbo.LookupDictionaryItem('Credit Note',Default)      
 when 7 then dbo.LookupDictionaryItem('Gift Voucher',Default)      
 end,          
 "Amount Recd" = Collections.Value, "Current Balance" = Collections.Balance,          
 "Cheque Number" = Case PaymentMode      
 When 1 then Cast(Collections.ChequeNumber as nVarchar)      
 when 4 then Cast(Collections.Memo as nVarchar)  
 When 2 then Cast(Collections.ChequeNumber as nVarchar)    
 Else ''      
 End,          
 "Cheque Date" = Case PaymentMode      
 When 1 then Cast(Collections.ChequeDate as nVarchar)  
 When 2 then Cast(Collections.ChequeDate as nVarchar)        
 Else ''  
 End,         
 "Account Number" =     
 Isnull((Select Bank.Account_Number from Bank where Bank.BankId = Isnull(Collections.BankId,0)),N''),     
 "Bank" = Case PaymentMode     
 When 3 Then     
  IsNull((select IsNull(BankMaster.BankName, N'') From BankMaster, Bank Where     
  BankMaster.bankcode = Bank.bankcode And Bank.BankID = Collections.BankID), N'')    
 Else    
  IsNull(BankMaster.BankName, N'')    
 End,    
 "Branch" = Case PaymentMode    
 When 3 Then    
  IsNull((select IsNull(BranchMaster.BranchName,N'') from BranchMaster, Bank where    
  BranchMaster.branchcode = Bank.branchcode     
  And Bank.BankID = Collections.BankID    
  And BranchMaster.BankCode = Bank.BankCode), N'')    
 Else    
  IsNull(BranchMaster.BranchName, N'')    
 End    
 from Collections
 Left Join BankMaster on Collections.BankCode = BankMaster.BankCode 
 Left Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode    
 WHERE      
 dbo.StripdateFromTime(Collections.DocumentDate) between @FromDate and @ToDate     
 And (Status & 64) <> 0     
 --And Collections.BankCode *= BankMaster.BankCode    
 --And Collections.BranchCode *= BranchMaster.BranchCode    
End      
Else      
Begin      
 select DocumentID, "Collection ID" = FullDocID, "Date" = DocumentDate,      
 "Type"= case when Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,          
 "Account Name" = case when others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID)       
 else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,           
 "Payment Mode" = case PaymentMode          
 when 0 then dbo.LookupDictionaryItem('Cash',Default)          
 when 1 then dbo.LookupDictionaryItem('Cheque',Default)          
 when 2 then dbo.LookupDictionaryItem('DD',Default)          
 when 3 then dbo.LookupDictionaryItem('Credit Card',Default)          
 when 4 then dbo.LookupDictionaryItem('Bank Transfer',Default)    
 when 5 then dbo.LookupDictionaryItem('Coupon',Default)          
 when 6 then dbo.LookupDictionaryItem('Credit Note',Default)      
 when 7 then dbo.LookupDictionaryItem('Gift Voucher',Default)      
 end,          
 "Amount Recd" = Collections.Value, "Current Balance" = Collections.Balance,          
 "Cheque Number" = Case PaymentMode      
 When 1 then Cast(Collections.ChequeNumber as nVarchar)      
 When 4 then Cast(Collections.Memo as nVarchar)  
 When 2 then Cast(Collections.ChequeNumber as nVarchar)    
 Else ''      
 End,           
 "Cheque Date" = Case PaymentMode      
 When 1 then Cast(Collections.ChequeDate as nVarchar)  
 When 2 then Cast(Collections.ChequeDate as nVarchar)      
 Else ''      
 End,          
 "Account Number" =     
 Isnull((Select Bank.Account_Number from Bank where Bank.BankId = Isnull(Collections.BankId,0)),N''),    
 "Bank" = Case PaymentMode     
 When 3 Then     
  IsNull((select IsNull(BankMaster.BankName, N'') From BankMaster, Bank Where     
  BankMaster.bankcode = Bank.bankcode And Bank.BankID = Collections.BankID), N'')    
 Else    
  IsNull(BankMaster.BankName, N'')    
 End,    
 "Branch" = Case PaymentMode    
 When 3 Then    
  IsNull((select IsNull(BranchMaster.BranchName,N'') from BranchMaster, Bank where    
  BranchMaster.branchcode = Bank.branchcode     
  And Bank.BankID = Collections.BankID    
  And BranchMaster.BankCode = Bank.BankCode), N'')    
 Else    
  IsNull(BranchMaster.BranchName, N'')    
 End    
 from Collections
 Left Join BankMaster on Collections.BankCode = BankMaster.BankCode 
 Left join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode
 WHERE      
 ((Collections.CustomerID is not null and (Select  Customer.CustomerID from customer where Customer.Company_name = @Account)= Collections.CustomerID) or      
 (Collections.CustomerID is null and  (Select AccountsMaster.AccountID from Accountsmaster where Accountsmaster.AccountName = @Account) =Collections.Others)) and      
 dbo.StripdateFromTime(Collections.DocumentDate) between @FromDate and @ToDate     
 And (Status & 64) <> 0     
 --And Collections.BankCode *= BankMaster.BankCode    
 --And Collections.BranchCode *= BranchMaster.BranchCode    
End
