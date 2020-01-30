Create Procedure mERP_sp_InsertRecdTaxBeforeDiscount(@MenuName nVarChar(100), @MenuLock  int, @EffDate DateTime, @Flag int, @trantype int)
As
Begin
Set DateFormat dmy

	Declare @RecConfigAbsID int
	Declare @InvTranDate Datetime
	Declare @BillTranDate Datetime


	Select @InvTranDate = Max(dbo.StripTimeFromDate(InvoiceDate)) from InvoiceAbstract 
	Select @BillTranDate = Max(dbo.StripTimeFromDate(BillDate)) from BillAbstract 

	If Exists(select * from tbl_merp_ConfigAbstract where ScreenCode = 'TaxBeforeDiscount')
	Begin
			/*
			After FSU Installation and while opening Forum Entries are created in the Process table based on the Registry
			For Fresh Installation Registry entries will not be available for TaxbeforeDiscount/ TaxbeforeDiscountBill.
			If the Process table (tbl_mERP_TaxBeforeDiscount) contains null Entries then 
			While flowing the CustomerConfig XML EffectiveDate for TaxbeforeDiscount will be Inserted into 
			tbl_mERP_TaxBeforeDiscount table.
			*/
		If (Select Count(*) from tbl_mERP_TaxBeforeDiscount Where Trantype = 1) = 0
	    Begin
				Insert Into tbl_mERP_TaxBeforeDiscount(Trantype, Flag, EffectiveFrom, Active, creationDate)
				Values(1, @Flag, @EffDate, 1, GetDate())
		End
		Else If (Select Count(*) from tbl_mERP_TaxBeforeDiscount Where Trantype = 2) = 0
		Begin
				Insert Into tbl_mERP_TaxBeforeDiscount(Trantype, Flag, EffectiveFrom, Active, creationDate)
				Values(2, @Flag, @EffDate, 1, GetDate())
		End
		Else
		Begin	
			Insert Into tbl_mERP_RecConfigAbstract(MenuName, Flag, Status) Values(@MenuName, @MenuLock, 0)
			SET @RecConfigAbsID = @@identity
			If IsNull(@trantype, 0) = 1 
			Begin
				Insert Into tbl_mERP_RecdTaxBeforeDiscount(RecdConfigAbsID, EffectiveDate, Flag, CreationDate, TranDate, Trantype)
				Values(@RecConfigAbsID, @EffDate, @Flag,  GetDate(), @InvTranDate, @trantype)
			End
			Else If IsNull(@trantype, 0) = 2
			Begin
				Insert Into tbl_mERP_RecdTaxBeforeDiscount(RecdConfigAbsID, EffectiveDate, Flag, CreationDate, TranDate, Trantype)
				Values(@RecConfigAbsID, @EffDate, @Flag, GetDate(), @BillTranDate, @trantype)
			End 		
		End
	End
End
