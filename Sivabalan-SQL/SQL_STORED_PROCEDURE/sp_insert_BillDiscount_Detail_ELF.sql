CREATE procedure sp_insert_BillDiscount_Detail_ELF(  
@BillId int,  
@ItemSerial int,  
@DiscountID int,  
@DiscountPercentage Decimal(18,6),  
@DiscountAmount Decimal(18,6),  
@Serial int)  
As  
Insert into BillDiscount   
(BillId,ItemSerial,DiscountID,DiscountPercentage,DiscountAmount,Serial)  
Values   
(@BillId,@ItemSerial,@DiscountID,@DiscountPercentage,@DiscountAmount,@Serial)  




