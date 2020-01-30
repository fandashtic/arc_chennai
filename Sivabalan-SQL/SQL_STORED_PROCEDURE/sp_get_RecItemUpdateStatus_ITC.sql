Create Procedure sp_get_RecItemUpdateStatus_ITC(@ID int)
AS
Select UpdateStatus from ItemsReceivedDetail where [ID] = @ID
