CREATE PROCEDURE sp_view_GRNDetail_UOM (@GRNID INT)  
AS  
SELECT GRNDetail.Product_Code, Items.ProductName,   
GRNDetail.UomQty,  
GRNDetail.uomRejection,   
GRNDetail.ReasonRejected, N'',  
0, GRNDetail.uomqty - GRNDetail.uomRejection,  
RejectionReason.Message,   
isNull(FreeQty, 0),GRNDetail.uom, GrnDetail.Serial,  
"UOMDescription" = (Select IsNull(Description, 'Multiple') From UOM Where UOM = GRNDetail.uom), 
"FreeConversion" = 
(Case IsNull(FreeQty,0) When 0 Then 0 
Else
(Case IsNull(GRNDetail.uom,0) 
When  IsNull(Items.UOM,0)  Then Items.ConversionFactor
When  IsNull(Items.UOM1,0) Then Items.UOM1_Conversion
When  IsNull(Items.UOM2,0) Then Items.UOM2_Conversion
Else 0 End)
End)
,"TaxSuffered" = (select top 1 taxsuffered from batch_products where batch_products.GRN_ID = @GRNID and batch_Products.Product_code = GRNDetail.Product_code order by batch_products.batch_code desc)
FROM GRNDetail Inner Join Items On
GRNDetail.GRNID = @GRNID   
AND GRNDetail.Product_Code = Items.Product_Code  
Left Outer Join RejectionReason On
GRNDetail.ReasonRejected = RejectionReason.MessageID  
order by GrnDetail.Serial  
