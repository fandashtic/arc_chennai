CREATE procedure sp_ser_coupondetail  (@mode as int, @CouponID as int = 0)
as
if (@mode = 1) 
	Select mode, value from PaymentMode Where Active = 1 and PaymentType = 4 	
else if (@mode = 2 and @CouponID > 0) 
	Select ServiceChargeCustomer, IsNull(ServiceChargeProvider,0) 'ServiceChargeProvider',  
	IsNull(ProviderAccountID,0) 'ProviderAccountID', IsNull(AccountName,'') 'AccountName' from PaymentMode 
	Left Outer Join AccountsMaster On AccountID = ProviderAccountID 
	Where PaymentMode.Active = 1 and PaymentType = 4 and Mode = @CouponID
else if (@mode = 3 and @CouponID > 0) --Mode 3 to get provider account name only  
									  --in Coupon creation provision in service invoice
	Select IsNull(AccountName,'') 'AccountName' from PaymentMode 
	Left Outer Join AccountsMaster On AccountID = ProviderAccountID 
	Where PaymentMode.Active = 1 and PaymentType = 4 and Mode = @CouponID

