CREATE VIEW [dbo].[V_Customerwise_LP]
(
[LP_Customer_ID] ,
[LP_Loyaltytype_Seq_No],
[LP_Loyaltytype_Desc],
[LP_Loyaltytype_Points]
) 
AS 
Select Distinct LP_ScoreDetail.CustomerId,LP_ScoreDetail.SequenceNo,PARTICULAR, cast(PointsEarned as Decimal(18,2)) PointsEarned  from LP_ScoreDetail,Customer C 
Where LP_ScoreDetail.Active = 1 
And C.CustomerID = LP_ScoreDetail.CustomerID
And isnull(c.active,0)=1
And Type in (Select LabelName from lpprintconfig where isnull(abstractField,0)=1)
--and Period in (select Distinct Period From LP_AchievementDetail Where Active = 1 
and dbo.stripTimeFromdate((select dbo.stripTimeFromdate(Transactiondate) from setup)) <= dbo.stripTimeFromdate(GraceDate)
and dbo.stripTimeFromdate((select dbo.stripTimeFromdate(Transactiondate) from setup)) >= dbo.stripTimeFromdate(DateAdd(m,+1,'01/' + Right(Period,2) + '/' + Left(Period,4)))
--)
