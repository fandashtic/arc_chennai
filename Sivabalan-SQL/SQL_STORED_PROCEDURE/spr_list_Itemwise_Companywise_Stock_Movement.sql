CREATE Procedure spr_list_Itemwise_Companywise_Stock_Movement (@Manufacturer nvarchar(100),@FromDate Datetime,@ToDate Datetime)      
as      
    
If @Manufacturer = '%'   
begin  
   Set @Manufacturer = 'All Manufacturers'  
end  
Select ReportDetailReceived.Field1 + ';' + @Manufacturer,  
"Item Code" = ReportDetailReceived.Field1,  
"Item Name" = ReportDetailReceived.Field2,      
/*"Category Name" = case when ((min(ReportAbstractReceived.Field3)) <> (max(ReportAbstractReceived.Field3))) Then  
'CATEGORY MISMATCH'  
Else max(ReportAbstractReceived.Field3)  
End,  
*/  
"Opening Quantity" = Sum(Cast(Cast (ReportDetailReceived.Field3 as Decimal(18,6))as Decimal(18,6))),    
"Free Opening Quantity" = Sum(Cast(Cast (ReportDetailReceived.Field4 as Decimal(18,6))as Decimal(18,6))),    
"Damage Opening Quantity" = Sum(Cast(Cast (ReportDetailReceived.Field5 as Decimal(18,6))as Decimal(18,6))),    
"Total Opening Quantity" = Sum(Cast(Cast (ReportDetailReceived.Field6 as Decimal(18,6))as Decimal(18,6))),    
"Opening Value" = Sum(Cast(Cast (ReportDetailReceived.Field7 as Decimal(18,6))as Decimal(18,6))),    
"Damage Opening Value" = Sum(Cast(Cast (ReportDetailReceived.Field8 as Decimal(18,6))as Decimal(18,6))),    
"Total Opening Value" = Sum(Cast(Cast (ReportDetailReceived.Field9 as Decimal(18,6))as Decimal(18,6))),    
"Purchase" = Sum(Cast(Cast (ReportDetailReceived.Field10 as Decimal(18,6))as Decimal(18,6))),    
"Free Purchase" = Sum(Cast(Cast (ReportDetailReceived.Field11 as Decimal(18,6))as Decimal(18,6))),    
"Sales Return Saleable" = Sum(Cast(Cast (ReportDetailReceived.Field12 as Decimal(18,6))as Decimal(18,6))),    
"Sales Return Damages" = Sum(Cast(Cast (ReportDetailReceived.Field13 as Decimal(18,6))as Decimal(18,6))),    
"Total Issues" = Sum(Cast(Cast (ReportDetailReceived.Field14 as Decimal(18,6))as Decimal(18,6))),     
"Free Issues" = Sum(Cast(Cast (ReportDetailReceived.Field15 as Decimal(18,6))as Decimal(18,6))),    
"Sales Value " = Sum(Cast(Cast (ReportDetailReceived.Field16 as Decimal(18,6))as Decimal(18,6))),    
"Purchase Return" = Sum(Cast(Cast (ReportDetailReceived.Field17 as Decimal(18,6))as Decimal(18,6))),    
"Adjustments" = Sum(Cast(Cast (ReportDetailReceived.Field18 as Decimal(18,6))as Decimal(18,6))),    
"Stock Transfer Out" = Sum(Cast(Cast (ReportDetailReceived.Field19 as Decimal(18,6))as Decimal(18,6))),    
"Stock Transfer In" = Sum(Cast(Cast (ReportDetailReceived.Field20 as Decimal(18,6))as Decimal(18,6))),    
"Stock Destruction" = Sum(Cast(Cast (ReportDetailReceived.Field21 as Decimal(18,6))as Decimal(18,6))),    
"On Hand Qty" = Sum(Cast(Cast (ReportDetailReceived.Field22 as  Decimal(18,6))as Decimal(18,6))),    
"On Hand Free Qty" = Sum(Cast(Cast (ReportDetailReceived.Field23 as Decimal(18,6))as Decimal(18,6))),    
"On Hand Damage Qty" = Sum(Cast(Cast (ReportDetailReceived.Field24 as Decimal(18,6))as Decimal(18,6))),    
"Total On Hand Qty" = Sum(Cast(Cast (ReportDetailReceived.Field25 as Decimal(18,6))as Decimal(18,6))),    
"On Hand Value" = Sum(Cast(Cast (ReportDetailReceived.Field26 as Decimal(18,6))as Decimal(18,6))),    
"On Hand Damages Value" = Sum(Cast(Cast (ReportDetailReceived.Field27 as Decimal(18,6))as Decimal(18,6))),    
"Total On Hand Value" = Sum(Cast(Cast (ReportDetailReceived.Field28 as Decimal(18,6))as Decimal(18,6)))      
    
from Reports, ReportAbstractReceived, ReportDetailReceived       
where Reports.ReportID in (Select Max(ReportID) From Reports Where ReportName = 'Stock Movement - Manufacturer'   
And ParameterID in (Select ParameterID From dbo.GetReportParameters2('Stock Movement - Manufacturer')   
Where Manufacturer = @Manufacturer   
And FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate))  
Group by CompanyID
)  
And ReportAbstractReceived.RecordID = ReportDetailReceived.RecordID   
And ReportAbstractReceived.ReportID = Reports.ReportID      
--and ReportDetailReceived.Field3 <> 'Category Name'  
and ReportDetailReceived.Field3 <> 'Opening Quantity'    
and ReportAbstractReceived.Field1 <> 'SubTotal:'    
and ReportAbstractReceived.Field1 <> 'GrandTotal:'  
Group By ReportDetailReceived.Field1,ReportDetailReceived.Field2  
  
  







