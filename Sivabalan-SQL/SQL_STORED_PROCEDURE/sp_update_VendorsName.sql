CREATE Procedure sp_update_VendorsName (@ID nvarchar(30),@NewName nvarchar(128))        
As        
Update Vendors Set Vendor_Name = @NewName      
Where VendorId = @ID        



