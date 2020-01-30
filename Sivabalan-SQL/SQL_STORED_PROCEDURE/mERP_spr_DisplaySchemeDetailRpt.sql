Create Procedure mERP_spr_DisplaySchemeDetailRpt( @SchPayoutID nVarchar(2550),
												  @FromDate Datetime,
									              @ToDate Datetime,
												  @RFAApplicable nVarchar(5),
												  @ActivityCode nVarchar(2550),
									              @SchemeName nVarchar(2550))
As

Declare @RFAPP Int
Declare @SchID Int
Declare @PayoutID Int
--Declare @DocRef nVarchar(2550)
Declare @IndexID1 Int
Declare @IndexID2 Int
Declare @Delimeter As Char(1)
--Declare @SchCrNote Table (SchID Int, PayoutID Int, CrN nVarchar(2550))

Declare @TSchID Int
Declare @TPayoutID Int
Declare @CrNoteDoc nVarchar(2550)
Declare @CustomerID nVarchar(255)

Declare @SchCrNote Table (SchID Int, PayoutID Int, CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	CrN nVarchar(2550) COLLATE SQL_Latin1_General_CP1_CI_AS)

Declare @FinalSchCrNote Table (SchID Int, PayoutID Int, CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CRValue Decimal(18, 6), CRBalance Decimal(18, 6))

Set @Delimeter = Char(15)

Set @IndexID1 = Charindex(@Delimeter, @SchPayoutID)
Set @RFAPP = Substring(@SchPayoutID, 1, @IndexID1 - 1)

If @RFAPP = 1 
Begin
	Set @IndexID2 = Charindex(@Delimeter, @SchPayoutID, @IndexID1 + 1)
	Set @SchID = Substring(@SchPayoutID, @IndexID1 + 1, @IndexID2 - (@IndexID1 + 1))
	Set @PayoutID = Substring(@SchPayoutID, @IndexID2 + 1, Len(@SchPayoutID))
End
Else
Begin

--	Set @IndexID2 = Charindex(@Delimeter, @SchPayoutID, @IndexID1 + 1)
	Set @SchID = Substring(@SchPayoutID, @IndexID1 + 1, Len(@SchPayoutID))
--	Set @PayoutID = Substring(@SchPayoutID, @IndexID2 + 1, Len(@SchPayoutID))
End



-- new channel classifications added-------------------------------

Declare @TOBEDEFINED nVarchar(50)

Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)

CREATE TABLE #OLClassMapping (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  

Create Table #OLClassCustLink (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
ChannelType Int, Active Int, [Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert Into #OLClassMapping 
Select  olcm.OLClassID, olcm.CustomerId, olc.Channel_Type_Desc, olc.Outlet_Type_Desc, 
olc.SubOutlet_Type_Desc 
From tbl_merp_olclass olc, tbl_merp_olclassmapping olcm
Where olc.ID = olcm.OLClassID And
olc.Channel_Type_Active = 1 And olc.Outlet_Type_Active = 1 And olc.SubOutlet_Type_Active = 1 And 
olcm.Active = 1  

Insert Into #OLClassCustLink 
Select olcm.OLClassID, C.CustomerId, C.ChannelType , C.Active, IsNull(olcm.[Channel Type], @TOBEDEFINED), 
IsNull(olcm.[Outlet Type], @TOBEDEFINED) , IsNull(olcm.[Loyalty Program], @TOBEDEFINED) 
From #OLClassMapping olcm
Right Outer Join Customer C On olcm.CustomerID = C.CustomerID

-------------------------------------------------

--===================================
--Select SA.SchemeID , DBP.PayoutPeriodID, DBP.DocReference, DBP.OutletCode
--		From tbl_mERP_SchemeAbstract SA, 
--		tbl_mERP_DispSchBudgetPayout DBP
--		Where IsNull(SA.RFAApplicable, 0) = (Case @RFAPP When 1 Then 1 Else 0 End) And 
--			  SA.SchemeID = @SchID And 
--			  SA.SchemeID = DBP.SchemeID And 
--			  DBP.AllocatedAmount > 0 And 
--			  IsNull(DBP.CrNoteRaised, 0) = (Case @RFAPP When 1 Then IsNull(DBP.CrNoteRaised, 0) Else 1 End) And 
--			  DBP.PayoutPeriodId = (Case @RFAPP When 1 Then @PayoutID Else DBP.PayoutPeriodId End) 

--===============================

	Declare CrNoteDtl Cursor for

	Select SA.SchemeID , DBP.PayoutPeriodID, DBP.DocReference, DBP.OutletCode
		From tbl_mERP_SchemeAbstract SA, 
		tbl_mERP_DispSchBudgetPayout DBP
		Where IsNull(SA.RFAApplicable, 0) = (Case @RFAPP When 1 Then 1 Else 0 End) And 
			  SA.SchemeID = @SchID And 
			  SA.SchemeID = DBP.SchemeID And 
			  DBP.AllocatedAmount > 0 And 
			  IsNull(DBP.CrNoteRaised, 0) = (Case @RFAPP When 1 Then IsNull(DBP.CrNoteRaised, 0) Else 1 End) And 
			  DBP.PayoutPeriodId = (Case @RFAPP When 1 Then @PayoutID Else DBP.PayoutPeriodId End) 
	Open CrNoteDtl 
	Fetch From CrNoteDtl InTo @TSchID , @TPayoutID , @CrNoteDoc, @CustomerID 
	While @@Fetch_Status = 0  
		Begin
			If IsNull(@CrNoteDoc, '') = '' 
			Begin
				Insert Into @SchCrNote (SchID , PayoutID , CustomerID, CrN) 
				Select  @TSchID , @TPayoutID , @CustomerID, ''
			End
			Else
			Begin
				Insert Into @SchCrNote (SchID , PayoutID , CustomerID, CrN) 
				Select @TSchID , @TPayoutID , @CustomerID, ItemValue From dbo.fn_SplitIn2Rows_CRN(@CrNoteDoc, ',')
			End

			Fetch Next From CrNoteDtl InTo @TSchID , @TPayoutID , @CrNoteDoc, @CustomerID 
		End
	Close CrNoteDtl
	Deallocate CrNoteDtl

If @RFAPP = 1 
Begin

	Insert Into @FinalSchCrNote(SchID , PayoutID , CustomerID, CRValue, CRBalance)
	Select schc.SchID , schc.PayoutID , schc.CustomerID, Sum(IsNull(CRN.NoteValue, 0)), Sum(IsNull(CRN.Balance, 0)) 
	From @SchCrNote schc
	Left Outer Join CreditNote CRN On schc.CrN = CRN.DocumentReference And schc.PayoutID = CRN.PayoutID And schc.CustomerID = CRN.CustomerID And CRN.Flag = 1 
	Group By schc.SchID , schc.PayoutID , schc.CustomerID
	/*
	If Reset voucher is done, same document reference is creating twice and report shows incorrect data. It is addressed.
	- 11434990
	*/

--	Select * From @SchCrNote

End
Else
Begin

	Insert Into @FinalSchCrNote(SchID , PayoutID , CustomerID, CRValue, CRBalance)
	Select schc.SchID , schc.PayoutID , schc.CustomerID, Sum(IsNull(CRN.NoteValue, 0)), Sum(IsNull(CRN.Balance, 0)) 
	From @SchCrNote schc
	Left Outer Join CreditNote CRN On schc.CustomerID = CRN.CustomerID
	Where schc.CrN = CRN.DocumentReference And CRN.DocumentDate Between @FromDate And @ToDate And CRN.Flag = 1

	/*
	If Reset voucher is done, same document reference is creating twice and report shows incorrect data. It is addressed.
	- 11434990
	*/
	And schc.PayoutID = CRN.PayoutID
	Group By schc.SchID , schc.PayoutID , schc.CustomerID
End

	Select DBP.OutletCode, "Outlet Code" = DBP.OutletCode, "Name of Outlet" = C.Company_Name, 
	"Channel Type" = IsNull(OLC.[Channel Type], @TOBEDEFINED), 
	"Outlet Type" = IsNull(OLC.[Outlet Type], @TOBEDEFINED), 
	"Loyalty Program" = IsNull(OLC.[Loyalty Program], @TOBEDEFINED),
	"Display Allocation" = DBP.AllocatedAmount, 
	"RFA Value" = FSC.CRValue, 
	"Credit Note Generated" = Case IsNull(DBP.CrNoteRaised, 0) When 1 Then 'Yes' Else 'No' End, 
	"Credit Note Adjusted" = Case when(isnull(FSC.CRValue,0)=0 and isnull(FSC.CRBalance,0)=0) then 'Yes'  When (FSC.CRValue - FSC.CRBalance) > 0 Then 'Yes' Else 'No' End,
	"Adjusted Amount" = (FSC.CRValue - FSC.CRBalance) --IsNull((Select NoteValue - Balance From CreditNote 
		--Where DocumentReference = SCN.CrN), 0)
	From tbl_mERP_DispSchBudgetPayout DBP, Customer C, 
		#OLClassCustLink OLC, @FinalSchCrNote FSC
	Where DBP.SchemeID = FSC.SchID And 
		DBP.PayoutPeriodID = FSC.PayoutID And 
		DBP.OutletCode = FSC.CustomerID And 
		DBP.OutletCode = C.CustomerID And 
		DBP.OutletCode = OLC.CustomerID And 
		DBP.AllocatedAmount > 0 

