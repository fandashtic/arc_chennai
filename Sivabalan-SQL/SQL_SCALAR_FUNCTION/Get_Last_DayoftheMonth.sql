Create Function Get_Last_DayoftheMonth(@inDate Datetime)Returns Datetime
As
Begin

DECLARE @tempDate 	AS DATETIME
DECLARE @lastDayOfMonth AS DATETIME
Set @TempDate=Dateadd(m,1,@inDate)
Select @lastDayOfMonth=Dateadd(d,-Day(@Tempdate),@Tempdate)

Return(@lastDayOfMonth)
End



