CREATE procedure sp_acc_Update_ChqStatus 
(@custID nvarchar(30),@chqNo Int,@BankCode nvarchar(40),@BranchCode nvarchar(40),@Active Int)
as
Update customercheques
set 
	Active = @Active,
	LastModifiedDate = Getdate()
where 
CustomerId = @CustID
and ChequeNumber = @ChqNo
and BankCode = @BankCode
and BranchCode = @BranchCode



