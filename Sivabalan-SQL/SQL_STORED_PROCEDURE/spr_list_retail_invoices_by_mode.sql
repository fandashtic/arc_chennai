CREATE PROCEDURE spr_list_retail_invoices_by_mode(@FROMDATE datetime, @TODATE datetime)        
AS        
DECLARE @PaymentType nvarchar(255)   
DECLARE @PaymentID Int    
DECLARE @PayDetail nvarchar(255)      
Declare @PaymentMode int  
Declare @NetValue Decimal(18,6)  
DECLARE @Pos int      
Declare @Status int  
Declare @CheckStatus int  
Declare @Mode nvarchar(100)  
Set @Status = 0  
Set @CheckStatus = 0  
CREATE TABLE #temp(Payment nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS null,            
  Amount Decimal(18,6) null)            
DECLARE getPayMode CURSOR for SELECT Value, Mode FROM paymentmode
      
OPEN getPayMode              
FETCH FROM getPayMode INTO  @PaymentType, @PaymentID  
    
WHILE @@Fetch_status = 0        
BEGIN      
  
 DECLARE getValue CURSOR for SELECT InvoiceID, PaymentMode, NetValue FROM InvoiceAbstract       
 WHERE InvoiceType = 2 And IsNull(Status, 0) & 128 = 0 And            
 InvoiceDate between @FromDate and @Todate  
    OPEN getValue      
    FETCH FROM getValue INTO @PayDetail, @PaymentMode, @NetValue  
       
 WHILE @@Fetch_status = 0        
    BEGIN    
    
  If @PaymentMode = 1   
  Begin  
   INSERT INTO #Temp(Payment, Amount)       
        SELECT @PaymentType, "Amount" = (Select NetRecieved from RetailPaymentDetails Where 
			RetailInvoiceID = @PayDetail and PaymentMode = @PaymentID)
  End  
--  Else  
--  Begin  
   --If @CheckStatus = 0  
   --INSERT INTO #Temp(Payment, Amount) SELECT 'Credit', @NetValue      
--  End  
   FETCH NEXT FROM getValue INTO @PayDetail, @PaymentMode, @NetValue      
 END         
      
CLOSE GetValue      
DEALLOCATE GetValue      
    Set @CheckStatus = 1  
FETCH NEXT FROM getPayMode INTO @PaymentType, @PaymentID  
END      
      
CLOSE getPayMode              
DEALLOCATE getPayMode        
SELECT Payment,"PaymentMode" = dbo.lookupdictionaryitem(Payment,default) , "Total" = sum(Amount) FROM #Temp  
 Where Amount <> 0 group by Payment      
Drop table #Temp        
  
  





