CREATE Procedure spr_list_Companywise_Itemwise_Stock_Movement         
(@Manufacturer nvarchar(100),@Company nvarchar(100), @FromDate Datetime,@ToDate Datetime)                
as                

Declare @OPENINGQTY NVarchar(50)
Declare @SUBTOTAL NVarchar(50)
Declare @GRNTOTAL NVarchar(50)

Set @OPENINGQTY = dbo.LookupDictionaryItem(N'Opening Quantity', Default) 
Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default) 
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default) 



If @Manufacturer = '%'         
begin        
   Set @Manufacturer = 'All Manufacturers'        
end        
        
CREATE TABLE #temp(CompanyID nvarchar(50), Field3 nvarchar(128), Field4 nvarchar(128),         
Field5 nvarchar(128), Field6 nvarchar(128), Field7 nvarchar(128), Field8 nvarchar(128),         
Field9 nvarchar(128), Field10 nvarchar(128), Field11 nvarchar(128), Field12 nvarchar(128),         
Field13 nvarchar(128), Field14 nvarchar(128), Field15 nvarchar(128), Field16 nvarchar(128),         
Field17 nvarchar(128), Field18 nvarchar(128), Field19 nvarchar(128), Field20 nvarchar(128),         
Field21 nvarchar(128), Field22 nvarchar(128), Field23 nvarchar(128), Field24 nvarchar(128),         
Field25 nvarchar(128), Field26 nvarchar(128), Field27 nvarchar(128), Field28 nvarchar(128))          
        
insert into #temp          
Select        
Reports.CompanyID,        
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
          
         
from Reports, ReportAbstractReceived, ReportDetailReceived            
where Reports.ReportID in         
         
 (Select Max(ReportID) From Reports               
 Where ReportName = 'Stock Movement - Manufacturer'         
 And CompanyID like @Company
 And ParameterID in (Select ParameterID From dbo.GetReportParameters2('Stock Movement - Manufacturer')         
 Where Manufacturer = @Manufacturer         
 And FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate))
 Group by CompanyID)           

And CompanyID Like @Company         
And ReportAbstractReceived.RecordID = ReportDetailReceived.RecordID     
And ReportAbstractReceived.ReportID = Reports.ReportID            
and ReportDetailReceived.Field3 <> @OPENINGQTY      
and ReportDetailReceived.Field1 <> @SUBTOTAL    
and ReportDetailReceived.Field1 <> @GRNTOTAL 

  
select CompanyID, CompanyID,           
"Opening Quantity" = Sum( Cast(Cast (Field3 as float)as Decimal(18,6))),          
"Free Opening Quantity" = Sum( Cast(Cast (Field4 as float)as Decimal(18,6))),          
"Damage Opening Quantity" = Sum( Cast(Cast (Field5 as float)as Decimal(18,6))),          
"Total Opening Quantity" = Sum( Cast(Cast (Field6 as float)as Decimal(18,6))),          
"Opening Value" = Sum( Cast(Cast (Field7 as float)as Decimal(18,6))),         
"Damage Opening Value" = Sum( Cast(Cast (Field8 as float)as Decimal(18,6))),          
"Total Opening Value" = Sum( Cast(Cast (Field9 as float)as Decimal(18,6))),          
"Purchase" = Sum( Cast(Cast (Field10 as float)as Decimal(18,6))),         
"Free Purchase" = Sum( Cast(Cast (Field11 as float)as Decimal(18,6))),    
"Sales Return Saleable" = Sum( Cast(Cast (Field12 as float)as Decimal(18,6))),          
"Sales Return Damages" = Sum( Cast(Cast (Field13 as float)as Decimal(18,6))),          
"Total Issues" = Sum( Cast(Cast (Field14 as float)as Decimal(18,6))),          
"Free Issues" = Sum( Cast(Cast (Field15 as float)as Decimal(18,6))),      
"Sales Value " = Sum( Cast(Cast (Field16 as float)as Decimal(18,6))),     
"Purchase Return" = Sum( Cast(Cast (Field17 as float)as Decimal(18,6))),          
"Adjustments" = Sum( Cast(Cast (Field18 as float)as Decimal(18,6))),      
"Stock Transfer Out" = Sum( Cast(Cast (Field19 as float)as Decimal(18,6))),         
"Stock Transfer In" = Sum( Cast(Cast (Field20 as float)as Decimal(18,6))),          
"Stock Destruction" = Sum( Cast(Cast (Field21 as  float)as Decimal(18,6))),     
"On Hand Qty" = Sum( Cast(Cast (Field22 as  float)as Decimal(18,6))),     
"On Hand Free Qty" = Sum( Cast(Cast (Field23 as float)as Decimal(18,6))),          
"On Hand Damage Qty" = Sum( Cast(Cast (Field24 as float)as Decimal(18,6))),          
"Total On Hand Qty" = Sum( Cast(Cast (Field25 as float)as Decimal(18,6))),          
"On Hand Value" = Sum( Cast(Cast (Field26 as float)as Decimal(18,6))),    
"On Hand Damages Value" = Sum( Cast(Cast (Field27 as float)as Decimal(18,6))),          
"Total On Hand Value" = Sum( Cast(Cast (Field28 as float)as Decimal(18,6)))            
from #temp          
Group By CompanyID          
drop table #temp          


