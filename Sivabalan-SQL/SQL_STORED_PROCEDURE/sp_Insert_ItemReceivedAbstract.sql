Create Procedure sp_Insert_ItemReceivedAbstract (@ForumCode nvarchar(255))
As
Declare @PartyCode nvarchar(255)
Declare @PartyName nvarchar(255)
Declare @PartyType nvarchar(20)

If exists(Select CustomerID From Customer Where AlternateCode = @ForumCode)
Begin
	Select @PartyCode = CustomerID, @PartyName = Company_Name,
	@PartyType = 'Customer' From Customer Where AlternateCode = @ForumCode
	Goto PartyFound
End
If exists(Select VendorID From Vendors Where AlternateCode = @ForumCode)
Begin 
	Select @PartyCode = VendorID, @PartyName = Vendor_Name,
	@PartyType = 'Vendor' From Vendors Where AlternateCode = @ForumCode
	Goto PartyFound
End
If exists(Select WareHouseID From WareHouse Where ForumID = @ForumCode)
Begin
	Select @PartyCode = WareHouseID, @PartyName = WareHouse_Name,
	@PartyType = 'Branch Office' From WareHouse Where ForumID = @ForumCode
	goto PartyFound
End
PartyFound:
Insert Into ItemsReceivedAbstract (ForumCode, PartyCode, PartyName, PartyType)
Values (@ForumCode, @PartyCode, @PartyName, @PartyType)
Select @@Identity
