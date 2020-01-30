Create Function Fn_IsPaymentMode_In_Scheme(@PaymentMode int,@SchemeID INT)    
Returns int    
as    
Begin    
	Declare @InScheme as int    
	Declare @SchemePaymentMode  nvarchar(255)    
	Select @SchemePaymentMode=PaymentMode From Schemes Where SchemeID=@SchemeID    
 	If @PaymentMode in (Select * from dbo.sp_splitin2rows(@SchemePaymentMode,','))    
 	begin    
   		set @InScheme =1    
 	end     
 	else    
 	begin    
   		set @InScheme =0    
 	end     
 	Return @InScheme    
End    

