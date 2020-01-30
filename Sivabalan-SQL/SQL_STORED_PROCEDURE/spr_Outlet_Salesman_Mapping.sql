Create Procedure spr_Outlet_Salesman_Mapping  
(  
  @SmanName as nVarchar(1000),  
  @SmanType as nVarchar(1000),  
  @FromDate as DateTime,  
  @ToDate as DateTime  
 
)  
As  
Begin  

Declare @WDCode as nVarchar(100)  
Declare @WDDestCode as nVarchar(100)  
Declare @CompaniesToUploadCode as nVarchar(255)
Declare @delimeter as char(1)

Declare @CUSTID nVarChar(50)  
Declare @SUBTOTAL NVarchar(50)    
Declare @GRNTOTAL NVarchar(50)    
  
Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)     
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)     
Set @CUSTID = dbo.LookupDictionaryItem(N'Customer ID', Default)   


Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload      
Select Top 1 @WDCode = RegisteredOwner From Setup        

Set @delimeter = char(15)
      
If @CompaniesToUploadCode='ITC001'      
	Set @WDDestCode= @WDCode      
Else      
Begin      
	Set @WDDestCode= @WDCode      
	Set @WDCode= @CompaniesToUploadCode      
End      

  
Create Table #tmpSManType(SmanID Integer)  
Create Table #tmpSman(SmanID Integer)  
Create Table #tmpSManID(SmanID Integer)  
  
If @SmanType = '%'   
	Insert Into #tmpSManType  
	Select SalesManID From Salesman  
else  
  	Insert Into #tmpSManType  
  	Select SalesmanId From DSType_Details Where DSTypeID In (select DSTypeID From DSType_Master Where DSTypeValue In (Select * From dbo.sp_splitIn2Rows(@SmanType,@delimeter)) and DSTypeCtlPos = 1 )  
  
if @SmanName = '%'  
	Insert Into #tmpSman  
	Select SalesmanID From Salesman  
else  
	Insert Into #tmpSman  
	Select SalesmanID From Salesman Where Salesman_Name In (Select * From dbo.sp_splitin2Rows(@SmanName,@delimeter))  
  


  
Insert Into #tmpSManID  
Select 
	T.SmanID  
From
	 #tmpSManType T,#tmpSman S  
Where
	 T.SmanID = S.SmanID  
  
   
Drop Table #tmpSManType  
Drop Table #tmpSman  
   
Create Table #tmpOutPut([WDCode] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[WD Code] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[WD Dest Code] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[From Date] DateTime,[To Date] Datetime,[Customer ID] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[RCS ID] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,[Salesman ID] Integer,[Salesman Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Salesman Type]  nVArchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Active in RCS] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert Into #tmpOutPut([WDCode],[WD Code] ,[WD Dest Code],[From Date],[To Date],[Customer ID],[RCS ID] ,
[Salesman ID] ,[Salesman Name] ,[Salesman Type],[Active in RCS])
Select  Distinct 
	@WDCode,@WDCode ,@WDDestCode ,@FromDate,@ToDate,C.CustomerID ,isnull(C.RcsOutletID,'') ,  
	ISNULL(BS.SalesmanID,'') ,Salesman_Name ,  
	(Select Top 1 DSTypeValue From DSType_Master DM,DSType_Details DD where DM.DSTypeID = DD.DSTypeID and DD.SalesmanID = BS.SalesmanID and DD.DSTypeCtlPos  = 1),
	isNull((Select isNull(TMDValue,'No') From Cust_TMD_Master Where TMDID = 
	(Select TMDID From Cust_TMD_Details Where TMDCtlPos = 3 And CustomerID = C.CustomerID)),'No')
From   
	Customer C,Beat_Salesman BS ,SalesMan SM
Where  
C.CustomerID = BS.CustomerID and  
BS.SalesmanID <> 0 and  
BS.SalesmanID = SM.SalesmanID and  
(C.CreationDate Between @FromDate And @ToDate Or
C.ModifiedDate Between @FromDate And @ToDate  Or
SM.ModifiedDate Between @FromDate And @ToDate
 ) and
SM.SalesmanId In(Select SManID  From #tmpSManID) 



If (Select Count(*) From Reports Where ReportName = 'TMD - Outlet Salesman Mapping' And ParameterID in     
(Select ParameterID From dbo.GetReportParametersForSPR('TMD - Outlet Salesman Mapping') Where     
FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))>=1    
Begin    
	Insert Into #tmpOutput([WDCode],[WD Code] ,[WD Dest Code],[From Date],[To Date],[Customer ID],[RCS ID] ,
	[Salesman ID] ,[Salesman Name] ,[Salesman Type],[Active in RCS])  
	Select 
		Field1,Field1,Field2,Field3,Field4 ,Field5,Field6,Field7,Field8,Field9,Field10 
	From   
		Reports, ReportAbstractReceived    
	Where   
	Reports.ReportID in             
	(Select Distinct ReportID From Reports                   
	Where ReportName = 'TMD - Outlet Salesman Mapping'             
	And ParameterID in (Select ParameterID From dbo.GetReportParametersForSPR('TMD - Outlet Salesman Mapping') Where            
	FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))    
	And ReportAbstractReceived.ReportID = Reports.ReportID                
	and ReportAbstractReceived.Field1 <> @SUBTOTAL        
	and ReportAbstractReceived.Field1 <> @GRNTOTAL     
	and ReportAbstractReceived.Field5 <> @CUSTID
End  
  

  

Select * From  #tmpOutPut
  
Drop Table #tmpSManID  
Drop Table #tmpOutput  
End  
  
