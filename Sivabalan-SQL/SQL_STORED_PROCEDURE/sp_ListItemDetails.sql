Create Procedure sp_ListItemDetails
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
	Order by It.Product_Code
END
