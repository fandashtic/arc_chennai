Create Procedure mERP_SP_ListFreeSKUList (@SchemeID int,@SlabID int) As
Begin
	Select I.Product_code,
    I.ProductName,
    "Quantity" = (select isnull(sum(Quantity),0) from Batch_Products where Product_Code=I.Product_Code --and Free=1
	and IsNull(Damage, 0) = 0
    and (expiry is null or dbo.Striptimefromdate(expiry) > dbo.Striptimefromdate(getdate()))),
	SL.SchemeID,SL.FreeUOM,SL.Volume,
    case when SL.FreeUOM=2 then Uom1_Conversion when SL.FreeUOM=3 then UOM2_Conversion else 1 end
	From tbl_mERP_SchemeFreeSKU F,tbl_merp_SchemeSlabDetail SL,Items I 
	Where F.SlabID=SL.SlabID and SL.SchemeID in (@SchemeID)
	and SL.SlabID=@SlabID
	and F.SKUCode=I.Product_Code
	and I.Active = 1
    Order by 3 desc
End
