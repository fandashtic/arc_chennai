CREATE procedure sp_get_customer(@CustomerID nvarchar(30),@ItemCode nvarchar(30),@closingDate datetime)
as
select customerID from Itemclosingstock where item_forumcode=@Itemcode and customerId=@CustomerID and ClosingDate=@closingDate





