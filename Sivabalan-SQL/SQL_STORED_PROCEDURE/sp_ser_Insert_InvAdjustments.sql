CREATE Procedure sp_ser_Insert_InvAdjustments (@InvoiceID Int,
					   @ReferenceID Int,
					   @DocumentType Int,
					   @Amount Decimal(18, 6),
					   @AdjReasonID Int)
As
Insert Into Service_AdjustmentReference (ServiceInvoiceID, ReferenceID, DocumentType, Amount, 
	AdjustmentReasonID, Balance) Values 
	(@InvoiceID, @ReferenceID, @DocumentType, @Amount, @AdjReasonID, @Amount)

