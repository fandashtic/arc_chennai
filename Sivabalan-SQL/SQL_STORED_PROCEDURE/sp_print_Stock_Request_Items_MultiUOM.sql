CREATE procedure [dbo].[sp_print_Stock_Request_Items_MultiUOM](@Stock_Transer_No INT)        
AS        
        
SELECT  "Item Code" = SRDet.Product_Code,       
 "Item Name" = Items.ProductName,       
 "UOM2Quantity" = dbo.GetFirstLevelUOMQty(SRDet.Product_Code, Sum(Quantity)),                
 "UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  SRDet.Product_Code )),                
 "UOM1Quantity" = dbo.GetSecondLevelUOMQty(SRDet.Product_Code, Sum(Quantity)),                
 "UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  SRDet.Product_Code )),                
 "UOMQuantity" = dbo.GetLastLevelUOMQty(SRDet.Product_Code, Sum(Quantity)),                
 "UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  SRDet.Product_Code )),                  
 "Price" = PurchasePrice,       
 "Pending" = Sum(Pending),        
 "Amount" = (Sum(Quantity) * PurchasePrice)      
FROM  stock_request_detail SRDet, Items, UOM        
WHERE SRDet.Stock_Req_Number = @Stock_Transer_No         
AND SRDet.Product_Code = Items.Product_Code        
AND Items.UOM *= UOM.UOM     
Group by SRDet.Stock_Req_Number, SRDet.Product_Code, Items.ProductName, PurchasePrice
