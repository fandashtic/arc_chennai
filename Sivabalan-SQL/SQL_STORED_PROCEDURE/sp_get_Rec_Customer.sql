CREATE procedure sp_get_Rec_Customer
As
Select BranchForumCode,"From Branch"=BranchForumCode,
"No.of.Customers Received"=Count(ID)
From ReceivedCustomers Where isnull(Status,0)=0
Group by BranchForumCode









