CREATE PROCEDURE [sp_acc_InsertCoupon]
	(@CollectionID INT,
	 @FromSerial nVarChar(100),
	 @ToSerial 	nVarChar(100),
	 @Denomination Decimal(18,6),
	 @Qty INT,
	 @Value	Decimal(18,6),
	 @CouponDepositID INT = 0)
AS
INSERT INTO Coupon 
 ([CollectionID],
	 [FromSerial],
	 [ToSerial],
	 [Denomination],
	 [Qty],
	 [Value],
	 [CouponDepositID]) 
VALUES 
 (@CollectionID,
	 @FromSerial,
	 @ToSerial,
	 @Denomination,
	 @Qty,
	 @Value,
	 @CouponDepositID)

