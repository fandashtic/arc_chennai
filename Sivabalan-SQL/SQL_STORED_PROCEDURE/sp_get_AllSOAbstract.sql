CREATE Procedure sp_get_AllSOAbstract (@SOFromDate Datetime,@SOToDate datetime)    
as     
set Dateformat DMY
Declare @Expirydate datetime
set @Expirydate= dbo.getSOExpiryDate() 

Select Customer.CustomerID, Customer.Company_Name, SOAbstract.SONumber,      
SOAbstract.SODate, SOAbstract.Value, SOAbstract.DeliveryDate, PODocReference, SOAbstract.DocumentID,  SV.DocumentID    
From   SOAbstract
 inner join Customer on  Customer.CustomerID=SOAbstract.CustomerID    
left outer join SVAbstract SV      on  SOAbstract.SalesVisitNumber = SV.SVNumber  
where ((SOAbstract.Status & 192) = 0)       
and (SOAbstract.SODate between @SOFromDate and @SOToDate)      
And Convert(Nvarchar(10),SOAbstract.SODate,103) > @Expirydate 
order by Customer.Company_Name, SOAbstract.SONumber  
  
  


