
CREATE Procedure sp_update_Disclaimer
                (@TRANID NVARCHAR (50),
                 @DISCLAIMERTEXT NVARCHAR (4000))
AS
Update Disclaimer Set DisclaimerText = @DISCLAIMERTEXT where TranID=@TRANID


