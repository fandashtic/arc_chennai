
CREATE Procedure sp_insert_customer_hierarchy(           
@HierarchyName nvarchar(255),@Level Int)                  
as         
Begin        
	--Checks whether Hierarchy Is Defined For A Particular Level  
	--If Not Defined Then Inserts a Hierarchy For That particular level  
	if (Select Count(*) From CustomerHierarchy Where  HierarchyID=@Level) =0    
	Begin 
		--Before Insertion It Checks whether there is corresponding level In The CustomerSegment Table   
		if (Select Distinct Isnull(Level,0) From CustomerSegment Where Level=@Level) <> 0
		Insert into  CustomerHierarchy values (@Level , @HierarchyName )    
	End
	else
 	Begin
 		--Updates HierarchyName if a hierarchy exists for that level
 		Update CustomerHierarchy Set HierarchyName=@HierarchyName Where HierarchyID=@Level
 	End    
End  

