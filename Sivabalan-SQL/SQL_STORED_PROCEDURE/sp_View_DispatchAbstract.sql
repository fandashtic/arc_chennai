Create PROCEDURE sp_View_DispatchAbstract(@DISPATCHID INT)  
AS  
SELECT RefNumber, DispatchDate, Customer.Company_Name,   
DispatchAbstract.CustomerID, DispatchAbstract.BillingAddress,  
DispatchAbstract.ShippingAddress, InvoiceID, DispatchAbstract.Status,  
DocumentID, NewRefNumber, Memo1, Memo2, Memo3, Remarks, DocRef, DocSerialtype, 
'GroupID'=IsNull(GroupID,-1), SalesmanID, BeatID ,
'GroupName' = dbo.mERP_fn_Get_GroupNames(IsNull(DispatchAbstract.GroupID,-1)) 
FROM DispatchAbstract, Customer  
WHERE DispatchID = @DISPATCHID   
AND DispatchAbstract.CustomerID = Customer.CustomerID  
