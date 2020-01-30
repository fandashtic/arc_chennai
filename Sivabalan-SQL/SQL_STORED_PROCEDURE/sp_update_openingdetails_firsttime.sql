CREATE PROCEDURE sp_update_openingdetails_firsttime(@ITEM_CODE nvarchar(15))
AS
DECLARE @OPENING_DATE datetime
DECLARE @SERVER_DATE datetime

IF NOT EXISTS (Select Top 1 Product_Code From OpeningDetails Where Product_Code = @ITEM_CODE)
BEGIN
SELECT @OPENING_DATE = OpeningDate FROM Setup
select @SERVER_DATE = dbo.StripDateFromTime(isnull(operating_date,GetDate())) from setup
SET @OPENING_DATE = DateAdd(d, 0 - 1, dbo.StripDateFromTime(@OPENING_DATE))
While @OPENING_DATE < @SERVER_DATE
BEGIN
	SET @OPENING_DATE = DateAdd(d, 1, @OPENING_DATE)
	INSERT INTO OpeningDetails(Product_Code, Opening_Date, Opening_Quantity, Opening_Value)
	VALUES (@ITEM_CODE, @OPENING_DATE, 0, 0)
END
END
