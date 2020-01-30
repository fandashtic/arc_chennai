Create procedure mERP_sp_list_RFASchemeAlertsCustomersCnt_QPSFree(@DSchemeID nVarchar(4000))
As  
Begin

Declare @SchemeID int
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

Create table #QPSSchemeIDS(ID Int identity(1,1), SchemeID int, PayoutID int)

Insert into #QPSSchemeIDS(SchemeID, PayoutID)
Select Distinct QPS.SchemeID, T.PayoutID from #TempSchemeID T Inner Join tbl_merp_schemeOutlet QPS On T.SchemeID = QPS.SchemeID
Inner Join tbl_merp_schemeSlabDetail SL on QPS.SchemeID = SL.SchemeID
Inner Join tbl_merp_schemeAbstract SA on SL.SchemeID = SA.SchemeID
Where QPS.QPS = 1
and SL.Slabtype  = 3

Declare @OLClassID int
Declare @cntCustomers int
Declare @PayoutID int
Declare @TotalcntCustomers int
Declare @CRNoteRaisedCustomers int
Declare @CntCustomersNOtCreated int
Declare @DispSchemeDesc nVarchar(1000)
Declare @QPSSchemeDesc nVarchar(1000)

Declare @InvAdjustedItemsCnt int
Declare @InvNotAdjustedItemsCnt int

Create table #QPSTradeSchemetmp(ID Int Identity(1,1), ActivityCode nVarchar(255), QPSSchDesc nVarchar(1000),  TotalCustomersCnt Int, InvAdjustedFreeItems Int, InvNotAdjustedFreeItems  int, SchemeID int, Schemetype nVarchar(100))

Declare @Channel nVarchar(255)  
Declare @Outlettype nVarchar(255)  
Declare @SubOutlettype  nVarchar(255)  
Declare @ActivityCode  nVarchar(255) 

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


Select ID, ActivityCode, QPSSchDesc, Schemetype, TotalCustomersCnt, InvAdjustedFreeItems, InvNotAdjustedFreeItems, SchemeID  from #QPSTradeSchemetmp where TotalCustomersCnt <> InvAdjustedFreeItems


Drop table #DispSchemeID
Drop table #TempSchemeID
Drop table #QPSTradeSchemetmp
Drop table #QPSSchemeIDS
End
