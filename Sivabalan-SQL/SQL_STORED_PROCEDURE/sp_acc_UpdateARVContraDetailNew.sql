CREATE Procedure sp_acc_UpdateARVContraDetailNew (@ContraSerial INT, @AdjustedFlag INT,  
          @Type INT, @DocumentID INT, @ARVID INT = 0)  
As  
/*Update Collections table if CollectionType is CreditCard*/  
If @Type = 3  
 Update Collections Set OtherDepositID = @ARVID Where DocumentID = @DocumentID  
Else /*Update Coupon table if CollectionType is Coupon*/  
 Update Coupon Set CouponDepositID = @ARVID Where SerialNo = @DocumentID  
/*Update Internal Contra Detail Table in both cases*/  
Update ContraDetail Set AdjustedFlag = @AdjustedFlag Where ContraSerialCode=@ContraSerial 
