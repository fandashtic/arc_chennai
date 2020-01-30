CREATE Procedure sp_acc_import_customeropeningbalance(@CustomerID nVarchar(15),@Balance Decimal(18,6))
As
Declare @AccountID Int

Select @AccountID=isNull(AccountID,0) from Customer where CustomerID=@CustomerID
If @AccountID <> 0
Begin
	Update AccountsMaster Set OpeningBalance= IsNull(OpeningBalance,0) + IsNull(@Balance,0) where AccountID=@AccountID
	Exec sp_acc_masterAccountOpening @AccountID
End




