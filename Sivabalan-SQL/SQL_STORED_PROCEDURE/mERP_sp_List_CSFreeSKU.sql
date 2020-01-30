Create Procedure mERP_sp_List_CSFreeSKU(@SlabID Int)As

Begin
 Select Distinct SKUCode, Items.ProductName 
 From tbl_mERP_SchemeFreeSKU FreeSKU
 Left Outer Join Items On FreeSKU.SKUCode  = Items.Product_Code
 Where FreeSKU.SlabID =@SlabID 
 Order by 1 
End 
