CREATE procedure [dbo].[sp_print_Rec_StkReq_Items_MUOM](@Stock_Transfer_No int)  
As  
SELECT  "Item Code" = SRDR.Product_Code,   
 "Item Name" = Items.ProductName,   
 "Quantity" = SRDR.UOMQty,  
 "UOM" =dbo.fn_GetUOMDesc(SRDR.UOM,0),  
 "Price" = SRDR.UOMPrice,   
 "Pending" = SRDR.UOMQty,
 "Amount" = (SRDR.Quantity * SRDR.PurchasePrice)
FROM  Stock_request_detail_received SRDR, Items, UOM    
WHERE SRDR.STK_REQ_Number = @Stock_Transfer_No     
AND SRDR.Product_Code = Items.Product_Code    
AND Items.UOM *= UOM.UOM    
order by SRDR.serial
