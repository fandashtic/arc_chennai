CREATE PROCEDURE [sp_insert_Coupon]
	(@CollectionID int,
	 @FromSerial nvarchar(100),
	 @ToSerial 	nvarchar(100),
	 @Denomination decimal(18,6),
	 @Qty int,
	 @Value	decimal(18,6),
	 @CouponDepositID int)

AS INSERT INTO Coupon 
	 ([CollectionID],
	 [FromSerial],
	 [ToSerial],
	 [Denomination],
	 [Qty],
	 [Value],
	 [CouponDepositID]) 
 
VALUES 
	( @CollectionID,
	 @FromSerial,
	 @ToSerial,
	 @Denomination,
	 @Qty,
	 @Value,
	 @CouponDepositID)


