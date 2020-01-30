CREATE Procedure Get_Bill_ComboID        
As        
Select IsNull(Max(Bill_combo_components.ComboID),0) + 1       
from Bill_Combo_Components


