
Create Procedure sp_GetProductCategoryGroup_ITC(@SalesmanID int)
As
	Select ProductCategoryGroupAbstract.GroupName, DSHandle.GroupID From ProductCategoryGroupAbstract, DSHandle
		Where DSHandle.GroupID = ProductCategoryGroupAbstract.GroupID
		And DSHandle.SalesmanID = @SalesmanID
		And DSHandle.Active = 1
		And ProductCategoryGroupAbstract.Active = 1

