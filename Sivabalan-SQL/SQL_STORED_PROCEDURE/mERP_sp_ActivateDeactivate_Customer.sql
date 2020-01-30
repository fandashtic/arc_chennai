Create Procedure mERP_sp_ActivateDeactivate_Customer
(
@Cust_Code nVarchar(500),
@Active Int,
@szRemarks nVarchar(255)
)
As
Begin
	
	--Select * From  tbl_mERP_CustActiveDeactive

	

	Update Customer Set Active = (Case @Active When -1 Then Active Else @Active End) Where CustomerID = @Cust_Code


	/* When Active column is -1 then it means Active column is locked for updating from 3 tier based on the
	config settings */
	Insert Into tbl_mERP_CustActiveDeactive(CustomerID,Active,Remarks)
									Values(@Cust_Code,@Active,@szRemarks)

	Select @@Identity
End

