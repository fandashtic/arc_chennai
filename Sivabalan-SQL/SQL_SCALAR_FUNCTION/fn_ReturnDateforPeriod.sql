
Create Function fn_ReturnDateforPeriod (@Period nvarchar(10))
Returns DateTime
AS
BEGIN

	Declare @Output Datetime
	Declare @Temp nvarchar(10)
	Select @Temp =  cast('1-' as nvarchar(3))+ cast(Case substring(@Period,1,3) 
	When 'Jan' Then '1'
	When 'Feb' Then '2'
	When 'Mar' Then '3'
	When 'Apr' Then '4'
	When 'May' Then '5'
	When 'Jun' Then '6'
	When 'Jul' Then '7'
	When 'Aug' Then '8'
	When 'Sep' Then '9'
	When 'Oct' Then '10'
	When 'Nov' Then '11'
	When 'Dec' Then '12' end as nvarchar(2)) + cast('-' as nvarchar)+  cast(substring(@Period,5,4) as nvarchar(4))
	Set @Output=@Temp
	Return @Output
END


