

CREATE Procedure sp_get_All_REC_STK_REQ_Abstract(@STK_REQ_FromDate Datetime,@STK_REQ_ToDate datetime)      
as       
Select warehouse.WareHouse_Name,     
 SRAbstractReceived.StockRequestNo ,      
 SRAbstractReceived.DocumentDate,     
 SRAbstractReceived.RequiredDate,     
 status,     
 SRAbstractReceived.OriginalStockRequest ,     
 SRAbstractReceived.[NetValue] , 
 SRAbstractReceived.StockRequestNo
from       
SRAbstractReceived, warehouse      
where warehouse.warehouseid = SRAbstractReceived.WareHouseID       
and (SRAbstractReceived.DocumentDate between @STK_REQ_FromDate and @STK_REQ_ToDate)      
order by warehouse.WareHouse_Name, SRAbstractReceived.StockRequestNo      
  


