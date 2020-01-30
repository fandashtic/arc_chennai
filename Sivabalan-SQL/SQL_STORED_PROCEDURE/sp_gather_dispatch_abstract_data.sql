
CREATE PROCEDURE sp_gather_dispatch_abstract_data(@START_DATE datetime,
					    @END_DATE datetime)
AS
SELECT DispatchID, DispatchDate, CreationTime, Customer.AlternateCode, 
DispatchAbstract.BillingAddress, 
DispatchAbstract.ShippingAddress, RefNumber, NewRefNumber, DocumentID, NewInvoiceID, Status,
Memo1, Memo2, Memo3, MemoLabel1, MemoLabel2, MemoLabel3, Remarks
FROM DispatchAbstract, Customer
WHERE DispatchDate BETWEEN @START_DATE AND @END_DATE And
DispatchAbstract.CustomerID = Customer.CustomerID

