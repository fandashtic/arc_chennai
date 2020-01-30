CREATE Procedure sp_update_promotion_UOM(  
@Product_Code nVarchar(15),  
@BillID Integer,  
@BATCH_CODE Integer,  
@TaxSuffered Decimal(18,6),  
@Promotion Integer)  
as  
Declare @ECP Decimal(18,6)  
If @Promotion = 1         
Begin        
	Select @ECP = ECP From Batch_Products Where Batch_Code In (Select BatchReference From        
	Batch_Products Where Free = 1 And Batch_Code = @BATCH_CODE)        
	Update Batch_Products Set ECP = @ECP, TaxSuffered = @TaxSuffered,         
	Promotion = @Promotion        
	Where Free = 1 And Batch_code = @BATCH_CODE        

	--Ecp should be updated only for Free item and Retailer promotion
	UPDATE Billdetail SET Promotion = @Promotion, ECP = @ECP  
	WHERE Billid = @BillID and isnull(Serial,0) = 0      
End        




