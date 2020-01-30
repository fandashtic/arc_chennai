Create Procedure mERP_SP_SaveDSTypePlan (@Month nvarchar(10), @DSTypeID int,@Planned int,@UserName nvarchar(50))
AS
BEGIN
		Set dateformat dmy
		If exists (select 'x' from DSTypePlanning where PlanMonth= @Month and DSTypeID=@DSTypeID and Planned is null)
			Delete from DSTypePlanning where PlanMonth= @Month and DSTypeID=@DSTypeID and Planned is null

		if exists (select * from DSTypePlanning where PlanMonth= @Month and DSTypeID=@DSTypeID and Planned <> @Planned)
		Begin
			Delete from DSTypePlanning where PlanMonth= @Month and DSTypeID=@DSTypeID			
			Insert into DSTypePlanning(PlanMonth,DSTypeID,Planned,LogonUser)
			Select @Month,@DSTypeID,@Planned,@UserName			
		End
		Else If not exists (select * from DSTypePlanning where PlanMonth= @Month and DSTypeID=@DSTypeID and Planned= @Planned)
		Begin			
			Insert into DSTypePlanning(PlanMonth,DSTypeID,Planned,LogonUser)
			Select @Month,@DSTypeID,@Planned,@UserName			
		End

END
