Create Procedure mERP_sp_Get_DisplayRFAClaimInfo(@Status Int)
As

	Create Table #tmpSchInfo(SchemeID Int, ActivityCode nVarchar(255), Description nVarchar(255), SchemeFrom DateTime,
			SchemeTo DateTime, PayoutPeriodFrom DateTime, PayoutPeriodTo DateTime, PayoutID Int, RFAValue Decimal(18, 6))
 
	If @Status = 1
		Insert Into #tmpSchInfo Select SA.SchemeID, SA.ActivityCode, SA.Description, SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo, 
			DBP.PayoutPeriodID, Sum(DBP.AllocatedAmount - PendingAmount) as RFAValue
			From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP,tbl_mERP_DispSchBudgetPayout DBP
			Where SA.SchemeID = SPP.SchemeID
			And IsNull(SA.RFAApplicable,0) = 1
			And	SPP.SchemeID = DBP.SchemeID
			And IsNull(SPP.ClaimRFA, 0) = 0
			And IsNull(SPP.Status, 0) = 128		
			And SPP.ID = DBP.PayoutPeriodID
			Group By SA.SchemeID,SA.ActivityCode, SA.Description, SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo,DBP.PayoutPeriodID
	
	Select * From #tmpSchInfo
	Drop Table #tmpSchInfo
