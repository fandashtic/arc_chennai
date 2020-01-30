Create Procedure mERP_sp_Update_PayoutStatus ( @SchemeId  int,@Payout int)
as
Begin
	if exists (select 1 from tbl_mERP_CSRedemption where schemeid=@schemeid and Payoutid=@Payout and RFAStatus=1) 	
		update dbo.tbl_merp_schemePayoutperiod set Status = 1 where [Id] = @Payout
End
