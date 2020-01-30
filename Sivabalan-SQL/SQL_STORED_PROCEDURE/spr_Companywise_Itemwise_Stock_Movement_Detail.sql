CREATE Procedure spr_Companywise_Itemwise_Stock_Movement_Detail       
(@Company nvarchar(100), @Manufacturer nvarchar(100), @Unused nvarchar(100), @FromDate Datetime,@ToDate Datetime)    
      
AS      
    
If @Manufacturer = '%'     
begin    
   Set @Manufacturer = 'All Manufacturers'    
end    
  
Select "Item Code" = ReportDetailReceived.Field1,  
"Item Code" = ReportDetailReceived.Field1,  
"Item Name" = ReportDetailReceived.Field2,      
"Opening Quantity" = Cast(Cast (ReportDetailReceived.Field3 as float)as Decimal(18,6)),        
"Free Opening Quantity" = Cast(Cast (ReportDetailReceived.Field4 as float)as Decimal(18,6)),        
"Damage Opening Quantity" = Cast(Cast (ReportDetailReceived.Field5 as float)as Decimal(18,6)),        
"Total Opening Quantity" = Cast(Cast (ReportDetailReceived.Field6 as float)as Decimal(18,6)),        
"Opening Value" = Cast(Cast (ReportDetailReceived.Field7 as float)as Decimal(18,6)),        
"Damage Opening Value" = Cast(Cast (ReportDetailReceived.Field8 as float)as Decimal(18,6)),        
"Total Opening Value" = Cast(Cast (ReportDetailReceived.Field9 as float)as Decimal(18,6)),        
"Purchase" = Cast(Cast (ReportDetailReceived.Field10 as float)as Decimal(18,6)),        
"Free Purchase" = Cast(Cast (ReportDetailReceived.Field11 as float)as Decimal(18,6)),        
"Sales Return Saleable" = Cast(Cast (ReportDetailReceived.Field12 as float)as Decimal(18,6)),        
"Sales Return Damages" = Cast(Cast (ReportDetailReceived.Field13 as float)as Decimal(18,6)),        
"Total Issues" = Cast(Cast (ReportDetailReceived.Field14 as float)as Decimal(18,6)),         
"Free Issues" = Cast(Cast (ReportDetailReceived.Field15 as float)as Decimal(18,6)),        
"Sales Value " = Cast(Cast (ReportDetailReceived.Field16 as float)as Decimal(18,6)),        
"Purchase Return" = Cast(Cast (ReportDetailReceived.Field17 as float)as Decimal(18,6)),        
"Adjustments" = Cast(Cast (ReportDetailReceived.Field18 as float)as Decimal(18,6)),        
"Stock Transfer Out" = Cast(Cast (ReportDetailReceived.Field19 as float)as Decimal(18,6)),        
"Stock Transfer In" = Cast(Cast (ReportDetailReceived.Field20 as float)as Decimal(18,6)),   
"Stock Destruction" = Cast(Cast (ReportDetailReceived.Field21 as float)as Decimal(18,6)),   
"On Hand Qty" = Cast(Cast (ReportDetailReceived.Field22 as  float)as Decimal(18,6)),        
"On Hand Free Qty" = Cast(Cast (ReportDetailReceived.Field23 as float)as Decimal(18,6)),        
"On Hand Damage Qty" = Cast(Cast (ReportDetailReceived.Field24 as float)as Decimal(18,6)),        
"Total On Hand Qty" = Cast(Cast (ReportDetailReceived.Field25 as float)as Decimal(18,6)),        
"On Hand Value" = Cast(Cast (ReportDetailReceived.Field26 as float)as Decimal(18,6)),        
"On Hand Damages Value" = Cast(Cast (ReportDetailReceived.Field27 as float)as Decimal(18,6)),        
"Total On Hand Value" = Cast(Cast (ReportDetailReceived.Field28 as float)as Decimal(18,6))          
        
from ReportAbstractReceived, Reports, ReportDetailReceived  
    
where Reports.ReportID in     
(Select Max(ReportID) From Reports Where ReportName = 'Stock Movement - Manufacturer'    
And ParameterID in (Select ParameterID From dbo.GetReportParameters2('Stock Movement - Manufacturer')       
Where Manufacturer = @Manufacturer       
And FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate))
Group by CompanyID)      
And CompanyID = @Company       
And ReportAbstractReceived.RecordID = ReportDetailReceived.RecordID   
And ReportAbstractReceived.ReportID = Reports.ReportID   
and ReportDetailReceived.Field1 <> 'Item Code'        
and ReportDetailReceived.Field1 <> 'SubTotal:'    
and ReportDetailReceived.Field1 <> 'GrandTotal:'






