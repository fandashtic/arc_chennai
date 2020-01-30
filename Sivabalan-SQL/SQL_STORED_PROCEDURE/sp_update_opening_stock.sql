CREATE PROCEDURE sp_update_opening_stock(
@ITEMCODE nvarchar(30), 
@OPENING_DATE datetime, 
@DIFF Decimal(18,6), 
@FREE Int, 
@PRICE Decimal(18,6), 
@DAMAGE Decimal(18,6) = 0, 
@ADJVALUE Decimal(18,6) = 0
,@Batch_Code Int = 0)  
AS  
Begin
Declare @FPTaxVal Decimal(18,6)

IF @Batch_Code > 0 
Begin
	Select @FPTaxVal = IsNull(dbo.Fn_openingbal_TaxCompCalc(@ITEMCODE,IsNull(GRNTaxID,0),IsNull(GSTTaxType,0),IsNull(@PRICE,0),IsNull(@DIFF,0),1,1),0)
	FROM Batch_Products
	Where Batch_Products.Product_Code = @ITEMCODE And Batch_code = @Batch_Code And IsNull(Batch_Products.GRNTaxID,0) > 0 And IsNull(Batch_Products.GSTTaxType,0) > 0
End

IF @FREE = 0  
BEGIN  
 IF @DAMAGE = 0  
 Update OpeningDetails Set Opening_Quantity = Opening_Quantity + ISNULL(@DIFF,0), Opening_Value = Opening_Value + ISNULL((@PRICE * @DIFF),0) + @ADJVALUE + IsNull(@FPTaxVal,0)
 Where Product_Code = @ITEMCODE And Opening_Date > @OPENING_DATE  
 ELSE  
 Update OpeningDetails Set Opening_Quantity = Opening_Quantity + ISNULL(@DIFF,0), Damage_Opening_Quantity = IsNull(Damage_Opening_Quantity, 0) + ISNULL(@DIFF,0), Opening_Value = Opening_Value + ISNULL((@PRICE * @DIFF),0) + @ADJVALUE, 
 Damage_Opening_Value = Damage_Opening_Value + ISNULL((@PRICE * @DIFF),0) + @ADJVALUE  
 Where Product_Code = @ITEMCODE And Opening_Date > @OPENING_DATE  
END  
ELSE IF @FREE = 1  
BEGIN  
 IF @DAMAGE = 0  
 Update OpeningDetails Set Opening_Quantity = Opening_Quantity + ISNULL(@DIFF,0), Free_Opening_Quantity = IsNull(Free_Opening_Quantity, 0) + ISNULL(@DIFF,0), Free_Saleable_Quantity = IsNull(Free_Saleable_Quantity, 0) + ISNULL(@DIFF,0)  
 Where Product_Code = @ITEMCODE And Opening_Date > @OPENING_DATE  
 ELSE  
 Update OpeningDetails Set Opening_Quantity = Opening_Quantity + ISNULL(@DIFF,0), Free_Opening_Quantity = IsNull(Free_Opening_Quantity, 0) + ISNULL(@DIFF,0), Damage_Opening_Quantity = IsNull(Damage_Opening_Quantity, 0) + IsNull(@DIFF, 0)   
 Where Product_Code = @ITEMCODE And Opening_Date > @OPENING_DATE  
END  

End
