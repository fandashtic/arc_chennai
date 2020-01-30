
create Procedure List_REC_STK_REQ_Abstract(@DocIDFrom int, @DocIDTo int)  
 as   
Select  Warehouse.Warehouse_Name, 
	SRAbstractReceived.StockRequestNo,  
	SRAbstractReceived.DocumentDate, 
	SRAbstractReceived.RequiredDate, 
	status,
	SRAbstractReceived.OriginalSerialNo, 
	SRAbstractReceived.NetValue 
from   
	SRAbstractReceived,Warehouse  
where 
	Warehouse.WarehouseID=SRAbstractReceived.WarehouseID   
and (SRAbstractReceived.OriginalSerialNo between @DocIDFrom and @DocIDTo)  
order by Warehouse.Warehouse_Name, SRAbstractReceived.StockRequestNo  

