CREATE PROCEDURE [dbo].[sp_print_Stock_Request_Abstract](@Stock_Req_No INT)      
AS      
SELECT  "Stock Request Date" = Stock_Req_Date,     
 "Required Date" = RequiredDate,       
 "Warehouse" = warehouse.WareHouse_Name,     
 "Value" = stock_request_abstract.Value,      
 "Address" = stock_request_abstract.ShippingAddress,       
 "Stock Request Number" = PO.Prefix + CAST(DocumentID AS nvarchar), 
"Status" = status, 
"Remarks" = Remarks,
"TIN Number" = TIN_Number
FROM stock_request_abstract
Inner Join warehouse On stock_request_abstract.WareHouseID = warehouse.WareHouseID
Left Outer Join CreditTerm on stock_request_abstract.CreditTerm = CreditTerm.CreditID
Inner Join VoucherPrefix PO on  PO.TranID = 'STOCK REQUEST' 
Inner Join VoucherPrefix GRN on  GRN.TranID = 'GOODS RECEIVED NOTE' 

WHERE stock_request_abstract.stock_req_number = @Stock_Req_No    
--AND stock_request_abstract.WareHouseID = warehouse.WareHouseID      
--AND stock_request_abstract.CreditTerm *= CreditTerm.CreditID     
--AND PO.TranID = 'STOCK REQUEST'    
--AND GRN.TranID = 'GOODS RECEIVED NOTE' 
