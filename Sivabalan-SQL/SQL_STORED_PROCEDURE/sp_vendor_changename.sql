CREATE procedure sp_vendor_changename  
(@vendorname as nvarchar(30),  
 @vendorid as nvarchar(50))  
as  
update vendors set vendor_name=@vendorname where vendorid=@vendorid 
