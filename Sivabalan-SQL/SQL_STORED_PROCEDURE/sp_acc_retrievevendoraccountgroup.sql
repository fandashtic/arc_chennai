




CREATE procedure sp_acc_retrievevendoraccountgroup(@vendorid nvarchar(50))
as
Declare @accountid integer
select AccountGroup.GroupID,AccountGroup.GroupName from Vendors,AccountsMaster,AccountGroup
where Vendor_Name = @vendorid and Vendors.AccountID = AccountsMaster.AccountID
and AccountsMaster.GroupID = AccountGroup.GroupID      






