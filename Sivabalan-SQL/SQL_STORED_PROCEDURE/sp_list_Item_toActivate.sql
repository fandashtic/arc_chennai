
Create Procedure sp_list_Item_toActivate
as 
Select Product_Code, ProductName, UserDefinedCode From Items 
Where Active = 0 Order By 1

