CREATE Procedure Spr_SurveyReport    
(    
 @SurveyName nVarchar(255),    
 @DSName nVarchar(30),    
 @Beat nVarchar(30),    
 @Customer nVarchar(30),    
 @FromDate DateTime,    
 @ToDate DateTime    
)    
As    
Begin    
 SET DATEFORMAT DMY    
 Declare @CompaniesToUploadCode nVarchar(255)     
 Declare @WDCode nVarchar(255)      
 Declare @WDDest nVarchar(255)     
    
 Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload        
 Select Top 1 @WDCode = RegisteredOwner From Setup          
         
 If @CompaniesToUploadCode='ITC001'        
  Set @WDDest= @WDCode        
 Else        
 Begin        
  Set @WDDest= @WDCode        
  Set @WDCode= @CompaniesToUploadCode        
 End        
    
  Declare @Delimeter Char(1)        
  Set @Delimeter = Char(15)       
      
  Create Table #TempSurvey(SurveyName nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)        
  Create Table #TempDS(SalesmanName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
  Create Table #TempBeat(BeatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
  Create Table #TempCustomer(CustomerName nVarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS)     
    
  If @SurveyName = N'%'        
  Insert into #TempSurvey Select [SurveyDescription] From tbl_merp_SurveyMaster    
  else        
  Insert into #TempSurvey Select * From Dbo.sp_SplitIn2Rows(@SurveyName, @Delimeter)      
    
  If @DSName = N'%'        
  Insert into #TempDS Select Salesman_Name From Salesman        
  else        
  Insert into #TempDS Select * From Dbo.sp_SplitIn2Rows(@DSName, @Delimeter)      
    
  If @Beat = N'%'        
  Insert into #TempBeat Select Description From Beat        
  else        
  Insert into #TempBeat Select * From Dbo.sp_SplitIn2Rows(@Beat, @Delimeter)      
    
  If @Customer = N'%'        
  Insert into #Tempcustomer Select company_Name From Customer    
  else        
  Insert into #Tempcustomer Select * From Dbo.sp_SplitIn2Rows(@Customer, @Delimeter)     
    
   
 Create table #SurveyDetails    
 (    
 [SurveyCode] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [WDCode] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [WDDest]nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [FromDate] datetime,    
 [ToDate] dateTime,    
 [Target Outlet Count] int,    
 [Completed Outlet Count] int,     
 [Pending Outlet Count] int,     
 [DSID] nvarchar(60) COLLATE SQL_Latin1_General_CP1_CI_AS,     
 [DS Name] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [DS Type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [SupervisorID] int,    
 [Supervisor Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [Supervisor Type] nvarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [CustomerID]nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [Customer Name] nvarchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [Channel Type] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [Outlet Type] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [Loyalty Program] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [SurveyID] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [Survey Name] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [Survey Type] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [ProductID] nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [Product Name] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [QuestionID] int,    
 [Question] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [AnswerID] int,    
 [AnswerValue] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 [UploadDate] datetime)     
    
Create table #temp(SurveyCode nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,DSID int,CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)

insert into #temp
select distinct SM.SurveyCode,DD.SalesmanID As DSID,BS.CustomerID from tbl_merp_SurveyDSMapping DS
join tbl_merp_SurveyMaster SM on SM.SurveyID=DS.SurveyID
join DSType_Master DM on isnull(DM.DSTypeValue,'')=DS.DSType
join DSType_Details DD on isnull(DD.DSTypeId,0)=DM.DSTypeId
join Beat_Salesman BS on cast(isnull(BS.SalesmanID,0) as nvarchar(60)) =isnull(DD.SalesmanID,'')
join Salesman S on isnull(BS.SalesmanID,0)=S.SalesmanID
join Customer C on C.CustomerID=BS.CustomerID
WHERE BS.CustomerID in (select OCM.CustomerID from tbl_merp_SurveyMaster ,tbl_mERP_OLClass OC,tbl_merp_SurveyChannelMapping SCM,tbl_mERP_OLClassMapping OCM
where isnull(OC.Channel_Type_Desc,'')=SCM.ChannelType
and isnull(OC.Outlet_Type_Desc,'')=SCM.OutletType
and isnull(OC.SubOutlet_Type_Desc,'')=SCM.LoyaltyProgram
and OC.ID=isnull(OCM.OLClassID,0)
and SM.SurveyID=SCM.SurveyID
and OCM.Active=1
and OC.Channel_Type_Active=1
and OC.Outlet_Type_Active=1
and OC.SubOutlet_Type_Active=1)
--and SM.Active=1
--and DM.Active=1
--and S.Active=1
and C.Active=1


 INSERT INTO #SurveyDetails (    
 [SurveyCode],    
 [Target Outlet Count],    
 [Completed Outlet Count],    
 [DSID],     
 [DS Name],    
 [DS Type],    
-- [SupervisorID],    
-- [Supervisor Name] ,    
-- [Supervisor Type],    
 [CustomerID],    
 [Customer Name],    
 [Channel Type],    
 [Outlet Type],    
 [Loyalty Program],    
 [SurveyID],    
 [Survey Name],    
 [Survey Type],    
 [ProductID],    
 [Product Name],    
 [QuestionID],    
 [Question],    
 [AnswerID],    
 [AnswerValue],    
 [UploadDate])    
     
 Select     
 SM.Surveycode,    
 (Select count(distinct isnull(#temp.CustomerID,'')) from #temp
  Where #temp.SurveyCode= SM.SurveyCode
  And #temp.DSID= S.SalesmanId
),    
 (select count(isnull(T.surveyID,'') ) from 
 (Select * from dbo.Fn_SurveyOutletmapping_Report()) T where isnull(T.SurveyID,'') = SurDet.SurveyID
  And T.DSID = S.SalesmanId
  and T.status=1),     
 S.SalesmanId as [DSID],    
 S.Salesman_Name as [DS Name],    
    DSM.DSType as [DS Type],    
-- S2.SalesmanID [SupervisorID],    
-- S2.SalesmanName as [Supervisor Name],    
-- SupType.TypeDesc as [Supervisor Type],    
 C.CustomerID as [CustomerID],    
 C.Company_Name as [Customer Name],    
 OLC.Channel_Type_Desc as [Channel Type],    
 OLC.Outlet_Type_Desc as [Outlet Type],    
 OLC.SubOutlet_Type_Desc as [Loyalty Program],    
 SM.SurveyCode as [SurveyID],    
 SM.SurveyDescription as [Survey Name],    
 (case SM.SurveyType When 'P' then 'Product' else 'General' end)as [Survey Type],    
 PM.ProductId as [ProductID],    
 PM.ProductName as [Product Name],    
 Ques.QuestionID as [QuestionID],    
    Ques.QuestionDesc as [Question],    
 SurDet.AnswerID as [AnswerID],    
 SurDet.AnswerValue as [AnswerValue],    
 SurDet.uploadDate as [UploadDate]     
     
 from Salesman S    
 Inner Join DSSurveyDetails SurDet On isnull(SurDet.DSID,'') = S.SalesmanID    
 Inner Join tbl_merp_SurveyMaster SM On isnull(SM.SurveyCode,'') = isnull(SurDet.SurveyID,'')        
 Left Outer Join tbl_merp_SurveyProductMapping PM On isnull(SM.SurveyID,0) = isnull(PM.SurveyID,0) And PM.ProductID = isnull(SurDet.ProductID,'')          
 Inner Join tbl_merp_SurveyQuestionMapping Ques  On isnull(Ques.SurveyID,0)= isnull(SM.SurveyID,0) and isnull(Ques.QuestionID,0)= isnull(SurDet.QuestionID,0)    
 Inner Join Customer C On isnull(SurDet.CustomerID,'') = isnull(C.CustomerID,'')    
 Inner Join tbl_merp_SurveyChannelMapping ChannelMap On isnull(ChannelMap.SurveyID,0) =isnull(SM.SurveyID,0)    
 Inner Join tbl_mERP_OLClass OLC On  isnull(OLC.Channel_Type_Desc,'') = isnull(ChannelMap.ChannelType,'') and isnull(OLC.Outlet_Type_Desc,'')=isnull(ChannelMap.OutletType ,'') and isnull(OLC.SubOutlet_Type_Desc,'')=isnull(ChannelMap.LoyaltyProgram,'')   
 Inner Join tbl_mERP_OLClassMapping OLCM On OLCM.CustomerID=C.CustomerID and isnull(OLC.ID,0) = isnull(OLCM.OLClassID,0)       
 Inner Join tbl_merp_SurveyDSMapping DSM On isnull(SM.SurveyID,0) =isnull(DSM.SurveyID,0)        
-- tbl_merp_SurveyQuestionAnswerMapping QuesA,    
 Inner Join DSType_Master DSMaster On isnull(DSMaster.DSTypeValue,'')=isnull(DSM.DSType,'')        
 --Salesman2 S2,    
-- tbl_mERP_SupervisorSalesman SManLink,    
-- tbl_merp_SupervisorType SupType,    
 Inner Join Beat_salesman B_S On isnull(S.SalesmanID,0) =isnull(B_S.SalesmanID,0)        
 Inner Join Beat B On isnull(B.BeatID,0) = isnull(B_S.BeatID,0) And isnull(C.CustomerID,'') = isnull(B_S.CustomerID,'')    
 Inner Join DSType_Details DSType On isnull(DSType.SalesmanID,0) = isnull(S.SalesmanID,0) And isnull(DSType.DSTypeID,0) =  isnull(DSMaster.DSTypeID,0)            
 Where     
 dbo.stripdatefromtime(SurDet.Uploaddate) between @fromdate and @Todate    
-- And isnull(SM.Active,0) = 1    
 And SM.SurveyType = 'P'    
 And isnull(SM.[SurveyDescription],'') in(Select isnull(SurveyName,'') from #TempSurvey)    
 And isnull(S.Salesman_Name,'') in (Select isnull(SalesmanName,'') from #TempDS)    
 And isnull(B.Description,'') in (Select isnull(BeatName,'') from #TempBeat)    
 And isnull(C.Company_name,'') in (Select isnull(CustomerName,'') from #Tempcustomer)    
 --And isnull(S2.SalesmanID,0) *= isnull(SManLink.SupervisorID,0)    
 --And isnull(S.SalesmanID,0) *=isnull(SManLink.SalesmanID,0)    
 --And isnull(SupType.TypeID,0) =isnull(S2.TypeID,0)    
 And isnull(C.CustomerID,'') in (select isnull(CustomerID,'') from tbl_mERP_OLClass OC,tbl_merp_SurveyChannelMapping SCM,tbl_mERP_OLClassMapping OCM,tbl_merp_SurveyMaster    
 where isnull(OC.Channel_Type_Desc,'') = isnull(SCM.ChannelType,'')    
  and isnull(SCM.SurveyID,0) = isnull(SM.SurveyID,0)    
  and isnull(OC.Outlet_Type_Desc,'')=isnull(SCM.OutletType ,'')    
  and isnull(OC.SubOutlet_Type_Desc,'')=isnull(SCM.LoyaltyProgram,'')    
  and isnull(OC.ID,0) = isnull(OLCM.OLClassID,0)
  and OC.Channel_Type_Active=1
  and OC.Outlet_Type_Active=1
  and OC.SubOutlet_Type_Active=1) And isnull(OLCM.Active,0) = 1
-- and OLC.Channel_Type_Active=1
-- and OLC.Outlet_Type_Active=1
-- and OLC.SubOutlet_Type_Active=1
-- And isnull(QuesA.SurveyID,0) = isnull(SM.SurveyID,0)    
-- And isnull(Ques.QuestionID,0)= isnull(QuesA.QuestionID,0)    
-- and isnull(SurDet.AnswerID,0) *= isnull(QuesA.AnswerID,0)    
 union    
    
 Select     
 SM.Surveycode,    
 (Select count(distinct isnull(#temp.CustomerID,'')) from #temp
  Where #temp.SurveyCode= SM.SurveyCode
  And #temp.DSID= S.SalesmanId
),       
  (select count(isnull(T.surveyID,'') ) from 
 (Select * from dbo.Fn_SurveyOutletmapping_Report()) T where isnull(T.SurveyID,'') = SurDet.SurveyID 
  and T.status=1
  And T.DSID = S.SalesmanId
),     
 S.SalesmanId as [DSID],    
 S.Salesman_Name as [DS Name],    
    DSM.DSType as [DS Type],    
-- S2.SalesmanID [SupervisorID],    
-- S2.SalesmanName as [Supervisor Name],    
-- SupType.TypeDesc as [Supervisor Type],    
 C.CustomerID as [CustomerID],    
 C.Company_Name as [Customer Name],    
 OLC.Channel_Type_Desc as [Channel Type],    
 OLC.Outlet_Type_Desc as [Outlet Type],    
 OLC.SubOutlet_Type_Desc as [Loyalty Program],  
 SM.SurveyCode as [SurveyID],    
 SM.SurveyDescription as [Survey Name],    
 (case SM.SurveyType When 'P' then 'Product' else 'General' end)as [Survey Type],    
 PM.ProductId as [ProductID],    
 PM.ProductName as [Product Name],    
 Ques.QuestionID as [QuestionID],    
    Ques.QuestionDesc as [Question],    
 SurDet.AnswerID as [AnswerID],    
 SurDet.AnswerValue as [AnswerValue],    
 SurDet.uploadDate as [UploadDate]     
     
 from Salesman S    
 Inner Join DSSurveyDetails SurDet On isnull(SurDet.DSID,'') = S.SalesmanID    
 Inner Join tbl_merp_SurveyMaster SM On isnull(SM.SurveyCode,'') = isnull(SurDet.SurveyID,'')    
 Left Outer Join tbl_merp_SurveyProductMapping PM On  isnull(SM.SurveyID,0) = isnull(PM.SurveyID,0)        
 Inner Join tbl_merp_SurveyDSMapping DSM On isnull(SM.SurveyID,0) =isnull(DSM.SurveyID,0)        
 Inner Join tbl_merp_SurveyChannelMapping ChannelMap On isnull(ChannelMap.SurveyID,0) =isnull(SM.SurveyID,0)        
-- tbl_merp_SurveyQuestionAnswerMapping QuesA,    
 Inner Join tbl_merp_SurveyQuestionMapping Ques On isnull(Ques.SurveyID,0)= isnull(SM.SurveyID,0) and isnull(Ques.QuestionID,0)= isnull(SurDet.QuestionID,0)           
 Inner Join Customer C On isnull(SurDet.CustomerID,'') = isnull(C.CustomerID,'')        
 Inner Join tbl_mERP_OLClass OLC On isnull(OLC.Channel_Type_Desc,'') = isnull(ChannelMap.ChannelType,'') and isnull(OLC.Outlet_Type_Desc,'')=isnull(ChannelMap.OutletType ,'') and isnull(OLC.SubOutlet_Type_Desc,'')=isnull(ChannelMap.LoyaltyProgram,'')              
 Inner Join tbl_mERP_OLClassMapping OLCM On isnull(OLC.ID,0) = isnull(OLCM.OLClassID,0) And OLCM.CustomerID=C.CustomerID       
 Inner Join DSType_Master DSMaster On isnull(DSMaster.DSTypeValue,'')=isnull(DSM.DSType,'')        
 Inner Join Beat_salesman B_S On isnull(S.SalesmanID,0) =isnull(B_S.SalesmanID,0) And isnull(C.CustomerID,'') = isnull(B_S.CustomerID,'')       
 Inner Join Beat B On isnull(B.BeatID,0) = isnull(B_S.BeatID,0)       
 --Salesman2 S2,    
-- tbl_mERP_SupervisorSalesman SManLink,    
-- tbl_merp_SupervisorType SupType,    
 Inner Join DSType_Details DSType On isnull(DSType.SalesmanID,0) = isnull(S.SalesmanID,0) And isnull(DSType.DSTypeID,0) =  isnull(DSMaster.DSTypeID,0)           
 Where       
 dbo.stripdatefromtime(SurDet.Uploaddate) between @fromdate and @Todate    
-- And isnull(SM.Active,0) = 1    
 And SM.SurveyType = 'Q' 
 And isnull(SM.[SurveyDescription],'') in(Select isnull(SurveyName,'') from #TempSurvey)    
 And isnull(S.Salesman_Name,'') in (Select isnull(SalesmanName,'') from #TempDS)    
 And isnull(B.Description,'') in (Select isnull(BeatName,'') from #TempBeat)    
 And isnull(C.Company_name,'') in (Select isnull(CustomerName,'') from #Tempcustomer)    
 --And isnull(S2.SalesmanID,0) *= isnull(SManLink.SupervisorID,0)    
 --And isnull(S.SalesmanID,0) *=isnull(SManLink.SalesmanID,0)    
 --And isnull(SupType.TypeID,0) =isnull(S2.TypeID,0)    
 And isnull(C.CustomerID,'') in (select isnull(CustomerID,'') from tbl_mERP_OLClass OC,tbl_merp_SurveyChannelMapping SCM,tbl_mERP_OLClassMapping OCM,tbl_merp_SurveyMaster    
  where isnull(OC.Channel_Type_Desc,'') = isnull(SCM.ChannelType,'')    
  and isnull(SCM.SurveyID,0) = isnull(SM.SurveyID,0)    
  and isnull(OC.Outlet_Type_Desc,'')=isnull(SCM.OutletType ,'')    
  and isnull(OC.SubOutlet_Type_Desc,'')=isnull(SCM.LoyaltyProgram,'')    
  and isnull(OC.ID,0) = isnull(OLCM.OLClassID,0)
  and OC.Channel_Type_Active=1
  and OC.Outlet_Type_Active=1
  and OC.SubOutlet_Type_Active=1)  
  And isnull(OLCM.Active,0) = 1
-- and OLC.Channel_Type_Active=1
-- and OLC.Outlet_Type_Active=1
-- and OLC.SubOutlet_Type_Active=1
-- And isnull(QuesA.SurveyID,0) = isnull(SM.SurveyID,0)    
 --And isnull(Ques.QuestionID,0)= isnull(QuesA.QuestionID,0)    
-- and isnull(SurDet.AnswerID,0) *= isnull(QuesA.AnswerID,0)    
      
 update #SurveyDetails set [WDCode] = @Wdcode,[WDDest] = @WDDest,[FromDate]=@fromDate,[ToDate]=@Todate    
    
 update #SurveyDetails set [Pending Outlet Count] = isnull([Target Outlet Count],0) - isnull([Completed Outlet Count],0)    
     

 update #SurveyDetails set [SupervisorID] = T.SalesmanID,    
 [Supervisor Name] = T.SalesmanName,    
 [Supervisor Type] = T.TypeDesc    
 From 
 (Select distinct min(S2.SalesmanID) [SalesmanID],S2.SalesmanName,SupType.TypeDesc,SManLink.SalesmanID [SID]  
 From Salesman2 S2,
 tbl_mERP_SupervisorSalesman SManLink,
 tbl_merp_SupervisorType SupType, 
 #SurveyDetails Temp    
 Where isnull(SupType.TypeID,0) =isnull(S2.TypeID,0)    
 And S2.Active = 1    
 And Temp.[DSID]= SManlink.SalesmanID        
 And S2.SalesmanID = SManlink.SupervisorID
 group by S2.SalesmanName,SupType.TypeDesc,SManLink.SalesmanID
) T
 Where T.SID=#SurveyDetails.DSID
 
 --To update Pending Outlet Count value as Zero if it has negative Value (ITC UAT point)
 update #SurveyDetails set [Pending Outlet Count] = 0 where [Pending Outlet Count] < 0
     
 Select distinct SurveyCode, [WDCode],[WDDest],[FromDate],[ToDate],[Target Outlet Count],    
 [Completed Outlet Count],    
 [Pending Outlet Count],    
 [DSID],     
 [DS Name],    
 [DS Type],    
 [SupervisorID],    
 [Supervisor Name] ,    
 [Supervisor Type],    
 [CustomerID],    
 [Customer Name],    
 [Channel Type],    
 [Outlet Type],    
 [Loyalty Program],    
 [SurveyID],    
 [Survey Name],    
 [Survey Type],    
 [ProductID],    
 [Product Name],    
 [QuestionID],    
 [Question],    
 [AnswerID],    
 [AnswerValue],    
 [UploadDate] from #SurveyDetails order by [SurveyID], [Customer Name],[UploadDate]     
    
 Drop Table #SurveyDetails    
 Drop table #TempSurvey    
 Drop table  #TempDS    
 Drop table  #TempBeat    
 Drop table  #TempCustomer    
 drop table #temp    

END 
