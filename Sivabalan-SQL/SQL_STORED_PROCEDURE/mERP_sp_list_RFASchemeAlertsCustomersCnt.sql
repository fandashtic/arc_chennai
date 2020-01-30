Create procedure mERP_sp_list_RFASchemeAlertsCustomersCnt(@DSchemeID nVarchar(4000))
As  
Begin

Declare @SchemeID int
-- Set @SchemeID = 146
--Declare @DSchemeID nVarchar(4000)
--Set @DSchemeID = '146205,148207,150209'

Create table #DispSchemeID(ID Int Identity(1,1), SchemeID nVarchar(255))
Insert Into #DispSchemeID
Select * from dbo.sp_SplitIn2Rows(@DSchemeID, ',')

Create table #TempSchemeID(ID Int identity(1,1), SchemeID int, PayoutID int)
Truncate table #TempSchemeID

Create table #TempDisplaySchemeIDs(ID Int identity(1,1), SchemeID int, PayoutID int)
Truncate table #TempDisplaySchemeIDs

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

Insert Into #TempDisplaySchemeIDs(SchemeID, PayoutID)
Select T.SchemeID, PayoutID From #TempSchemeID T Inner Join tbl_merp_SchemeAbstract SA ON T.SchemeID = SA.SchemeID
and SA.Schemetype = 3

-- Select * from #TempDisplaySchemeIDs

Create table #QPSSchemeIDS(ID Int identity(1,1), SchemeID int, PayoutID int)

Insert into #QPSSchemeIDS(SchemeID, PayoutID)
Select Distinct QPS.SchemeID, T.PayoutID from #TempSchemeID T Inner Join tbl_merp_schemeOutlet QPS On T.SchemeID = QPS.SchemeID
Inner Join tbl_merp_schemeSlabDetail SL on QPS.SchemeID = SL.SchemeID
Inner Join tbl_merp_schemeAbstract SA on SL.SchemeID = SA.SchemeID
Where QPS.QPS = 1
and SL.Slabtype  = 3

--Select * from #QPSSchemeIDS


Declare @OLClassID int
Declare @cntCustomers int
Declare @PayoutID int
Declare @TotalcntCustomers int
Declare @CRNoteRaisedCustomers int
Declare @CntCustomersNOtCreated int
Declare @DispSchemeDesc nVarchar(1000)
Declare @QPSSchemeDesc nVarchar(1000)


Create table #DisplaySchemetmp(ID Int Identity(1,1), ActivityCode nVarchar(255),  SchDesc nVarchar(1000),  TotalCustomersCnt Int, CreditNoteCustomers Int, CntCustomersNOtCreated int, SchemeID int,Schemetype nVarchar(100))

Declare @Channel nVarchar(255)
Declare @Outlettype nVarchar(255)
Declare @SubOutlettype  nVarchar(255)
Declare @ActivityCode  nVarchar(255)

Declare SchemeCur Cursor For
--Select SchemeID, PayoutID From #TempSchemeID Order By ID
Select SchemeID, PayoutID From #TempDisplaySchemeIDs Order By ID
Open SchemeCur
Fetch From SchemeCur Into @SchemeID, @payoutID
While @@Fetch_Status = 0
Begin
	Set @ActivityCode  = ''
	Select @ActivityCode = ActivityCode, @DispSchemeDesc = Description  from tbl_merp_SchemeAbstract where SchemeID = @SchemeID 
	
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
		Insert Into #DisplaySchemetmp(ActivityCode, SchDesc, TotalCustomersCnt, CreditNoteCustomers, CntCustomersNOtCreated, SchemeID, Schemetype)
		Select @ActivityCode, @DispSchemeDesc, IsNull(@TotalcntCustomers,0), IsNull(@CRNoteRaisedCustomers,0), IsNull(@CntCustomersNOtCreated,0), @SchemeID, 'Display'
	End

Fetch Next From SchemeCur Into @SchemeID, @payoutID
End 
Close SchemeCur
Deallocate SchemeCur

--Select Distinct SchemeID from #tmp
Declare @InvAdjustedItemsCnt int
Declare @InvNotAdjustedItemsCnt int

Create table #QPSTradeSchemetmp(ID Int Identity(1,1), ActivityCode nVarchar(255), QPSSchDesc nVarchar(1000),  TotalCustomersCnt Int, InvAdjustedFreeItems Int, InvNotAdjustedFreeItems  int, SchemeID int, Schemetype nVarchar(100))

Declare SchemeCur Cursor For
Select SchemeID, PayoutID From #QPSSchemeIDS Order By ID
Open SchemeCur
Fetch From SchemeCur Into @SchemeID, @payoutID
While @@Fetch_Status = 0
Begin
	Set @ActivityCode  = ''
	Select @ActivityCode = ActivityCode, @QPSSchemeDesc = Description  from tbl_merp_SchemeAbstract where SchemeID = @SchemeID

	Set @cntCustomers = 0
	Set @InvAdjustedItemsCnt = 0
	Set @InvNotAdjustedItemsCnt = 0

	Select @cntCustomers = Count(Distinct CustomerID) from SchemeCustomerItems where SchemeID = @SchemeID and PayoutID = @payoutID
	Select @InvAdjustedItemsCnt = Count( Distinct CustomerID) from  SchemeCustomerItems where SchemeID = @SchemeID and IsInvoiced = 1 and PayoutID = @PayoutID
	Select @InvNotAdjustedItemsCnt = Count( Distinct CustomerID) from  SchemeCustomerItems where SchemeID = @SchemeID and IsInvoiced = 0 and PayoutID = @PayoutID

	If IsNull(@cntCustomers,0) > 0 
	Begin
		Insert Into #QPSTradeSchemetmp(ActivityCode, QPSSchDesc, TotalCustomersCnt, InvAdjustedFreeItems, InvNotAdjustedFreeItems, SchemeID, Schemetype)
		Select @ActivityCode, @QPSSchemeDesc, IsNull(@cntCustomers,0), IsNull(@InvAdjustedItemsCnt,0), IsNull(@InvNotAdjustedItemsCnt,0), @SchemeID, 'QPS Item Free' 
	End

Fetch Next From SchemeCur Into @SchemeID, @payoutID
End 
Close SchemeCur
Deallocate SchemeCur


Select ID, ActivityCode, SchDesc,  Schemetype, TotalCustomersCnt, CreditNoteCustomers, cntCustomersNotCreated, SchemeID from #DisplaySchemetmp where TotalCustomersCnt <> CreditNoteCustomers
UNION
-- ActivityCode nVarchar(255), TotalCustomersCnt Int, InvAdjustedFreeItems Int, InvNotAdjustedFreeItems  int, SchemeID int, Schemetype nVarchar(100)
Select ID, ActivityCode, QPSSchDesc, Schemetype, TotalCustomersCnt, InvAdjustedFreeItems, InvNotAdjustedFreeItems, SchemeID  from #QPSTradeSchemetmp where TotalCustomersCnt <> InvAdjustedFreeItems

Drop table #DisplaySchemetmp
Drop table #DispSchemeID
Drop table #TempSchemeID
Drop table #TempDisplaySchemeIDs
Drop table #QPSTradeSchemetmp
Drop table #QPSSchemeIDS
End
