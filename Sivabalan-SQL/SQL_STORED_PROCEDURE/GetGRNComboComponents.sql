CREATE Procedure GetGRNComboComponents (@GRNID as Integer, @ItemCode nvarchar(50), @ComboID nvarchar(50))  
As
select Combo_Components.Component_Item_Code, Items.ProductName, Combo_Components.Quantity,
Combo_Components.Free, Combo_Components.PTS, Combo_Components.PTR, Combo_Components.ECP, Combo_Components.SpecialPrice
from Batch_Products,Combo_Components, Items   
Where Batch_Products.GRN_ID = @GRNID and Combo_Components.Combo_Item_Code = @ItemCode
and Combo_Components.ComboID = @ComboID and Batch_Products.ComboID = Combo_Components.ComboID
and Combo_Components.Component_Item_Code = Items.Product_Code 

