CREATE procedure sp_insert_sentInvoices(@FromDate datetime,@ToDate datetime)        
as        
Declare @DocId int        
Declare @DocRef nvarchar(100)        
Declare @CustId nvarchar(30)        
Declare @InvDate datetime        
declare @bFound int        
Declare cur_inv Cursor for        
select AlternateCode,InvoiceId,IsNull(DocReference,N''),dbo.stripdatefromtime(InvoiceDate) from invoiceabstract,customer where Invoiceabstract.CustomerId=Customer.CustomerId and InvoiceDate <=@ToDate
and status & 128=0      
and status &64=0      
open cur_inv         
fetch cur_inv into @CustId,@DocID,@DocRef,@InvDate        
while(@@FETCH_STATUS=0)        
Begin        
Exec sp_get_sentInvoice @CustId,@DocID,@DocRef,@InvDate,@bFound output        
if @bFound=0         
exec sp_insert_sentinvoice @CustId,@DocId,@DocRef,@InvDate    
fetch cur_inv into @CustId, @DocID,@DocRef,@InvDate        
End        
close cur_inv        
deallocate cur_inv         
  







