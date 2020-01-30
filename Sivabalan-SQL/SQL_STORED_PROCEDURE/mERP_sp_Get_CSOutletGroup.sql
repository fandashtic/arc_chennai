Create Procedure mERP_sp_Get_CSOutletGroup(@SchemeID Int)
as 
Begin
  Select SG.GroupID,
 (Select  Top 1 Case QPS When 0 Then 'No' Else 'Yes' End as QPS  From tbl_mERP_SchemeOutlet Where SchemeID = SG.SchemeID
  And  	GroupID = Max(SG.SubGroupID))
  From  tbl_mERP_SchemeSubGroup SG
  Where SG.SchemeID = @SchemeID  Group by SG.SchemeID,SG.GroupID Order By GroupID
End
