CREATE  function fn_get_RetailPaymentModeDescription(@RetailInvoiceID Int)  
RETURNS NVarchar(255)  
As  
Begin  
 Declare @Description NVarchar(255)  
 Declare @PayModeDescription NVarchar(255)  
  
 Declare Cursor_PayMode Cursor for   
 Select Paymentmode.value from retailpaymentdetails,Paymentmode   
 where retailinvoiceID = @RetailInvoiceID and retailpaymentdetails.paymentmode=Paymentmode.mode  
 Order by Paymentmode.value  
 Open Cursor_Paymode  
 FETCH NEXT FROM Cursor_Paymode INTO @Description  
 While @@FETCH_STATUS = 0  
 BEGIN  
  Set @PayModeDescription = Case When IsNull(@PayModeDescription,'') = '' Then  @Description Else @PayModeDescription+','+ @Description End  
  FETCH NEXT FROM Cursor_Paymode INTO @Description  
 END  
 RETURN @PayModeDescription  
End  
  


