Create Procedure mERP_SP_ListFreeSKUList_VAN(@SchemeID int,@SlabID int,@DocID int) As
Begin	
	Select I.Product_code,
    I.ProductName,
    "Quantity" = (select isnull(sum(V.Pending),0) from Batch_Products B, VanStatementDetail V  
				  where V.Batch_Code=B.Batch_Code  and V.Product_Code=I.Product_Code --and Free=1 
				  and IsNull(B.Damage, 0) = 0
				  and V.DocSerial = @DocID Group by V.Product_Code),
    SL.SchemeID,SL.FreeUOM,SL.Volume,
    case when SL.FreeUOM=2 then Uom1_Conversion when SL.FreeUOM=3 then UOM2_Conversion else 1 end
	From tbl_mERP_SchemeFreeSKU F,tbl_merp_SchemeSlabDetail SL,Items I 
	Where F.SlabID=SL.SlabID and SL.SchemeID in (@SchemeID)
	and SL.SlabID=@SlabID
	and F.SKUCode=I.Product_Code
	and I.Active = 1
    Order by 3 desc    
End
