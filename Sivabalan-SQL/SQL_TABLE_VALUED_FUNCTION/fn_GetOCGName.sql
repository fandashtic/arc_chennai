CREATE Function fn_GetOCGName(@GroupType nvarchar(4000))    
Returns @GroupID Table (GroupID Int)    
As    
Begin    
	If  @GroupType = N'Regular'
	Begin
		Insert Into @GroupID select Distinct GroupID from ProductCategoryGroupAbstract Where GroupName In(Select Distinct CategoryGroup From tblcgdivmapping) And Active = 1
	End

	Else If  @GroupType = N'Operational'
	Begin
		Insert Into @GroupID select Distinct GroupID from ProductCategoryGroupAbstract Where isnull(ocgtype,0) = 1 And Active = 1
	End

	else If  @GroupType = N'All' or @GroupType = N'%' or @GroupType = N''
	Begin
		Insert Into @GroupID select Distinct GroupID from ProductCategoryGroupAbstract Where Active = 1
	End  
Return    
End    
  
