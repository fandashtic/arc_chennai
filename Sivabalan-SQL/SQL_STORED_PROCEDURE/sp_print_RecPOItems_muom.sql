--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
CREATE procedure [dbo].[sp_print_RecPOItems_muom](@PONo INT)    
AS    
SELECT     
"Item Code" =     
  case    
  when Items.Product_Code is null then    
  PODetailReceived.Product_Code    
  else    
  Items.Product_Code    
  end,   
"Item Name" = Items.ProductName,   
"Quantity" = DBO.GetQtyAsMultiple(PODetailReceived.Product_Code, sum(Quantity)),     
"Dummy" = NULL, "Purchase Price" = PurchasePrice   ,sum(Quantity)
FROM PODetailReceived, Items    
WHERE PODetailReceived.PONumber = @PONo     
AND PODetailReceived.Product_Code *= Items.Alias    
group by PODetailReceived.Product_Code, Items.Product_Code, Items.ProductName,   
 PODetailReceived.PurchasePrice
