
CREATE Procedure sp_get_AllPOs (@POFromDate Datetime,@POToDate datetime)
 as 

Select POAbstractReceived.CustomerID,Customer.Company_Name,POAbstractReceived.PONumber,
POAbstractReceived.PODate,POAbstractReceived.Value, POReference, DocumentID,
POAbstractReceived.RequiredDate, POAbstractReceived.POPrefix
from POAbstractReceived,customer
where ((POAbstractReceived.Status & 128)=0) and 
Customer.CustomerID=POAbstractReceived.CustomerID and customer.Active=1
and (POAbstractReceived.PODate between @POFromDate and @POToDate)
order by Customer.company_Name,POAbstractReceived.PODate



