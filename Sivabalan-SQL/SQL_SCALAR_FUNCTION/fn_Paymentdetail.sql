CREATE FUNCTION fn_Paymentdetail(@Invoiceid int, @MODE INT)              
RETURNS nvarchar(500)  
AS              
BEGIN  
DECLARE @START INT                
DECLARE @INDEX INT                
DECLARE @INDEX1 INT                
DECLARE @PaymentDetails nvarchar(500)                
DECLARE @PaymentDesc nvarchar(500)                
DECLARE @PayDetails nvarchar(500)                
DECLARE @ServiceCharge nvarchar(500)                
DECLARE @ServiceCharges nvarchar(500)                
DECLARE @DETAIL nvarchar(500)                
DECLARE @PRINTDETAIL nvarchar(500)                
DECLARE @PaymentMode nvarchar(100)                
DECLARE @FIRSTVALUE FLOAT                
DECLARE @SECONDVALUE FLOAT                
DECLARE @FIRSTSERVICECHARGE FLOAT      
DECLARE @RESULT AS nvarchar(500)               
DECLARE @RETURNAMOUNT AS FLOAT        
DECLARE @COUNT AS INT                
DECLARE @Amount AS Decimal(18,6)    
DECLARE @AmountReceived AS Decimal(18,6)    
DECLARE @NetValue As Decimal(18,6)
DECLARE @TotalAmount AS Decimal(18,6)    
DECLARE @TotalServiceCharge As Decimal(18,6)  

SELECT @NetValue = NetValue + RoundOffAmount, @AmountReceived = AmountRecd, @PayDetails = PaymentDetails + N';' , @ServiceCharges = CASE WHEN ServiceCharge IS NULL THEN N'' ELSE ServiceCharge + N';' END FROM InvoiceAbstract WHERE InvoiceID = @InvoiceID And InvoiceType = 2               
                 
 SET @START = 1                
 SET @INDEX = 1                
 SET @INDEX1 = 1                
 SET @Detail = N''                
 SET @PRINTDETAIL = N''                
 SET @SecondValue = 0               
 SET @COUNT = 0      
 SET @TotalAmount = 0    
 SET @TotalServiceCharge = 0  
 WHILE @INDEX <> 0                
 BEGIN                
      
   IF @COUNT > 2      
   SELECT @INDEX = CHARINDEX(N';',@PayDetails,@INDEX)                
      
   SELECT @PaymentDetails = LEFT(@PayDetails, CHARINDEX(N';',@PayDetails,1))      
   SELECT @PayDetails = RIGHT(@PayDetails, LEN(@PayDetails) - CHARINDEX(N';',@PayDetails,1))                
   SELECT @COUNT = @COUNT + 1      
   IF @ServiceCharges <> N''                
   BEGIN                
         
    SELECT @ServiceCharge = LEFT(@ServiceCharges, CHARINDEX(N';',@ServiceCharges,@INDEX1))        
                  
    SELECT @ServiceCharges = RIGHT(@ServiceCharges, LEN(@ServiceCharges) - CHARINDEX(N';',@ServiceCharges,@INDEX1))                
   END                
    SELECT @PaymentDetails = REPLACE(@PaymentDetails,N';',N'') + N':'                
    SELECT @ServiceCharge = REPLACE(@ServiceCharge,N';',N'')                 
    SELECT @START = 1           
   IF @PaymentDetails <> N':'                
    BEGIN                
     SELECT @PaymentMode = LEFT(@PaymentDetails, CHARINDEX(N':',@PaymentDetails,1)-1)                
     SELECT @PaymentDetails = RIGHT(@PaymentDetails, LEN(@PaymentDetails) - CHARINDEX(N':',@PaymentDetails,1))                
     SELECT @FirstValue = Replace(LEFT(@PaymentDetails,(CHARINDEX(N':',@PaymentDetails, 1))),N':',N'')                
     SELECT @PaymentDetails = RIGHT(@PaymentDetails, LEN(@PaymentDetails) - CHARINDEX(N':',@PaymentDetails,1))                
     SELECT @PAYMENTDESC = Replace(LEFT(@PaymentDetails,(CHARINDEX(N':',@PaymentDetails, 1))),N':',N'')        
     SELECT @PaymentDetails = RIGHT(@PaymentDetails, LEN(@PaymentDetails) - CHARINDEX(N':',@PaymentDetails,1))                
     SELECT @SECONDVALUE = Replace(LEFT(@PaymentDetails,(CHARINDEX(N':',@PaymentDetails, 1))),N':',N'')        
     IF @ServiceCharge <> N''                 
       SELECT @FIRSTSERVICECHARGE = Right(@ServiceCharge,LEN(@ServiceCharge) - CHARINDEX(N':',@ServiceCharge, 1))      
     ELSE                
       SELECT @FIRSTSERVICECHARGE = 0.0                
                  
      SELECT @Detail = @PaymentMode + N':' + Cast((@FirstValue - CONVERT(FLOAT,@FIRSTSERVICECHARGE)) As nvarchar) + N'::' + @PAYMENTDESC + N'::' + CAST(@SecondValue As nvarchar) + N'::' + cast(@FIRSTSERVICECHARGE As nvarchar) + N'::' + cast(@FirstValue As nvarchar)                
    
      SELECT @TotalAmount = @TotalAmount + (@FirstValue - CONVERT(FLOAT,@FIRSTSERVICECHARGE))  
  
      SELECT @TotalServiceCharge  = @TotalServiceCharge + CONVERT(FLOAT,@FIRSTSERVICECHARGE)  
  
       IF @SecondValue <> 0  
          SELECT @RETURNAMOUNT = @SecondValue        
     END                
   IF @Detail <> N''                
    SELECT @PRINTDETAIL = @PRINTDETAIL + @Detail + N';'       
   ELSE                
    SELECT @PRINTDETAIL = @PRINTDETAIL + @Detail                
    SELECT @Detail = N''         
    SELECT @PAYMENTDESC = N''               
  END            
 IF @MODE = 1        
   SELECT @RESULT = @PRINTDETAIL            
 ELSE IF @MODE = 2        
 BEGIN      
   IF @RETURNAMOUNT IS NULL       
     SELECT @RESULT = 0  
   ELSE      
     SELECT @RESULT = @RETURNAMOUNT            
 END  
 ELSE IF @MODE = 3  
     SELECT @RESULT = @TotalAmount - @NetValue
 ELSE  
    SELECT @RESULT = @TotalServiceCharge   
RETURN(@RESULT)  
END  
      
  


