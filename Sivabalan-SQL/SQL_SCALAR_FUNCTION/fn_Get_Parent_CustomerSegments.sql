
Create Function fn_Get_Parent_CustomerSegments(@SEGMENTID Int = 0)
Returns nVarchar(1100)
As
Begin
Declare @PARENTID Int 
Declare @TmpParent Int
Declare @PARENTLIST nVarchar(1100)
Set @PARENTID = 1
Set @PARENTLIST = @SEGMENTID
Set @TmpParent = 0
While @PARENTID <> 0 
Begin
Select @TmpParent = ParentId From CustomerSegment Where SegmentID = @SegmentID
    IF @TmpParent <> 0 
	Set @PARENTLIST = @PARENTLIST  + N',' + Cast(@TmpParent as nVarchar(10))
    ELSE
	Set @PARENTLIST = @PARENTLIST + N',0' 
Set @PARENTID = @TmpParent
Set @SegmentID = @TmpParent
End

Return (Select @PARENTLIST)
End

