CREATE procedure [dbo].[sp_get_SVInfo](@SVNUMBER INT)                
AS                
SELECT 
	SVDate,DeliveryDate, Customer.Company_Name, SVAbstract.Value,                 
	SVAbstract.BillingAddress, SVAbstract.ShippingAddress, DocRef,                
	CreditTerm.Description as CreditTerm, SVAbstract.CustomerID,
 Status,DocumentID, Remarks,DocSerialType ,DocumentReference,              
	Beat.Description as BeatName, SalesMan.SalesMan_Name,
	SVAbstract.OHDPre,SalesmanRemarks
FROM 
	SVAbstract, Customer, CreditTerm, Beat, SalesMan                
WHERE 
	SVAbstract.SVNumber = @SVNUMBER                 
	AND SVAbstract.CustomerID = Customer.CustomerID                
	AND CreditTerm.CreditID = SVAbstract.CreditTerm                
	And SVAbstract.BeatID *= Beat.BeatID 
	And SVAbstract.SalesManCode *= SalesMan.SalesManCode
