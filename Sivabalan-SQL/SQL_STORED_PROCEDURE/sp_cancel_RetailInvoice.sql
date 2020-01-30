CREATE PROCEDURE sp_cancel_RetailInvoice  
  (@InvoiceId int)  
AS  
DECLARE @Batch_Code  int  
DECLARE @Quantity Decimal(18,6)  
DECLARE @InvoiceType int

select @InvoiceType=Invoicetype from invoiceabstract where invoiceid=@InvoiceId
If not exists(Select * From InvoiceAbstract Where Status & 192 = 0 And InvoiceID = @InvoiceID)   
 GoTo AlreadyCancelled  
DECLARE GetReturnedInvoice CURSOR STATIC FOR  
select Batch_Code, Quantity from InvoiceDetail where InvoiceId = @InvoiceId  
OPEN GetReturnedInvoice  
  
FETCH FROM GetReturnedInvoice INTO  @Batch_Code , @Quantity   
WHILE @@FETCH_STATUS = 0  
BEGIN  
 if @InvoiceType=5 or @InvoiceType=6
 begin
  UPDATE batch_products set Quantity = Quantity - @Quantity   
  where Batch_Code = @Batch_Code And (Quantity - @Quantity) >= 0  
 end
 else If @Quantity < 0  
 Begin  
  UPDATE batch_products set Quantity = Quantity + @Quantity   
  where Batch_Code = @Batch_Code And (Quantity + @Quantity) >= 0  
 End  
 Else  
 Begin   
  UPDATE batch_products set Quantity = Quantity + @Quantity where Batch_Code = @Batch_Code  
 End  
 FETCH NEXT FROM GetReturnedInvoice INTO  @Batch_Code , @Quantity   
END  
UPDATE InvoiceAbstract Set CancelDate = Getdate(), Status = InvoiceAbstract.Status | 192, Balance = 0  
Where InvoiceID = @InvoiceID  
CLOSE GetReturnedInvoice  
DEALLOCATE GetReturnedInvoice  
AlreadyCancelled:  





