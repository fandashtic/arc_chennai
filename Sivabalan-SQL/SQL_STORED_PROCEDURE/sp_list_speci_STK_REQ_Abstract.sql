

CREATE Procedure sp_list_speci_STK_REQ_Abstract (@Warehouseid nvarchar(50),  
  @STK_REQ_FromDate Datetime,@STK_REQ_ToDate datetime, @Mode int)      
as       
if @mode = 1 
begin
	Select warehouse.WareHouse_Name, Stock_Request_Abstract.Stock_Req_Number,      
	Stock_Request_Abstract.Stock_Req_Date,     
	Stock_Request_Abstract.RequiredDate,     
	status,     
	Stock_Request_Abstract.DocumentID,     
	Stock_Request_Abstract.Value from       
	Stock_Request_Abstract,warehouse      
	where warehouse.warehouseid=Stock_Request_Abstract.WareHouseID       
	and (Stock_Request_Abstract.Stock_Req_Date between @STK_REQ_FromDate and @STK_REQ_ToDate)      
	and warehouse.warehouseid = @Warehouseid  
	order by warehouse.WareHouse_Name, Stock_Request_Abstract.Stock_Req_Number      
end
else
begin
	Select warehouse.WareHouse_Name, SRAbstractReceived.StockRequestNo,      
	SRAbstractReceived.DocumentDate,     
	SRAbstractReceived.RequiredDate,     
	status,     
	SRAbstractReceived.OriginalSerialNo,     
	SRAbstractReceived.NetValue from       
	SRAbstractReceived,warehouse      
	where warehouse.warehouseid=SRAbstractReceived.WareHouseID       
	and (SRAbstractReceived.DocumentDate between @STK_REQ_FromDate and @STK_REQ_ToDate)      
	and warehouse.warehouseid = @Warehouseid  
	order by warehouse.WareHouse_Name, SRAbstractReceived.StockRequestNo      
end


