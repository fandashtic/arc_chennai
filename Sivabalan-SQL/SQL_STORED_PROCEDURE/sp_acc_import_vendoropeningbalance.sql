
Create Procedure sp_acc_import_vendoropeningbalance(@VendorID nVarchar(15),@Balance Decimal(18,6))
As
Declare @DEBIT Int,@CREDIT Int,@AccountID Int
--Set @DEBIT=1
--Set @CREDIT=1
Select @AccountID=isNull(AccountID,0) from Vendors where VendorID=@VendorID
If @AccountID <> 0
Begin
-- 	If @Mode =@DEBIT
-- 	Begin
-- 		Update AccountsMaster Set OpeningBalance= IsNull(OpeningBalance,0) + IsNull(@VendorOpenBal,0) where AccountID=@AccountID
-- 	End
-- 	Else If @Mode=@CREDIT 
-- 	Begin
-- 	End
	Update AccountsMaster Set OpeningBalance= IsNull(OpeningBalance,0) + IsNull(@Balance,0) where AccountID=@AccountID
End


