Create Procedure mERP_SP_ListFreeSKUCount(@SchemeID int,@SlabID int) As
Begin
IF (Select Count(*) From tbl_mERP_SchemeFreeSKU F,tbl_merp_SchemeSlabDetail SL,Items I
Where F.SlabID=SL.SlabID and SL.SchemeID in (@SchemeID)
and SL.SlabID=@SlabID
and F.SKUCode=I.Product_Code And I.Active = 1) > 0
	Select 1
Else
	Select 0
End
