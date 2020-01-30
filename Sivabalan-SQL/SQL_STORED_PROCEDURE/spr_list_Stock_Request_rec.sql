CREATE Procedure spr_list_Stock_Request_rec (@FromDate datetime,@ToDate datetime)
As        
Declare @OPEN As NVarchar(50)
Declare @CLOSED As NVarchar(50)

Set @OPEN = dbo.LookupDictionaryItem(N'Open',Default)
Set @CLOSED = dbo.LookupDictionaryItem(N'Closed',Default)

Select  "Request NO" = StockRequestNo,      
 "Document ID" = OriginalStockRequest ,  
 "Document Date" =DocumentDate,  
 "Received Date" = CreationDate,  
 "Branch Office" = Warehouse.Warehouse_Name     ,      
 "Required Date" = RequiredDate ,                                                
 "Value" = NetValue,       
 "Status" = CASE (isnull(Status, 0) & 128) WHEN 0 THEN @OPEN ELSE @CLOSED END       ,      
 "Reference" = OriginalSerialNo     
from  SRAbstractReceived, Warehouse      
where  DocumentDate between @FromDate and @ToDate      
 and SRAbstractReceived.Warehouseid = Warehouse.warehouseid   


