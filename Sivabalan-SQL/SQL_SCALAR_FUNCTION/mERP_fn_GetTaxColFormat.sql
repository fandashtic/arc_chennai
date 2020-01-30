
Create Function mERP_fn_GetTaxColFormat(@TaxCode Int, @TaxCompCode Int)
Returns nVarchar(1000)
As
Begin
	Declare @RetStr as nVarchar(1000), @StrTaxCode as nVarchar(4), @LT as nVarchar(15), @CT as nVarchar(15)
	Declare @StrTaxCompCode as nVarchar(4), @TaxComp as nVarchar(15)
	Declare @LTConst as nVarchar(4), @CTConst as nVarchar(4)
	Declare @LSTPercent as Decimal(18,6), @CSTPercent as Decimal(18,6), @Cnt as Int
	Set @LTConst = 'VAT_'
	Set @CTConst = 'CST_'

	Declare @Appon as nvarchar(200)
	Declare @sp_percent as decimal(18,3)

	-- To get format for tax column heading
	
	Select @LSTPercent = Percentage, @CSTPercent = CST_Percentage From Tax Where Tax_Code = @TaxCode
	Select @Cnt = Count(Tax_Code) From Tax Where Percentage = @LSTPercent And CST_Percentage = @CSTPercent

	Set @StrTaxCode = (Case When @Cnt > 1 Then '_' + Cast(@TaxCode as nVarchar) Else '' End)

	Select @LT = @LTConst + Cast(Cast(IsNull(Percentage, 0) as Decimal(18,3)) as nVarchar) + '%', 
	@CT = @CTConst + Cast(Cast(IsNull(CST_Percentage, 0) as Decimal(18,3)) as nVarchar) + '%' 
	From Tax Where Tax_Code = @TaxCode

	Set @RetStr = @LT + '_' + @CT + @StrTaxCode

	-- To get format for tax column heading along with tax component

	If @TaxCompCode > 0
	Begin
		Select @TaxComp = (Case LST_Flag When 1 then @LTConst When 0 Then @CTConst End) + Cast(Cast(IsNull(Tax_Percentage, 0) as Decimal(18,3)) as nVarchar) + '%' 
		From TaxComponents Where Tax_Code = @TaxCode And TaxComponent_Code = @TaxCompCode

		Set @RetStr = @RetStr + '_(' + @TaxComp + ')'

		-- The issue raised on CRM 10861902 is resolved
		-- Report not generated when same tax component detail is added in Tax for different taxes
		Select @Appon = applicableon From TaxComponents Where Tax_Code = @TaxCode And TaxComponent_Code = @TaxCompCode  
		Select @sp_percent = SP_Percentage From TaxComponents Where Tax_Code = @TaxCode And TaxComponent_Code = @TaxCompCode  

		Set @RetStr = @RetStr + ' ' + @Appon
		Set @RetStr = @RetStr + ' ' + cast (@sp_percent as varchar) + '%'
	End

	Return @RetStr
End
