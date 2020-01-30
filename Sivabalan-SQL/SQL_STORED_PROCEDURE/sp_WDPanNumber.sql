Create Proc sp_WDPanNumber(@InvoiceId int,@TranType Nvarchar(15),@Mode int)  
As  
Begin  
Declare @CustPanNo Nvarchar(100) 
	   select @CustPanNo = dbo.Fn_Get_PANNumber(@InvoiceId,@TranType,'WD') 
          if @Mode = 1
	   Begin  
	   if Isnull(@CustPanNo,'') <> ''     
			select left(BillingAddress,29) + ' PAN No:' + isnull(PANNumber,'') From Setup    
	   else  
			select BillingAddress From Setup     
	   End 	
	   if @Mode = 2
	   Begin  
	   if Isnull(@CustPanNo,'') <> ''     
			select left(BillingAddress,29) + ' PAN No:' + isnull(PANNumber,'') From Setup    
	   else  
			select BillingAddress From Setup     
	   End 	
End   
