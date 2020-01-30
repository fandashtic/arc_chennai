CREATE Procedure sp_Insert_TaxDetails (
	@TaxCode int,   
     @TaxComp_Code int,   
     @TaxComp_Desc nvarchar(255),   
     @TaxPer decimal(18,6),   
     @ApplicableOn nvarchar(255),   
     @Sp_Per decimal(18,6),
     @Lst_Flag int)
As  
Begin  
	If @TaxComp_Code = 0   
	Begin  
		Insert into TaxComponentDetail (TaxComponent_desc) Values(@TaxComp_Desc)   
		Select @TaxComp_Code = TaxComponent_Code from TaxComponentDetail where TaxComponent_Code = @@Identity  
	End  
  
	Insert into TaxComponents (Tax_Code, TaxComponent_Code, Tax_Percentage, ApplicableOn, Sp_Percentage, LST_Flag)
	Values (@TaxCode, @TaxComp_Code, @TaxPer, @ApplicableOn, @Sp_Per, @Lst_Flag)

End
