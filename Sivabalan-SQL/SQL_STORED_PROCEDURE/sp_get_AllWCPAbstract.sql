CREATE Procedure sp_get_AllWCPAbstract (@WCPFromDate Datetime,@WCPToDate datetime, @Salesman NVarchar(15)='')          
as           
if @salesman=''    
begin        
SELECT WCPAbstract.salesmanid,docref,documentid,documentdate,
status,salesman.salesman_name, wcpabstract.code, WcpAbstract.WeekDate       
FROM WCPAbstract,Salesman        
WHERE wcpabstract.salesmanID = salesman.salesmanCode        
and (wcpAbstract.documentDate between @wcpFromDate and @wcpToDate)          
order by salesman.salesman_name,code        
end        
else        
begin        
SELECT WCPAbstract.salesmanid,docref,documentid,documentdate,status,
salesman.salesman_name, wcpabstract.code, WcpAbstract.WeekDate
FROM WCPAbstract,Salesman        
WHERE wcpabstract.salesmanID = salesman.salesmanCode    
and (wcpAbstract.documentDate between @wcpFromDate and @wcpToDate)          
and  wcpabstract.salesmanid =@salesman        
order by salesman.salesman_name,code        
end        


