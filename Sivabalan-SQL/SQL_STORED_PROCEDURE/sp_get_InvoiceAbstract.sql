Create PROCEDURE sp_get_InvoiceAbstract(@INVOICENO INT)
AS
BEGIN

Declare @GroupID as nVarchar(500)
Declare @GroupNames as nVarchar(1000)

Select @GroupID = isNull(GroupID,'-1') From InvoiceAbstract Where InvoiceID = @INVOICENO

if isNull(@GroupID,'-1' ) <> '-1'
Select  @GroupNames = dbo.mERP_fn_Get_GroupNames(@GroupID)

SELECT InvoiceType, InvoiceDate, InvoiceAbstract.CustomerID,
Customer.Company_Name, InvoiceAbstract.BillingAddress,
InvoiceAbstract.ShippingAddress, GrossValue, DiscountPercentage,
DiscountValue, NetValue, InvoiceReference, ReferenceNumber,
AdditionalDiscount, Freight, InvoiceAbstract.CreditTerm,
CreditTerm.Description, InvoiceAbstract.Status, DocumentID, NewReference,
Memo1, Memo2, Memo3, InvoiceAbstract.PaymentMode, InvoiceAbstract.PaymentDetails,
Salesman2.SalesmanName, InvoiceAbstract.Balance, InvoiceAbstract.SalesmanID,
InvoiceAbstract.DocReference, InvoiceAbstract.RoundOffAmount,
InvoiceAbstract.AdjustmentValue, InvoiceAbstract.TaxOnMRP,DocSerialType, InvoiceAbstract.GroupID,
@GroupNames As "GroupName",Beat.Description, Beat.BeatID, InvoiceAbstract.Flags,
Salesman.Salesman_Name, IsNull(Customer.Locality, 1) Locality,"DeliveryDate" = DeliveryDate,
--"TinNumber" = Customer.TIN_Number,
"TinNumber" = isnull(InvoiceAbstract.GSTIN,''),
"AddlDiscountValue" =  AddlDiscountValue, "GSTSerialNo" = GSTFullDocID, "GSTFLAG" = isnull(GSTFlag,0)
FROM InvoiceAbstract
inner join Customer on InvoiceAbstract.CustomerID = Customer.CustomerID
left outer join CreditTerm on  InvoiceAbstract.CreditTerm = CreditTerm.CreditID
left outer join Salesman2 on InvoiceAbstract.Salesman2 = Salesman2.SalesmanID
left outer join Beat on  InvoiceAbstract.BeatID = Beat.BeatID
left outer join Salesman on  InvoiceAbstract.SalesmanID = Salesman.SalesmanID
WHERE
InvoiceAbstract.InvoiceID = @INVOICENO
END
