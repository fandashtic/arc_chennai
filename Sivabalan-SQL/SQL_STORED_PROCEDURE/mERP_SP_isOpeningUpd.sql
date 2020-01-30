Create Procedure mERP_SP_isOpeningUpd @AccID int, @date datetime
AS
BEGIN
	/*
	 Selected Date  in Accounts Opening Details.EXE - 1 will be passed as a parameter to this SP. This SP will check the Opening Value for the previous date
	 If Value exists, it will allow to update opening Details for the selected date.
	 For First Transaction Date, No Check will happen. Since Opening Value can be taken from Accounts Master Table.
	*/
	Set dateformat DMY
	Declare @OpeningDate datetime
	Select Top 1 @OpeningDate = DateAdd(Day,-1,OpeningDate) from setup
	if dbo.stripdatefromtime(@date) = dbo.stripdatefromtime(@openingDate)
	BEGIN
		Select 1
	END
	ELSE
	BEGIN
	if (Select Count(*) from AccountopeningBalance Where Accountid  = @AccID and openingDate = @Date) >= 1
		Select 1
	Else
		Select 0
	END
END
