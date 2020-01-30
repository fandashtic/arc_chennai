CREATE Procedure Sp_Acc_GetDefaultProvider (@PaymentMode integer,@DefaultProvider Integer)
as
/*
-- -- @PaymentMode = 0 - Then Query Used to Load Combo in Add/Edit Payment 
-- -- 				 Mode - All Bank Accounts will be loaded
-- -- @PaymentMode > 0 - Then Query Used to Load Combo in Collections Screen - Bank Accounts 
-- -- 				 pertaining to the Selected Payment Mode will be listed
@DefaultProvider = 0 - Then Query Used to Load Combo in Add/Edit Payment 
				 Mode - All Bank Accounts will be loaded
@DefaultProvider = 1 - Then Query Used to Load Combo in Collections Screen - Bank Accounts 
				 pertaining to the Selected Payment Mode will be listed
*/
If @DefaultProvider = 1
Begin
	Select Bank.BankID,'Account_Number' = BankMaster.BankName + N' - ' + CAST(Bank.Account_Number As nVarChar(100))
	From Bank,BankMaster,PaymentMode
	Where PaymentMode.Mode = @PaymentMode
	and PaymentMode.ProviderAccountId = Bank.AccountID
	and Bank.BankCode = BankMaster.BankCode
End
Else
Begin
	Select Bank.AccountID,'Account_Number' = BankMaster.BankName + N' - ' + CAST(Bank.Account_Number As nVarChar(100))
	From Bank,BankMaster,BankAccount_PaymentModes
	Where 
	Bank.BankCode = BankMaster.BankCode and
	BankAccount_PaymentModes.CreditCardID = @PaymentMode and
	BankAccount_PaymentModes.BankId = Bank.BankId
End


