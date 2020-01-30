CREATE Procedure spr_Itemwise_Companywise_Stock_Movement_Detail (@ItemAndManufact nvarchar(100), @FromDate Datetime,@ToDate Datetime)        
as    
Declare @ProductCode nvarchar(255)    
Declare @Manufacturer nvarchar(255)    
Declare @Pos int    
    
Set @Pos = charindex(';', @ItemAndManufact)    
Set @ProductCode = substring(@ItemAndManufact, 1, @Pos-1)     
Set @Manufacturer = substring(@ItemAndManufact, @Pos + 1, 255)    
    
Select CompanyID,  
"Company ID" = CompanyID,    
"Item Code" = ReportDetailReceived.Field1,    
"Item Name" = ReportDetailReceived.Field2,        
"Opening Quantity" = Cast(Cast (ReportDetailReceived.Field3 as Decimal(18,6))as Decimal(18,6)),      
"Free Opening Quantity" = Cast(Cast (ReportDetailReceived.Field4 as Decimal(18,6))as Decimal(18,6)),      
"Damage Opening Quantity" = Cast(Cast (ReportDetailReceived.Field5 as Decimal(18,6))as Decimal(18,6)),      
"Total Opening Quantity" = Cast(Cast (ReportDetailReceived.Field6 as Decimal(18,6))as Decimal(18,6)),      
"Opening Value" = Cast(Cast (ReportDetailReceived.Field7 as Decimal(18,6))as Decimal(18,6)),      
"Damage Opening Value" = Cast(Cast (ReportDetailReceived.Field8 as Decimal(18,6))as Decimal(18,6)),      
"Total Opening Value" = Cast(Cast (ReportDetailReceived.Field9 as Decimal(18,6))as Decimal(18,6)),      
"Purchase" = Cast(Cast (ReportDetailReceived.Field10 as Decimal(18,6))as Decimal(18,6)),      
"Free Purchase" = Cast(Cast (ReportDetailReceived.Field11 as Decimal(18,6))as Decimal(18,6)),      
"Sales Return Saleable" = Cast(Cast (ReportDetailReceived.Field12 as Decimal(18,6))as Decimal(18,6)),      
"Sales Return Damages" = Cast(Cast (ReportDetailReceived.Field13 as Decimal(18,6))as Decimal(18,6)),      
"Total Issues" = Cast(Cast (ReportDetailReceived.Field14 as Decimal(18,6))as Decimal(18,6)),       
"Free Issues" = Cast(Cast (ReportDetailReceived.Field15 as Decimal(18,6))as Decimal(18,6)),      
"Sales Value " = Cast(Cast (ReportDetailReceived.Field16 as Decimal(18,6))as Decimal(18,6)),      
"Purchase Return" = Cast(Cast (ReportDetailReceived.Field17 as Decimal(18,6))as Decimal(18,6)),      
"Adjustments" = Cast(Cast (ReportDetailReceived.Field18 as Decimal(18,6))as Decimal(18,6)),      
"Stock Transfer Out" = Cast(Cast (ReportDetailReceived.Field19 as Decimal(18,6))as Decimal(18,6)),      
"Stock Transfer In" = Cast(Cast (ReportDetailReceived.Field20 as Decimal(18,6))as Decimal(18,6)),      
"Stock Destruction" = (Cast(Cast (ReportDetailReceived.Field21 as Decimal(18,6))as Decimal(18,6))),    
"On Hand Qty" = Cast(Cast (ReportDetailReceived.Field22 as  Decimal(18,6))as Decimal(18,6)),      
"On Hand Free Qty" = Cast(Cast (ReportDetailReceived.Field23 as Decimal(18,6))as Decimal(18,6)),      
"On Hand Damage Qty" = Cast(Cast (ReportDetailReceived.Field24 as Decimal(18,6))as Decimal(18,6)),      
"Total On Hand Qty" = Cast(Cast (ReportDetailReceived.Field25 as Decimal(18,6))as Decimal(18,6)),      
"On Hand Value" = Cast(Cast (ReportDetailReceived.Field26 as Decimal(18,6))as Decimal(18,6)),      
"On Hand Damages Value" = Cast(Cast (ReportDetailReceived.Field27 as Decimal(18,6))as Decimal(18,6)),      
"Total On Hand Value" = Cast(Cast (ReportDetailReceived.Field28 as Decimal(18,6))as Decimal(18,6))        
      
from Reports, ReportAbstractReceived, ReportDetailReceived          
where Reports.ReportID in (Select Max(ReportID) From Reports Where ReportName = 'Stock Movement - Manufacturer'     
And ParameterID in (Select ParameterID From dbo.GetReportParameters2('Stock Movement - Manufacturer')     
Where Manufacturer = @Manufacturer     
And FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate))
Group by CompanyID    
)    
And ReportAbstractReceived.RecordID = ReportDetailReceived.RecordID   
And ReportDetailReceived.Field1 = @ProductCode    
And ReportAbstractReceived.ReportID = Reports.ReportID   
--and ReportDetailReceived.Field3 <> 'Category Name'       
and ReportDetailReceived.Field3 <> 'Opening Quantity'      
and ReportAbstractReceived.Field1 <> 'SubTotal:'    
and ReportAbstractReceived.Field1 <> 'GrandTotal:' 






