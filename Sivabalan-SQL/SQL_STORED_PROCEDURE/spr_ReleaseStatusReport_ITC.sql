
Create PROCEDURE [dbo].[spr_ReleaseStatusReport_ITC](@FromDate Datetime, @ToDate Datetime)    
As    
SET DateFormat DMY    
Declare @WDCode nVarchar(10)    
Select Top 1 @WDCode = RegisteredOwner From Setup    
    
Create table #tempcons (instalid nvarchar(25),[InstallationID] nvarchar(25),    
[WD Code] nvarchar(10) ,[FSUID] nvarchar(10),[ReleaseID] nvarchar(10) ,[Patch Name]  nvarchar(200),    
[Machine Type] nvarchar(7),[Machine Name] nvarchar(200),[Installation Status] nvarchar(200),    
[Installed Date] nvarchar(25),Filecontent nvarchar(max),OrderBy Int)    
      
insert into #tempcons       
Select insd.InstallationID as Instalid,        
"InstallationID" = insd.InstallationID,        
"WD Code" = @WDCode,         
"FSUID" = insd.FSUID,        
"ReleaseID" = insd.ReleaseID,        
"Patch Name" = insd.[FileName],        
"Machine Type" = Case clm.IsServer When 0 Then 'Client' Else 'Server' End,        
"Machine Name" = clm.SystemName,        
"Installation Status" = Case     
        When IsNull(insd.Status, 0) & 4 = 4 Then 'Installed'        
        When IsNull(insd.Status, 0) & 8 = 8 Then 'Installation Failed - Unable to install'    
        When IsNull(insd.Status, 0) & 16 = 16 Then 'Installation Failed - Try again'    
        When IsNull(insd.Status, 0) & 1 = 1 Then 'Download Successful'    
        When IsNull(insd.Status, 0) & 2 = 2 Then 'Download Failed'    
        When IsNull(insd.Status, 0) & 32 = 32 Then 'Copied successfully'    
        When IsNull(insd.Status, 0) & 64 = 64 Then 'UpdateToReleaseTable'    
        End,                  
"Installed Date" = Cast(insd.DateofInstallation As nVarchar),   
 "Filecontent" =(dbo.fn_get_filename([FSUID])),  
insd.InstallationID  
--into #TempCons      
From tblClientMaster clm, tblInstallationDetail insd        
Where clm.ClientID = insd.ClientID And     
isnull(clm.IsServer,0)= 1 and        
insd.ModifiedDate Between @FromDate And @ToDate    
    
--If (Select Count(*) From Reports Where ReportName = 'Release Status Report' And ParameterID in    
--(Select ReportParameters.ParameterID From Reports,ReportParameters  Where ReportName = 'Release Status Report'    
--And Reports.ParameterID = ReportParameters.ParameterID)) >=1    
--Insert Into #TempCons    
--Select  cast(ReportAbstractReceived.Field1 as nvarchar(25)),    
--"InstallationID"=cast(ReportAbstractReceived.Field1 as nvarchar(25)),    
--"WD Code" = cast(ReportAbstractReceived.Field2 as nvarchar(10)) ,    
--"FSUID" = cast(ReportAbstractReceived.Field3 as nvarchar(10)),    
--"ReleaseID"=cast(ReportAbstractReceived.Field4 as nvarchar(10)),    
--"Patch Name"= cast(ReportAbstractReceived.Field5 as nvarchar(200)),    
--"Machine Type" = cast(ReportAbstractReceived.Field6 as Varchar(7)),    
--"Machine Name" = cast(ReportAbstractReceived.Field7 as Varchar(200)),    
--"Installation Status"=cast(ReportAbstractReceived.Field8 as nvarchar(200)),    
--"Installation Date"= Cast(ReportAbstractReceived.Field9 as varchar), 0,  
--"Filecontent"= cast(ReportAbstractReceived.Field10 as Varchar(255))  
--From ReportAbstractReceived Where    
--ReportAbstractReceived.ReportID in    
--(Select Distinct ReportID From Reports    
--Where ReportName = 'Release Status Report'    
--And     
--cast(ReportAbstractReceived.Field6 as Varchar(7)) = '1' And    
--ParameterID in (    
--Select ParameterID From dbo.GetReportParametersForSPR('Release Status Report')    
--where FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)    
--)    
--And ParameterID In (Select Distinct ReportParameters.ParameterID    
--From Reports, ReportParameters Where ReportName = 'Release Status Report'    
--And Reports.ParameterID = ReportParameters.ParameterID    
--))    
--And ReportAbstractReceived.Field1 <> 'InstallationID'    
    
Select [DetArg],[InstallationID],[WD Code],[FSUID],[ReleaseID],    
[Patch Name],[Machine Type],[Machine Name] ,[Installation Status],[Installed Date],Filecontent From (    
Select Distinct "DetArg" = InstallationId+char(15)+[WD Code], [InstallationID],[WD Code],[FSUID],[ReleaseID],    
[Patch Name],[Machine Type],[Machine Name] ,[Installation Status],[Installed Date],[OrderBy],Filecontent From #tempCons     
) As TempCons Order by [FSUID]     
    
Drop Table #tempCons    


