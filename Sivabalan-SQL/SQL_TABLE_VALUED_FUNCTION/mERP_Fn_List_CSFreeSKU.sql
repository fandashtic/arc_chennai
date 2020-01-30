Create Function  mERP_Fn_List_CSFreeSKU(@SchemeID Int) 
Returns @Items Table  
(  
 SKUCode  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS  
)  
As
Begin
	
 Insert Into @items	
 Select Distinct FreeSKU.SKUCode, Items.ProductName From tbl_mERP_SchemeFreeSKU FreeSKU
 Left Outer Join  Items On FreeSKU.SKUCode = Items.Product_Code
 Inner Join  tbl_merp_schemeSlabDetail  TSS On FreeskU.SlabID = TSS.SlabID 
 Where  TSS.SchemeID = @SchemeID
 Order by 1 
return
End
