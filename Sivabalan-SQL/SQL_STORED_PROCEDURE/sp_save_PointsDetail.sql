CREATE PROCEDURE [sp_save_PointsDetail]
	(@DocSerial	int, @Product_Code nvarchar(15),@CategoryID int,
	 @PointsType int, @Points int,@Value decimal(18,6), @Active int)
AS
INSERT INTO PointsDetail
	 ([DocSerial],	 [Product_Code],[CategoryID], [PointsType],
	 [Points],  [Value],  [Active]) 
 
VALUES 
	(@DocSerial,	@Product_Code, @CategoryID,
	 @PointsType,	 @Points,  @Value, @Active)


