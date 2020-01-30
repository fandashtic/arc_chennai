Create Procedure Sp_Recd_TaxMasterCount
As
Begin
	
	If Exists (Select 'x' From Recd_Tax Where IsNull(Flag,0) = 0)
	Begin
		Exec sp_ProcessGSTax 1
	End

	select Count(*) NoOfTaxMaster From Recd_Tax  Where Isnull(AlertCount,0) = 1
	Update Recd_Tax  Set AlertCount = 32 Where Isnull(AlertCount,0) = 1
End
