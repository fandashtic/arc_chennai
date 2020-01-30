
CREATE procedure sp_get_price(@Product_ID as nvarchar(15)) as
select ProductName, Purchase_Price from Items where Product_Code = @Product_ID


