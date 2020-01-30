CREATE procedure sp_insert_BillDiscount_Detail_Pidilite(  
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



