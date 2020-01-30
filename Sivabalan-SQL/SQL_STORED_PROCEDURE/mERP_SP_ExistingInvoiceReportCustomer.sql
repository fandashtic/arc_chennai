
Create Procedure mERP_SP_ExistingInvoiceReportCustomer
AS
Begin
Select M.CustomerID,C.Company_Name,Case When C.Active = 1 Then 'Active' Else 'Inactive' End  As Active from InvoiceReportCustomer_Mapping M
Inner Join Customer C on M.CustomerID = C.CustomerID
End
