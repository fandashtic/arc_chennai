CREATE procedure [dbo].[Sp_Acc_Rpt_List_CustomerChequeDetail] (@Details nvarchar(4000))
as
Declare @ChqNo Int
Declare @BankCode nVarchar(50)
Declare @BranchCode nVarchar(50)


Create table #Info
(
	RowNum int Identity(1,1),
	Details nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS
)

insert into #info
exec sp_acc_sqlsplit @details,'€'

Select @ChqNo      = Details from #info where RowNum = 1
Select @BankCode   = Details from #info where RowNum = 2
Select @BranchCode = Details from #info where RowNum = 3

select 
"Collection ID" =  Collections.FullDocID,    
"Collection Date" = Collections.DocumentDate,  
"Type"= case when Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,      
-- -- -- "Account Name" = 
-- -- -- Case 
-- -- -- 	when others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
-- -- -- 	else (Select AccountName from AccountsMaster where AccountID=Collections.Others) 
-- -- -- end,       
"Amount" = Collections.Value,  
"Payment Mode" = 
case Collections.PaymentMode     
	When 1 then dbo.LookupDictionaryItem('Cheque',Default)    
	When 2 then dbo.LookupDictionaryItem('DD',Default)    
End,    
"Cheque Date" = Collections.ChequeDate,  
"Deposit ID"= Deposits.FullDocID,   
"Deposited Date" = Collections.DepositDate,    
"Account Number" = (select Bank.Account_Number From BankMaster, Bank     
Where Collections.Deposit_To = Bank.BankID and Bank.BankCode = BankMaster.BankCode),  
"Deposited Bank" = (select BankMaster.BankName From BankMaster, Bank
Where Collections.Deposit_To = Bank.BankID and Bank.BankCode = BankMaster.BankCode)    
from Collections
Inner Join BankMaster on Collections.BankCode = BankMaster.Bankcode
Left Join Deposits on Collections.DepositID = Deposits.DepositID  
 
where 
Collections.BankCode = @BankCode    
and Collections.BranchCode = @BranchCode 
and Collections.ChequeNumber = @ChqNo 
and isnull(Collections.status,0) in (0,1,2)
--and Collections.BankCode = BankMaster.Bankcode 
---- -- and Collections.BranchCode = BranchMaster.BranchCode 
--and Collections.DepositID *= Deposits.DepositID  
Drop Table #Info
