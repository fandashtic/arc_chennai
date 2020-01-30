CREATE procedure [dbo].[spc_DebitNote] (@StartDate datetime, @EndDate datetime)
as 
select DocumentID, DocumentDate, Customer.AlternateCode, Vendors.AlternateCode,
NoteValue, Balance, Memo, DebitID, Salesman.Salesman_Name, Flag, DocRef
From DebitNote, Salesman, Customer, Vendors
Where DocumentDate Between @StartDate And @EndDate And
DebitNote.SalesmanID *= Salesman.SalesmanID And
DebitNote.CustomerID *= Customer.CustomerID And
DebitNote.VendorID *= Vendors.VendorID
