create procedure sp_item_changename  
(@productname as nvarchar(30),  
 @productid as nvarchar(30))  
as  
update items set ProductName=@productname where Product_Code=@productid   

