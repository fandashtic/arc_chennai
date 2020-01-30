
CREATE Function dbo.GetBeatDescriptionFromID (@BeatID Int)
Returns Nvarchar(255)
As
Begin
Declare @BeatName NVarchar(255)
Select @BeatName=Description From Beat Where BeatID = @BeatID And Active = 1
Return (@BeatName)
End

