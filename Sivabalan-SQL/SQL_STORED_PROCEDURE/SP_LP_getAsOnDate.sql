create Procedure SP_LP_getAsOnDate @CustomerID nvarchar(30)
AS
BEGIN
	Declare @Dayclose datetime
	Declare @TargetTo datetime
	Select top 1 @Dayclose = isnull(Lastinventoryupload,getdate()) from Setup
	Select @TargetTo = max(targetTo) from LP_AchievementDetail where isnull(active,0) = 1 and customerid=@CustomerID
	/*If there is no  LP_AchievementDetail for the customer */
	if @TargetTo is  null
	Begin
		set @TargetTo=@Dayclose
		select CONVERT(VARCHAR(11), @TargetTo, 106)
	End
	else
	Begin
		if @TargetTo < @Dayclose
			select CONVERT(VARCHAR(11), @TargetTo, 106)
		else
			select CONVERT(VARCHAR(11), @Dayclose, 106)
	End
END
