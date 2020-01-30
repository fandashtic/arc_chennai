CREATE Procedure spr_Itemwise_Companywise_BookStock_RecDetails(@ItemCode nvarchar(100),   
        @FromDate Datetime)   
  
as  
  
Select CompanyID, CompanyID, 
"Category" = Field3, 
"Total Quantity" = (cast(Cast(ReportAbstractReceived.Field4 as float)as Decimal(18,6))),      
"Saleable Stock" = (cast(Cast(ReportAbstractReceived.Field5 as float)as Decimal(18,6))),      
"Free Stock" = (cast(Cast(ReportAbstractReceived.Field6 as float) as Decimal(18,6))),      
"Damage Stock" = (cast(Cast(ReportAbstractReceived.Field7 as float)as Decimal(18,6)))  
from ReportAbstractReceived, Reports  
where ReportAbstractReceived.Field1 = @ItemCode  
and Reports.ReportID = ReportAbstractReceived.ReportID    
and Reports.ReportID in (Select Max(ReportID) From Reports   
Where ReportName = 'Available Book Stock'   
And dbo.StripDateFromTime(ReportDate) = dbo.StripDateFromTime(@FROMDATE) Group By CompanyID)  
  
and ReportAbstractReceived.Field1 <> 'Item Code'        
and ReportAbstractReceived.Field1 <> 'SubTotal:'    
and ReportAbstractReceived.Field1 <> 'GrandTotal:'    
  



