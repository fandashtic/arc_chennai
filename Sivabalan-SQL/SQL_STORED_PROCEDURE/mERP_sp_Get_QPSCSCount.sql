Create Procedure mERP_sp_Get_QPSCSCount(@TransactionDate  DateTime) 
As
Begin
    set DateFormat DMY
    Declare @CLSDAY_FLAG Int  
    Declare @DAY_CLOSE DateTime 
    /*To Check Day Close Date*/
	Select @CLSDAY_FLAG = IsNull(Flag,0) from tbl_mErp_ConfigAbstract where ScreenCode like N'CLSDAY01'
    Select @DAY_CLOSE = dbo.StripTimeFromDate(IsNull(LastInventoryUpload, 'Jan 01 1900')) From SetUp

	/*To Get Grace Period*/
--    Declare @GRACEDAYS Int
--    Set @GRACEDAYS = 0 
--    If IsNull((select Flag from tbl_mErp_ConfigAbstract where ScreenCode like 'CLSDAY01'),0) = 1 
--    BEGIN
--      Select @GRACEDAYS = IsNull([Value],0) from tbl_mErp_ConfigDetail where ScreenCode like 'CLSDAY01' and ControlName Like 'GracePeriod'
--    END

    IF @CLSDAY_FLAG = 0 
    Begin
      Select Count(Distinct SchAbs.SchemeID)
	  From tbl_mERP_SchemeAbstract SchAbs, tbl_mERP_SchemeOutlet SchOtl, tbl_mERP_SchemePayoutPeriod SchPP
	  Where SchAbs.SchemeID = SchOtl.SchemeID And 
      SchAbs.SchemeID = SchPP.SchemeID And 
     (DateAdd(Day, DateDiff(d, dbo.StripTimeFromDate(SchAbs.ActiveTo), dbo.StripTimeFromDate(SchAbs.ExpiryDate)), dbo.StripTimeFromDate(SchPP.PayoutPeriodTo)) < dbo.StripTimeFromDate(@TransactionDate)) And 
	  SchOtl.QPS = 1 And SchAbs.Active = 1 And 
      SchPP.Active = 1 And SchPP.Status & 128= 0 And SchPP.ClaimRFA = 0 And
      SchAbs.SchemeType in (1,2)
    End
    ELSE
    Begin
	Select Count(Distinct SchAbs.SchemeID)
	From tbl_mERP_SchemeAbstract SchAbs, tbl_mERP_SchemeOutlet SchOtl, tbl_mERP_SchemePayoutPeriod SchPP
	Where SchAbs.SchemeID = SchOtl.SchemeID And 
      SchAbs.SchemeID = SchPP.SchemeID And 
      dbo.StripTimeFromDate(SchPP.PayoutPeriodTo) <= @DAY_CLOSE And
      dbo.StripTimeFromDate(SchPP.PayoutPeriodTo) < dbo.StripTimeFromDate(@TransactionDate) And 
	  SchOtl.QPS = 1 And SchAbs.Active = 1 And 
      SchPP.Active = 1 And SchPP.Status & 128= 0 And SchPP.ClaimRFA = 0 And
      SchAbs.SchemeType in (1,2)
    End
End
