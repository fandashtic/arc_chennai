CREATE Procedure spr_list_Stock_Request ( @FromDate datetime,          
     @ToDate datetime)          
As         
Declare  @CANCELLED As NVarchar(50)
Declare  @CLOSED As NVarchar(50)
Declare  @PENDING As NVarchar(50)

Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled',Default)
Set @CLOSED = dbo.LookupDictionaryItem(N'Closed',Default)
Set @PENDING = dbo.LookupDictionaryItem(N'Pending',Default)

Select  "Request NO" = Stock_Req_Number,        
 "Document ID" = isnull(STK_REQ_Prefix,N'')  + cast (stock_request_abstract.DocumentID as nvarchar),          
 "Request Date" = Stock_Req_Date,        
 "Branch Office" = Warehouse.Warehouse_Name     ,        
 "Required Date" = RequiredDate ,                                                  
 "Value" = [Value]               ,         
 "Status" = CASE 
		when (Status & 64) <> 0 THEN @CANCELLED
		when (Status & 128) <> 0 THEN @CLOSED
		ELSE @PENDING 
	    END               
-- , "Reference" = Stock_Req_Reference       
      
from stock_request_abstract, Warehouse        
where Stock_Req_Date between @FromDate and @ToDate        
 and stock_request_abstract.Warehouseid = Warehouse.warehouseid        


