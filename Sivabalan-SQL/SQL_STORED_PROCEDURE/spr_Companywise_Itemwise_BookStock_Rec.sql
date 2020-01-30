CREATE Procedure spr_Companywise_Itemwise_BookStock_Rec (@CompanyID nvarchar(100),@FromDate Datetime, @Unused nvarchar(255))  
    
as    
    
Select "Item Code" = ReportAbstractReceived.Field1,     
"Item Code" = ReportAbstractReceived.Field1,     
"Item Name" = ReportAbstractReceived.Field2,     
"Category" = ReportAbstractReceived.Field3,     
"Total Qty" = (cast(Cast(ReportAbstractReceived.Field4 as float)as Decimal(18,6))),    
"Saleable Stock" = (cast(Cast(ReportAbstractReceived.Field5 as float)as Decimal(18,6))),    
"Free Stock" = (cast(Cast(ReportAbstractReceived.Field6 as float)as Decimal(18,6))),    
"Damage Stock" = (cast(Cast(ReportAbstractReceived.Field7 as float)as Decimal(18,6)))    
    
from ReportAbstractReceived, Reports     
    
where Reports.ReportID = ReportAbstractReceived.ReportID    
and Reports.ReportID = dbo.LocateReport(@CompanyID, 'Available Book Stock', @FromDate, Null)      
and ReportAbstractReceived.Field1 <> 'Item Code'  
and ReportAbstractReceived.Field1 <> 'SubTotal:'      
and ReportAbstractReceived.Field1 <> 'GrandTotal:'



