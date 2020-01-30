CREATE Procedure sp_Get_RecdSegment_Info_Chevron(@SegmentID Int)          
As          
Declare @ParentID Int          
Declare @NewSegmentID Int          
Select SegmentCode,SegmentName From ReceivedSegments Where SegmentID = @SegmentID           
