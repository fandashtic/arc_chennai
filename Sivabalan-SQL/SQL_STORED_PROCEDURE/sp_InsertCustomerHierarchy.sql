
Create Proc sp_InsertCustomerHierarchy(@HierarchyID int, @HierarchyName nVarChar(255))
As
	Insert Into CustomerHierarchy Values(@HierarchyID, @HierarchyName )

