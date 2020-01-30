CREATE PROCEDURE sp_ser_update_opening_stock(@ITEMCODE nvarchar(15), @OPENING_DATE datetime, @DIFF float, @FREE int, @PRICE float, @DAMAGE int = 0, @ADJVALUE float = 0)
AS
IF @FREE = 0
BEGIN
	IF @DAMAGE = 0
		Update OpeningDetails Set Opening_Quantity = Opening_Quantity + ISNULL(@DIFF,0), 
		Opening_Value = Opening_Value + ISNULL((@PRICE * @DIFF),0) + @ADJVALUE 
		Where Product_Code = @ITEMCODE And Opening_Date > @OPENING_DATE
	ELSE
		Update OpeningDetails Set Opening_Quantity = Opening_Quantity + ISNULL(@DIFF,0), 
		Damage_Opening_Quantity = IsNull(Damage_Opening_Quantity, 0) + ISNULL(@DIFF,0), 
		Opening_Value = Opening_Value + ISNULL((@PRICE * @DIFF),0) + @ADJVALUE, 
		Damage_Opening_Value = Damage_Opening_Value + ISNULL((@PRICE * @DIFF),0) + @ADJVALUE
		Where Product_Code = @ITEMCODE And Opening_Date > @OPENING_DATE
END
ELSE IF @FREE = 1
BEGIN
	IF @DAMAGE = 0
		Update OpeningDetails Set Opening_Quantity = Opening_Quantity + ISNULL(@DIFF,0), 
		Free_Opening_Quantity = IsNull(Free_Opening_Quantity, 0) + ISNULL(@DIFF,0), 
		Free_Saleable_Quantity = IsNull(Free_Saleable_Quantity, 0) + ISNULL(@DIFF,0)
		Where Product_Code = @ITEMCODE And Opening_Date > @OPENING_DATE
	ELSE
		Update OpeningDetails Set Opening_Quantity = Opening_Quantity + ISNULL(@DIFF,0), 
		Free_Opening_Quantity = IsNull(Free_Opening_Quantity, 0) + ISNULL(@DIFF,0), 
		Damage_Opening_Quantity = IsNull(Damage_Opening_Quantity, 0) + IsNull(@DIFF, 0) 
		Where Product_Code = @ITEMCODE And Opening_Date > @OPENING_DATE
END



