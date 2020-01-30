Create procedure spr_Trace_Route_Report ( @FromDate Datetime, @ToDate Datetime)
as 

Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)

set dateformat dmy 
 
Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
Select Top 1 @WDCode = RegisteredOwner From Setup    

If @CompaniesToUploadCode='ITC001'  
 Set @WDDest= @WDCode  
Else  
Begin  
 Set @WDDest= @WDCode  
 Set @WDCode= @CompaniesToUploadCode  
End  

select @WDCode [WD Code1],  @WDCode [WD Code], @WDDest [WD Dest], @FromDate [From Date], @ToDate [To Date] 
, Gps.DSID, sm.Salesman_Name [DS Name]
, Gps.RouteId  RouteId, B.Description [Route Name], GPS.CustomerId,C.Company_Name as CustomerName, OutletCount as [Outlet Visit Sequence]
, Cast(Isnull(Latitude,0) as Nvarchar(50)) Latitude, Cast(Isnull(Longitude,0) as Nvarchar(50)) Longitude , (Convert(varchar(10), Gps.Modifieddate, 103)+ ' ' + Convert(varchar(10), Gps.Modifieddate, 108)) [Data Captured On]
,(Convert(varchar(10), Gps.HH_to_Forum_Uploaded_Date, 103)+ ' ' + Convert(varchar(10), Gps.HH_to_Forum_Uploaded_Date, 108)) [HH to Forum Uploaded Date]
from HH_TRACEROUTE_GPS Gps 
--Join Beat_salesman BS
--ON GPS.DSId = BS.salesmanid
Join Salesman sm 
on GPS.DSId = sm.salesmanid 
Join Beat B 
on Gps.RouteId = B.BeatId 
Join Customer C 
on GPS.CustomerId = C.CustomerID
--Join Salesman sm on GPS.DSId = sm.salesmanid Join Beat B on Gps.RouteId = B.BeatId 
where dbo.stripdatefromtime(Gps.HH_to_Forum_Uploaded_Date) between @fromDate and @toDate  
And Gps.RouteId = B.BeatId 
And Gps.CustomerId = C.CustomerId 
and Gps.DSID= SM.SalesmanId
Order by Salesman_Name
