Create Procedure SP_get_LPAbstractDetails @Details  nvarchar(4000),@customerID nvarchar(15)   
AS  
BEGIN
  Declare @FromDate as datetime  
  Declare @MaxDate as datetime
  Declare @MaxPeriod as nvarchar(25)
  set dateformat dmy	
  Select @MaxDate= max(cast(('01/'+(Right(Period,2) + '/' +  Left(Period,4)))as DateTime)) from LP_ScoreDetail where isnull(active,0)=1 and customerID= @customerID
  Set @MaxPeriod= CONVERT(VARCHAR(7), @MaxDate, 126)

  if (select top 1 dbo.stripdatefromtime(Transactiondate) from setup) <=(Select top 1 dbo.stripdatefromtime(GraceDate) from LP_ScoreDetail where isnull(active,0)=1 and customerID= @customerID and Period =@MaxPeriod)
  Begin
	 select Top 1 @FromDate='01' +'-'+ left(Period,4)+'-'+Right(Period,2)  from LP_ScoreDetail where Type in (Select * from dbo.sp_SplitIn2rows(@Details,',')) 
	 and isnull(active,0)=1  and customerID=@customerID and Period = @MaxPeriod
	 Set @FromDate=dateadd(m,1,@FromDate)
	 if (select top 1 dbo.stripdatefromtime(Transactiondate) from setup) >= @Fromdate
	 Begin
		 select Particular,cast(PointsEarned as decimal(18,6)) from LP_ScoreDetail where Type in (Select * from dbo.sp_SplitIn2rows(@Details,',')) 
		 and isnull(active,0)=1  and customerID=@customerID and Period = @MaxPeriod order by sequenceno
	 End
 End
END
