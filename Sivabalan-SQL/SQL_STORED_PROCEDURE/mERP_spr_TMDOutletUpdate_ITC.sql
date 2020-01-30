Create Procedure mERP_spr_TMDOutletUpdate_ITC(@FromDate DateTime, @ToDate DateTime)  
As  
Declare @WDCode NVarchar(255)  
Declare @WDDest NVarchar(255)  
Declare @CompaniesToUploadCode NVarchar(255)  
  
declare @CUSTID nVarChar(50)  
Declare @SUBTOTAL NVarchar(50)    
Declare @GRNTOTAL NVarchar(50)    
  
Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)     
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)     
Set @CUSTID = dbo.LookupDictionaryItem(N'Customer ID', Default)   
  
Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload    
Select Top 1 @WDCode = RegisteredOwner From Setup      
    
If @CompaniesToUploadCode='ITC001'    
 Set @WDDest= @WDCode    
Else    
Begin    
 Set @WDDest= @WDCode    
 Set @WDCode= @CompaniesToUploadCode    
End    
  
Create Table #TempConsolidate   
(WDCode NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, WDDest NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
FromDate DateTime,ToDate Datetime, CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
RCSID nVarChar(255),Active nVarChar(255),OutletName nVarChar(510),  
OutletAddress nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
ActiveInRCS nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)    
  
Insert into #TempConsolidate (WDCode, WDDest,FromDate,ToDate,CustomerID, RCSID, Active, OutletName, OutletAddress,ActiveInRCS)  
Select @WDCode, @WDDest,@FromDate,@ToDate, C.CustomerID, C.RCSOutletID,  
Case When C.Active = 1 Then 'Y' Else 'N' end,  
C.Company_Name, C.BillingAddress,  
isNull((Select isNull(TMDValue,'No') From Cust_TMD_Master Where TMDID =   
(Select TMDID From Cust_TMD_Details Where TMDCtlPos = 3 And CustomerID = C.CustomerID)),Case When Len(isnull(C.RCSOutletID,'')) >= 1 Then 'Yes' Else 'No' end)  
From Customer C
LEFT JOIN Customer_Audit ON Customer_Audit.CustomerID = C.CustomerID
where 
(C.CreationDate Between @FromDate And @ToDate  
Or C.ModifiedDate Between @FromDate And @ToDate
Or Customer_Audit.Modified Between @FromDate And @ToDate) 
And CustomerCategory Not in (4,5)  
  
If (Select Count(*) From Reports Where ReportName = 'TMD- Outlet Update' And ParameterID in     
(Select ParameterID From dbo.GetReportParametersForSPR('TMD- Outlet Update') Where     
FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))>=1    
Begin    
Insert into #TempConsolidate (WDCode, WDDest,FromDate,ToDate,CustomerID, RCSID, Active, OutletName, OutletAddress,ActiveInRCS)  
Select Field1,Field2,Field3,Field4,Field5,Field6,Field7,Field8,Field9,Field10  
From Reports, ReportAbstractReceived    
Where Reports.ReportID in             
(Select Distinct ReportID From Reports                   
Where ReportName = 'TMD- Outlet Update'             
And ParameterID in (Select ParameterID From dbo.GetReportParametersForSPR('TMD- Outlet Update') Where            
FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))    
And ReportAbstractReceived.ReportID = Reports.ReportID                
and ReportAbstractReceived.Field1 <> @SUBTOTAL        
and ReportAbstractReceived.Field1 <> @GRNTOTAL     
and ReportAbstractReceived.Field5 <> @CUSTID  
End  
  
Select 1,  
"WD Code" = WDCode,  
"WD Dest Code" = WDDest,  
"From Date" = FromDate,  
"To Date" = ToDate,  
"Customer ID" = CustomerID,  
"RCS ID" = RCSID,  
"Active" = Active,  
"Outlet Name" = OutletName,  
"Outlet Address" = OutletAddress,  
"Active in RCS" = ActiveInRCS  
from #TempConsolidate  
  
Drop Table #TempConsolidate   
