CREATE Procedure sp_ser_creditcarddetail(@Paymentmode as int)
as 
Select IsNull(ServiceChargeCustomer, 0) ServiceChargeCustomer from PaymentMode where Mode = @PaymentMode 

