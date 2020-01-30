Create Function OnHandFreeQ(@ToDate DateTime, @CurrentDate DateTime, @ItemCode nvarchar(255))
RETURNS Decimal(18, 6)
Begin
Declare @OnHandQuantity Decimal(18, 6)

If @ToDate < @CurrentDate
  Begin
    Set @OnHandQuantity = (IsNull((Select IsNull(Free_Opening_Quantity, 0) From OpeningDetails 
    Where Product_Code = @ItemCode And Opening_Date = DateAdd(dd, 1, @ToDate)), 0))
  End
Else
  Begin
    Set @OnHandQuantity = (ISNULL((SELECT SUM(Quantity) FROM Batch_Products                 
    WHERE Product_Code = @ItemCode And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0))
  End
RETURN @OnHandQuantity
End

