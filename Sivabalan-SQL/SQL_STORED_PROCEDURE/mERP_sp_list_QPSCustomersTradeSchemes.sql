Create procedure mERP_sp_list_QPSCustomersTradeSchemes(@DSchemeID nVarchar(4000))
As  
Begin

Declare @SchemeID int
--Set @DSchemeID = '150|209,150|210'

Create table #QPSSchemeID(ID Int Identity(1,1), SchemeID nVarchar(255))
Insert Into #QPSSchemeID
Select * from dbo.sp_SplitIn2Rows(@DSchemeID, ',')

--Select * from #QPSSchemeID

Create table #TempSchemeID(ID Int identity(1,1), SchemeID int, PayoutID int)
Truncate table #TempSchemeID

Declare @SchPayID nVarchar(100)

Declare PayCur Cursor for
Select SchemeID from #QPSSchemeID Order By ID
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

Declare @cntCustomers int
Declare @PayoutID int
Declare @TotalcntCustomers int
Declare @InvAdjustedItemsCnt int
Declare @InvNotAdjustedItemsCnt int
Declare @ActivityCode  nVarchar(255)

Create table #tmp(ID Int Identity(1,1), ActivityCode nVarchar(255), TotalCustomersCnt Int, InvAdjustedFreeItems Int, InvNotAdjustedFreeItems  int, SchemeID int)

Create table #QPSSchemeIDS(ID Int identity(1,1), SchemeID int, PayoutID int)

Insert into #QPSSchemeIDS(SchemeID, PayoutID)
Select Distinct QPS.SchemeID, T.PayoutID from #TempSchemeID T Inner Join tbl_merp_schemeOutlet QPS On T.SchemeID = QPS.SchemeID
Inner Join tbl_merp_schemeSlabDetail SL on QPS.SchemeID = SL.SchemeID
Where QPS.QPS = 1
and SL.Slabtype  = 3

-- Select * from #QPSSchemeIDS

	If (Select Count(*) From #QPSSchemeIDS) <= 0 
	Begin
		GoTo Quit
	End


Declare SchemeCur Cursor For
Select SchemeID, PayoutID From #QPSSchemeIDS Order By ID
Open SchemeCur
Fetch From SchemeCur Into @SchemeID, @payoutID
While @@Fetch_Status = 0
Begin
	Set @ActivityCode  = ''
	Select @ActivityCode   = ActivityCode  from tbl_merp_SchemeAbstract where SchemeID = @SchemeID

	Set @cntCustomers = 0
	Set @InvAdjustedItemsCnt = 0
	Set @InvNotAdjustedItemsCnt = 0

	Select @cntCustomers = Count(Distinct CustomerID) from SchemeCustomerItems where SchemeID = @SchemeID and PayoutID = @payoutID
	Select @InvAdjustedItemsCnt = Count( Distinct CustomerID) from  SchemeCustomerItems where SchemeID = @SchemeID and IsInvoiced = 1 and PayoutID = @PayoutID
	Select @InvNotAdjustedItemsCnt = Count( Distinct CustomerID) from  SchemeCustomerItems where SchemeID = @SchemeID and IsInvoiced = 0 and PayoutID = @PayoutID

	If IsNull(@cntCustomers,0) > 0 
	Begin
		Insert Into #tmp(ActivityCode, TotalCustomersCnt, InvAdjustedFreeItems, InvNotAdjustedFreeItems, SchemeID)
		Select @ActivityCode, IsNull(@cntCustomers,0), IsNull(@InvAdjustedItemsCnt,0), IsNull(@InvNotAdjustedItemsCnt,0), @SchemeID 
	End

Fetch Next From SchemeCur Into @SchemeID, @payoutID
End 
Close SchemeCur
Deallocate SchemeCur

Quit:
	Select * from #tmp

	Drop table #tmp
	Drop table #QPSSchemeID
	Drop table #TempSchemeID
	Drop table #QPSSchemeIDS
End
