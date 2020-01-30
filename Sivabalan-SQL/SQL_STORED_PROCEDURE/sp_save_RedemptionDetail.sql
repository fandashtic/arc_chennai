CREATE PROCEDURE [sp_save_RedemptionDetail]
	(@DocSerial int,	 @Product_Code nvarchar(50),
	 @Quantity decimal,	 @Points int)
AS INSERT INTO [RedemptionDetail] 
	 ( [DocSerial],	 [Product_Code],	 [Quantity],
	 [Points]) 
VALUES 
	( @DocSerial,  @Product_Code, @Quantity,
	 @Points)


