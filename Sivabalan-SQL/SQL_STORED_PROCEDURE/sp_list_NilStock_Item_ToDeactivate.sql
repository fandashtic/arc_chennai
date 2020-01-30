CREATE procedure [dbo].[sp_list_NilStock_Item_ToDeactivate]
as 
Select Itm.Product_Code, Itm.ProductName, Itm.UserDefinedCode 
From 	Items Itm, Batch_Products Bprdt, VanStatementDetail inVan
Where	Itm.Product_Code *= BPrdt.Product_Code
    And Itm.Product_code *= inVan.Product_code
    And Itm.Active = 1
Group By Itm.Product_Code, Itm.ProductName, Itm.UserDefinedCode
Having 	 Sum(IsNull(BPrdt.Quantity,0)) = 0 and Sum(IsNull(Pending,0)) = 0
Order By Itm.Product_Code
