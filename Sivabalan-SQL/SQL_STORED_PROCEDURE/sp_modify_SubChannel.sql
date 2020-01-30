CREATE procedure sp_modify_SubChannel(@SubChannelTypeID INT,@ACTIVE INT)  
AS  
update subchannel  set Active = @ACTIVE where SubChannelID = @SubChannelTypeID  

