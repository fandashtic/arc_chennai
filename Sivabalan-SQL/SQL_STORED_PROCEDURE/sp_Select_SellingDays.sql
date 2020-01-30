
CREATE PROCEDURE sp_Select_SellingDays
(
	@SalesmanId Int
)
As 

Select MonthNo,Days From SellingDays Where SalesmanId=@SalesmanId

