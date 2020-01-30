CREATE procedure [dbo].[sp_acc_rpt_list_cheque_collections](@FromDate datetime,  
	          @ToDate datetime)  
	as  
	select DocumentID, "Collection ID" =  Collections.FullDocID,  
	"Date" = Collections.DocumentDate,
	"Type"= case when Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,  	 
	"Account Name" = Case when others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID) 
	else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,     
	"Amount" = Collections.Value,
	"Payment Mode" = case Collections.PaymentMode   
	When 1 then  
	dbo.LookupDictionaryItem('Cheque',Default)  
	When 2 then  
	dbo.LookupDictionaryItem('DD',Default)  
	End,  
  "Realised Status" = case Isnull(Collections.Realised,0)   
  When 1 then
	dbo.LookupDictionaryItem('Realised',Default)
	When 2 then  
	dbo.LookupDictionaryItem('Bounced',Default)  
	When 3 then  
	dbo.LookupDictionaryItem('Bounced and Represented',Default) 
	Else
	dbo.LookupDictionaryItem('Yet to Realise',Default)
	End,  
	"Cheque Number" = Collections.ChequeNumber, "Cheque Date" = Collections.ChequeDate,
	"Bank" = BankMaster.BankName,
	'Deposit ID'= Deposits.FullDocID, 
	"Deposited Date" = Collections.DepositDate,  
	"Account Number" = (select Bank.Account_Number From BankMaster, Bank   
	Where Collections.Deposit_To = Bank.BankID   
	and Bank.BankCode = BankMaster.BankCode),
	"Deposited Bank" = (select BankMaster.BankName From BankMaster, Bank   
	Where Collections.Deposit_To = Bank.BankID   
	and Bank.BankCode = BankMaster.BankCode)  
	--"Branch" = (select BranchMaster.BranchName From BranchMaster, Bank   
	--Where Collections.Deposit_To = Bank.BankID   
	--and Bank.BranchCode = BranchMaster.BranchCode)
	from Collections
	Left Join BankMaster on Collections.BankCode = BankMaster.BankCode
	Left Join Deposits on Collections.DepositID = Deposits.DepositID	
	where dbo.stripdatefromtime(Collections.DocumentDate) between @FromDate and @ToDate 
	and Collections.PaymentMode in (1, 2) 
	and IsNull(Collections.Status, 0) in (0,1) 
	--And Collections.BankCode *= BankMaster.BankCode  
	--and Collections.DepositID *= Deposits.DepositID
