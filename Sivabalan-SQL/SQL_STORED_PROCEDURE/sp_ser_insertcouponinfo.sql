CREATE procedure sp_ser_insertcouponinfo
(@CollectionID int, @FromSerial nvarchar(255), @ToSerial nvarchar(255), @Denomination int, @Quantity int, 
@Value decimal(18,6)) 
as 
Insert into Coupon (CollectionID, FromSerial, TOSERIAL, Denomination, qty, Value) 
Values (@CollectionID, @FromSerial, @ToSerial, @Denomination, @Quantity, @Value) 

Select @@Rowcount

