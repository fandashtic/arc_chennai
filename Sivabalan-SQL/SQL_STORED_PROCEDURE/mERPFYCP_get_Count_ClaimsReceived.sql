Create Procedure mERPFYCP_get_Count_ClaimsReceived ( @yearenddate datetime )
as
--Lists all the Unprocessed ClaimsNote
Select Count(*) from ClaimsNoteReceived Where isnull(Status,0)=0  and ClaimDate <= @yearenddate
