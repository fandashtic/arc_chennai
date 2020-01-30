Create Procedure mERP_SP_ListSchemeDetails(@SchemeID int,@GroupID Int) As
Begin
If @GroupID = -1
Begin
Select SlabType, Case SlabType When 1 Then 'Amount' When 2 Then 'Percentage' When 3 Then 'Free SKU' End as 'GivenAs',
Case IsNull(UOM,0) When 1 Then 'BUOM' When 2 Then 'UOM1' When 3 Then 'UOM2' When 4 Then 'Value' When 5 Then 'TLC' End as 'PrimaryUOM',
SlabStart, SlabEnd, IsNull(Onward,0) 'For Every', IsNull([Value],0) as 'Discount',
Case IsNull(FreeUOM,0) When 1 Then 'Base UOM' When 2 Then 'UOM1' When 3 Then 'UOM2' End as 'FreeUOM',
IsNull(Volume,0) 'Qty',dbo.mERP_fn_Get_FreeSKUList(slabID), IsNull(UOM,0)
From tbl_mERP_SchemeSlabDetail
Where SchemeID = @SchemeID
Order By SlabID
End
Else
Begin
Select SlabType, Case SlabType When 1 Then 'Amount' When 2 Then 'Percentage' When 3 Then 'Free SKU' End as 'GivenAs',
Case IsNull(UOM,0) When 1 Then 'BUOM' When 2 Then 'UOM1' When 3 Then 'UOM2' When 4 Then 'Value' When 5 Then 'TLC' End as 'PrimaryUOM',
SlabStart, SlabEnd, IsNull(Onward,0) 'For Every', IsNull([Value],0) as 'Discount',
Case IsNull(FreeUOM,0) When 1 Then 'Base UOM' When 2 Then 'UOM1' When 3 Then 'UOM2' End as 'FreeUOM',
IsNull(Volume,0) 'Qty',dbo.mERP_fn_Get_FreeSKUList(slabID), IsNull(UOM,0)
From tbl_mERP_SchemeSlabDetail
Where SchemeID = @SchemeID And GroupID = @GroupID
Order By SlabID
End
End
