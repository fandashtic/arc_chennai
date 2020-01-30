CREATE PROCEDURE sp_Copy_Openingdetails_Specific(@FIRST_OPENING_DATE datetime, @LAST_OPENING_DATE datetime, @ITEMCODE nvarchar(15))
AS
   --The procedure will copy the specified item's stock into
   --all the dates between FirstOpeningDate and LastOpeningDate
	DECLARE @CURRENT_DATE Datetime
	SET @CURRENT_DATE = @FIRST_OPENING_DATE
   While @CURRENT_DATE < @LAST_OPENING_DATE
	Begin	
		Set @CURRENT_DATE = DateAdd(Day, 1, @CURRENT_DATE)
		Insert into openingdetails(Product_Code, Opening_Date, Opening_Quantity, Opening_Value, 
		Free_Opening_Quantity, Damage_Opening_Quantity, Damage_Opening_Value, 
		Free_Saleable_Quantity, TaxSuffered_Value, CST_TaxSuffered)
		Select Product_Code, @CURRENT_DATE, Opening_Quantity, Opening_Value, Free_Opening_Quantity, 
		Damage_Opening_Quantity, Damage_Opening_Value, Free_Saleable_Quantity, TaxSuffered_Value, CST_TaxSuffered
		From OpeningDetails
		Where Product_Code=@ITEMCODE and Opening_Date = @FIRST_OPENING_DATE
	End

