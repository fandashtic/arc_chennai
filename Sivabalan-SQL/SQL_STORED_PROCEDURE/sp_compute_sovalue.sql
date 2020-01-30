
CREATE PROCEDURE sp_compute_sovalue(@SONUMBER int)
AS
SELECT SUM(Pending * (SalePrice+(saleprice*isnull(saletax,0)/100)-((SalePrice*isnull(Discount,0))/100))) FROM SODetail WHERE SONumber = @SONUMBER


