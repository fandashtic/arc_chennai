CREATE procedure sp_get_ShortExpiryCount (@ShortExpiry  DateTime)
as
select count(distinct Product_Code) from Batch_Products
where 
Batch_Products.Expiry is not null 
And Batch_Products.Expiry <= @ShortExpiry 
And Batch_Products.Quantity > 0
And Batch_Products.Expiry > GetDate()
