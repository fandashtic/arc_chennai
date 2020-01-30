
CREATE procedure sp_get_ExpiredQty(@ItemCode nvarchar(50))
as
select Sum(Quantity) from Batch_Products where Product_Code = @ItemCode and
(Expiry < GetDate() and Expiry is not null) group by Product_Code

