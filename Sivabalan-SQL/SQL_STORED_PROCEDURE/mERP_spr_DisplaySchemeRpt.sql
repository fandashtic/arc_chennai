Create Procedure mERP_spr_DisplaySchemeRpt(@FromDate Datetime,
									 @ToDate Datetime,
								     @RFAApplicable nVarchar(5),
									 @ActivityCode nVarchar(2550),
									 @SchemeName nVarchar(2550))
As

Declare @SchID Int
Declare @PayoutID Int
Declare @CrNoteDoc nVarchar(2550)
Declare @CustomerID nVarchar(255)
Declare @Delimeter As Char(1)
Declare @RFAToDate Datetime

Set @Delimeter = Char(15)

Declare @ActCode Table (ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Declare @SchName Table (SchName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Declare @SchCrNote Table (SchID Int, PayoutID Int, CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	CrN nVarchar(2550) COLLATE SQL_Latin1_General_CP1_CI_AS)

Declare @FinalSchCrNote Table (SchID Int, PayoutID Int, CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CRValue Decimal(18, 6))
	

if @ActivityCode = N'%'     
Begin
   Insert InTo @ActCode Select Distinct ActivityCode From tbl_mERP_SchemeAbstract where schemetype = 3
End
Else    
Begin
   Insert InTo @ActCode Select ItemValue From dbo.sp_SplitIn2Rows(@ActivityCode, @Delimeter)

End

if @SchemeName = N'%'     
Begin
   Insert InTo @SchName Select Distinct Description From tbl_merp_SchemeAbstract where schemetype = 3
   And ActivityCode In (Select ActivityCode From @ActCode)
End
Else    
Begin
   Insert InTo @SchName Select ItemValue From dbo.sp_SplitIn2Rows(@SchemeName, @Delimeter)

End

Set @RFAToDate = Cast(Datepart(dd, @ToDate) As nVarchar) + N'-' + Cast(Datepart(mm, @ToDate) As nVarchar) + N'-' + 
				Cast(Datepart(yyyy, @ToDate) As nVarchar)
				
If @RFAApplicable = N'Yes'
Begin
	Select "SchPay" = [SchPay], "ActivityCode" = [ActivityCode], 
		"Description" = [Description], "Applicable Period" = [Applicable Period],
		"RFA Period" = [RFA Period], "RFA Value" = Sum([RFA Value]),
		"SubmissionDate" = [SubmissionDate] From (
	Select  "SchPay" = '1' + @Delimeter + Cast(SA.SchemeID As nVarchar) + @Delimeter + Cast(SPP.ID As nVarchar), --+ @Delimeter + 
--	IsNull(DBP.DocReference, ''), 
	"ActivityCode" = SA.ActivityCode, "Description" = SA.Description, 
	"Applicable Period" = Cast(Convert(Char(13), SA.ActiveFrom, 103) As nVarchar) + N'- ' + 
		Cast(Convert(Char(13), SA.ActiveTo, 103) As nVarchar), 
	"RFA Period" = Cast(Convert(Char(13), SPP.PayoutPeriodFrom, 103) As nVarchar) + N'- ' + 
		Cast(Convert(Char(13), SPP.PayoutPeriodTo, 103) As nVarchar),
	"RFA Value" = (DBP.AllocatedAmount - DBP.PendingAmount), 
	"SubmissionDate" = RFA.SubmissionDate
	From tbl_mERP_SchemeAbstract SA
	Inner Join tbl_mERP_SchemePayoutPeriod SPP On  SA.SchemeID = SPP.SchemeID And SA.SchemeID = SPP.SchemeID
	Inner Join tbl_mERP_DispSchBudgetPayout DBP On SPP.SchemeID = DBP.SchemeID And SPP.ID = DBP.PayoutPeriodID
	Left Outer Join  tbl_mERP_RFAAbstract RFA On SA.ActivityCode = RFA.ActivityCode And SPP.PayoutPeriodFrom = RFA.PayoutFrom And SPP.PayoutPeriodTo = RFA.PayoutTo 
	Where SA.ActivityCode In (Select ActivityCode From @ActCode) And SA.Description In (Select SchName From @SchName) And SPP.PayoutPeriodTo Between @FromDate And @ToDate And 
		  IsNull(SA.RFAApplicable, 0) = 1 And DBP.AllocatedAmount > 0 And RFA.Status <> 5) Als
	--		  @RFAToDate Between SPP.PayoutPeriodFrom And SPP.PayoutPeriodTo And
	Group By [SchPay], [ActivityCode], [Description], 
		[Applicable Period], [RFA Period], [SubmissionDate]

End
Else
Begin

	Declare CrNoteDtl Cursor for

	Select SA.SchemeID , DBP.PayoutPeriodID, DBP.DocReference, DBP.OutletCode
		From tbl_mERP_SchemeAbstract SA, 
		tbl_mERP_DispSchBudgetPayout DBP
		Where SA.ActivityCode In (Select ActivityCode From @ActCode) And 
			  SA.Description In (Select SchName From @SchName) And
			  IsNull(SA.RFAApplicable, 0) = 0 And 
			  SA.SchemeID = DBP.SchemeID And 
			  DBP.AllocatedAmount > 0 And 
			  IsNull(DBP.CrNoteRaised, 0) = 1 
	Open CrNoteDtl 
	Fetch From CrNoteDtl InTo @SchID , @PayoutID , @CrNoteDoc, @CustomerID 
	While @@Fetch_Status = 0  
		Begin
			Insert Into @SchCrNote (SchID , PayoutID , CustomerID, CrN) 
			Select @SchID, @PayoutID, @CustomerID, ItemValue From dbo.fn_SplitIn2Rows_CRN(@CrNoteDoc, ',')

			Fetch Next From CrNoteDtl InTo @SchID , @PayoutID , @CrNoteDoc, @CustomerID
		End
	Close CrNoteDtl
	Deallocate CrNoteDtl

	Insert Into @FinalSchCrNote(SchID , PayoutID , CustomerID, CRValue)
	Select schc.SchID , schc.PayoutID , schc.CustomerID, Sum(CRN.NoteValue) From @SchCrNote schc, CreditNote CRN
	Where schc.CrN = CRN.DocumentReference And CRN.DocumentDate Between @FromDate And @ToDate 
	/*
	11434990
	Display scheme report shows RFA value more than allocated amount.
	*/
	and schc.PayoutID = CRN.PayoutID
	Group By schc.SchID , schc.PayoutID , schc.CustomerID
	
--select * from @SchCrNote
	Select "SchPay" = [SchPay], "ActivityCode" = [ActivityCode], 
		"Description" = [Description], "Applicable Period" = [Applicable Period],
		"RFA Period" = [RFA Period], "RFA Value" = Sum([RFA Value]),
		"SubmissionDate" = [SubmissionDate] From (
	Select  
	"SchPay" = '0' + @Delimeter + Cast(SA.SchemeID As nVarchar),
	"ActivityCode" = SA.ActivityCode, "Description" = SA.Description, 
	"Applicable Period" = Cast(Convert(Char(13), SA.ActiveFrom, 103) As nVarchar) + N'- ' + 
		Cast(Convert(Char(13), SA.ActiveTo, 103) As nVarchar), 
	"RFA Period" = Cast(Convert(Char(13), @FromDate, 103) As nVarchar) + N'- ' + 
		Cast(Convert(Char(13), @ToDate, 103) As nVarchar),
	"RFA Value" = FSC.CRValue,
--	DBP.AllocatedAmount - DBP.PendingAmount, 
	"SubmissionDate" = '' --RFA.SubmissionDate --, DBP.DocReference
	From tbl_mERP_SchemeAbstract SA, tbl_mERP_DispSchBudgetPayout DBP, @FinalSchCrNote FSC
	--tbl_mERP_RFAAbstract RFA, 
--	@SchCrNote TCR, CreditNote CRN
	Where SA.ActivityCode In (Select ActivityCode From @ActCode) And 
		  SA.Description In (Select SchName From @SchName) And
		  IsNull(SA.RFAApplicable, 0) = 0 And 
		  SA.SchemeID = DBP.SchemeID And 
		  IsNull(DBP.CrNoteRaised, 0) = 1 And
		  FSC.SchID = DBP.SchemeID And
		  FSC.PayoutID = DBP.PayoutPeriodID And 
		  FSC.CustomerID = DBP.OutletCode And 
		  DBP.AllocatedAmount > 0) Als
	Group By [SchPay], [ActivityCode], [Description], 
		[Applicable Period], [RFA Period], [SubmissionDate]

End

