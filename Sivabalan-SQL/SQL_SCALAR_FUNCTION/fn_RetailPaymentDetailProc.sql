Create Function fn_RetailPaymentDetailProc(@InvoiceID as Int, @Mode as Int)        
RETURNS nvarchar(2000)        
As        
Begin        
 DECLARE @DISPLAYTABLE Table (Details nvarchar(500))        
 DECLARE @DETAIL nvarchar(2000)        
 DECLARE @PRINTDETAIL nvarchar(2000)        
 DECLARE @AMOUNT Decimal(18,6)        
 DECLARE @RESULT nvarchar(2000)        
 If @Mode = 1  -- we have to display PaymentDetails       
  Begin    --  Inserting the PaymentDetails in the Virtual Table    
  
 If Not Exists(Select PaymentMode.Value + N':' + Cast(NetRecieved as nvarchar) +         
    Case PaymentMode.PaymentType         
     When 1 Then N''        
     When 6 Then N''        
     Else        
      + N':' + Replace(Replace(RetailPaymentDetails.Paymentdetails,Char(2),N':'),Char(5),N',')         
    End        
    From invoiceabstract, RetailPaymentDetails, PaymentMode        
    Where invoiceid = retailinvoiceid     
 And RetailPaymentDetails.PaymentMode = PaymentMode.Mode     
 And invoiceid = @InvoiceID)  
 Goto Cont  
  
   Insert @DISPLAYTABLE         
   Select PaymentMode.Value + N':' + Cast(NetRecieved as nvarchar) +         
    Case PaymentMode.PaymentType         
     When 1 Then N''        
     When 6 Then N''        
     Else        
      + N':' + Replace(Replace(RetailPaymentDetails.Paymentdetails,Char(2),N':'),Char(5),N',')         
    End        
    From invoiceabstract, RetailPaymentDetails, PaymentMode        
    Where invoiceid = retailinvoiceid     
 And RetailPaymentDetails.PaymentMode = PaymentMode.Mode     
 And invoiceid = @InvoiceID        
   Set @PRINTDETAIL = N''  --  Initialize the variable    
   Declare detailCursor Cursor For Select Details from @DisplayTable        
   Open detailCursor        
   Fetch Next From detailCursor into @DETAIL        
   While @@Fetch_Status = 0        
   Begin        
     Set @PRINTDETAIL = @PRINTDETAIL + @DETAIL + N';'        
      Fetch Next From detailCursor into @DETAIL            
 End        
   Close detailCursor        
   DeAllocate detailCursor        
   Set @PRINTDETAIL = Left(@PRINTDETAIL, (CharIndex(N';', @PRINTDETAIL, Len(@PRINTDETAIL)) -1))        
Cont:  
   SELECT @RESULT = IsNull(@PRINTDETAIL,N'') -- Return the PaymentDetail       
  End        
 Else If @Mode = 2    -- Amount Returned to the Customer    
  Begin        
    Select @Amount = IsNull(Sum(AmountReturned),0)     
   From invoiceabstract, RetailPaymentDetails        
     Where invoiceid = retailinvoiceid     
   And Invoiceid = @InvoiceID              
    SELECT @RESULT = @Amount        
  End        
 Else If @Mode = 3    -- Showing the Balance Amount    
  Begin        
    Select @Amount = IsNull(Sum(NetRecieved - CustomerServiceCharge),0)     
   From invoiceabstract, RetailPaymentDetails        
     Where invoiceid = retailinvoiceid     
   And Invoiceid = @InvoiceID        
    SELECT @RESULT = @Amount        
  End        
 Else     --  Showing the total Customer Server Charge    
  Begin        
    Select @Amount = IsNull(Sum(CustomerServiceCharge),0)     
   From invoiceabstract, RetailPaymentDetails     
   Where invoiceid = retailinvoiceid     
   And Invoiceid = @InvoiceID        
    SELECT @RESULT = @Amount        
  End        
RETURN(@RESULT)            
End        
       


