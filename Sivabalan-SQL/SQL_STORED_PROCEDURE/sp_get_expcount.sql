CREATE procedure sp_get_expcount
as
select count(distinct Product_Code) from Batch_Products
where 
Batch_Products.Expiry is not null and
Batch_Products.Expiry <= getdate()
AND Batch_Products.Quantity > 0
