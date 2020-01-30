Create Procedure mERP_sp_ProcessTaxBeforeDiscount(@ID int) 
As
Begin

Declare @TranDate Datetime
Declare @MaxEffFromDateInv Datetime
Declare @MaxEffFromDateBill Datetime
Declare @InvProcessID int
Declare @BillProcessID int
Declare @InvTranDate Datetime
Declare @BillTranDate Datetime
Declare @EffDateInvPrev Datetime
Declare @EffDateBillPrev Datetime

Declare @KeyValue nVarchar(255)
Declare @Errmessage nVarchar(1000)
Declare @ErrStatus int
Declare @PrevRecordID int

Declare @RecdID int
Declare @Trantype int

Set DateFormat dmy

Select @InvTranDate = Max(dbo.StripTimeFromDate(InvoiceDate)) from InvoiceAbstract
Select @BillTranDate = Max(dbo.StripTimeFromDate(BillDate)) from BillAbstract


Declare @EffDate datetime
Declare @Flag int


select @EffDate = IsNull(EffectiveDate,'') 
, @Flag = IsNull(Flag,0), @RecdID = IsNull(ID,0), @Trantype = isNull(Trantype,0)
from  tbl_mERP_RecdTaxBeforeDiscount 
where RecdConfigAbsID = @ID


Select top 1 @InvProcessID = ID,  @MaxEffFromDateInv = Max(EffectiveFrom) 
from tbl_mERP_TaxBeforeDiscount where TranType = 1 and Active = 1
Group By ID
Order By ID desc

Select top 1 @BillProcessID = ID,  @MaxEffFromDateBill = Max(EffectiveFrom)
from tbl_mERP_TaxBeforeDiscount where TranType = 2 and Active = 1
Group By ID
Order By ID desc

-- Invoice Validation
Set @ErrStatus = 0

--Begin: New type
If IsNull(@Trantype,0) = 1
Begin
	If IsNull(Year(@EffDate),0) < 2000
	Begin
		Set @Errmessage = 'Config Tax Settings has Invalid Values for Effectivedate Of Invoice'
		Set @ErrStatus = 1
		Goto last
	End
	Else If IsNull(@Flag,0) > 1
	Begin
		Set @Errmessage = 'Invoice Flag has Invalid Value'
		Set @ErrStatus = 1
		Goto last
	End
	Else If (IsNull(@EffDate,'') <> '') 
	Begin
	  If (Select Count(*) from tbl_mERP_TaxBeforeDiscount where TranType = 1) = 0
	   Begin
		Goto Last
	   End
		Else 
		Begin
			If (IsNull(@EffDate,'') >= IsNull(@MaxEffFromDateInv,''))
			Begin
				IF (IsNull(@MaxEffFromDateInv,'') > dbo.StripTimeFromDate(@InvTranDate))
				Begin
					If (IsNull(@EffDate,'') > (IsNull(@MaxEffFromDateInv,'')))
					Begin
						Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @InvProcessID and TranType = 1
						Set  @EffDateInvPrev = DateAdd(day, -1, @EffDate)	
						If Exists ( Select ID from tbl_merp_TaxbeforeDiscount Where @InvTranDate Between EffectiveFrom and EffectiveTo and Trantype = 1)
						Begin		
							Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@EffDateInvPrev)
							where TranType = 1 and @InvTranDate Between EffectiveFrom and EffectiveTo 
						End
						Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID)
						Values (1, @Flag, @EffDate, @RecdID)
					End
					Else
					Begin
						Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @InvProcessID and TranType = 1
						Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID) 
						Values(1, @Flag, @EffDate, @RecdID)
					End
				End
				Else
				Begin
					If (IsNull(@EffDate,'') < (IsNull(dbo.StripTimeFromDate(@InvTranDate),'')))
					Begin
						If ((IsNull(dbo.StripTimeFromDate(@InvTranDate),'')) > IsNull(@EffDate,''))
						Begin
							Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@InvTranDate) where TranType = 1
							and ID = @InvProcessID and TranType = 1
							Set @InvTranDate = dbo.StripTimeFromDate(@InvTranDate) + 1
							Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID) 
							Values(1, @Flag, @InvTranDate, @RecdID)
						End	
						Else
						begin
							Set  @EffDateInvPrev = DateAdd(day, -1, @EffDate)			
							Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@EffDateInvPrev) where TranType = 1
							and ID = @InvProcessID and TranType = 1
							Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID) 
							Values(1, @Flag, @EffDate, @RecdID)
						End
					End
					Else If (IsNull(@EffDate,'') > (IsNull(dbo.StripTimeFromDate(@InvTranDate),'')))
					Begin
						Set  @EffDateInvPrev = DateAdd(day, -1, @EffDate)			
						Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@EffDateInvPrev) where TranType = 1
						and ID = @InvProcessID and TranType = 1
						Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID) 
						Values(1, @Flag, @EffDate, @RecdID)
					End
					Else
					Begin
						Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@InvTranDate) 
						where TranType = 1 and ID = @InvProcessID and TranType = 1
						Set @InvTranDate = dbo.StripTimeFromDate(@InvTranDate) + 1
						Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID) 
						Values(1, @Flag, @InvTranDate, @RecdID)
					End
				End
			End
			Else --EffectiveDate is lesser than Max(EffectiveDate)
			Begin
				If (IsNull(@EffDate,'') > dbo.StripTimeFromDate(@InvTranDate))
				Begin
					Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @InvProcessID and TranType = 1
					--Here for ParentID EffectiveTo Date is updated
					Set  @EffDateInvPrev = DateAdd(day, -1, @EffDate)
					If ( Select Count(*) from tbl_mERP_TaxBeforeDiscount where @EffDateInvPrev between EffectiveFrom and Effectiveto and Trantype = 1) = 1
					Begin
						Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = @EffDateInvPrev where @EffDateInvPrev between EffectiveFrom and Effectiveto
						and TranType = 1
					End
					Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where EffectiveFrom  > @EffDateInvPrev and TranType = 1
					Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID)
					Values (1, @Flag, @EffDate, @RecdID)		
				End
				Else
				Begin
					If (IsNull(@EffDate,'') < (IsNull(dbo.StripTimeFromDate(@InvTranDate),'')))
					Begin
						If ((@InvTranDate) >= (@MaxEffFromDateInv))
						Begin
							--Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @InvProcessID
							Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@InvTranDate)
							where ID = @InvProcessID and TranType = 1
							Set @InvTranDate = dbo.StripTimeFromDate(@InvTranDate) + 1
							Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID)
							Values (1, @Flag, @InvTranDate, @RecdID)		
						End
						Else If ((@InvTranDate) <= (@MaxEffFromDateInv))
						Begin
							Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @InvProcessID and TranType = 1
							If (Select Count(*) from tbl_mERP_TaxBeforeDiscount where @InvTranDate between EffectiveFrom and Effectiveto and Trantype = 1 ) = 1
							Begin
								Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = @InvTranDate where @InvTranDate between EffectiveFrom and Effectiveto
								and TranType = 1
							End						
							Set @InvTranDate = dbo.StripTimeFromDate(@InvTranDate) + 1
							Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID)
							Values (1, @Flag, @InvTranDate, @RecdID)		
						End
						Else
						Begin
							Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @InvProcessID and TranType = 1
							--Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@Trandate)
							--where ID = @InvparentID
							Set @InvTranDate = dbo.StripTimeFromDate(@InvTranDate) + 1
							Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID)
							Values (1, @Flag, @InvTranDate, @RecdID)		
						End
					End
					Else 
					Begin
						Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @InvProcessID and TranType = 1
						--Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@Trandate) where TranType = 1
						--and ID = @InvProcessID
						Set @InvTranDate = dbo.StripTimeFromDate(@InvTranDate) + 1
						Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID) 
						Values(1, @Flag, @InvTranDate, @RecdID)
					End	
				End
			End
		End
End -- End Of Invoice
End



--Bill
If IsNull(@Trantype,0) = 2
Begin
	If IsNull(Year(@EffDate),0) < 2000
	Begin
		Set @Errmessage = 'Config Tax Settings has Invalid Values for Effectivedate Of Bill'
		Set @ErrStatus = 1
		Goto last
	End
	Else If IsNull(@Flag,0) > 1
	Begin
		Set @Errmessage = 'Bill Flag has Invalid Value'
		Set @ErrStatus = 1
		Goto last
	End
	Else If (isNull(@EffDate,'') <> '')
	Begin
		If (Select Count(*) from tbl_mERP_TaxBeforeDiscount where TranType = 2) = 0
		Begin
			Goto Last
		End
		Else 
		Begin
			If (IsNull(@EffDate,'') >= IsNull(@MaxEffFromDateBill,''))
			Begin
				IF (IsNull(@MaxEffFromDateBill,'') > dbo.StripTimeFromDate(@BillTranDate))
				Begin
					If (IsNull(@EffDate,'') > (IsNull(@MaxEffFromDateBill,'')))
					Begin
						Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @BillProcessID and TranType = 2
						Set  @EffDateBillPrev = DateAdd(day, -1, @EffDate)			
						If Exists ( Select ID from tbl_merp_TaxbeforeDiscount Where @BillTranDate Between EffectiveFrom and EffectiveTo and Trantype = 2)
						Begin		
							Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@EffDateBillPrev)
							where TranType = 2 and @BillTranDate Between EffectiveFrom and EffectiveTo 
						End
						Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID)
						Values (2, @Flag, @EffDate, @RecdID)
					End
					Else
					Begin
						Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @BillProcessID and TranType = 2
						Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID) 
						Values(2, @Flag, @EffDate, @RecdID)
					End
				End
				Else
				Begin
					If (IsNull(@EffDate,'') < (IsNull(dbo.StripTimeFromDate(@BillTranDate),'')))
					Begin
						If ((IsNull(dbo.StripTimeFromDate(@BillTranDate),'')) > IsNull(@EffDate,''))
						Begin
							Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@BillTranDate) where TranType = 2
							and ID = @BillProcessID and TranType = 2
							Set @BillTranDate = dbo.StripTimeFromDate(@BillTranDate) + 1
							Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID) 
							Values(2, @Flag, @BillTranDate, @RecdID)
						End	
						Else
						Begin
							Set  @EffDateBillPrev = DateAdd(day, -1, @EffDate)			
							Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@EffDateBillPrev) 
							where ID = @BillProcessID and TranType = 2
							Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID) 
							Values(2, @Flag, @EffDate, @RecdID)
						End
					End
					Else If (IsNull(@EffDate,'') > (IsNull(dbo.StripTimeFromDate(@BillTranDate),'')))
					Begin
						Set  @EffDateBillPrev = DateAdd(day, -1, @EffDate)			
						Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@EffDateBillPrev) 
						where ID = @BillProcessID and TranType = 2
						Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID) 
						Values(2, @Flag, @EffDate, @RecdID)
					End
					Else
					Begin
						Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@BillTranDate) 
						where TranType = 2 and ID = @BillProcessID 
						Set @BillTranDate = dbo.StripTimeFromDate(@BillTranDate) + 1
						Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom,  RecdID) 
						Values(2, @Flag, @BillTranDate, @RecdID)
					End
				End
			End
		Else --EffectiveDate is lesser than Max(EffectiveDate)
		Begin
			If (IsNull(@EffDate,'') > dbo.StripTimeFromDate(@BillTranDate))
			Begin
				Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @BillProcessID and TranType = 2
				--Here for ParentID EffectiveTo Date is updated
				Set  @EffDateBillPrev = DateAdd(day, -1, @EffDate)
				If ( Select Count(*) from tbl_mERP_TaxBeforeDiscount where @EffDateBillPrev between EffectiveFrom and Effectiveto and Trantype =  2) = 1
				Begin
					Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = @EffDateBillPrev where @EffDateBillPrev between EffectiveFrom and Effectiveto and TranType = 2
				End
				Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where EffectiveFrom  > @EffDateBillPrev  and TranType = 2
				Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom,  RecdID)
				Values (2, @Flag, @EffDate, @RecdID)		
			End
			Else
			Begin
				If (IsNull(@EffDate,'') < (IsNull(dbo.StripTimeFromDate(@BillTranDate),'')))
				Begin
					If ((@BillTranDate) >= (@MaxEffFromDateBill))
					Begin
						Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = dbo.StripTimeFromDate(@BillTranDate)
						where ID = @BillProcessID and TranType = 2
						Set @BillTranDate = dbo.StripTimeFromDate(@BillTranDate) + 1
						Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID)
						Values (2, @Flag, @BillTranDate, @RecdID)		
					End
					Else If ((@BillTranDate) <= (@MaxEffFromDateBill))
					Begin
						Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @BillProcessID and TranType = 2
						If ( Select Count(*) from tbl_mERP_TaxBeforeDiscount where @BillTranDate between EffectiveFrom and Effectiveto and Trantype = 2) = 1
						Begin
							Update tbl_mERP_TaxBeforeDiscount Set EffectiveTo = @BillTranDate where @BillTranDate between EffectiveFrom and Effectiveto and TranType = 2
						End						
						Set @BillTranDate = dbo.StripTimeFromDate(@BillTranDate) + 1
						Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID)
						Values (2, @Flag, @BillTranDate, @RecdID)		
					End
					Else
					Begin
						Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @BillProcessID and TranType = 2
						Set @BillTranDate = dbo.StripTimeFromDate(@BillTranDate) + 1
						Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID)
						Values (2, @Flag, @BillTranDate, @RecdID)		
					End
				End
				Else 
				Begin
					Update tbl_mERP_TaxBeforeDiscount Set Active = 0 where ID = @BillProcessID and TranType = 2
					Set @BillTranDate = dbo.StripTimeFromDate(@BillTranDate) + 1
					Insert Into tbl_mERP_TaxBeforeDiscount(TranType, Flag, EffectiveFrom, RecdID) 
					Values(2, @Flag, @BillTranDate, @RecdID)
				End	
			End
		End
	End
 End 
End -- End Of Bill


	Update tbl_mERP_RecConfigAbstract Set Status = Status | 32 where ID = @ID
	Goto Out
Last:
	-- Error Log Written and Status Updation of rejected Detail 
	If (@ErrStatus = 1)
	Begin
		Set @KeyValue = ''
		Set @KeyValue = Convert(nVarchar, @ID) --+ '|' + Convert(nVarchar,@SlNo)
		Update tbl_mERP_RecConfigAbstract Set Status = 2
		Insert Into tbl_mERP_RecdErrMessages (TransactionType, ErrMessage, KeyValue, ProcessDate)    
		Values('TaxbeforeDiscount', @Errmessage,  @KeyValue, Getdate())  
		Select 1
		Goto endl
	End

Out:
	Select 100

endl:
End
