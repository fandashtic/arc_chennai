Create Procedure mERP_sp_Update_ExistPointsRedeemed ( @SchemeId  int,@Payout int)
as
Begin
	update tbl_mERP_CSRedemption set RFAStatus = 2 where schemeid=@schemeID and PayOutId = @Payout and RFAStatus = 0
End
