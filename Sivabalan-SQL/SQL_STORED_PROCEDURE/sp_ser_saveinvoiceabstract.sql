CREATE procedure  sp_ser_saveinvoiceabstract
(@InvoiceDate DateTime, @ServiceInvoiceType Int, @JobCardID Int, @CustomerID nvarchar(50), 
@UserName nvarchar(255), @DocReference nvarchar(255), @PaymentMode Int, 
@NetValue decimal(18,6), @Balance decimal(18,6), @PaymentDate datetime, 
@RoundOffAmount decimal(18,6), @TradeDiscountPercentage Decimal(18,6), 
@TradeDiscountValue decimal(18,6), @AdditionalDiscountPercentage decimal(18,6), 
@AdditionalDiscountValue decimal(18,6), @TotalTaxSuffered Decimal(18,6), 
@TotalTaxApplicable decimal(18,6), @ItemDiscount decimal(18,6), 
@TotalServiceTax decimal(18,6), @BillingAddress nvarchar(510), 
@ShippingAddress nvarchar(510), @Freight decimal(18,6), @CreditTerm int, 
@SpareTradeDisc decimal(18,6), @SpareADisc decimal(18,6), 
@TaskTradeDisc decimal(18,6), @TaskADisc decimal(18,6),@DocSerialType nvarchar(100), 
@AdjustmentValue decimal(18,6), @Status int = 0)
as
Declare @InvoiceID Int
Declare @DocumentID Int
begin tran
	update DocumentNumbers set DocumentID = DocumentID + 1, 
				@DocumentID = DocumentID where DocType = 103
commit tran

Insert into ServiceInvoiceAbstract (ServiceInvoiceDate, DOCUMENTID, ServiceInvoiceType, 
JobCardID, CustomerID, Username, DOCREFERENCE, PAYMENTMODE, NETVALUE, Balance, 
PaymentDate, RoundOffAmount, TradeDiscountPercentage, TradeDiscountValue, 
AdditionalDiscountPercentage, AdditionalDiscountValue, TotalTaxSuffered, TotalTaxApplicable, 
ItemDiscount, TotalServiceTax, BillingAddress, ShippingAddress, 
Freight, CreditTerm, TradeDiscountValue_Task, TradeDiscountValue_Spare, 
AdditionalDiscountValue_Task, AdditionalDiscountValue_Spare, Status, DocSerialType, 
AdjustmentValue)
Values 
(@InvoiceDate, @DocumentID, @ServiceInvoiceType, 
@JobCardID, @CustomerID, @UserName, @DocReference, @PaymentMode, @NetValue, 
@Balance, @PaymentDate, @RoundOffAmount, @TradeDiscountPercentage, @TradeDiscountValue, 
@AdditionalDiscountPercentage, @AdditionalDiscountValue, @TotalTaxSuffered, 
@TotalTaxApplicable, @ItemDiscount, @TotalServiceTax, @BillingAddress, @ShippingAddress, 
@Freight, @CreditTerm, @TaskTradeDisc, @SpareTradeDisc, 
@TaskADisc, @SpareADisc, @Status, @DocSerialType, @AdjustmentValue)

Set @InvoiceID = @@Identity

/* Update Jobcardabstract to 32 */
Update JobCardAbstract Set ServiceInvoiceID = @InvoiceID, Status = (Isnull(Status, 0) | 32) 
	where JobCardID = @JobCardId

Select @InvoiceID, @DocumentID
/*
procedure to save Service Invoice and update Jobcard status to 32 
Service invoice abstract status will be 1 for jobcard based invoice and 8 for Direct invoice 
Direct invoice status will be updated thr sp_ser_updatedirinvoicebase
*/



