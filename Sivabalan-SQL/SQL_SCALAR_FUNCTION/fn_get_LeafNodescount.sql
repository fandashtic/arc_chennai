CREATE Function fn_get_LeafNodescount( @Node Int)       
Returns Int      
As      
Begin  
	Declare @Count int       
	SELECT @Count=COUNT(CategoryID) FROM 
	dbo.sp_get_leafnodes(@Node)
	WHERE CategoryID IN 
	(SELECT DISTINCT CategoryID       
	  FROM Items WHERE Active = 1)
	Return @Count
End    

