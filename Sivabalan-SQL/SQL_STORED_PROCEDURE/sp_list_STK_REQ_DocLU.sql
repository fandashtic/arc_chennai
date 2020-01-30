
create Procedure sp_list_STK_REQ_DocLU (@DocIDFrom int, @DocIDTo int)  
 as   
Select Warehouse.Warehouse_Name, Stock_Request_Abstract.Stock_Req_Number,  
Stock_Request_Abstract.Stock_Req_Date, Stock_Request_Abstract.RequiredDate, status,
Stock_Request_Abstract.DocumentID, Stock_Request_Abstract.Value from   
Stock_Request_Abstract,Warehouse  

where Warehouse.WarehouseID=Stock_Request_Abstract.WarehouseID   
and (Stock_Request_Abstract.DocumentID between @DocIDFrom and @DocIDTo)  
order by Warehouse.Warehouse_Name, Stock_Request_Abstract.Stock_Req_Number  
  


