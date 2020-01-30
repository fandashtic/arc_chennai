CREATE procedure [dbo].[spc_CreditNote] (@Start_Date datetime, @End_Date datetime)
as
Select DocumentID, DocumentDate, Customer.AlternateCode, Vendors.AlternateCode, 
NoteValue, Balance, Memo, CreditID,
Salesman.Salesman_Name, DocPrefix, DocRef
From CreditNote, Salesman, Customer, Vendors
Where DocumentDate Between @Start_Date And @End_Date And
CreditNote.SalesmanID *= Salesman.SalesmanID And
CreditNote.CustomerID *= Customer.CustomerID And
CreditNote.VendorID *= Vendors.VendorID
