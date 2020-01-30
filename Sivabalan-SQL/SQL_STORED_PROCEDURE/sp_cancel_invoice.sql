Create PROCEDURE sp_cancel_invoice    
  (@InvoiceId int,@Reason Nvarchar(255),@UserID Nvarchar(50) = '')    
AS    
DECLARE @Batch_Code  int    
DECLARE @Quantity Decimal(18,6)    
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
DECLARE GetReturnedInvoice CURSOR STATIC FOR    
select Batch_Code, Quantity from InvoiceDetail where InvoiceId = @InvoiceId    
OPEN GetReturnedInvoice    
    
FETCH FROM GetReturnedInvoice INTO  @Batch_Code , @Quantity     
WHILE @@FETCH_STATUS = 0    
BEGIN    
 UPDATE batch_products set Quantity = Quantity + @Quantity where Batch_Code = @Batch_Code    
 FETCH NEXT FROM GetReturnedInvoice INTO  @Batch_Code , @Quantity     
END    
UPDATE InvoiceAbstract Set CancelDate = Getdate() , Status = InvoiceAbstract.Status | 192, Balance = 0 ,
CancelReasonID = @ReasonID,CancelUser = @UserID Where InvoiceID = @InvoiceID    
Update DispatchAbstract Set Status = Status | 192 Where InvoiceID in (@InvoiceID)    
-- exec sp_update_scheme_invoice_cancel @InvoiceID    
CLOSE GetReturnedInvoice    
DEALLOCATE GetReturnedInvoice    
If exists (select * from sysobjects where xtype = 'u' and name = 'tbl_mERP_OutletPoints')  
	update tbl_mERP_OutletPoints set Status = 1 where invoiceid = @InvoiceId
