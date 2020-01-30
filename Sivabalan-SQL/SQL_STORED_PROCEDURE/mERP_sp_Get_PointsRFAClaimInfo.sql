Create Procedure mERP_sp_Get_PointsRFAClaimInfo(@Status Int)
As

	Create Table #tmpSchInfo(SchemeID Int, ActivityCode nVarchar(255), Description nVarchar(255), SchemeFrom DateTime,
			SchemeTo DateTime, PayoutPeriodFrom DateTime, PayoutPeriodTo DateTime, PayoutID Int, RFAValue Decimal(18, 6))
	If @Status = 1

		Insert Into #tmpSchInfo Select SA.SchemeId, SA.ActivityCode, SA.Description, SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo, 
			CSR.PayoutID, Sum(AmountSpent) as RFAValue
			From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP, 
			tbl_mERP_CSRedemption CSR
			Where SA.SchemeID = SPP.SchemeID
			And IsNull(RFAApplicable,0) = 1
			And IsNull(SPP.Status, 0) = 1	
			And IsNull(SPP.ClaimRFA, 0) = 0	
			And SPP.SchemeID = CSR.SchemeID
			And SPP.ID = CSR.PayoutID
			And IsNull(CSR.RFAStatus, 0) = 1
			Group By SA.SchemeId, SA.ActivityCode, SA.Description, SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo,CSR.PayoutID
	Select * From #tmpSchInfo
	Drop Table #tmpSchInfo

