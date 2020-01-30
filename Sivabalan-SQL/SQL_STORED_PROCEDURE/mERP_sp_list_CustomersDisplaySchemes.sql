Create procedure mERP_sp_list_CustomersDisplaySchemes(@DSchemeID nVarchar(4000))
As  
Begin

Declare @SchemeID int
-- Set @SchemeID = 146
--Declare @DSchemeID nVarchar(4000)
--Set @DSchemeID = '150|209,150|210'

Create table #DispSchemeID(ID Int Identity(1,1), SchemeID nVarchar(255))
Insert Into #DispSchemeID
Select * from dbo.sp_SplitIn2Rows(@DSchemeID, ',')

Create table #TempSchemeID(ID Int identity(1,1), SchemeID int, PayoutID int)
Truncate table #TempSchemeID

Declare @SchPayID nVarchar(100)

Declare PayCur Cursor for
Select SchemeID from #DispSchemeID Order By ID

Open PayCur
Fetch from payCur Into @SchPayID
While @@Fetch_Status = 0  
Begin  
	Insert Into #TempSchemeID(SchemeID, PayoutID)
	Select * from dbo.merp_fn_SplitIn2Cols_Disp(@SchPayID, '|')
Fetch Next from payCur Into @SchPayID
End
Close PayCur
Deallocate Paycur

--Select * from #TempSchemeID

Declare @OLClassID int
Declare @cntCustomers int
Declare @PayoutID int
Declare @TotalcntCustomers int
Declare @CRNoteRaisedCustomers int
Declare @CntCustomersNOtCreated int

Create table #tmp(ID Int Identity(1,1), ActivityCode nVarchar(255), TotalCustomersCnt Int, CreditNoteCustomers Int, CntCustomersNOtCreated int, SchemeID int)

Declare @Channel nVarchar(255)
Declare @Outlettype nVarchar(255)
Declare @SubOutlettype  nVarchar(255)
Declare @ActivityCode  nVarchar(255)

Declare SchemeCur Cursor For
Select SchemeID, PayoutID From #TempSchemeID Order By ID
Open SchemeCur
Fetch From SchemeCur Into @SchemeID, @payoutID
While @@Fetch_Status = 0
Begin
	Set @ActivityCode  = ''
	Select @ActivityCode   = ActivityCode  from tbl_merp_SchemeAbstract where SchemeID = @SchemeID

	Set @cntCustomers = 0
	Set @TotalcntCustomers = 0

	Set @OlclassID = 0
	Set @cntCustomers = 0

	Select @cntCustomers = Count(*) from tbl_mERP_DispSchBudgetPayout where SchemeID = @SchemeID and payoutPeriodID = @payoutID

	Select @CRNoteRaisedCustomers = Count(*) from  tbl_mERP_DispSchBudgetPayout where SchemeID = @SchemeID 
	and CRNoteRaised = 1 and PayoutPeriodID = @PayoutID

	Set @TotalcntCustomers = @TotalcntCustomers + @cntCustomers

	If IsNull(@TotalcntCustomers,0) > IsNull(@CRNoteRaisedCustomers,0)
	Begin
		Set @CntCustomersNotCreated = IsNull(@TotalcntCustomers,0) - IsNull(@CRNoteRaisedCustomers,0)
	End

	If IsNull(@CntCustomersNOtCreated,0) > 0 
	Begin
		Insert Into #tmp(ActivityCode, TotalCustomersCnt, CreditNoteCustomers, CntCustomersNOtCreated, SchemeID)
		Select @ActivityCode, IsNull(@TotalcntCustomers,0), IsNull(@CRNoteRaisedCustomers,0), IsNull(@CntCustomersNOtCreated,0), @SchemeID 
	End

Fetch Next From SchemeCur Into @SchemeID, @payoutID
End 
Close SchemeCur
Deallocate SchemeCur

--Select Distinct SchemeID from #tmp

Select * from #tmp

Drop table #tmp
Drop table #DispSchemeID
Drop table #TempSchemeID

End
