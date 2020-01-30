CREATE procedure sp_get_sentinvoice(@CustID nvarchar(30),@InvoiceId int,@DocReference nvarchar(30),@InvoiceDate datetime,@retVal int=0 output)        
as        
Declare @bFound int        
set @bFound=0        
if(exists(select customerId from sentInvoices where customerId=@CustId and InvoiceID=@Invoiceid and InvoiceDate=@Invoicedate) and @InvoiceId<>'')        
set @bFound=1        
if exists(select customerId from sentInvoices where customerId=@CustId and InvoiceId=@InvoiceId and DocReference=@DocReference and Invoicedate=@InvoiceDate)        
set @bFound=1        
if(Not exists(Select customerId from sentinvoices where DocReference=@DocReference) or @InvoiceId='')    
if exists(select customerId from sentInvoices where customerId=@CustId and DocReference=@DocReference and InvoiceDate=@Invoicedate)        
set @bFound=1        
set @retVal=@bFound  
select @bFound        
        
        
        
        
        
        
      
        
      
    
  


