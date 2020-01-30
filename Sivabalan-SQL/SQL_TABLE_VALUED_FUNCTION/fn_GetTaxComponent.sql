CREATE Function fn_GetTaxComponent(@TaxCode Int,@LstOrCst Int)
Returns @TaxComponent Table(ComponentCode Int,ComponentName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)  
As
Begin
	Insert @TaxComponent
	Select TaxComponent_Code , TaxComponent_Desc From TaxComponentDetail Where TaxComponent_Code 
	In(Select Distinct(Taxcomponent_code) From TaxComponents Where Tax_code = @TaxCode and LST_Flag = @LstOrCst)  
	RETURN    
End
