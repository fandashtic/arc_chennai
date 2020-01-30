Create Procedure mERP_sp_Get_CSDisplayCapPerPayout(@SchemeID Int)
As
Begin
  Select ID, Channel,OutletType,SubOutletType,CapPerOutlet from tbl_mERP_DispSchCapPerOutlet
  Where SchemeID = @SchemeID
  Order by Channel,CapPerOutlet
End
