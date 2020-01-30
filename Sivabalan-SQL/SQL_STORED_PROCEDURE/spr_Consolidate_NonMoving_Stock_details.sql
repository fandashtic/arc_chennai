CREATE Procedure spr_Consolidate_NonMoving_Stock_details (@CompanyID nvarchar(100),@FromDate Datetime, @ToDate datetime)    
as    
Declare @ITEMCODE NVarchar(50)
Declare @ITEMNAME NVarchar(50)
Declare @GRNTOTAL NVarchar(50)
Declare @SUBTOTAL NVarchar(50)

Set @ITEMCODE=dbo.LookupDictionaryItem(N'Item Code', Default)
Set @ITEMNAME=dbo.LookupDictionaryItem(N'Item Name', Default)
Set @GRNTOTAL=dbo.LookupDictionaryItem(N'GrandTotal:', Default)
Set @SUBTOTAL=dbo.LookupDictionaryItem(N'SubTotal:', Default)

Select "Item Code" = ReportAbstractReceived.Field1,     
"Item Code" = ReportAbstractReceived.Field1,     
"Item Name" = ReportAbstractReceived.Field2,     
"Description" = ReportAbstractReceived.Field3,     
"Category" = ReportAbstractReceived.Field4,     
"Last Sale Date" = ReportAbstractReceived.Field5,    
"Saleable Stock" = ReportAbstractReceived.Field6,    
"Damage Stock" = ReportAbstractReceived.Field7,  
"Free Stock" = ReportAbstractReceived.Field8,   
"Total Stock" = ReportAbstractReceived.Field10,  
"Total Value" = ReportAbstractReceived.Field11   
     
from ReportAbstractReceived, Reports     
where Reports.ReportID = ReportAbstractReceived.ReportID    
and Reports.ReportID = dbo.LocateReport(@CompanyID, 'Non Moving Stock', @FromDate, @ToDate)  
and ReportAbstractReceived.Field1 <> @ITEMCODE     
and ReportAbstractReceived.Field2 <> @ITEMNAME     
and ReportAbstractReceived.Field1 <> @SUBTOTAL    
and ReportAbstractReceived.Field1 <> @GRNTOTAL   


