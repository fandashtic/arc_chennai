CREATE PROCEDURE mERP_spr_DSTraining_Detail(@KeyData nVarchar(2550),
@TrainingName nVarchar(2550),@GivenDate datetime)
As
Begin
set dateformat dmy
Declare @DsTypeID as Int
Declare @DsTrainingID as Int
Declare @Facilitator as nVarchar(200)
Declare @Town as nVarchar(200)
Declare @ActualDate as datetime
Declare @PlanDate as datetime
Declare @RefNo Int

Declare @Delimeter as char(1)
Set @Delimeter = Char(15)

Declare @TmpParameters Table
([RowID] Int Identity(1,1), KeyValue nVarchar(2510) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert Into @TmpParameters
select * from dbo.sp_splitin2Rows(@KeyData,@Delimeter)

Set @DsTRainingID = (Select KeyValue from @TmpParameters where [RowID] = 1)
Set @Facilitator = (Select KeyValue from @TmpParameters where [RowID] = 2)
Set @Town = (Select KeyValue from @TmpParameters where [RowID] = 3) 
Set @PlanDate = (Select KeyValue from @TmpParameters where [RowID] = 4)
Set @ActualDate = (Select KeyValue from @TmpParameters where [RowID] = 5)
Set @RefNo = (Select KeyValue from @TmpParameters where [RowID] = 6)

Declare @TmpDsTrainingDetails Table([Sl No] Int Identity(1,1), 
[DS Type] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[DS Code] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[DS Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Attended] nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,	
[Score] Decimal(18,6),[Skill Level] Int,[Active] nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)

Declare @TmpDsDetails Table
(DSTypeID Int,DsTypeName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, DsStatus Int,
SalesmanID Int, SalesmanCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SalesmanName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SalesmanStatus Int,
SkillLevel Int)

Insert Into @TmpDsDetails(DsTypeID,DsTypeName,DsStatus,
SalesmanID,SalesmanCode,SalesmanName,SalesmanStatus,SkillLevel)
select Distinct DsTypeDet.DSTypeID, DsTypeAbs.DsTypeValue, DsTypeAbs.Active,
SM.SalesmanID,SM.SalesmanCode,Sm.Salesman_Name,Sm.Active,Sm.SkillLevel 
from DSType_Details DsTypeDet, DsType_Master DsTypeAbs, Salesman SM
Where DsTypeDet.SalesmanID = SM.SalesmanID
and DsTypeAbs.DsTypeID = DsTypeDet.DsTypeID
and DsTypeAbs.dstypectlpos = 1
and SM.CategoryMapping = 1
and DsTypeAbs.Active = 1 

Insert Into @TmpDsTrainingDetails([DS Type],[DS Code],[DS Name],[Attended],[Score],
[Skill Level],[Active]) 
Select DsTypeName, SalesmanID, SalesmanName, Attended, Score, SkillLevel, Status From
(
Select DsDet.DsTypeName DsTypeName, DsDet.SalesmanID SalesmanID, DsDet.SalesmanName SalesmanName,
Case DsTrainDet.Attended When 1 Then N'Yes' Else N'No' End Attended,
DsTrainDet.Score Score, DsDet.SkillLevel SkillLevel, 
Case DsDet.SalesmanStatus When 1 Then N'Yes' Else N'No' End Status 
From tbl_mERP_DSTrainingDetail DsTrainDet, @TmpDsDetails DsDet
Where DsTrainDet.Dscode = DsDet.SalesmanID
and DSTrainDet.Town = @Town
and DsTrainDet.Facilitator = @Facilitator
and dbo.striptimefromdate(DsTRainDet.PlannedDate) = @PlanDate
and dbo.striptimefromdate(DsTrainDet.ActualDate) = @ActualDate
and DsTrainDet.DSTrainingID = @DsTRainingID
union
Select DsTypeAbs.DsTypeValue DsTypeName, SM.SalesmanID SalesmanID, SM.Salesman_Name SalesmanName,
  N'No' as Attended, NULL as Score, SM.SkillLevel, Case SM.Active When 1 Then N'Yes' Else N'No' End Status
From DsType_Master DsTypeAbs, DSType_Details DsTypeDet, Salesman SM
Where DsTypeAbs.dstypectlpos = 1
and DsTypeAbs.Active = 1 
and SM.CategoryMapping = 1
and DsTypeAbs.DsTypeID = DsTypeDet.DsTypeID 
and DsTypeDet.SalesmanID = SM.SalesmanID
and SM.SalesmanID not in (Select  DsT_det.DSCode from tbl_merp_dstrainingdetail DsT_det, tbl_merp_dstraining DsT_Abs
                          where DsT_det.DSTrainingID =  DsT_Abs.DSTraining_ID
                          And DsT_det.DSTrainingID = @DsTRainingID
                          And DsT_det.Town = @Town
                          And DsT_det.Facilitator = @Facilitator
						  And dbo.striptimefromdate(DsT_det.PlannedDate) = @PlanDate
						  And dbo.striptimefromdate(DsT_det.ActualDate) = @ActualDate )
) A
Order by DsTypeName, Attended Desc, SalesmanName, Status Desc

Select 1, [Sl No], [DS Type],[DS Code],[DS Name],[Attended],
Case IsNull([Attended],N'') When N'Yes' then [Score] Else NULL End [Score],
Case ISNull([Skill Level],0) When 0 Then NULL Else ISNull([Skill Level],0) End [Skill Level],
[Active],@RefNo as RefNo from @TmpDsTrainingDetails
Order by 2 

End
