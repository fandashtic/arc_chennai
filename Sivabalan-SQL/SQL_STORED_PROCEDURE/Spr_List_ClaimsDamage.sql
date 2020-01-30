CREATE Procedure Spr_List_ClaimsDamage
(@Fromdate as DateTime , @Todate as DateTime)
as
Select ItemCategories.Category_Name , "Category Name" = ItemCategories.Category_Name, 
"Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,
"UOM" = UOM.Description, "Quantity" = Sum(ClaimsDetail.Quantity), 
"Value (%c)" = Sum(ClaimsDetail.Quantity * ClaimsDetail.Rate),
"Rate (%c)" = Avg(ClaimsDetail.Rate)
From
ClaimsNote , ClaimsDetail , Items , ItemCategories , UOM
Where
ClaimsNote.ClaimID = ClaimsDetail.ClaimID
And ClaimsNote.ClaimType = 2
And (ClaimsNote.Status & 128) = 0
And ClaimsDetail.Product_Code = Items.Product_Code 
And Items.CategoryID = ItemCategories.CategoryID 
And Items.UOM = UOM.UOM
And ClaimsNote.ClaimDate Between @FromDate And @Todate
Group By ItemCategories.Category_Name , Items.Product_Code, Items.ProductName , UOM.Description
Order By ItemCategories.Category_Name

