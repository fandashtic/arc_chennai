CREATE function sp_ser_getSparesName(@Productcode nvarchar(15))  
returns nvarchar(255)  
as  
begin  
declare @productName nvarchar(255)  
select @ProductName = ProductName from Items where product_code =@productcode     
return @ProductName  
end  

