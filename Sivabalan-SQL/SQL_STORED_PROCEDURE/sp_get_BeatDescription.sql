
Create Procedure sp_get_BeatDescription(@BeatID int)
as 
Select Description from beat where BeatId=@BeatID

