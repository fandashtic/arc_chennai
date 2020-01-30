Create Procedure merp_SP_ConfigTaxSettings(@ServerDate datetime, @Mode as int)
As
Begin

Declare @Flag int
Declare @CommonFlag int
Declare @Invoicedate datetime
Set Dateformat dmy

Declare @Invdate datetime
Declare @BillDate datetime


Select @Invdate = Max(IsNull(EffectiveFrom,''))  from tbl_mERP_TaxBeforeDiscount 
where isNull(EffectiveTo,'') = '' and Active = 1 and TranType = 1

Select @BillDate = Max(IsNull(EffectiveFrom,''))  from tbl_mERP_TaxBeforeDiscount 
where isNull(EffectiveTo,'') = '' and Active = 1 and TranType = 2

Set @Invoicedate = dbo.StripTimeFromDate(@ServerDate)

If (Select Count(*) from tbl_mERP_TaxBeforeDiscount) = 0
Begin
	--Set @Flag = 0
	Goto Out
End

If (isNull(@Mode,0) > 2)
Begin
	Goto Out
	Insert Into tbl_mERP_RecdErrMessages (TransactionType, ErrMessage, KeyValue, ProcessDate)    
	Values('GeneralSettings-ComputeTaxbeforeDiscount', 'Mode is Greater than one',  Convert(Datetime, Cast(@Invoicedate as nVarchar(100))), Getdate())  	
End


If IsNull(@Mode,0) = 1 
Begin
	If dbo.StripTimeFromDate(@Invoicedate) >= dbo.StripTimeFromDate(@Invdate)
	Begin
		Select @CommonFlag = IsNull(Flag,0) from tbl_mERP_TaxBeforeDiscount
		Where @Invoicedate >= @Invdate and Active = 1 and Trantype = 1
	End
	Else If (Select Count(*) from tbl_mERP_TaxBeforeDiscount
		Where dbo.striptimeFromDate(@Invoicedate) Between dbo.striptimeFromDate(EffectiveFrom) and dbo.striptimeFromDate(EffectiveTo)
		And Active = 1 and Trantype = 1) = 1
		Begin
			Select @CommonFlag = IsNull(Flag,0) from tbl_mERP_TaxBeforeDiscount
			Where dbo.striptimeFromDate(@Invoicedate) Between dbo.striptimeFromDate(EffectiveFrom) and dbo.striptimeFromDate(EffectiveTo)
			And Active = 1 and Trantype = 1
		End
	Else If dbo.StripTimeFromDate(@Invoicedate) < dbo.StripTimeFromDate(@Invdate)
	Begin
		Select Top 1 @CommonFlag = IsNull(Flag,0) from tbl_mERP_TaxBeforeDiscount
		Where @Invoicedate < @Invdate and Active = 1 and Trantype = 1
	End
End
Else If IsNull(@Mode,0) = 2 
Begin
	If @Invoicedate >= dbo.StripTimeFromDate(@BillDate)
	Begin
		Select @CommonFlag = IsNull(Flag,0) from tbl_mERP_TaxBeforeDiscount
		Where @Invoicedate >= @BillDate and ACtive = 1 and Trantype = 2
	End
	Else If (Select Count(*) from tbl_mERP_TaxBeforeDiscount
		Where dbo.striptimeFromDate(@Invoicedate) Between dbo.striptimeFromDate(EffectiveFrom) and dbo.striptimeFromDate(EffectiveTo)
		And ACtive = 1 and Trantype = 2) = 1
		Begin	
			Select @CommonFlag = IsNull(Flag,0) from tbl_mERP_TaxBeforeDiscount
			Where @Invoicedate Between dbo.striptimeFromDate(EffectiveFrom) and dbo.striptimeFromDate(EffectiveTo) 
			And ACtive = 1 and Trantype = 2
		End
	Else If @Invoicedate < dbo.StripTimeFromDate(@BillDate)
	Begin
		Select Top 1 @CommonFlag = IsNull(Flag,0) from tbl_mERP_TaxBeforeDiscount
		Where @Invoicedate < dbo.StripTimeFromDate(@BillDate) and Active = 1 and Trantype = 2
	End
End

Select @CommonFlag

Out:

End
