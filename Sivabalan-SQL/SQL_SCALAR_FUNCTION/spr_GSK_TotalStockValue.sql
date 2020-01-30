CREATE Function spr_GSK_TotalStockValue(@ToDate Datetime, @CurrentDate Datetime)      
Returns Decimal(18,6)    
As      
Begin    
Declare @F_ToDate Datetime, @F_CurrentDate Datetime  
DECLARE @TotalStockValue Decimal(18,6)  
  
Set @F_ToDate = Cast(Datepart(dd, @ToDate) As nvarchar) + '/'   
+ Cast(Datepart(mm, @ToDate) As nvarchar) + '/'   
+ Cast(Datepart(yyyy, @ToDate) As nvarchar)  
  
If DateDiff(dd, @F_ToDate, @CurrentDate) < 1  
Begin  
select @TotalStockValue = IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchasePrice, 0)), 0)
from Batch_Products    
End    
  
Else  
  
Begin  
Set @F_ToDate = DateAdd(dd, 1, @F_ToDate)  
Select @TotalStockValue = Sum(IsNull(Opening_Value, 0)) From OpeningDetails  
Where Opening_Date = @F_ToDate  
End  
  
Return @TotalStockValue    
End  


