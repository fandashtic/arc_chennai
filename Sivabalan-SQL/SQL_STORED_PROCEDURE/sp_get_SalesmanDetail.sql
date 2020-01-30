CREATE Procedure sp_get_SalesmanDetail  
(@SalesmanID INT)  
as  
Select s.SalesmanID,s.Target,s.measureID,t.Description,s.Period,s.Remarks, p.Period 
from salesmanTarget s
Left Join TargetMeasure t ON s.measureID =t.measureID
Left Join TargetPeriod p ON s.Period = p.PeriodID  
where salesmanID=@SalesmanID 
order by s.Target desc  
