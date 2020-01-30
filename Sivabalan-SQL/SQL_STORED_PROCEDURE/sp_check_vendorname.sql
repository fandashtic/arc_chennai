create procedure sp_check_vendorname
(@name as nvarchar(30))
as
select count(*) from vendors where vendor_name=@name

