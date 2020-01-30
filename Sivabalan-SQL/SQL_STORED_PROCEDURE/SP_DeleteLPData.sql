Create Procedure SP_DeleteLPData
AS
BEGIN
	Delete from LPCustomerScore where Period in
	(select isnull(Period,'') from LP_AchievementDetail where isnull(Active,0) = 1)
END
