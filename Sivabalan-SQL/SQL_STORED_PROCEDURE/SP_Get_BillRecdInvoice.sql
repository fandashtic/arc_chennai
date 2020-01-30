CREATE Procedure [dbo].[SP_Get_BillRecdInvoice] (@GRNID Int)
As
Select IsNull(RecdInvoiceID, 0), InvoiceAbstractReceived.DocumentID,
IsNull(InvoiceAbstractReceived.DiscountPercentage, 0) 
+ IsNull(InvoiceAbstractReceived.AdditionalDiscount, 0),
IsNull(InvoiceAbstractReceived.NetValue, 0),
IsNull(InvoiceAbstractReceived.NetAmountAfterAdjustment, 0),
InvoiceAbstractReceived.InvoiceID
From GRNAbstract
Left Outer Join InvoiceAbstractReceived on IsNull(GRNAbstract.RecdInvoiceID, 0) = InvoiceAbstractReceived.InvoiceID
Where GRNID = @GRNID 
--And IsNull(GRNAbstract.RecdInvoiceID, 0) *= InvoiceAbstractReceived.InvoiceID

