CREATE Procedure mERP_Get_FreeSKU(@SlabID AS Int)  
As  
Begin  
	Select Top 1  
	(Case isNull(FreeUOM,0)
	When 1 Then isNull(Volume,0)
	When 2 Then isNull(Volume,0) * (Select UOM1_Conversion From Items Where Items.Product_Code = FreeSKU.SKUCode)	
	When 3 Then isNull(Volume,0) * (Select UOM2_Conversion From Items Where Items.Product_Code = FreeSKU.SKUCode)	
	End),
	SKUCode 
	From 
		tbl_mERP_SchemeSlabDetail Slab,tbl_mERP_SchemeFreeSKU FreeSKU
	Where 
		Slab.SlabID = FreeSKU.SlabID And
		Slab.SlabID = @SlabID  
End
