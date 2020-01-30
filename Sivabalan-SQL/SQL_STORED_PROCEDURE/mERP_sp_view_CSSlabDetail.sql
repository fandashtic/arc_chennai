Create Procedure mERP_sp_view_CSSlabDetail(@SchemeID Int, @GroupID Int,@SchemeType Int)As
If (@SchemeType = 1 )
Begin
Select SlabType, Case SlabType When 1 Then 'Amount' When 2 Then 'Percentage' When 3 Then 'Free SKU' Else '' End as 'GivenAs',
Case IsNull(UOM,0) When 1 Then 'BUOM' When 2 Then 'UOM1' When 3 Then 'UOM2' When 4 Then 'Value' When 5 Then 'TLC' Else '' End as 'PrimaryUOM',
SlabStart, SlabEnd, IsNull(Onward,0) 'For Every', IsNull([Value],0) as 'Discount',
Case IsNull(FreeUOM,0) When 1 Then 'BUOM' When 2 Then 'UOM1' When 3 Then 'UOM2' When 4
Then 'Value' Else '' End as 'FreeUOM',
IsNull(Volume,0) 'Qty', SlabID
From tbl_mERP_SchemeSlabDetail
Where SchemeID = @SchemeID And
GroupID = (Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where GroupID = @GroupID And SchemeID = @SchemeID)
Order By SlabID
End
Else if (@SchemeType = 2)
Begin
Select SlabType, 'Points' as 'GivenAs',
Case IsNull(UOM,0) When 1 Then 'BUOM' When 2 Then 'UOM1' When 3 Then 'UOM2' When 4 Then 'Value' When 5 Then 'TLC' Else '' End as 'PrimaryUOM',
SlabStart, SlabEnd, IsNull(Onward,0) 'For Every', IsNull([Value],0) 'Accrual Points',IsNull(UnitRate,0) 'Unit Rate',SlabId
From tbl_mERP_SchemeSlabDetail
Where SchemeID = @SchemeID And SlabType = 5 and
GroupID = (Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where GroupID = @GroupID And SchemeID = @SchemeID)
Order By SlabID
End
Else if(@SchemeType = 3)
Begin
Select SlabType, Case SlabType When 2 Then 'Percentage'  Else '' End as 'GivenAs',
Case IsNull(UOM,0) When 1 Then 'BUOM'  Else '' End as 'PrimaryUOM',
SlabStart, SlabEnd, '' as 'For Every', IsNull([Value],0) as 'Discount',
'' as 'FreeUOM','' As  'Qty', SlabID
From tbl_mERP_SchemeSlabDetail
Where SchemeID = @SchemeID And
GroupID = (Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where GroupID = @GroupID And SchemeID = @SchemeID)
Order By SlabID
End

