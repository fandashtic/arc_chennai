
CREATE PROCEDURE sp_print_Rec_Stock_Request_Abstract(@Stock_Req_No INT)    
AS    
SELECT  "Document Date" = DocumentDate,   
 "Required Date" = RequiredDate,     
 "Warehouse" = warehouse.WareHouse_Name,   
 "Value" = SRAbstractReceived.NetValue,    
 "Stock Request Number" = OriginalStockRequest,
 status
  
FROM SRAbstractReceived, warehouse   
WHERE SRAbstractReceived.StockRequestNo = @Stock_Req_No  
AND SRAbstractReceived.WareHouseID = warehouse.WareHouseID    




