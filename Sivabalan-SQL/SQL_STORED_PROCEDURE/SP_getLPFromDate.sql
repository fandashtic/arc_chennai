Create Procedure SP_getLPFromDate
AS
BEGIN
	select isnull(AchievedTo,getdate())+1 from LP_AchievementDetail where isnull(Active,0) = 1
END
