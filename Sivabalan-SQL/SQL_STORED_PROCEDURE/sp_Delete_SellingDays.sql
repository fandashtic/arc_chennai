
CREATE PROCEDURE sp_Delete_SellingDays
(
	@SalesmanId Int
)
As 

Delete From SellingDays Where SalesmanId=@SalesmanId

