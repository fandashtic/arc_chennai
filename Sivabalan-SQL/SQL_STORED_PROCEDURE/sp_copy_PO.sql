
create proc sp_copy_PO(@PONumber int)
as
select product_code,productname from items where 
product_code in(select product_code from PODetail 
where PONumber = @PONumber)


