CREATE procedure Sp_Get_CollFullDocID(@DocID int) as 
begin
	--Status checking is removed bcz if advanced collection
	--is created for cheque status will changed.
	select fullDocID,value 
	from Collections 
	where DocumentID = @DocID
end


