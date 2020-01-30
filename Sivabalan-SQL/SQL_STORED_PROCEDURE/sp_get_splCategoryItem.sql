
Create Procedure sp_get_splCategoryItem
                (@Special_Cat_Code INT)
As
Select Product_Code from Special_Cat_Product where Special_Cat_Code=@Special_Cat_Code


