

CREATE PROCEDURE sp_get_Pending_REQ_Qty(@PRODUCTCODE NVARCHAR(15))  
  
AS  
  
SELECT SUM(stock_request_detail.Pending), Product_Code FROM stock_request_abstract, stock_request_detail   
WHERE stock_request_detail.Stock_Req_Number = stock_request_abstract.Stock_Req_Number AND (stock_request_abstract.Status & 128 = 0)  
AND Product_Code = @PRODUCTCODE  
GROUP BY Product_Code


