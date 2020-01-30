CREATE procedure sp_modify_ChannelType(@ChannelTypeID INT,@ACTIVE INT)
AS
update Customer_Channel  set Active = @ACTIVE where ChannelType = @ChannelTypeID


