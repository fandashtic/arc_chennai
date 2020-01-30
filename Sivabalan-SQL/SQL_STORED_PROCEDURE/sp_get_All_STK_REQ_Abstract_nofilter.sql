
CREATE Procedure sp_get_All_STK_REQ_Abstract_nofilter (@STK_REQ_FromDate Datetime,@STK_REQ_ToDate datetime)  
as   
Select warehouse.WareHouse_Name, 
	Stock_Request_Abstract.stock_req_number,  
	Stock_Request_Abstract.Stock_Req_Date, 
	Stock_Request_Abstract.RequiredDate, 
	status, 
	Stock_Request_Abstract.DocumentID, 
	Stock_Request_Abstract.[Value] from   
	Stock_Request_Abstract, warehouse  
where warehouse.warehouseid = Stock_Request_Abstract.WareHouseID   
	and (Stock_Request_Abstract.Stock_Req_Date between @STK_REQ_FromDate and @STK_REQ_ToDate)  
order by warehouse.WareHouse_Name, Stock_Request_Abstract.Stock_Req_Number  


