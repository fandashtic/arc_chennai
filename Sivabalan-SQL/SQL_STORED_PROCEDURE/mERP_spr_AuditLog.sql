Create Procedure mERP_spr_AuditLog(@FromDate DateTime,@ToDate DateTime)  
As  
Begin  
 Declare @WDCode NVarchar(255)    
 Declare @WDDest NVarchar(255)    
 Declare @CompaniesToUploadCode NVarchar(255)    
  
 Declare @WD_CODE nVarChar(50)    
 Declare @SUBTOTAL NVarchar(50)      
 Declare @GRNTOTAL NVarchar(50)      
    
  
  
 Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)       
 Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)       
 Set @WD_CODE = dbo.LookupDictionaryItem(N'WD Code', Default)   
  
 Create Table #tmpAudit(AEModuleID Int,[WD Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [WD Dest] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [From Date] DateTime,[To Date] Datetime,  
         [Updated Through] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         Menu nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [User Name] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         --[Activity Date And Time] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Activity Date And Time] Datetime,  
         [Customer ID] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Customer Name] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Channel Type] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Outlet Type] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Loyalty Program] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Customer Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Active/InActive] nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Active In RCS] nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Remarks] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Change Description] nVarchar(255) ,  
		 [Base GOI Market ID] int,   
		 [Base GOI Market Name] [nvarchar](2000)COLLATE SQL_Latin1_General_CP1_CI_AS,
		 [Outlet Creation Date] DateTime,
		 [RCSID] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)

 Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload      
 Select Top 1 @WDCode = RegisteredOwner From Setup        
      
 If @CompaniesToUploadCode='ITC001'      
  Set @WDDest= @WDCode      
 Else      
 Begin      
  Set @WDDest = @WDCode      
  Set @WDCode = @CompaniesToUploadCode      
 End  
 /*Outlet Classification*/     
 Insert Into #tmpAudit  
 Select AELog.AEModuleID,@WDCode,@WDDest,@FromDate,@ToDate,  
   (Case isNull(Login_Type,1) When 1 Then N'Restricted Login' When 2 Then N'WD Login' End), N'Outlet Classification' ,  
   AELog.AEUserName,ActivityTimeStamp,C.CustomerID,C.Company_Name,OLClass.Channel_Type_Desc,OLClass.Outlet_Type_Desc,  
   SubOutlet_Type_Desc,CC.ChannelDesc,(Case C.Active When 1 Then N'Yes' Else N'No' End),  
   isNull((Select isNull(TMDValue,'No') From Cust_TMD_Master Where TMDID =     
   (Select TMDID From Cust_TMD_Details Where TMDCtlPos = 3 And CustomerID = C.CustomerID)),Case When Len(isnull(C.RCSOutletID,'')) >= 1 Then 'Yes' Else 'No' end) ,   
   '',AELog.TaskName ,Null,Null 
   , C.CreationDate, IsNull(C.RCSOutletID,'')
   
 From   
   tbl_mERP_AEAuditLog AELog
  Inner Join tbl_mERP_AEActivity AEAct  on AELog.AEActivityID = AEAct.ID 
  Inner Join tbl_mERP_OLClassMapping OLMap on OLMap.AEAuditLogID = AELog.ID 
  Inner Join tbl_mERP_OLClass OLClass On OLClass.ID = OLMap.OLClassID
  Inner Join Customer C on C.CustomerID = OLMap.CustomerID
  Left Outer Join Customer_Channel CC on C.ChannelType = CC.ChannelType 
 Where   
  dbo.StripTimeFromDate(AEAct.ActivityTimeStamp) Between @FromDate And @ToDate  
  --And AELog.AEActivityID = AEAct.ID  
  And AEAct.AEModuleID In(1)  
  And OLMap.Active = 1  
  --And OLMap.AEAuditLogID = AELog.ID  
  --And OLClass.ID = OLMap.OLClassID  
  --And C.CustomerID = OLMap.CustomerID  
  --And C.ChannelType *= CC.ChannelType   
   
 Union  
    /*Active/Deactive*/  
 Select AELog.AEModuleID,@WDCode,@WDDest,@FromDate,@ToDate,  
   (Case isNull(Login_Type,1) When 1 Then N'Restricted Login' When 2 Then N'WD Login' End), N'Active/Deactive' ,  
   AELog.AEUserName,ActivityTimeStamp,C.CustomerID,C.Company_Name,  
            '' as 'Channel_Type_Desc','' as 'Outlet_Type_Desc', '' as  'SubOutlet_Type_Desc',  
            CC.ChannelDesc,(Case CustActive.Active When 1 Then N'Yes' Else N'No' End),  
   isNull((Select isNull(TMDValue,'No') From Cust_TMD_Master Where TMDID =     
   (Select TMDID From Cust_TMD_Details Where TMDCtlPos = 3 And CustomerID = C.CustomerID)),Case When Len(isnull(C.RCSOutletID,'')) >= 1 Then 'Yes' Else 'No' end) ,   
   CustActive.Remarks,AELog.TaskName  ,Null,Null 
   , C.CreationDate, IsNull(C.RCSOutletID,'')
  
 From   
    tbl_mERP_AEAuditLog AELog 
  Inner Join tbl_mERP_AEActivity AEAct on AELog.AEActivityID = AEAct.ID
  Inner Join tbl_mERP_CustActiveDeactive CustActive On   CustActive.AEAuditLogID = AELog.ID
  Inner Join Customer C on C.CustomerID = CustActive.CustomerID 
  Left Outer Join tbl_mERP_OLClassMapping OLMap On C.CustomerID = OLMap.CustomerID
  Left Outer Join Customer_Channel CC on C.ChannelType = CC.ChannelType 
  
 Where   
  dbo.StripTimeFromDate(AEAct.ActivityTimeStamp) Between @FromDate And @ToDate  
  --And AELog.AEActivityID = AEAct.ID  
  And AEAct.AEModuleID In(3)  
  And OLMap.Active = 1  
  --And CustActive.AEAuditLogID = AELog.ID  
  --And OLClass.ID = OLMap.OLClassID  
  --And C.CustomerID *= OLMap.CustomerID  
  --And C.ChannelType *= CC.ChannelType   
  --And C.CustomerID = CustActive.CustomerID  
    /*Category Handler*/  
 Union  
  Select AELog.AEModuleID,@WDCode,@WDDest,@FromDate,@ToDate,  
   (Case isNull(Login_Type,1) When 1 Then N'Restricted Login' When 2 Then N'WD Login' End), N'Category Handler' ,  
   AELog.AEUserName,ActivityTimeStamp,C.CustomerID,C.Company_Name,  
            '' as 'Channel_Type_Desc','' as 'Outlet_Type_Desc', '' as  'SubOutlet_Type_Desc',  
            CC.ChannelDesc,(Case C.Active When 1 Then N'Yes' Else N'No' End),  
   isNull((Select isNull(TMDValue,'No') From Cust_TMD_Master Where TMDID =     
   (Select TMDID From Cust_TMD_Details Where TMDCtlPos = 3 And CustomerID = C.CustomerID)),Case When Len(isnull(C.RCSOutletID,'')) >= 1 Then N'Yes' Else N'No' end) , N'',AELog.TaskName ,Null,Null  
   , C.CreationDate, IsNull(C.RCSOutletID,'')
 From    
  tbl_mERP_AEAuditLog AELog
  Inner Join tbl_mERP_AEActivity AEAct on AELog.AEActivityID = AEAct.ID 
  Inner Join tbl_mERP_CatHandler_Log CustCatHandler on CustCatHandler.AEAuditLogID = AELog.ID 
  Inner Join Customer C  on C.CustomerID = CustCatHandler.CustomerID 
  Left Outer Join tbl_mERP_OLClassMapping OLMap on C.CustomerID = OLMap.CustomerID 
  Left Outer Join Customer_Channel CC on C.ChannelType = CC.ChannelType
   
 Where   
  dbo.StripTimeFromDate(AEAct.ActivityTimeStamp) Between @FromDate And @ToDate  
  --And AELog.AEActivityID = AEAct.ID  
  And AEAct.AEModuleID = 4  
  And OLMap.Active = 1  
  --And CustCatHandler.AEAuditLogID = AELog.ID  
  --And OLClass.ID = OLMap.OLClassID  
  --And C.CustomerID *= OLMap.CustomerID  
  --And C.ChannelType *= CC.ChannelType   
  --And C.CustomerID = CustCatHandler.CustomerID  
  
 /* Add New Customer*/  
 Union  
  Select AELog.AEModuleID,@WDCode,@WDDest,@FromDate,@ToDate,  
   (Case isNull(Login_Type,1) When 1 Then N'Restricted Login' When 2 Then N'WD Login' End), isnull(AELog.Menu,'ADD NEW CUSTOMER') ,  
   AELog.AEUserName,ActivityTimeStamp,C.CustomerID,C.Company_Name,  
            '' as 'Channel_Type_Desc','' as 'Outlet_Type_Desc', '' as  'SubOutlet_Type_Desc',  
            CC.ChannelDesc,(Case C.Active When 1 Then N'Yes' Else N'No' End),  
   isNull((Select isNull(TMDValue,'No') From Cust_TMD_Master Where TMDID =     
   (Select TMDID From Cust_TMD_Details Where TMDCtlPos = 3 And CustomerID = C.CustomerID)),Case When Len(isnull(C.RCSOutletID,'')) >= 1 Then N'Yes' Else N'No' end) , N'','CUSTOMER TYPE UPDATED'--AELog.TaskName  
	,Null,Null  
	, C.CreationDate, IsNull(C.RCSOutletID,'')
From   
  tbl_mERP_AEAuditLog AELog ,  tbl_mERP_AEActivity AEAct,  
  Customer C,Customer_Channel CC,Customer_Type_Log C_log  
 Where   
  dbo.StripTimeFromDate(AEAct.ActivityTimeStamp) Between @FromDate And @ToDate  
  And AELog.AEActivityID = AEAct.ID  
  And AEAct.AEModuleID = 5  
  And C.ChannelType = CC.ChannelType   
  And C_Log.AEAuditlogID=AEAct.AEAuditlogID  
  And C_Log.CustomerID=C.CustomerID  
  And C_Log.Active = 1
          
 /*Modify Customer*/  
 Union  
  Select distinct AELog.AEModuleID,@WDCode,@WDDest,@FromDate,@ToDate,  
   (Case isNull(Login_Type,1) When 1 Then N'Restricted Login' When 2 Then N'WD Login' End), isnull(AELog.Menu,'MODIFY CUSTOMER') ,  
   AELog.AEUserName,ActivityTimeStamp,C.CustomerID,C.Company_Name,  
            '','','',  
            CC.ChannelDesc,(Case C.Active When 1 Then N'Yes' Else N'No' End),  
   isNull((Select isNull(TMDValue,'No') From Cust_TMD_Master Where TMDID =     
   (Select TMDID From Cust_TMD_Details Where TMDCtlPos = 3 And CustomerID = C.CustomerID)),Case When Len(isnull(C.RCSOutletID,'')) >= 1 Then N'Yes' Else N'No' end) , N'','CUSTOMER TYPE UPDATED'--AELog.TaskName  
	,Null,Null  
	, C.CreationDate, IsNull(C.RCSOutletID,'')
From   
  tbl_mERP_AEAuditLog AELog ,  tbl_mERP_AEActivity AEAct,  
  Customer_Channel CC,Customer_Type_Log C_log,Customer C  
 Where   
  dbo.StripTimeFromDate(AEAct.ActivityTimeStamp) Between @FromDate And @ToDate  
  And AELog.AEActivityID = AEAct.ID  
  And AEAct.AEModuleID = 6  
  And C.ChannelType = CC.ChannelType   
  And C_Log.AEAuditlogID=AEAct.AEAuditlogID  
  And C_Log.CustomerID=C.CustomerID  
  And C_Log.Active = 1

/*iMPORT Add Customer*/ 
 Union  
  Select distinct AELog.AEModuleID,@WDCode,@WDDest,@FromDate,@ToDate,  
   (Case isNull(Login_Type,1) When 1 Then N'Restricted Login' When 2 Then N'WD Login' End), isnull(AELog.Menu,'IMPORT ADD CUSTOMER') ,  
   AELog.AEUserName,ActivityTimeStamp,C.CustomerID,C.Company_Name,  
            '','','',  
            CC.ChannelDesc,(Case C.Active When 1 Then N'Yes' Else N'No' End),  
   isNull((Select isNull(TMDValue,'No') From Cust_TMD_Master Where TMDID =     
   (Select TMDID From Cust_TMD_Details Where TMDCtlPos = 3 And CustomerID = C.CustomerID)),Case When Len(isnull(C.RCSOutletID,'')) >= 1 Then N'Yes' Else N'No' end) , N'','CUSTOMER TYPE UPDATED' --AELog.TaskName  
	,Null,Null  
	, C.CreationDate, IsNull(C.RCSOutletID,'')
From   
  tbl_mERP_AEAuditLog AELog ,  tbl_mERP_AEActivity AEAct,  
  Customer_Channel CC,Customer_Type_Log C_log,Customer C  
 Where   
  dbo.StripTimeFromDate(AEAct.ActivityTimeStamp) Between @FromDate And @ToDate  
  And AELog.AEActivityID = AEAct.ID  
  And AEAct.AEModuleID = 8  
  And C.ChannelType = CC.ChannelType   
  And C_Log.AEAuditlogID=AEAct.AEAuditlogID  
  And C_Log.CustomerID=C.CustomerID 
  And C_Log.Active = 1
 

/*iMPORT Modify Customer*/ 
 Union  
  Select distinct AELog.AEModuleID,@WDCode,@WDDest,@FromDate,@ToDate,  
   (Case isNull(Login_Type,1) When 1 Then N'Restricted Login' When 2 Then N'WD Login' End), isnull(AELog.Menu,'IMPORT MODIFY CUSTOMER') ,  
   AELog.AEUserName,ActivityTimeStamp,C.CustomerID,C.Company_Name,  
            '','','',  
            CC.ChannelDesc,(Case C.Active When 1 Then N'Yes' Else N'No' End),  
   isNull((Select isNull(TMDValue,'No') From Cust_TMD_Master Where TMDID =     
   (Select TMDID From Cust_TMD_Details Where TMDCtlPos = 3 And CustomerID = C.CustomerID)),Case When Len(isnull(C.RCSOutletID,'')) >= 1 Then N'Yes' Else N'No' end) , N'','CUSTOMER TYPE UPDATED' --AELog.TaskName  
	,Null,Null 
	, C.CreationDate, IsNull(C.RCSOutletID,'')
 From   
  tbl_mERP_AEAuditLog AELog ,  tbl_mERP_AEActivity AEAct,  
  Customer_Channel CC,Customer_Type_Log C_log,Customer C  
 Where   
  dbo.StripTimeFromDate(AEAct.ActivityTimeStamp) Between @FromDate And @ToDate  
  And AELog.AEActivityID = AEAct.ID  
  And AEAct.AEModuleID = 9  
  And C.ChannelType = CC.ChannelType   
  And C_Log.AEAuditlogID=AEAct.AEAuditlogID  
  And C_Log.CustomerID=C.CustomerID 
  And C_Log.Active = 1

 union
 /*Received OL Classification from portal*/
 Select AELog.AEModuleID,@WDCode,@WDDest,@FromDate,@ToDate,  
   (Case isNull(Login_Type,1) When 1 Then N'Restricted Login' When 2 Then N'WD Login' End), isnull(AELog.Menu,'CENTRAL') ,  
   AELog.AEUserName,ActivityTimeStamp,C.CustomerID,C.Company_Name,OLClass.Channel_Type_Desc,OLClass.Outlet_Type_Desc,  
   SubOutlet_Type_Desc,CC.ChannelDesc,(Case C.Active When 1 Then N'Yes' Else N'No' End),  
   isNull((Select isNull(TMDValue,'No') From Cust_TMD_Master Where TMDID =     
   (Select TMDID From Cust_TMD_Details Where TMDCtlPos = 3 And CustomerID = C.CustomerID)),Case When Len(isnull(C.RCSOutletID,'')) >= 1 Then 'Yes' Else 'No' end) ,   
   '','OUTLET CLASSIFICATION CHANGED'--AELog.TaskName  
	,Null,Null    
	, C.CreationDate, IsNull(C.RCSOutletID,'')  
 From   
  tbl_mERP_AEAuditLog AELog
  Inner Join tbl_mERP_AEActivity AEAct  on AELog.AEActivityID = AEAct.ID
  Inner Join tbl_mERP_OLClassMapping OLMap on OLMap.AEAuditLogID = AELog.AEActivityID
  Inner Join tbl_mERP_OLClass OLClass on OLClass.ID = OLMap.OLClassID
  Inner Join Customer C on C.CustomerID = OLMap.CustomerID
  Left Outer Join Customer_Channel CC on C.ChannelType = CC.ChannelType
 Where   
  dbo.StripTimeFromDate(AEAct.ActivityTimeStamp) Between @FromDate And @ToDate  
  --And AELog.AEActivityID = AEAct.ID  
  And AEAct.AEModuleID =7 
  And OLMap.Active = 1  
  --And OLMap.AEAuditLogID = AELog.AEActivityID  
  --And OLClass.ID = OLMap.OLClassID  
  --And C.CustomerID = OLMap.CustomerID  
  --And C.ChannelType *= CC.ChannelType   
 Order By AELog.AEModuleID,ActivityTimeStamp  
    /*To Update tmpAudit for Channel_Type_Desc,Outlet_Type_Desc, SubOutlet_Type_Desc*/  
    Update tAudit  
    Set tAudit.[Channel Type] = OLClass.Channel_Type_Desc,  
    tAudit.[Outlet Type] = OLClass.Outlet_Type_Desc,  
    tAudit.[Loyalty Program] = OLClass.SubOutlet_Type_Desc  
    From #tmpAudit tAudit, tbl_mERP_OLClass OLClass, tbl_mERP_OLClassMapping OLMap  
    Where IsNull(tAudit.[Customer ID],'') = OLMap.CustomerID  
    And OLMap.OLClassID = OLClass.ID And OLMap.Active = 1  
  
 If (Select Count(*) From Reports Where ReportName = 'Audit Log Report' And ParameterID in       
 (Select ParameterID From dbo.GetReportParametersForSPR('Audit Log Report') Where       
 FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))>=1      
 Begin      
  Insert into #tmpAudit([WD Code],[WD Dest],[From Date] ,[Updated Through] ,Menu,  
     [User Name] ,[Activity Date And Time] ,[Customer ID],  
     [Customer Name],[Channel Type],[Outlet Type],[Loyalty Program],  
     [Customer Type],[Active/InActive],[Active In RCS],  
     [Remarks] ,[Change Description])  
  Select Field1,Field2,Field3,Field4,Field5,Field6,Field7,Field8,Field9,Field10,  
  Field11,Field12 ,Field13 ,Field14 ,Field15,Field16,Field107   
  From Reports, ReportAbstractReceived      
  Where Reports.ReportID in               
  (Select Distinct ReportID From Reports                     
  Where ReportName = 'Audit Log Report'               
  And ParameterID in (Select ParameterID From dbo.GetReportParametersForSPR('Audit Log Report') Where              
  FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))      
  And ReportAbstractReceived.ReportID = Reports.ReportID                  
  and ReportAbstractReceived.Field1 <> @SUBTOTAL          
  and ReportAbstractReceived.Field1 <> @GRNTOTAL       
  and ReportAbstractReceived.Field1 <> @WD_CODE    
 End    
  
 Update Audit Set Audit.[Base GOI Market ID] = MarInfo.MarketID,Audit.[Base GOI Market Name] = MarInfo.MarketName  From #tmpAudit As Audit,CustomerMarketInfo as CustMark,MarketInfo as MarInfo
 Where Audit.[Customer ID] = CustMark.CustomerCode
 And CustMark.MMID = MarInfo.MMID
 And isnull(CustMark.Active,0)=1
 And isnull(MarInfo.Active,0)=1
  
 Select AEModuleID,[WD Code],[WD Dest],[From Date],[To Date],[Updated Through] ,Menu,  
     [User Name] ,Convert(nVarchar(10),[Activity Date And Time],103) + N' ' + Convert(nVarchar(8),[Activity Date And Time],108) as [Activity Date And Time],[Customer ID],  
     [Customer Name],[Channel Type],[Outlet Type],[Loyalty Program],  
     [Customer Type],[Active/InActive],[Active In RCS],  
     [Remarks] ,[Change Description],[Base GOI Market ID],[Base GOI Market Name] ,  
     Convert(varchar,[Outlet Creation Date],103) +N' ' + Convert(varchar,[Outlet Creation Date],108) as [Outlet Creation Date],
     [RCSID]
 From #tmpAudit  
   
End  
