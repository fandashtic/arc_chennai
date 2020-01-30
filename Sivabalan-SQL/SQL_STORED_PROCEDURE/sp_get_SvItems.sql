CREATE PROCEDURE sp_get_SvItems (@SVNumber int)                
AS                
SELECT SVDetail.Product_Code, ProductName,        
"StockCount" = StkCntUOMQTY,         
"UOM" = dbo.fn_GetUOMDesc(SVDetail.UOMID,0),          
"UOMID" = SVDetail.UOMID,      
OffTake,         
"SuggestedQty" = UOMQty,    
"ActualQty" = AUOMQTY,    
SalePrice,  
StockCountUomID          
FROM SVDetail, Items, UOM            
WHERE SVDetail.SVNumber = @SVNumber            
AND UOM.UOM = SVDetail.UOMID                 
AND SVDetail.Product_Code = Items.Product_Code      
         
    
    
  
  


