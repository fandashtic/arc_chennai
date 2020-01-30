Create Procedure SP_LP_getPeriodDetails @customerID nvarchar(15) 
AS  
Begin  
 SET Dateformat DMY
 Declare @LPDate as datetime  
 Declare @FromDate as datetime
 Declare @MaxDate as datetime
 Declare @MaxPeriod as nvarchar(25)

 if (select top 1 dbo.stripdatefromtime(Transactiondate) from setup) <=	
	(Select max(dbo.stripdatefromtime(GraceDate)) from LP_ScoreDetail where isnull(active,0)=1 and customerID= @customerID)
 Begin

	Select @MaxDate=max(cast(('01/'+(Right(Period,2) + '/' +  Left(Period,4)))as DateTime)) from LP_ScoreDetail where isnull(active,0)=1 and customerID= @customerID
	Set @MaxPeriod= CONVERT(VARCHAR(7), @MaxDate, 126)

	 select Top 1 @FromDate='01' +'-'+ left(Period,4)+'-'+Right(Period,2)  from LP_ScoreDetail where isnull(active,0)=1 and customerID= @customerID and period =@MaxPeriod
	 Set @FromDate=dateadd(m,1,@FromDate)
	 if (select top 1 dbo.stripdatefromtime(Transactiondate) from setup) >= @Fromdate
	 Begin
		 select Top 1 @LPDate='01' +'-'+ left(Period,4)+'-'+Right(Period,2)  from LP_ScoreDetail where isnull(active,0)=1 and customerID= @customerID and period =@MaxPeriod
		 Select top 1 Tier,right(convert(varchar, @LPDate, 106), 8)  as 'Period' from LP_ScoreDetail where isnull(active,0)=1 and customerID= @customerID and period =@MaxPeriod
	 End
 End	
END  
