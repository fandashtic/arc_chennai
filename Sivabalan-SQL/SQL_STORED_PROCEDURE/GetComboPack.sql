CREATE Procedure GetComboPack (@ItemCode nvarchar(50))    
As    
Select Items.ItemCombo ,Items.TrackInventoryCombo    
from Items     
Where Items.Product_Code = @ItemCode 

