CREATE procedure [dbo].[sp_print_POItems_MultiUOM_Serial](@PONo INT)  
AS  
SELECT "Item Code" = PODetail.Product_Code, "Item Name" = Items.ProductName,   
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(PODetail.Product_Code, Sum(PODetail.Quantity)),  
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  PODetail.Product_Code )),  
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(PODetail.Product_Code, Sum(PODetail.Quantity)),  
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  PODetail.Product_Code )),  
"UOMQuantity" = dbo.GetLastLevelUOMQty(PODetail.Product_Code, Sum(PODetail.Quantity)),  
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  PODetail.Product_Code )),    
  
"Price" = PurchasePrice, "Pending" = Sum(Pending),  
"Amount" = Sum(Quantity) * PurchasePrice,  
"Property1" = dbo.GetProperty(PODetail.Product_Code, 1),  
"Property2" = dbo.GetProperty(PODetail.Product_Code, 2),  
"Property3" = dbo.GetProperty(PODetail.Product_Code, 3),  
"Property4" = dbo.GetProperty(PODetail.Product_Code, 4),  
"Category" = ItemCategories.Category_Name  
FROM PODetail, Items, UOM, ItemCategories  
WHERE PODetail.PONumber = @PONo   
AND PODetail.Product_Code = Items.Product_Code  
AND Items.UOM *= UOM.UOM  
And Items.CategoryID = ItemCategories.CategoryID  
group by PODetail.Serial,PODetail.Product_Code, Items.ProductName, PurchasePrice, 
ItemCategories.Category_Name  
Order by PODetail.Serial
