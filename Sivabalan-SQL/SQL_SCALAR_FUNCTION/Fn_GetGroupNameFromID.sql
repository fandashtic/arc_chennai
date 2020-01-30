Create function Fn_GetGroupNameFromID(@GroupID Int)
Returns nVarchar(255)
As
Begin
	Declare @GroupName nVarchar(255)
	if @GroupID = 0
		Set @GroupName = dbo.LookupDictionaryItem('All Categories',Default)      
      else if @GroupID = -1
		Set @GroupName = N''
	else
		Select @GroupName = GroupName From ProductCategoryGroupAbstract Where GroupID = @GroupID And Active =1

	return @GroupName
End
