CREATE Procedure sp_Insert_InvAdjustments (@InvoiceID Int,
					   @ReferenceID Int,
					   @DocumentType Int,
					   @Amount Decimal(18, 6),
					   @AdjReasonID Int, 
					   @TransType Int = 0)
As
Insert Into AdjustmentReference (InvoiceID, ReferenceID, DocumentType, Amount, 
AdjustmentReasonID, Balance, TransactionType) Values 
(@InvoiceID, @ReferenceID, @DocumentType, @Amount, @AdjReasonID, @Amount, @TransType)

