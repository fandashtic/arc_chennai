Create Function sp_acc_GetFiscalYearStart()
Returns DateTime
As
Begin
	Declare @CheckDate as datetime,@StrDate as nvarchar(255)
	Declare @YearStart Int,@FiscalYear Int,@OpeningDate DateTime
	Select @FiscalYear=IsNull(FiscalYear,4),@OpeningDate=OpeningDate From Setup
	If @FiscalYear =1
	Begin
		Select @StrDate=  N'1/' + Cast(IsNull(@FiscalYear,4) as nvarchar) + N'/' + Cast(Year(@OpeningDate) As nVarchar(50))-- From Setup
	End
	Else
	Begin
		If Month(@OpeningDate) < @Fiscalyear
		Begin
			Select @StrDate=  N'1/' + Cast(IsNull(@FiscalYear,4) as nvarchar) + N'/' + Cast((Year(@OpeningDate)-1) As nVarchar(50))
		End
		Else
		Begin
			Select @StrDate=  N'1/' + Cast(IsNull(@FiscalYear,4) as nvarchar) + N'/' + Cast(Year(@OpeningDate) As nVarchar(50)) --From Setup
		End
	End
	Set @CheckDate =Cast(@StrDate As DateTime)
	Return @CheckDate
End







