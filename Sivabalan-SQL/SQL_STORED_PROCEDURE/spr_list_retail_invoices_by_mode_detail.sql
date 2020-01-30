CREATE procedure [dbo].[spr_list_retail_invoices_by_mode_detail] (@PaymentMode nvarchar(255),                
               @FromDate Datetime,                
               @ToDate Datetime)                
As                
        
Declare @PaymentInfo As nvarchar(20)               
Declare @Voucher as nvarchar(20)       
Declare @Type as nvarchar(100)  
  
If @PaymentMode = 'Credit'  
Set @Type = 0  
Else  
Set @Type = 1  
  
Select @Voucher = Prefix From VoucherPrefix Where TranID = 'INVOICE'           
        
If Rtrim(@PaymentMode) = 'Post Dated Cheque'                 
Begin                 
 Select 1,         
 "InvoiceID" = @Voucher + Cast(DocumentID as nvarchar),           
 "Customer" = Company_Name, "Invoice Date" = InvoiceDate,           
 "Net Value (%c)" = NetValue - ISNULL(Freight,0)              
 From InvoiceAbstract, Customer              
 Where          
 InvoiceAbstract.InvoiceType = 2 And                
 InvoiceAbstract.CustomerID *= Cast(Customer.CustomerID As nvarchar)        
 And InvoiceDate Between @FROMDATE And @TODATE And          
 (InvoiceAbstract.Status & 128) = 0 And PaymentMode = 1               
End                    
Else           
Begin                
 Select 1,         
 "InvoiceID" = @Voucher + Cast(DocumentID as nvarchar),           
 "Customer" = Company_Name, "Invoice Date" = InvoiceDate,           
 "Net Value (%c)" = NetValue - ISNULL(Freight,0),          
 "Amount Adjusted (%c)" = Case PaymentMode When 1 Then  
  --dbo.fn_GetAmountCollected(InvoiceAbstract.PaymentDetails, @PaymentMode)   
	(Select NetRecieved from RetailPaymentDetails Where 
	RetailInvoiceID = InvoiceAbstract.InvoiceID and PaymentMode in (SELECT Mode 
	FROM paymentmode Where Value = @PaymentMode))

  Else  
   NetValue - ISNULL(Freight,0)  
  End  
 From InvoiceAbstract, Customer , VoucherPrefix             
 Where          
 InvoiceAbstract.InvoiceType = 2 And                
 InvoiceAbstract.CustomerID = Cast(Customer.CustomerID As nvarchar)        
 And InvoiceDate Between @FROMDATE And @TODATE And          
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And                
 VoucherPrefix.TranID = 'INVOICE' And PaymentMode = @Type And 0 <>  
 Case @Type When 1 Then   
	(Select NetRecieved from RetailPaymentDetails Where 
	RetailInvoiceID = InvoiceAbstract.InvoiceID and PaymentMode in (SELECT Mode 
	FROM paymentmode Where Value = @PaymentMode))
 Else  
 1  
 End  
End
