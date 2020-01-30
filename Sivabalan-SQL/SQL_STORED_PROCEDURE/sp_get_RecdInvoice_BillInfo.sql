Create Procedure sp_get_RecdInvoice_BillInfo (@GRNID Int)
As
Declare @InvoiceID Int

Select @InvoiceID = RecdInvoiceID From GRNAbstract Where GRNID = @GRNID
Select DocumentID, IsNull(DiscountPercentage, 0) + IsNull(AdditionalDiscount, 0),
NetValue, NetAmountAfterAdjustment From InvoiceAbstractReceived Where InvoiceID = @InvoiceID
