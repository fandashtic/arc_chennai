
Create Procedure sp_get_CategoryBasedSplCategoryItems
                (@CATEGORYID INT)
As
Select Product_Code from Items where CategoryID=@CATEGORYID


