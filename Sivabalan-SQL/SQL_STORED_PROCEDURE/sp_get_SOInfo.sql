CREATE PROCEDURE sp_get_SOInfo(@SONUMBER INT)  
AS  
SELECT
 SODate, DeliveryDate, Customer.Company_Name, SOAbstract.Value,   
 SOAbstract.BillingAddress, SOAbstract.ShippingAddress, RefNumber,  
 CreditTerm.Description, PODocReference, SOAbstract.CustomerID, Status,  
 DocumentID, Remarks,DocSerialType,DocumentReference,"POReference"=POReference,
 Beat.Description, SalesMan.SalesMan_Name,Beat.BeatID,IsNull(GroupID,'-1'),
 isNull(SupervisorID,0),
 isNull((Select SalesmanName From Salesman2 Where SalesmanID = isNull(SupervisorID,0)),'')
FROM
 SOAbstract
 inner join Customer on  SOAbstract.CustomerID = Customer.CustomerID  
 inner join CreditTerm on  CreditTerm.CreditID = SOAbstract.CreditTerm  
 left outer join Beat on  SoAbstract.BeatID = Beat.BeatID  
 left outer join SalesMan on SoAbstract.SalesManID = SalesMan.SalesManID
WHERE
 SOAbstract.SONumber = @SONUMBER   
 
