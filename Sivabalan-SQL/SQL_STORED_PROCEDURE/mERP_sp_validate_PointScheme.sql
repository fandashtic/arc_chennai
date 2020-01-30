Create procedure mERP_sp_validate_PointScheme(@nSchemeid int)
as
	Set Dateformat dmy    

	Declare @CLSDAY_FLAG Int  
	Declare @DAY_CLOSE DateTime 
	Declare @ActiveCheck int
	Declare @GraceDays as Int

	Select @GraceDays = DateDiff(d, ActiveTo, ExpiryDate) From tbl_mERP_SchemeAbstract Where SchemeID = @nSchemeid
	
	if exists(select * from tbl_mERP_PSDCProgressStatus where isnull(active,0) = 1)
		Set @ActiveCheck = 1
	
	if isnull(@ActiveCheck,0) <> 1
	BEGIN
		/*To Check Day Close Date*/
		Select @CLSDAY_FLAG = IsNull(Flag,0) from tbl_mErp_ConfigAbstract where ScreenCode like N'CLSDAY01'
		Select @DAY_CLOSE = dbo.StripTimeFromDate(IsNull(LastInventoryUpload, 'Jan 01 1900')) From SetUp
		IF @CLSDAY_FLAG = 0 
		BEGIN
			Select case when DateAdd(d,@GraceDays,dbo.StripTimeFromDate(payoutperiodto)) < DATEADD(D, 0, DATEDIFF(D, 0, GETDATE())) then 1 else 0 end "Valid",
			ID,PayoutPeriodFrom,PayOutPeriodTo from  tbl_mERP_SchemePayoutPeriod 
			where Schemeid = @nSchemeID and DateAdd(d,@GraceDays,dbo.StripTimeFromDate(payoutperiodto)) < DATEADD(D, 0, DATEDIFF(D, 0, GETDATE()))
			order by PayoutPeriodFrom
		END
		ELSE
		BEGIN
			Select case when DateAdd(d,@GraceDays,dbo.StripTimeFromDate(payoutperiodto)) < DATEADD(D, 0, DATEDIFF(D, 0, GETDATE())) then 1 else 0 end "Valid",
			ID,PayoutPeriodFrom,PayOutPeriodTo from  tbl_mERP_SchemePayoutPeriod 
			where Schemeid = @nSchemeID and DateAdd(d,@GraceDays,dbo.StripTimeFromDate(payoutperiodto)) < DATEADD(D, 0, DATEDIFF(D, 0, GETDATE()))
			AND dbo.StripTimeFromDate(payoutperiodto) <= @DAY_CLOSE
			order by PayoutPeriodFrom
		END
	END
