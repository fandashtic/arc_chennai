create procedure sp_Insert_ExtCustPoints 
(@CustomerId nVarchar(30),@UserId nVarchar(50),@Points decimal(18,6),@Remarks nVarchar(250))
as
Update Customer set CollectedPoints = CollectedPoints + @Points where CustomerId = @CustomerId
Insert Into TrackCustomerPoint (CustomerId,UserId,Points,Remarks)
values (@CustomerId,@UserId,@Points,@Remarks)


