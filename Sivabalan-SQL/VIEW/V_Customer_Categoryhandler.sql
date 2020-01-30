Create VIEW  [V_Customer_Categoryhandler]
([CustomerID], [CategoryID], [Level], [Active])
AS
	SELECT     Customerproductcategory.CustomerID, Customerproductcategory.CategoryID, 
	Isnull(ItemCategories.[Level], 0), Isnull(Customerproductcategory.Active, 0) & IsNull(ItemCategories.Active, 0)
	FROM       Customerproductcategory
	Inner Join  ItemCategories 
	On ItemCategories.CategoryID = Customerproductcategory.CategoryID
	and 	Customerproductcategory.Active = 1 
	and 1 = 2
