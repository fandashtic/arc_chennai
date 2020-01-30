Create Procedure mERP_sp_get_AutoFixItems
AS 
BEGIN
	Select 
	It.Product_Code,
	It.ProductName,
	IC.Category_Name,
	Case Isnull(It.Active,0) When 1 then 'Yes' Else  'No' END
	From Items It, ItemCategories IC
	Where It.CategoryID=IC.CategoryID
	And It.Product_Code In (Select Distinct Product_Code From Batch_Products)
	And It.Product_Code In (Select Distinct ItemCode From FixedItems Where FixFlag = 0)
	Order by It.Product_Code
END
