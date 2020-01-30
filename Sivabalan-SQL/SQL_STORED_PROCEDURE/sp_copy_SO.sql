
create proc sp_copy_SO(@SONumber int)
as
select product_code,productname from items where 
product_code in(select product_code from SODetail
where SONumber = @SONumber)


