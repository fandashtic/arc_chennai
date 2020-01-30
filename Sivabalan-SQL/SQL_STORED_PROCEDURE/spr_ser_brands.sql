CREATE PROCEDURE spr_ser_brands(@FROMDATE datetime, @TODATE datetime, @CusType nVarchar(50))
AS
--@CusType - unused parameter
SELECT "BrandID" = BrandID, "Brand Name" = BrandName FROM Brand


