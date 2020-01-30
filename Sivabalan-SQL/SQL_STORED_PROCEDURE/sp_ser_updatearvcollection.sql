CREATE Procedure sp_ser_updatearvcollection(@CollectionID as int,@ARVID int=0, @DetailType as int)
As
/*Detailtype --3 for Credit card and 4 for Coupon*/

If (@DetailType <> 4) 
	Update Collections set OtherDepositID = @ARVID where DocumentID = @CollectionID
else
	Update Coupon set CouponDepositID = @ARVID where SerialNo = @CollectionID


