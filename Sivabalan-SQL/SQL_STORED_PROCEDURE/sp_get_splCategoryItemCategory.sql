
Create Procedure sp_get_splCategoryItemCategory
                (@Special_Cat_Code INT)
As
Select items.product_Code from Items where items.CategoryID in (Select categoryID from Special_Cat_Product where Special_Cat_Code=@Special_Cat_Code)


