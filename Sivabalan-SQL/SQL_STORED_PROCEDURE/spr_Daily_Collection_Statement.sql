CREATE Procedure spr_Daily_Collection_Statement(@FromDate datetime,          
					       @ToDate datetime)          
As      
DECLARE @PaymentType nvarchar(255)    
DECLARE @PayDetail nvarchar(255)    
DECLARE @Pos int    
DECLARE @Type nvarchar(255)
DECLARE @Pos1 int

Declare @CASH As NVarchar(50)
Declare @DD As NVarchar(50)
Declare @BANKTRANSFER As NVarchar(50)
Declare @CREDITCARD As NVarchar(50)
Declare @COUPON As NVarchar(50)
Declare @CHEQUE As NVarchar(50)
Declare @POSTDATEDCHEQUE As NVarchar(50)

Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)
Set @BANKTRANSFER = dbo.LookupDictionaryItem(N'Bank Transfer', Default)
Set @CREDITCARD = dbo.LookupDictionaryItem(N'Credit Card', Default)
Set @COUPON = dbo.LookupDictionaryItem(N'Coupon', Default)
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default)
Set @POSTDATEDCHEQUE = dbo.LookupDictionaryItem(N'Post Dated Cheque', Default)



CREATE TABLE #temp(Payment nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS null, Amount Decimal(18,6) null)          
DECLARE getPayMode CURSOR for SELECT Value FROM paymentmode   
    
OPEN getPayMode            
FETCH FROM getPayMode INTO @PaymentType            
  
WHILE @@Fetch_status = 0      
BEGIN    
	DECLARE getValue CURSOR for SELECT PaymentDetails FROM InvoiceAbstract     
	WHERE InvoiceType = 2 And IsNull(Status, 0) & 128 = 0 And          
	InvoiceDate between @FromDate and @Todate   
	OPEN getValue    
	FETCH FROM getValue INTO @PayDetail    
	WHILE @@Fetch_status = 0      
	BEGIN    
		SET @Pos   = CHARINDEX(@PaymentType,@PayDetail,1) 
		SET @Pos1  = CHARINDEX(':',@PayDetail,@Pos) 		
		SET @Type  = substring(@paydetail,@Pos, @Pos1 -@Pos)
		IF @Pos <> 0    
		BEGIN      
			IF Len(@Type) = len(@PaymentType) 
			Begin
				INSERT INTO #Temp(Payment, Amount)
				SELECT @PaymentType, dbo.GetAmountCollected(@PayDetail, @PaymentType + ':')   
			End  
		END    
		FETCH NEXT FROM getValue INTO @PayDetail    
	END       
	CLOSE GetValue    
	DEALLOCATE GetValue    
	FETCH NEXT FROM getPayMode INTO @PaymentType    
END    
CLOSE getPayMode            
DEALLOCATE getPayMode          
INSERT INTO #temp          
SELECT Case PaymentMode       
WHEN 0 THEN @CASH    
WHEN 2 THEN @DD  
WHEN 4 THEN @BANKTRANSFER
END,    
Sum(Value)          
FROM Collections          
WHERE Collections.DocumentDate Between @FromDate and @Todate And          
IsNull(Collections.Status, 0) & 128 = 0 And          
PaymentMode in (0, 2, 4)          
Group By PaymentMode Having Sum(Value) > 0        
      
INSERT INTO #temp          
SELECT Case PaymentMode       
WHEN 3 THEN @CREDITCARD
WHEN 5 THEN @COUPON
END,    
Sum(Value)          
FROM Collections          
WHERE Collections.DocumentDate Between @FromDate and @Todate And          
IsNull(Collections.Status, 0) & 128 = 0 And          
PaymentMode in (3, 5)          
Group By PaymentMode Having Sum(Value) > 0        

INSERT INTO #temp          
SELECT Case PaymentMode      
WHEN 1 THEN  
@CHEQUE
END,          
Sum(Value)          
FROM Collections          
WHERE Collections.DocumentDate Between  @FromDate and @Todate And               
IsNull(Collections.Status, 0) & 128 = 0 And          
PaymentMode = 1 And          
dbo.StripDateFromTime(ChequeDate) = dbo.StripDateFromTime(@FromDate)          
Group By PaymentMode Having Sum(Value) > 0    

INSERT INTO #temp  
SELECT Case PaymentMode  
WHEN 1 THEN  
@POSTDATEDCHEQUE
END,   
Sum(Value)  
FROM Collections  
WHERE Collections.DocumentDate Between @FromDate And @ToDate And  
IsNull(Collections.Status, 0) & 128 = 0 And  
PaymentMode = 1 And  
dbo.StripDateFromTime(ChequeDate) > dbo.StripDateFromTime(@FromDate)  
Group By PaymentMode Having Sum(Value) > 0  
      
SELECT Payment,"PaymentMode" = Payment, "Total" = sum(Amount) FROM #Temp group by payment    
Drop table #Temp 



