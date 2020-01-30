
CREATE Procedure sp_get_POs (@CustomerID nVarchar (15),@POFromDate datetime,@POToDate datetime)
 as 
Select POAbstractReceived.CustomerID,Customer.Company_Name,POAbstractReceived.PONumber,
POAbstractReceived.PODate,POAbstractReceived.Value, POReference, DocumentID,
POAbstractReceived.RequiredDate, POAbstractReceived.POPrefix
from 
POAbstractReceived,customer
where ((POAbstractReceived.Status & 128)=0) and  
Customer.CustomerID=POAbstractReceived.CustomerID 
and POAbstractReceived.CustomerID = @CustomerID
and (POAbstractReceived.PODate between @POFromDate and @POToDate) 
order by POAbstractReceived.PODate 



