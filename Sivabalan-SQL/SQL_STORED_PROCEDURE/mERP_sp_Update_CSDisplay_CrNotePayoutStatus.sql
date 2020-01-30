Create Procedure mERP_sp_Update_CSDisplay_CrNotePayoutStatus(@SchemeID Int, 
    @PayoutPeriodID Int, @CustomerID nVarchar(50), @DocRef nVarchar(25))
As
Begin

	Declare @SchDesc nVarchar(2000)
	Declare @CreditID int
	Declare @SchPayoutFrom DateTime
	Declare @PayoutDate nVarchar(100)
	Select @SchPayoutFrom = dbo.StripTimeFromDate(PayoutPeriodFrom) from tbl_mERP_SchemePayoutPeriod where  ID = @PayoutPeriodID

	select @PayoutDate = convert(varchar(100), @SchPayoutFrom, 3)
	select @PayoutDate = Substring(@PayoutDate, CharIndex('/',@PayoutDate,1)+1, Len(@PayoutDate))

	Select @CreditID  = CreditID from CreditNote Where DocumentReference = @DocRef and isNull(Flag,0) = 1
	Select @SchDesc = IsNull(Description, '') from tbl_mERP_SchemeAbstract Where SchemeID = @SchemeID 

	Update CreditNote Set 
	 Memo = 'CR' + Cast(@CreditID as nVarchar(1000)) + '-' + @PayoutDate + '-' + 'QPS' + '-' + @SchDesc, Payoutid = @PayoutPeriodID
		Where CreditID = @CreditID 

	

	Declare @CrNoteValue Decimal(18,6)
	Select @CrNoteValue = NoteValue from CreditNote Where DocumentReference = @DocRef And IsNull(Status,0) & 128 = 0
  
  Update tbl_mERP_DispSchBudgetPayout Set  PayoutAmount=0, CrNoteRaised = 1,  
    DocReference = Case Len(IsNull(DocReference,'')) When 0 Then @DocRef Else DocReference + N', '+ @DocRef End
  Where SchemeID = @SchemeID And 
    PayoutPeriodID = @PayoutPeriodID And   
    OutletCode = @CustomerID

  Select @@ROWCOUNT 
End 
