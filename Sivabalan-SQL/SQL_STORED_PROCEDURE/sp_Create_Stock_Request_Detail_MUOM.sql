CREATE PROCEDURE sp_Create_Stock_Request_Detail_MUOM(@Stock_Req_Number INT,   
	@ProductCode NVARCHAR(15),   
	@Quantity Decimal(18,6),   
	@PurchasePrice Decimal(18,6),
	@UOMID Int = 0,
    @UOMQty Decimal(18,6),
    @UOMPrice Decimal(18,6),
	@Serial int = 0	)  
AS  
INSERT INTO  Stock_Request_Detail(
Stock_Req_Number,Product_Code,Quantity,Pending,PurchasePrice,
UOM,UOMQty,UOMPrice,Serial)  
VALUES(
@Stock_Req_Number,@ProductCode,@Quantity,@Quantity,@PurchasePrice,
@UOMID,@UOMQty,@UOMPrice,@Serial)  



