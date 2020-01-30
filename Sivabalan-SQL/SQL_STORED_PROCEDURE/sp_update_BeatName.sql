CREATE Procedure [dbo].[sp_update_BeatName] (@BeatID nvarchar(20),
@NewName nvarchar(255))
As
Update beat  Set Description  = @NewName
Where BeatID = @BeatID
