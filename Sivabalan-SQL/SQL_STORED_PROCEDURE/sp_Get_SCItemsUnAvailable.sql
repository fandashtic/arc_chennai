
CREATE Procedure sp_Get_SCItemsUnAvailable(@SchID int)
as

    select "Type"=1, special_Cat_Product_Rec.product_code 
    from Special_Cat_Product_Rec, Special_category_Rec
    where Special_Category_Rec.Special_Cat_Code = Special_cat_Product_Rec.Special_Cat_Code
    and special_Cat_Product_Rec.product_code not in (select items.Alias from items)
    and Special_Category_Rec.schemeID = @SchID
    and Special_Category_Rec.CategoryType = 1

    union

    select "Type"=2, special_Cat_Product_Rec.CategoryName
    from Special_Cat_Product_Rec, Special_category_Rec
    where Special_Category_Rec.Special_Cat_Code = Special_cat_Product_Rec.Special_Cat_Code
    and special_Cat_Product_Rec.CategoryName not in (select category_Name from itemcategories)
    and Special_Category_Rec.schemeID = @SchID
    and Special_Category_Rec.CategoryType = 2

