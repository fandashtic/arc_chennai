Create  procedure [dbo].[spr_salesmanwise_collections]      
(@fromdate as datetime,      
 @todate as datetime) as      
Declare @MLOthers NVarchar(50)
Set @MLOthers = dbo.LookupDictionaryItem(N'Others', Default)

select Isnull(collections.salesmanid, 0),       
"Salesman Name"= case Isnull(collections.Salesmanid,0)    
 when 0 then @MLOthers    
 else Salesman_Name    
end,      
"Total Collections"= sum(value)       
from collections
Left Outer Join salesman On Salesman.SalesmanId = collections.Salesmanid
where documentdate between @fromdate and @todate       
and (IsNull(Collections.Status, 0) & 64) = 0     
And (IsNull(Collections.Status,0) & 128) = 0     
group by Isnull(collections.salesmanid, 0),salesman_name 

