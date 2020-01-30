CREATE Procedure sp_ClaimAlready_StockDestruction (@Batch_Code nvarchar(255))   
As  
Select isnull(ClaimedAlready, 0)
from Batch_Products   
Where Batch_Code in (@Batch_Code)  
  


