CREATE Procedure sp_get_CancelSV (@CustomerID nVarchar (15),    
      @SVFromDate datetime,    
      @SVToDate datetime,    
      @STATUS INT)    
as    
     
Select SVAbstract.CustomerID,Customer.Company_Name,SVAbstract.SVNumber,    
SVAbstract.SVDate, 0, Status, DocumentID,documentReference,DocSerialType,SVAbstract.SVRef
from SVAbstract,customer    
where ((SVAbstract.Status & @STATUS)=0) and      
Customer.CustomerID=SVAbstract.CustomerID     
and SVAbstract.CustomerID like @CustomerID    
and (SVAbstract.SVDate between @SVFromDate and @SVToDate)     
order by Customer.Company_Name, SVAbstract.SVDate     
    
    
  


