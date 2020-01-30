CREATE PROCEDURE mERP_spr_DSTraining_Abstract(@TrainingName nVarchar(2550),
@GivenDate datetime)
As
Begin
Declare @Delimiter as Char(1)
Set @Delimiter = Char(15)

Declare @WDCode NVarchar(255),@WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)
Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload        
Select Top 1 @WDCode = RegisteredOwner From Setup          
        
If @CompaniesToUploadCode='ITC001'        
Begin        
 Set @WDDest= @WDCode        
End        
Else        
Begin        
 Set @WDDest= @WDCode        
 Set @WDCode= @CompaniesToUploadCode        
End 

Declare @TmpTrainingDetails Table(TrainingName nvarchar(2550) COLLATE SQL_Latin1_General_CP1_CI_AS, Active Int)

If @TrainingName = N'%'
Begin
 Insert Into @TmpTrainingDetails
 Select DSTraining_Name,DSTraining_Active from tbl_mERP_DSTraining
End
Else
Begin
 Insert Into @TmpTrainingDetails
 Select DSTraining_Name,DSTraining_Active from tbl_mERP_DSTraining
 Where DSTraining_Name in (Select * from dbo.sp_splitin2Rows(@TrainingName,@Delimiter))
End

Create Table #tmpAbstract (
ID Int Identity (1,1),
DsTraining_ID Int,
DsTraining_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
DsTraining_Name nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
Facilitator nvarchar(550) COLLATE SQL_Latin1_General_CP1_CI_AS,
PlannedDate DateTime,
ActualDate DateTime,
Town nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Attended Int
) 

Insert into #tmpAbstract(DsTraining_ID, DsTraining_Code,DsTraining_Name,Facilitator,PlannedDate,ActualDate,Town,Attended)
Select DstAbs.DsTraining_ID, DstAbs.DsTraining_Code, DstAbs.DsTraining_Name, DstDet.Facilitator, DstDet.PlannedDate,
DstDet.ActualDate, DstDet.Town, Sum(Case IsNull(DstDet.Attended,0) When 0 then 0 else 1 End)
From tbl_mERP_DSTraining DstAbs, tbl_mERP_DSTrainingDetail DstDet
Where DstAbs.DSTraining_ID = DstDet.DsTrainingID And 
  DstAbs.DSTraining_Name in (Select TrainingName from @TmpTrainingDetails) And 
  dbo.striptimefromdate(DstDet.ActualDate) <= @GivenDate
Group by DstAbs.DsTraining_ID, DstAbs.DsTraining_Code, DstAbs.DsTraining_Name, DstDet.Facilitator, DstDet.PlannedDate,
DstDet.ActualDate, DstDet.Town
Order by DstDet.ActualDate, DstAbs.DsTraining_Name

Select Cast(tmp.DsTraining_ID as nVarchar(10))+ Char(15) + tmp.Facilitator + Char(15) +
tmp.Town + Char(15) + cast(dbo.striptimefromdate(tmp.PlannedDate) as Varchar) + Char(15)
+ cast(dbo.striptimefromdate(tmp.ActualDate) as Varchar)+ Char(15) + Cast(tmp.ID as nVarchar(10)), 
"WDCode"=@WDCode, "WDDest"=@WDDest,
"To Date" = dbo.striptimefromdate(@GivenDate),
"Training Code" = tmp.DsTraining_Code,
"Training Name" = tmp.DsTraining_Name,
"Facilitator" = tmp.Facilitator,
"Plan Date" = dbo.striptimefromdate(tmp.PlannedDate),
"Actual Date" = dbo.striptimefromdate(tmp.ActualDate),
"Town" = tmp.Town,
"No of Participant" = tmp.Attended,
"No of Active DS" = ( select Count(Distinct SM.SalesmanID) 
                      From Salesman SM, DSType_Details DsTypeDet, DsType_Master DsTypeAbs
                      Where DsTypeAbs.DsTypeID = DsTypeDet.DsTypeID and 
                             SM.SalesmanID =DsTypeDet.SalesmanID and 
                             SM.Active= 1 and 
                             DsTypeAbs.Active = 1 and
                             SM.CategoryMapping = 1 and 
                             DsTypeAbs.DSTypeCtlPos = 1),
"RefNo" = tmp.ID
From #tmpAbstract tmp
Order By tmp.ID

Drop table #tmpAbstract

End
