
Create Procedure mERP_SP_SaveSurveyChannel_Outlet_Loyalty (@SurveyID int, @ChannelType nvarchar(255),@OutletType nvarchar(255),@LoyaltyProgram nvarchar(255))
AS
BEGIN
	insert into [tbl_merp_SurveyChannelMapping]([SurveyID],[ChannelType],[OutletType],[LoyaltyProgram]) values (@SurveyID,@ChannelType,@OutletType,@LoyaltyProgram)
END
