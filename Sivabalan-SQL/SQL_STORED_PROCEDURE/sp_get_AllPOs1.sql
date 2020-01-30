
CREATE Procedure sp_get_AllPOs1 (@i int) as 
Select Customer.Company_Name,POAbstractReceived.PONumber,
POAbstractReceived.PODate,POAbstractReceived.Value from 
POAbstractReceived,customer
where POAbstractReceived.Status=1 and 
Customer.CustomerID=POAbstractReceived.CustomerID 
and (POAbstractReceived.PODate between '10/23/2001'  and '10/23/2001')
order by Customer.company_Name,POAbstractReceived.PODate


