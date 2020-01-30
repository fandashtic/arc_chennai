CREATE PROCEDURE sp_View_POItems_UOM(@PONo INT)  
  
AS  

Declare @MULTIPLE As NVarchar(50)

Set @MULTIPLE = dbo.LookupDictionaryItem(N'Multiple', Default)
  
SELECT "Item Code" = PODetail.Product_Code, "Item Name" = Items.ProductName,   
"Quantity" = dbo.GetQtyAsMultiple (PODetail.Product_Code,Sum(PODetail.Quantity)),   
"UOM" = @MULTIPLE,
"Price" = PurchasePrice, "Pending" = dbo.GetQtyAsMultiple (PODetail.Product_Code,Sum(Pending)),  
"Amount" = Sum(Quantity * PurchasePrice)  
FROM PODetail, Items
WHERE PODetail.PONumber = @PONo   
AND PODetail.Product_Code = Items.Product_Code  
Group By PODetail.Serial,PODetail.Product_Code, Items.ProductName,PurchasePrice
Order By PODetail.Serial
  


