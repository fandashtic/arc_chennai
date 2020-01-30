CREATE Function Fn_GetSegmentLevel(@LevelName NVarChar(255))
Returns BigInt
As
Begin
	Declare @Level BigInt
	If @LevelName = N'%%'
		Set @Level = (Select Distinct Max(Level) From CustomerSegment)
	Else
		Set @Level = (Select	HierarchyID	From CustomerHierarchy		Where	HierarchyName = @LevelName)
	Return @Level  
End

