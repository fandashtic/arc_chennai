
CREATE PROCEDURE sp_save_thickclient(@CLIENT_ID int,
					     @DESCRIPTION nvarchar(255))
AS
UPDATE ClientInformation SET Description = @DESCRIPTION WHERE ClientID = @CLIENT_ID
