
CREATE procedure sp_Clear_Cheqeus (@BankID int,
				   @Fromdate datetime,
				   @Todate datetime)
as
Select Collections.CustomerID, Customer.Company_Name, BankMaster.BankName, 
Collections.ChequeNumber, Collections.ChequeDate, Collections.Value, DocumentID,
PaymentMode
From Collections, Customer, Bank, BankMaster
Where Collections.Deposit_To = @BankID And
Collections.PaymentMode in (1, 2) And
Collections.Deposit_To = Bank.BankID And
Collections.DepositDate Between @Fromdate And @Todate And
Collections.CustomerID = Customer.CustomerID And
Collections.BankCode = BankMaster.BankCode And
ISNULL(Collections.Realised, 0) = 0

