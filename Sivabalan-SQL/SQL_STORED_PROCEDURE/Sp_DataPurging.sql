Create Procedure dbo.Sp_DataPurging
As
Begin
Set DateFormat DMY
Create Table #tmpConfig(ID Int,
Processname Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Value] int,
ProcessDate DateTime)

Declare @LastMonthEnddate as DateTime
Declare @Mydate as DateTime
Declare @Flag as Int

Declare @Max_SKUPortFolio as int

If not exists(select * from setup where isnull(fycpstatus,0)=0)
BEGIN
Set @Flag = 0
goto GoOut
End

/* Date Removing Process Included */
Exec Sp_DataRemoveProcess

set @Mydate = Getdate()
Set @Flag = 0
Set @LastMonthEnddate = (Select DateAdd(d,-1,Cast(('01/' + cast(Month(@Mydate) as Nvarchar) + '/' + cast(Year(@Mydate) as Nvarchar)) as DateTime)))


Insert Into #tmpConfig (id,Processname,[value])
Select Distinct ID,Processname,[value] From Config_DataPurging Where Isnull(Active,0) = 1 And isnull(Value,0) <> 0

Update #tmpConfig Set ProcessDate = DateAdd(d,+1,DateAdd(m,-([Value]),@LastMonthEnddate)) Where isnull(Value,0) <> 0

-- 8. Delete RFA XML Data:
If Exists(Select Top 1 'x' from tbl_merp_rfaxmlstatus where creationdate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'RFA XML Data'))
Begin
Set @Flag = 1
End
Delete from tbl_merp_rfaxmlstatus where creationdate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'RFA XML Data')

-- 9. Delete SKU Optimization Master
If Exists(Select Top 1 'x' From Recd_SKUPortfolio Where isnull(Status,0) in (1,2))
Begin
Set @Flag = 1
End
Delete From Recd_SKUPortfolio Where isnull(Status,0) in (1,2)

--	If Exists(Select Top 1 'x' from SKUPortfolio Where isnull(Active,0) = 0)
--	Begin
--		Set @Flag = 1
--	End
--	Delete from SKUPortfolio Where isnull(Active,0) = 0

Select @Max_SKUPortFolio = Max(ID) From SKUPortfolio
If Exists(Select Top 1 'x' from SKUPortfolio Where ID < @Max_SKUPortFolio)
Begin
Set @Flag = 1
End
Delete From SKUPortfolio Where ID < @Max_SKUPortFolio

If Exists(Select Top 1 'x' from WDSKUList Where isnull(Active,0) = 0)
Begin
Set @Flag = 1
End
Delete from WDSKUList Where isnull(Active,0) = 0

If Exists(Select Top 1 'x' from HMSKU Where isnull(Active,0) = 0)
Begin
Set @Flag = 1
End
Delete from HMSKU Where isnull(Active,0) = 0

-- 10. Delete SKU Optimization Data Posting
If Exists(Select Top 1 'x' from tbl_SKUOpt_Incremental Where Todate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'SKU Optimization Data Posting'))
Begin
Set @Flag = 1
End
Delete from tbl_SKUOpt_Incremental Where Todate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'SKU Optimization Data Posting')

If Exists(Select Top 1 'x' from tbl_SKUOpt_Monthly Where Todate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'SKU Optimization Data Posting'))
Begin
Set @Flag = 1
End
Delete from tbl_SKUOpt_Monthly Where Todate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'SKU Optimization Data Posting')
/*
-- 11. Delete Loyalty Score Details:
If Exists(Select Top 1 'x' from LP_ScoreDetail Where cast(('01-' + Period) as dateTime) < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'Loyalty Score Details'))
Begin
Set @Flag = 1
End
Delete from LP_ScoreDetail Where cast(('01-' + Period) as dateTime) < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'Loyalty Score Details')

-- 12. Delete Loyalty Tgt vs Ach Details:
If Exists(Select Top 1 'x' from LP_AchievementDetail Where TargetFrom < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'Loyalty Tgt vs Ach Details'))
Begin
Set @Flag = 1
End
Delete from LP_AchievementDetail Where TargetFrom < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'Loyalty Tgt vs Ach Details')

if exists(select * from sys.columns where name='ProgramType' and object_id =(select id from sysobjects where xtype='u' and name ='LP_ItemCodeMap'))
Begin
If Exists(Select Top 1 'x' From LP_ItemCodeMap Where ID Not In(
select P.ID from LP_ItemCodeMap P, LP_AchievementDetail A
Where P.ProductScope =  A.ProductScope
And P.Period = A.Period
And P.Program_Type = A.Program_Type))
Begin
Set @Flag = 1
End
Delete From LP_ItemCodeMap Where ID Not In(
select P.ID from LP_ItemCodeMap P, LP_AchievementDetail A
Where P.ProductScope =  A.ProductScope
And P.Period = A.Period
And P.Program_Type = A.Program_Type)
End
Else
Begin
If Exists(Select Top 1 'x' From LP_ItemCodeMap Where ID Not In(
select P.ID from LP_ItemCodeMap P, LP_AchievementDetail A
Where P.ProductScope =  A.ProductScope
And P.Period = A.Period))
Begin
Set @Flag = 1
End
Delete From LP_ItemCodeMap Where ID Not In(
select P.ID from LP_ItemCodeMap P, LP_AchievementDetail A
Where P.ProductScope =  A.ProductScope
And P.Period = A.Period)

End
*/
-- 13. Delete Loyalty Data Posting:
If Exists(Select Top 1 'x' from LPCustomerScore Where Dayclose < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'Loyalty Data Posting'))
Begin
Set @Flag = 1
End
Delete from LPCustomerScore Where Dayclose < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'Loyalty Data Posting')
--13a.Delete LP Log
If exists(Select Top 1 'x' from LPLog where period not in (select isnull(period,'') from LP_AchievementDetail))
Begin
Set @Flag=1
End
Delete from LPLog where period not in (select isnull(period,'') from LP_AchievementDetail)

--14. Delete HH CFT Data:
If Exists(Select Top 1 'x' from DS_TimeSpent Where CALL_DATE < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'HH CFT Data'))
Begin
Set @Flag = 1
End
Delete from DS_TimeSpent Where CALL_DATE < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'HH CFT Data')

-- 15. Delete HH Survey Detailed Data:
If Exists(Select Top 1 'x' from DSSurveyDetails Where Uploaddate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'HH Survey Detailed Data'))
Begin
Set @Flag = 1
End
Delete from DSSurveyDetails Where Uploaddate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'HH Survey Detailed Data')

-- 16. Delete Document Exchange Tracker
If Exists(Select Top 1 'x' From tbl_merp_UploadReportTracker Where ReportTodate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'Document Exchange Tracker'))
Begin
Set @Flag = 1
End
Delete From tbl_merp_UploadReportTracker Where ReportTodate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'Document Exchange Tracker')

If Exists(Select Top 1 'x' From tbl_mERP_UploadReportXMLTracker Where ReportDocID not In (Select Distinct ReportDocID from tbl_merp_UploadReportTracker))
Begin
Set @Flag = 1
End
Delete From tbl_mERP_UploadReportXMLTracker Where ReportDocID not In (Select Distinct ReportDocID from tbl_merp_UploadReportTracker)
/*
-- 17. Delete GGRR Masters:
If Exists(Select Top 1 'x' from GGDROutlet Where cast(('01-' + Todate) as dateTime) < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'GGRR Masters'))
Begin
Set @Flag = 1
End
Delete from GGDROutlet Where cast(('01-' + Todate) as dateTime) < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'GGRR Masters')

If Exists(Select Top 1 'x' from GGDRProduct Where ProdDefnID Not in (Select Distinct ProdDefnID from GGDROutlet))
Begin
Set @Flag = 1
End
Delete from GGDRProduct Where ProdDefnID Not in (Select Distinct ProdDefnID from GGDROutlet)

If Exists(Select Top 1 'x' from TmpGGDRSKUDetails Where ProdDefnID Not in (Select Distinct ProdDefnID from GGDROutlet))
Begin
Set @Flag = 1
End
Delete from TmpGGDRSKUDetails Where ProdDefnID Not in (Select Distinct ProdDefnID from GGDROutlet)

-- 18. Delete GGRR Data Posting:
If Exists(Select Top 1 'x' from GGDRData Where InvoiceDate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'GGRR Data Posting'))
Begin
Set @Flag = 1
End
Delete from GGDRData Where InvoiceDate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'GGRR Data Posting')
*/
If Exists(Select Top 1 'x' From GGRRFinalData Where [Month] Not in (Select Distinct Fromdate [Month] From GGDROutlet Union Select Distinct Todate [Month] From GGDROutlet))
Begin
Set @Flag = 1
End
Delete From GGRRFinalData Where [Month] Not in (Select Distinct Fromdate [Month] From GGDROutlet Union Select Distinct Todate [Month] From GGDROutlet)

If Exists(Select Top 1 'x' from LP_RecdScoreDetail Where isnull(Status,0) in (1,2))
Begin
Set @Flag = 1
End
Delete from LP_RecdScoreDetail Where isnull(Status,0) in (1,2)

If Exists(Select Top 1 'x' from LP_RecdAchievementDetail Where isnull(Status,0) in (1,2))
Begin
Set @Flag = 1
End
Delete from LP_RecdAchievementDetail Where isnull(Status,0) in (1,2)

If Exists(Select Top 1 'x' From tbl_mERP_CatHandler_Log Where CreationDate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'CatHandler_Log'))
Begin
Set @Flag = 1
End
Delete From tbl_mERP_CatHandler_Log Where CreationDate < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'CatHandler_Log')

If Exists(Select Top 1 'x' From Order_Header Where Order_Date < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'HH Order Header'))
Begin
Set @Flag = 1
Delete From Order_Details Where ordernumber in (select ordernumber from Order_Header where order_Date < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'HH Order Header')  )
Delete From Order_Header Where Order_DATE < (Select Top 1 ProcessDate From #tmpConfig Where ProcessName = 'HH Order Header')
End


GoOut:

Drop Table #tmpConfig

Update ValidateDataPurging Set Status = 1,Modifydate = Getdate() Where Isnull(Status,0) = 0

/* After Completer First level data Purging the Flag Value set as 7 : Default value for Data Purging day close Validation Changes */
IF Exists(Select Top 1 'x' From Tbl_Merp_ConfigAbstract Where Screencode = 'DATAPURGE' And Isnull(Flag,0) = -1)
Begin
Update Tbl_Merp_ConfigAbstract Set Flag = 7 Where Screencode = 'DATAPURGE' And Isnull(Flag,0) = -1
Set @Flag = 1
End
Select @Flag Flag
END
