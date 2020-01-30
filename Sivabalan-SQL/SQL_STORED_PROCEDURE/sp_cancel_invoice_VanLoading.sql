CREATE PROCEDURE sp_cancel_invoice_VanLoading    
  (@InvoiceId int,@Reason Nvarchar(255))    
AS    
DECLARE @Batch_Code  int    
DECLARE @Quantity Decimal(18,6)    
DECLARE @DocSerial int    
DECLARE @PaymentDetails int    
Declare @ReasonID as Int
Set @ReasonID = (Select Top 1 Isnull(ID,0) From InvoiceReasons Where Reason = @Reason And [Type] = 'Invoice Cancellation')
    
SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @InvoiceID) as int)    
IF Exists (select DocumentID from collections Where (IsNull(Status,0) & 64) = 0 And DocumentID = @PaymentDetails)    
BEGIN    
 exec sp_Cancel_Collection @PaymentDetails    
 if exists(Select ReferenceID From AdjustmentReference Where InvoiceID = @InvoiceID and TransactionType = 0)    
 Begin    
  Update DebitNote Set Status = 192, Balance = 0    
  Where DebitID In (Select ReferenceID From AdjustmentReference    
  Where InvoiceID = @InvoiceID And DocumentType = 5 and TransactionType = 0)       
  Update CreditNote Set Status = 192, Balance = 0    
  Where CreditID In (Select ReferenceID From AdjustmentReference    
  Where InvoiceID = @InvoiceID And DocumentType = 2 and TransactionType = 0)       
  Update AdjustmentReference Set Status = 128 Where InvoiceID = @InvoiceID and TransactionType = 0   
 End    
END    
Select @DocSerial = CAST(ReferenceNumber AS int) From InvoiceAbstract Where InvoiceID = @InvoiceID    
DECLARE GetReturnedInvoice CURSOR STATIC FOR    
select Batch_Code, Quantity from InvoiceDetail where InvoiceId = @InvoiceId    
OPEN GetReturnedInvoice    
    
FETCH FROM GetReturnedInvoice INTO  @Batch_Code , @Quantity     
WHILE @@FETCH_STATUS = 0    
BEGIN    
 UPDATE VanStatementDetail set Pending = Pending + @Quantity     
 where [ID] = @Batch_Code    
 FETCH NEXT FROM GetReturnedInvoice INTO  @Batch_Code , @Quantity     
END    
UPDATE InvoiceAbstract Set CancelDate = Getdate(), Status = InvoiceAbstract.Status | 192, Balance = 0  ,CancelReasonID = @ReasonID      
Where InvoiceID = @InvoiceID    
UPDATE VanStatementAbstract Set Status = 0 where DocSerial = @DocSerial    
Update DispatchAbstract Set Status = Status | 192 Where InvoiceID in (@InvoiceID)    
CLOSE GetReturnedInvoice    
DEALLOCATE GetReturnedInvoice    
SET QUOTED_IDENTIFIER OFF
