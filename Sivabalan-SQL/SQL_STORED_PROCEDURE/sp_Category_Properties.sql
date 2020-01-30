Create Procedure sp_Category_Properties (@CategoryID Int)
As
Select Properties.Property_Name From Properties, Category_Properties
Where Category_Properties.CategoryID = @CategoryID And
Category_Properties.PropertyID = Properties.PropertyID

