CREATE Procedure sp_get_CancelSO (@CustomerID nVarchar (15),
				  @SOFromDate datetime,
				  @SOToDate datetime,
				  @STATUS INT)
as
 
Select SOAbstract.CustomerID,Customer.Company_Name,SOAbstract.SONumber,
SOAbstract.SODate, Value, Status, DocumentID,documentReference,DocSerialType,SoAbstract.SoRef as SORef 
from SOAbstract,customer
where ((SOAbstract.Status & @STATUS)=0) and  
Customer.CustomerID=SOAbstract.CustomerID 
and SOAbstract.CustomerID like @CustomerID
and (SOAbstract.SODate between @SOFromDate and @SOToDate) 
order by Customer.Company_Name, SOAbstract.SODate 


