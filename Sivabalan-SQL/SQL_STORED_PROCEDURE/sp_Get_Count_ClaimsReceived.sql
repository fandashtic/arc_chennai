Create Procedure sp_Get_Count_ClaimsReceived
as
--Lists all the Unprocessed ClaimsNote
Select Count(*) from ClaimsNoteReceived Where isnull(Status,0)=0

