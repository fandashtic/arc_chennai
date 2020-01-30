CREATE PROCEDURE [dbo].[sp_print_Stock_Request_Items_MUOM](@Stock_Transer_No INT)    
AS    
SELECT  "Item Code" = SRD.Product_Code,   
 "Item Name" = Items.ProductName,   
 "Quantity" = SRD.UOMQty,     
 "UOM" = dbo.fn_GetUOMDesc(SRD.UOM,0),   
 "Price" = SRD.UOMPrice,   
 "Pending" = SRD.Pending / IsNull((Select Case When SRD.UOM = Items.UOM2 Then Items.UOM2_Conversion
			When SRD.UOM = Items.UOM1 Then Items.UOM1_Conversion Else 1 End),1),
 "Amount" = (SRD.Quantity * SRD.PurchasePrice),  
 "UOMID" = SRD.UOM,  
 "UOMPrice" = SRD.UOMPrice
FROM  stock_request_detail SRD
Inner Join Items on SRD.Product_Code = Items.Product_Code
Left Outer Join UOM on Items.UOM = UOM.UOM
WHERE SRD.Stock_Req_Number = @Stock_Transer_No     
--AND SRD.Product_Code = Items.Product_Code    
--AND Items.UOM *= UOM.UOM    
order by SRD.serial  
  


