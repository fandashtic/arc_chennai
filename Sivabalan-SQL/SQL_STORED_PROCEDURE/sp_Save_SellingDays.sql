
CREATE PROCEDURE sp_Save_SellingDays
(
	@SalesmanId Int,
	@MonthNo Int,
	@Days Int
)
As 

Insert  InTo SellingDays(SalesmanId,MonthNo,Days) Values(@SalesmanId,@MonthNo,@Days)

