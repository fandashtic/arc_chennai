CREATE procedure sp_insert_sentinvoice(@CustID nvarchar(30),@InvoiceId int,@DocReference nvarchar(30),@InvoiceDate datetime)    
as   
Declare @CustomerId nvarchar(30) 
if @InvoiceId=0   
set @InvoiceId=null
select @CustomerId=customerId from customer where alternatecode=@CustID  
insert into sentInvoices(CustomerId,InvoiceId,DocReference,InvoiceDate,CustID) values(@CustID,@InvoiceId,@DocReference,@InvoiceDate,@CustomerId)    
    
    


    
    

    
    
    
  
    
    
    
    
  




