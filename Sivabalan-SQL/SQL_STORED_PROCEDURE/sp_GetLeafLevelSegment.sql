
Create Procedure  sp_GetLeafLevelSegment (@SegmentID int)
As
	Select * From fn_GetLeafLevelSegment(@SegmentID)	

