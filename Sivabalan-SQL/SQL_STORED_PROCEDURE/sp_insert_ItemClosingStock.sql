CREATE procedure sp_insert_ItemClosingStock(@CustomerID nvarchar(30),@ItemCode nvarchar(30),@ClosingDate datetime,@Quantity decimal(18,6),@ItemForumCode nvarchar(30))    
as    
Declare @CustId nvarchar(30)
select @CustId=CustomerID from customer where alternatecode=@CustomerId
if(@ItemCode=N'')    
set @ItemCode=null    
if(exists(select customerId from ItemClosingStock where customerID=@CustomerID and Item_ForumCode=@ItemForumcode and Closingdate=@ClosingDate))    
Begin    
update ItemClosingStock set CustomerID=@CustomerID,product_code=@ItemCode,ClosingDate=@ClosingDate,Quantity=@Quantity,Item_ForumCode=@ItemForumCode,CustId=@CustId where     
CustomerID=@CustomerId and Item_Forumcode=@ItemForumCode and ClosingDate=@ClosingDate    
End    
Else    
insert into ItemClosingStock(CustomerId,Product_code,ClosingDate,Quantity,Item_ForumCode,CustId)values(@CustomerID,@ItemCode,@ClosingDate,@Quantity,@ItemForumCode,@CustId)    
    
    

    
    
    
    
  
    
    
    
    
    
     
    
  


