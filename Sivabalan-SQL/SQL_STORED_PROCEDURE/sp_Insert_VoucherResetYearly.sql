Create Procedure sp_Insert_VoucherResetYearly(@OperatingYear nVarchar(255),  
     @UserName nVarchar(255))  
As  

If (Select Count(*) from tbl_mERP_VoucherResetYearly Where OpeartionYear = @OperatingYear) = 0
Begin
	Insert Into tbl_mERP_VoucherResetYearly (OpeartionYear,Flag,UserName,CreationTime) Values (@OperatingYear,1,@UserName,Getdate())
End
	
