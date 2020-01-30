Create Procedure mERP_sp_InsertRecdQuotationDetail
( @RecdID int=0, @ChannelCode nVArchar(255)= NULL, @ChannelName nVArchar(510)= NULL,
@OutletCode nVArchar(255)= NULL, @OutletName nVArchar(510)= NULL,
@LoyaltyCode nVArchar(255)= NULL, @LoyaltyName nVArchar(510)= NULL,
@Active int, @QuotationType int = 1 
)
As
Insert into tbl_mERP_RecdQuotationDetail ( RecdID, ChannelCode, Channelname, OutletCode, OutletName, LoyaltyCode, LoyaltyName, Active, QuotationType) 
Values (@RecdID, @ChannelCode, @ChannelName, @OutletCode, @OutletName, @LoyaltyCode, @LoyaltyName,  @Active, @QuotationType)
