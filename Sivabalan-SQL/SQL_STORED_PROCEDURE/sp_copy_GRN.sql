
CREATE proc sp_copy_GRN(@GRNID int)
as
select product_code,productname from items where 
product_code in(select product_code from GRNDetail 
where GRNID = @GRNID)


