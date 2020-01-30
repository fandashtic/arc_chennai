Create Procedure spr_list_CentralSchemeDetail(@SchemeID Int)
As
Begin
Select distinct SchOlt.GroupID,
"Outlet Group" = SchOlt.GroupID, "QPS" = Case IsNull(SchOlt.QPS,0) When 1 Then 'Yes' Else 'No' End,
"Channel" = dbo.mERP_fn_make_CSScopeInfo_Inline(@SchemeID, 1, 1, SchOlt.GroupID),
"Outlet Class" = dbo.mERP_fn_make_CSScopeInfo_Inline(@SchemeID, 1, 2, SchOlt.GroupID),
"Outlet Name" = dbo.mERP_fn_make_CSScopeInfo_Inline(@SchemeID, 1, 3, SchOlt.GroupID),
"Category" = dbo.mERP_fn_make_CSScopeInfo_Inline(@SchemeID, 2, 1, SchPrdtScp.SchemeID),
"Sub Category" = dbo.mERP_fn_make_CSScopeInfo_Inline(@SchemeID, 2, 2, SchPrdtScp.SchemeID),
"Market SKU" = dbo.mERP_fn_make_CSScopeInfo_Inline(@SchemeID, 2, 3, SchPrdtScp.SchemeID),
"SKU" = dbo.mERP_fn_make_CSScopeInfo_Inline(@SchemeID, 2, 4, SchPrdtScp.SchemeID),
"Min_Range" = dbo.mERP_fn_CSMinRangeUOM(@SchemeID, 'MinRange'),
"UOM" = dbo.mERP_fn_CSMinRangeUOM(@SchemeID, 'UOM'),
"Given As" = Case schSlab.SlabType When 1 Then 'Amount' When 2 Then 'Percentage' When 3 Then 'Free SKU' Else '' End,
"UOM" = Case IsNull(schSlab.UOM,0) When 1 Then 'BUOM' When 2 Then 'UOM1' When 3 Then 'UOM2' When 4 Then 'Value' When 5 Then 'TLC' Else '' End,
"From" = schSlab.SlabStart,
"To" = schSlab.SlabEnd,
"For Every" = IsNull(Onward,0),
"Dis Amt" = Case schSlab.SlabType When 1 Then IsNull(schSlab.[Value],0) Else 0 End,
"Dis%" = Case schSlab.SlabType When 2 Then IsNull(schSlab.[Value],0) Else 0 End,
"Free UOM" = Case IsNull(schSlab.FreeUOM,0) When 1 Then 'BUOM' When 2 Then 'UOM1' When 3 Then 'UOM2' When 4 Then 'Value' Else '' End,
"Free Qty" = IsNull(Volume,0),
"Free SKU" = dbo.mERP_fn_Get_FreeSKUList(schSlab.SlabID)
From (Select SchemeID, GroupID, QPS From tbl_mERP_SchemeOutlet Where SchemeID = @SchemeID Group By SchemeID, GroupID, QPS) SchOlt,
tbl_mERP_SchemeProductScopeMap SchPrdtScp,
tbl_mERP_SchemeSlabDetail schSlab
Where SchOlt.SchemeID = @SchemeID And
SchOlt.SchemeID = SchPrdtScp.SchemeID And
SchOlt.SchemeID = schSlab.SchemeID And
SchOlt.GroupID = SchSlab.GroupID
End
