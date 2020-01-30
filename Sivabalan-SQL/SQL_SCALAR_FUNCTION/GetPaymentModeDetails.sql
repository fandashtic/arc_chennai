CREATE Function GetPaymentModeDetails (@PaymentDetails nvarchar(2000)) Returns nvarchar(255)  
As  
  
Begin  
Declare @StartPos Int  
Declare @EndPos Int  
Declare @Str1 nvarchar(255)  
  
Set @Str1 = left(@PaymentDetails,Patindex('%:%',@PaymentDetails)-1)  
Set @StartPos = charindex(';', @PaymentDetails, 1)  
While Not @StartPos = 0   
Begin   
Set @EndPos = charindex(':', @PaymentDetails, @StartPos+1)  
Set @Str1 = @Str1 + ',' +  Cast(SubString(@PaymentDetails,@StartPos+1,(@EndPos - @StartPos - 1))as nvarchar)  
Set @StartPos = charindex(';', @PaymentDetails, @EndPos )  
End  
Return @Str1  
End  

