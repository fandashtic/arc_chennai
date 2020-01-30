CREATE Function Fn_Get_OffTake                
(                
@ProductCode NVarchar(15),                
@SalesVisitCount Int,          
@CustomerID Nvarchar(15)
)                
Returns  Decimal(18,6)
As
Begin

Declare @SvDate DateTime          
Declare @StockCount Decimal(18,6)          
Declare @StockCountSum Decimal(18,6)          
Declare @FIDate DateTime          
Declare @TIDate DateTime          
Declare @PurQuantity Decimal(18,6)          
Declare @PurQuantitySum Decimal(18,6)          
Declare @Count Int          
Declare @OffTake Decimal(18,6)
Declare @TempStockCountSum Decimal(18,6)          
Declare @RowCount Int      
      
Set @Count = 1           
Set @OffTake = 0          
Set @PurQuantity = 0          
Set @PurQuantitySum = 0          
Set @StockCount = 0          
Set @TempStockCountSum = 0          
Set @StockCountSum = 0          
Set @RowCount = @SalesVisitCount + 1      
        
Declare Cur_SV Cursor For           
Select
 SVA.SVDate,Max(SVD.StockCount)
From
	SVAbstract SVA, SVDetail SVD           
Where
 SVA.SVNumber = SVD.SVNumber          
	And SVA.CustomerID = @CustomerID           
	And SVD.Product_Code = @ProductCode           
	And (IsNull(SVA.Status,0) & 64) = 0    
	And (IsNull(SVA.Status,0) & 32) = 0           
Group by
 SVA.SVNumber,SVA.SVDate  
Order by
 SVA.SVDate desc,SVA.SVNumber desc     
        
Open Cur_SV          
Fetch Next From Cur_SV INTO @SvDate,@StockCount          
While @@Fetch_Status = 0          
Begin          
 If @RowCount = 0 Break          
 If @Count > 1           
  Begin          
   Set @FIDate = @SVDate          
   Select @PurQuantity = IsNull(Sum(Quantity),0)           
   From InvoiceAbstract IA, InvoiceDetail IND           
   Where IA.InvoiceID = IND.InvoiceID          
   And IND.Product_Code = @ProductCode           
   And IA.CustomerID = @CustomerID           
   And IA.InvoiceDate Between @FIDate And @TIDate
   And (IsNull(IA.Status,0) & 192) = 0          
   And IA.InvoiceType IN (1,3)          
   Set @TIDate = @FIDate
   --Stock Count from SV            
   Set @TempStockCountSum = @StockCount - @TempStockCountSum          
   Set @StockCountSum =  @TempStockCountSum + @StockCountSum           
   Set @TempStockCountSum = @StockCount          
  End          
 Else          
  Begin          
   Set @TIDate = @SVDate
   Set @TempStockCountSum = @StockCount         
  End          
 --Invoice Sum of Quantity(Purchases)          
 Set @PurQuantitySum = @PurQuantitySum + @PurQuantity          
 Set @PurQuantity = 0          
 Fetch Next From Cur_SV INTO @SvDate,@StockCount          
 Set @Count = @Count + 1            
 Set @RowCount = @RowCount - 1            
End          
Close Cur_SV          
DeAllocate Cur_SV          
  
If (@StockCountSum + @PurQuantitySum) > 0          
Set @OffTake = (@StockCountSum + @PurQuantitySum) / @SalesVisitCount
Return @OffTake
End

