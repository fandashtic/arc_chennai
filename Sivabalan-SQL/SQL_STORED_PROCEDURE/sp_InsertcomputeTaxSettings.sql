Create Procedure sp_InsertcomputeTaxSettings(@InvoiceFlag int, @BillFlag int) 
As
Begin
	Declare @InvTranDate datetime
	Declare @BillTranDate datetime


	Select @InvTranDate = Max(dbo.StripTimeFromDate(InvoiceDate)) from InvoiceAbstract 
	Select @BillTranDate = Max(dbo.StripTimeFromDate(BillDate)) from BillAbstract 

	If (Select Count(*) from tbl_mERP_TaxBeforeDiscount) = 0
	Begin
		Insert Into tbl_mERP_TaxBeforeDiscount(tranType, Flag, EffectiveFrom, Effectiveto, Active, CreationDate)
		Values(1, @InvoiceFlag, @InvTranDate, null, 1, getDate())
		Insert Into tbl_mERP_TaxBeforeDiscount(tranType, Flag, EffectiveFrom, Effectiveto, Active, CreationDate)
		Values(2, @BillFlag, @BillTranDate, null, 1, getDate())
	End		
End
