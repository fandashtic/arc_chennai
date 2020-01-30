Create Procedure mERP_sp_view_CentralSchemeDetail(@SchemeID Int, @GroupID Int)
As
Begin
 Select SlabType, Case SlabType When 1 Then 'CashDisc-Amt' When 2 Then 'CashDisc-Per' When 3 Then 'Item Free' End as 'GivenAs',
  Case IsNull(UOM,0) When 1 Then 'Base UOM' When 2 Then 'UOM1' When 3 Then 'UOM2' End as 'PrimaryUOM', 
  SlabStart, SlabEnd, IsNull(Onward,0) 'For Every', IsNull([Value],0) as 'Discount', 
  Case IsNull(FreeUOM,0) When 1 Then 'Base UOM' When 2 Then 'UOM1' When 3 Then 'UOM2' End as 'FreeUOM', 
  IsNull(Volume,0) 'Qty'
 From tbl_mERP_SchemeSlabDetail
 Where SchemeID = @SchemeID And
  GroupID = @GroupID 
 Order By SlabID
End 
