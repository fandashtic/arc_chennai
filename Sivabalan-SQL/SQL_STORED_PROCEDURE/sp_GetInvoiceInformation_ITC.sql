CREATE Procedure sp_GetInvoiceInformation_ITC (@InvoiceID int)
As
Begin
SELECT InvoiceAbstract.CustomerID, Customer.Company_Name, InvoiceAbstract.PaymentDate, ISNULL(InvoiceAbstract.CreditTerm, 0) as CreditTerm,
InvoiceAbstract.BillingAddress, InvoiceAbstract.ShippingAddress, InvoiceAbstract.AdditionalDiscount, InvoiceAbstract.DiscountPercentage,
InvoiceAbstract.Freight, InvoiceAbstract.GrossValue, InvoiceAbstract.NetValue, InvoiceAbstract.Memo1, InvoiceAbstract.Memo2, InvoiceAbstract.Memo3,
InvoiceAbstract.Balance, InvoiceAbstract.RoundOffAmount, InvoiceAbstract.Flags, InvoiceAbstract.BeatID, InvoiceAbstract.GroupID, InvoiceAbstract.SalesmanID,
Salesman.Salesman_Name, Beat.Description, dbo.mERP_fn_Get_GroupNames(GroupID) as 'GroupName',
--"TinNumber" = customer.Tin_Number,
"TinNumber" = isnull(InvoiceAbstract.GSTIN,''),
"SupervisorID" = 	ISNULL(InvoiceAbstract.Salesman2, 0),
isNull(InvoiceAbstract.MultipleSchemeDetails,'') MultipleSchemeDetails,
isnull(InvoiceAbstract.AlternateCGCustomerName,'') CGCustomerName
FROM InvoiceAbstract
Inner Join Customer on InvoiceAbstract.CustomerID = Customer.CustomerID
Left Join Salesman on InvoiceAbstract.SalesmanID = Salesman.SalesmanID
Left join Beat on InvoiceAbstract.BeatID = Beat.BeatID

WHERE
--InvoiceAbstract.CustomerID = Customer.CustomerID
--And InvoiceAbstract.SalesmanID *= Salesman.SalesmanID
--And InvoiceAbstract.BeatID *= Beat.BeatID
--And
InvoiceID = @InvoiceID
End
