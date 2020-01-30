CREATE procedure [dbo].[spr_Consolidate_NonMoving_Stock](@CompanyID nvarchar(100),@FromDate Datetime, @ToDate datetime)       
as      
Declare @SALEABLESTOCK As NVarchar(50)
Declare @SUBTOTAL As NVarchar(50)
Declare @GRNTOTAL As NVarchar(50)

Set @SALEABLESTOCK = dbo.LookupDictionaryItem(N'Saleable Stock', Default)
Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)

Select Reports.CompanyID, Reports.CompanyID,        
"Saleable Stock" = Sum(cast(cast (ReportAbstractReceived.Field6 as Decimal(18,6)) as Decimal(18,6))),      
"Damaged Stock" = Sum(cast(cast (ReportAbstractReceived.Field7 as Decimal(18,6)) as Decimal(18,6))),    
"Free Stock" = Sum(cast(cast (ReportAbstractReceived.Field8 as Decimal(18,6)) as Decimal(18,6))),      
"Total Stock" = Sum(cast(cast (ReportAbstractReceived.Field10 as Decimal(18,6)) as Decimal(18,6))),    
"Total Value" = Sum(cast(cast (ReportAbstractReceived.Field11 as Decimal(18,6)) as Decimal(18,6)))       
from Reports, ReportAbstractReceived, ReportDetailReceived
where Reports.ReportID = ReportAbstractReceived.ReportID      
and ReportAbstractReceived.RecordID *= ReportDetailReceived.RecordID 
and Reports.ReportID in (Select Max(ReportID) From Reports Where ReportName ='Non Moving Stock' And CompanyID like @COMPANYID  
And ParameterID in (Select ParameterID From dbo.GetReportParameters(@COMPANYID, 'Non Moving Stock')   
Where FromDate = dbo.StripDateFromTime(@FROMDATE) And ToDate = dbo.StripDateFromTime(@TODATE)) Group By CompanyID)  
and ReportAbstractReceived.Field6 <> @SALEABLESTOCK      
and ReportAbstractReceived.Field1 <> @SUBTOTAL     
and ReportAbstractReceived.Field1 <> @GRNTOTAL     
Group by Reports.CompanyID
