CREATE PROCEDURE sp_create_stock_request_detail(@stock_req_Number INT,   
	@ProductCode NVARCHAR(15),   
	@Quantity Decimal(18,6),   
	@PurchasePrice Decimal(18,6),
	@Serial int = 0	)  
AS  
INSERT INTO   
stock_request_detail   (stock_req_Number,   
	Product_Code,   
	Quantity,   
	Pending,  
	PurchasePrice,
	Serial)  
VALUES    
	(@stock_req_Number,   
	@ProductCode,   
	@Quantity,   
	@Quantity,   
	@PurchasePrice,
	@Serial)  


