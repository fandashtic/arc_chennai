Create Procedure mERP_sp_Save_PointsRedeemed ( @SchemeId  int,@outletcode nvarchar(255),@TotalPoints decimal(18,6),@RedeemedPoints decimal(18,6),@RedeemValue decimal(18,6),@AmountSpent decimal(18,6),@PlannedPayout nvarchar(4000),@Payout int,@RFAClaim int)
as
Begin
	Insert into tbl_mERP_CSRedemption (SchemeId ,outletcode ,TotalPoints,RedeemedPoints ,RedeemValue ,AmountSpent ,PlannedPayout ,RFAStatus,PayoutId) Values
	(@SchemeId ,@outletcode ,@TotalPoints,@RedeemedPoints ,@RedeemValue ,@AmountSpent ,@PlannedPayout ,@RFAClaim ,@Payout)

Select @@Identity

End
