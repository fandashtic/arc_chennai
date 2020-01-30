Create Procedure SP_Check_LPLog
AS
BEGIN
	delete from lplog where cast(period as nvarchar(7)) + isnull(customerid,'NULL') not in 
	(Select distinct cast(Period as nvarchar(7))+Isnull(CustomerID,'NULL') from lp_achievementdetail where active=1)

	If exists(select Top 1 Period from LPLog where isnull(active,0) = 1)
	Select 1
	else
	select 0 

END
