CREATE Function [dbo].[OnHandQ](@ToDate DateTime, @CurrentDate DateTime, @ItemCode nvarchar(255))  
RETURNS Decimal(18, 6)  
Begin  
Declare @OnHandQuantity Decimal(18, 6)  
  
If @ToDate < @CurrentDate  
  Begin  
    Set @OnHandQuantity = IsNull((Select Opening_Quantity - IsNull(Damage_Opening_Quantity, 0) From 
   OpeningDetails Where Product_Code = @ItemCode And Opening_Date = DateAdd(dd, 1, @ToDate)), 0)  
  End  
Else  
  Begin  
    Set @OnHandQuantity = ISNULL((SELECT SUM(Quantity)  
    FROM Batch_Products  
    WHERE Product_Code = @ItemCode And IsNull(Damage, 0) = 0), 0) + 
    IsNull((SELECT SUM(IsNull(Pending, 0))
    FROM VanStatementDetail, VanStatementAbstract                 
    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                 
    AND (VanStatementAbstract.Status & 128) = 0                 
    And VanStatementDetail.Product_Code = @ItemCode), 0)
  END  
RETURN @OnHandQuantity  
End   
