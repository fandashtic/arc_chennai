CREATE Procedure sp_save_forecast (@DocSerial int, @Product_Code nvarchar(20),
@MRP Decimal(18,6), @Wk1Qty Decimal(18,6), @Wk2Qty Decimal(18,6), @Wk3Qty Decimal(18,6), 
@Wk4Qty Decimal(18,6), @Wk5Qty Decimal(18,6),	@Wk6Qty Decimal(18,6),	@Wk7Qty Decimal(18,6),	@Wk8Qty Decimal(18,6),	
@Wk9Qty Decimal(18,6), @Wk10Qty Decimal(18,6),	@Wk11Qty Decimal(18,6),	@Wk12Qty Decimal(18,6),	@Wk13Qty Decimal(18,6))
As
Insert into ForeCast (DocSerial, Product_Code, MRP, Wk1Qty, Wk2Qty, Wk3Qty, Wk4Qty, 
Wk5Qty, Wk6Qty, Wk7Qty, Wk8Qty, Wk9Qty, Wk10Qty, Wk11Qty, Wk12Qty, Wk13Qty) Values 
(@DocSerial, @Product_Code, @MRP, @Wk1Qty, @Wk2Qty, @Wk3Qty, @Wk4Qty, @Wk5Qty, @Wk6Qty, 
@Wk7Qty, @Wk8Qty, @Wk9Qty, @Wk10Qty, @Wk11Qty, @Wk12Qty, @Wk13Qty)
