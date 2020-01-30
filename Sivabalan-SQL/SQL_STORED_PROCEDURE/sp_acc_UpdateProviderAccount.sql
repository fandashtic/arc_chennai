CREATE Procedure sp_acc_UpdateProviderAccount(@PaymentMode nVarChar(255),@PaymentType Int,@ProviderAccount Int)
As
Update PaymentMode Set ProviderAccountID = @ProviderAccount
Where Value = @PaymentMode And PaymentType = @PaymentType

