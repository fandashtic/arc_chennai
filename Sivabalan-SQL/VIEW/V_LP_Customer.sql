CREATE VIEW [dbo].[V_LP_Customer]
(
[LP_Customer_ID],
[LP_Loyalty_Tier],
[LP_Month]
) 
AS 
Select Distinct LP_ScoreDetail.Customerid,Tier, (Right(Period,2)  + '/' +  Left(Period,4)) Period
from LP_ScoreDetail,Customer C
Where LP_ScoreDetail.Active = 1 
And LP_ScoreDetail.CustomerId = C.CustomerID
And isnull(C.Active,0)=1
and dbo.stripTimeFromdate((select dbo.stripTimeFromdate(Transactiondate) from setup)) <= dbo.stripTimeFromdate(GraceDate)
and dbo.stripTimeFromdate((select dbo.stripTimeFromdate(Transactiondate) from setup)) >= dbo.stripTimeFromdate(DateAdd(m,+1,'01/' + Right(Period,2) + '/' + Left(Period,4)))

Union All
select Distinct LP_AchievementDetail.Customerid,'' Tier,(Right(Period,2)  + '/' +  Left(Period,4)) Period From LP_AchievementDetail,Customer C
Where 
C.CustomerID =LP_AchievementDetail.Customerid
And isnull(C.Active,0)=1
And LP_AchievementDetail.Customerid not in (select Distinct Customerid From LP_ScoreDetail Where Active = 1
and dbo.stripTimeFromdate((select dbo.stripTimeFromdate(Transactiondate) from setup)) <= dbo.stripTimeFromdate(GraceDate)
and dbo.stripTimeFromdate((select dbo.stripTimeFromdate(Transactiondate) from setup)) >= dbo.stripTimeFromdate(DateAdd(m,+1,'01/' + Right(Period,2) + '/' + Left(Period,4)))) 
and dbo.stripTimeFromdate((select dbo.stripTimeFromdate(Transactiondate) from setup)) <= dbo.stripTimeFromdate(GraceDate)
and dbo.stripTimeFromdate((select dbo.stripTimeFromdate(Transactiondate) from setup)) >= dbo.stripTimeFromdate(AchievedTo + 1)
and dbo.stripTimeFromdate((select dbo.stripTimeFromdate(Transactiondate) from setup)) Between dbo.stripTimeFromdate(TargetFrom) And dbo.stripTimeFromdate(TargetTo)

