CREATE PROCEDURE [dbo].[sp_gather_so_abstract_data](@START_DATE datetime,
					    @END_DATE datetime)
AS
SELECT SONumber, SODate, DeliveryDate, CreationTime, Customer.AlternateCode, SOAbstract.Value, 
Customer.BillingAddress, Customer.ShippingAddress, CreditTerm.Description, RefNumber, 
POReference, 
DocumentID, PODocReference, Status, Remarks, Salesman.Salesman_Name
FROM SOAbstract
Left Outer Join CreditTerm on SOAbstract.CreditTerm = CreditTerm.CreditID
Inner Join Customer on SOAbstract.CustomerID = Customer.CustomerID
Left Outer Join Salesman on SOAbstract.SalesmanID = Salesman.SalesmanID
WHERE   SODate BETWEEN @START_DATE AND @END_DATE 
	--AND
	--SOAbstract.CreditTerm *= CreditTerm.CreditID And
	--SOAbstract.CustomerID = Customer.CustomerID AND
	--SOAbstract.SalesmanID *= Salesman.SalesmanID

