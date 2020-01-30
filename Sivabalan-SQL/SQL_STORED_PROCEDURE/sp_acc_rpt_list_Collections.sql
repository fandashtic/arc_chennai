CREATE procedure [dbo].[sp_acc_rpt_list_Collections] (@Account nvarchar(50),            
     @FromDate datetime,            
     @ToDate datetime)            
as      
  
If @Account = N'%'        
Begin        
 select DocumentID, "Collection ID" = FullDocID, "Document Ref" = DocReference,"Date" = DocumentDate,        
 "Type"= case when Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,            
--  "Account Name" = Case when others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID)         
--  else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,             
 "Collection Type" = case when CustomerID is null then case when (IsNull(Others,0) <> 0) and (IsNull(ExpenseAccount,0) <> 0) then        
 dbo.LookupDictionaryItem('Collection from Party for Expense',Default) else case when (IsNull(Others,0) = 0)  and (IsNull(ExpenseAccount,0) <> 0)        
 then dbo.LookupDictionaryItem('Collection for Expense',Default) else dbo.LookupDictionaryItem('Collection from Party',Default) end end else ' ' end,              
 "Party" = Case when IsNull(Collections.others,0) = 0 then (Select Company_Name From Customer where CustomerID=Collections.CustomerID)         
 else (Select AccountName from AccountsMaster where AccountID= IsNull(Collections.Others,0)) end,        
 "Expense Account" = (Select AccountName from AccountsMaster where AccountID = Isnull(Collections.ExpenseAccount,0)),        
 "Payment Mode" = case PaymentMode            
 when 0 then dbo.LookupDictionaryItem('Cash',Default)            
 when 1 then dbo.LookupDictionaryItem('Cheque',Default)            
 when 2 then dbo.LookupDictionaryItem('DD',Default)            
 when 3 then dbo.LookupDictionaryItem('Credit Card',Default)        
 When 4 then dbo.LookupDictionaryItem('Bank Transfer',Default)        
 when 5 then dbo.LookupDictionaryItem('Coupon',Default)        
 end,            
 "Amount Recd" = Collections.Value, "Current Balance" = Collections.Balance,            
 "Cheque Number" =         
 Case PaymentMode        
  When 4 then Collections.Memo        
  Else Cast(Collections.ChequeNumber as nVarchar(400))        
 End,             
 "Cheque Date" = Case PaymentMode        
 When 1 then        
  Cast(Collections.ChequeDate as nVarchar)        
When 2 then        
  Cast(Collections.ChequeDate as nVarchar)        
 Else        
  ''        
 End,            
--  "Account Number" =         
--   Isnull((Select Bank.Account_Number from Bank where Bank.BankId = Isnull(Collections.BankId,0)),N''),        
 "Account Number" =         
  Isnull((Select Bank.Account_Number from Bank where Bank.BankId = (Select AccountID from Deposits where DepositID = Isnull(Collections.DepositID,0)) ),N''),        
-- "Bank" = BankMaster.BankName,  
"Bank" = Case PaymentMode When 3 Then (Select bankMaster.BankName from BankMaster,Bank Where BankMaster.BankCode = Bank.BankCode  
                    and bank.BankID = Collections.BankID)  
                      Else BankMaster.bankname End,            
 "Branch" = Case PaymentMode When 3 Then (Select BranchMaster.BranchName from BankMaster,Bank,BranchMaster Where BankMaster.BankCode = Bank.BankCode  
                    and bank.BankID = Collections.BankID and BranchMaster.BankCode = Bank.BankCode)  
     Else BranchMaster.BranchName End      
--  "Status" = case (IsNull(Collections.Status, 0) & 64)         
--  when 0 then           
--  ''          
--  else          
--  'Cancelled'          
--  end        
 from Collections
 Left Join BankMaster on Collections.BankCode =  BankMaster.BankCode
 Left Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode and Collections.BankCode = BranchMaster.BankCode 
 WHERE        
 dbo.StripdateFromTime(Collections.DocumentDate) between @FromDate and @ToDate and            
 --Collections.BankCode *=  BankMaster.BankCode and            
 --Collections.BranchCode *= BranchMaster.BranchCode and            
 --Collections.BankCode *= BranchMaster.BankCode and        
 (IsNull(Collections.Status,0) & 64) = 0  And          
 (IsNull(Collections.Status,0) & 128) = 0         
End        
Else        
Begin        
 select DocumentID, "Collection ID" = FullDocID, "Document Ref" = DocReference,"Date" = DocumentDate,        
 "Type"= case when Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,            
--  "Account Name" = case when others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID)         
--  else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,             
 "Collection Type" = case when CustomerID is null then case when (IsNull(Others,0) <> 0) and (IsNull(ExpenseAccount,0) <> 0) then        
 dbo.LookupDictionaryItem('Collection from Party for Expense',Default) else case when (IsNull(Others,0) = 0)  and (IsNull(ExpenseAccount,0) <> 0)        
 then dbo.LookupDictionaryItem('Collection for Expense',Default) else dbo.LookupDictionaryItem('Collection from Party',Default) end end else ' ' end,              
 "Party" = Case when IsNull(Collections.others,0) = 0 then (Select Company_Name From Customer where CustomerID=Collections.CustomerID)         
 else (Select AccountName from AccountsMaster where AccountID= IsNull(Collections.Others,0)) end,        
 "Expense Account" = (Select AccountName from AccountsMaster where AccountID = Isnull(Collections.ExpenseAccount,0)),        
 "Payment Mode" = case PaymentMode            
 when 0 then dbo.LookupDictionaryItem('Cash',Default)            
 when 1 then dbo.LookupDictionaryItem('Cheque',Default)            
 when 2 then dbo.LookupDictionaryItem('DD',Default)         
 when 3 then dbo.LookupDictionaryItem('Credit Card',Default)        
 When 4 then dbo.LookupDictionaryItem('Bank Transfer',Default)        
 when 5 then dbo.LookupDictionaryItem('Coupon',Default)        
 end,            
 "Amount Recd" = Collections.Value, "Current Balance" = Collections.Balance,            
 "Cheque Number" =         
 Case PaymentMode         
  When 4 then Collections.Memo        
  Else Cast(Collections.ChequeNumber as nVarchar(400))        
 End,        
 "Cheque Date" = Case PaymentMode        
 When 1 then        
  Cast(Collections.ChequeDate as nVarchar)          
 Else        
  ''        
 End,            
--  "Account Number" =         
--   Isnull((Select Bank.Account_Number from Bank where Bank.BankId = Isnull(Collections.BankId,0)),N''),        
 "Account Number" =         
  Isnull((Select Bank.Account_Number from Bank where Bank.BankId = (Select AccountID from Deposits where DepositID = Isnull(Collections.DepositID,0))),N''),        
"Bank" = Case PaymentMode When 3 Then (Select bankMaster.BankName from BankMaster,Bank Where BankMaster.BankCode = Bank.BankCode  
                    and bank.BankID = Collections.BankID)  
                      When 5 Then (Select bankMaster.BankName from BankMaster Where BankMaster.BankCode = Collections.BankCode)  
         Else BankMaster.bankname End,            
 "Branch" = Case PaymentMode When 3 Then (Select BranchMaster.BranchName from BankMaster,Bank,BranchMaster Where BankMaster.BankCode = Bank.BankCode  
                    and bank.BankID = Collections.BankID and BranchMaster.BankCode = Bank.BankCode)  
     Else BranchMaster.BranchName End         
--  "Status" = case (IsNull(Collections.Status, 0) & 64)         
--  when 0 then           
--  ''          
--  else         
--  'Cancelled'          
--  end         
 from Collections
 Left Join BankMaster on Collections.BankCode =  BankMaster.BankCode
 Left Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode  and Collections.BankCode = BranchMaster.BankCode
 WHERE        
 ((Collections.CustomerID is not null and (Select  Customer.CustomerID from customer where Customer.Company_name = @Account)= Collections.CustomerID) or        
 (Collections.CustomerID is null and  (Select AccountsMaster.AccountID from Accountsmaster where Accountsmaster.AccountName = @Account) =Collections.Others)) and        
 dbo.StripdateFromTime(Collections.DocumentDate) between @FromDate and @ToDate and            
 --Collections.BankCode *=  BankMaster.BankCode and            
 --Collections.BranchCode *= BranchMaster.BranchCode and            
 --Collections.BankCode *= BranchMaster.BankCode and        
 (IsNull(Collections.Status,0) & 64) = 0  And          
 (IsNull(Collections.Status,0) & 128) = 0         
End        
        

