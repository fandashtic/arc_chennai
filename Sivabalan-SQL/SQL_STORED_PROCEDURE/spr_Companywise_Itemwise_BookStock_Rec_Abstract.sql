CREATE Procedure spr_Companywise_Itemwise_BookStock_Rec_Abstract (@FromDate Datetime, @CompanyID nvarchar(100))      
as      
CREATE TABLE #temp(CompanyID nvarchar(50), Field4 nvarchar(128), Field5 nvarchar(128), Field6 nvarchar(128), Field7 nvarchar(128))    
insert into #temp    
Select Reports.CompanyID,       
"Total Qty" = Cast(Cast (ReportAbstractReceived.Field4 as float)as Decimal(18,6)),        
"Saleable Stock" =Cast( Cast(ReportAbstractReceived.Field5 as float)as Decimal(18,6)),         
"Free Stock" = Cast( Cast(ReportAbstractReceived.Field6 as float)as Decimal(18,6)),        
"Damage Stock" = Cast( Cast(ReportAbstractReceived.Field7 as float)as Decimal(18,6))       
from Reports, ReportAbstractReceived       
where Reports.ReportID in (Select Max(ReportID) From Reports     
   Where ReportName = 'Available Book Stock' And CompanyID Like @COMPANYID     
   And dbo.StripDateFromTime(ReportDate) = dbo.StripDateFromTime(@FROMDATE) Group By CompanyID)    
And ReportAbstractReceived.ReportID = Reports.ReportID      
and ReportAbstractReceived.Field4 <> 'Total Qty'         
and ReportAbstractReceived.Field1 <> 'SubTotal:'    
and ReportAbstractReceived.Field1 <> 'GrandTotal:'  
    
select CompanyID, CompanyID, "Total Qty" = sum(cast(field4 as Decimal(18,6))),     
"Total Saleable Stock" = sum(cast(field5 as Decimal(18,6))),     
"Total Free Stock" = sum(cast(field6 as Decimal(18,6))),     
"Total Damage Stock" = sum(cast(field7 as Decimal(18,6)))     
from #temp    
Group By CompanyID    
drop table #temp    
  





