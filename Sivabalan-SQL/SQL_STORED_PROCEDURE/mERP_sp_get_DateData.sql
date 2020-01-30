Create Procedure mERP_sp_get_DateData
AS 
BEGIN
Declare @OpnDate DateTime
Declare @LastDate DateTime
Set DateFormat DMY
Select @OpnDate = Max(dbo.StripDateFromTime(OpeningDate)) From Setup
Select @LastDate = dbo.StripDateFromTime(Max(Opening_Date)) From OpeningDetails
If @LastDate < (Select dbo.StripDateFromTime(Max(TransactionDate)) From Setup)
	Select @LastDate = dbo.StripDateFromTime(Max(TransactionDate)) From Setup
IF @LastDate Is Null
	Select @LastDate = Max(dbo.StripDateFromTime(OpeningDate)) From Setup
Select @OpnDate, @LastDate
END
SET QUOTED_IDENTIFIER OFF 
