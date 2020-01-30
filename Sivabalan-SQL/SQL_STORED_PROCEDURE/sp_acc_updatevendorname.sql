CREATE procedure sp_acc_updatevendorname(@vendorid nvarchar(50))
as 
Declare @accountid integer,@vendorname nvarchar(255)

select @accountid=AccountID,@vendorname = Vendor_Name from Vendors
where [VendorID]=@vendorid

update AccountsMaster Set AccountName = @vendorname
where AccountID = @accountid
