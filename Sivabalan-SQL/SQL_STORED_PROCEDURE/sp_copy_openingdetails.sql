CREATE PROCEDURE sp_copy_openingdetails(@OPENING_DATE datetime, @FIRST_OPENING_DATE datetime)
AS
insert into openingdetails(Product_Code, Opening_Date, Opening_Quantity, Opening_Value, 
Free_Opening_Quantity, Damage_Opening_Quantity, Damage_Opening_Value, 
Free_Saleable_Quantity, TaxSuffered_Value, CST_TaxSuffered)
Select Product_Code, @OPENING_DATE, Opening_Quantity, Opening_Value, Free_Opening_Quantity, 
Damage_Opening_Quantity, Damage_Opening_Value, Free_Saleable_Quantity, TaxSuffered_Value, CST_TaxSuffered
From OpeningDetails
Where Opening_Date = @FIRST_OPENING_DATE

