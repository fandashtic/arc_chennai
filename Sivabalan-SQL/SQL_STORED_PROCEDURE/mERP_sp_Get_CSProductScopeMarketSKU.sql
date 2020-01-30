Create Procedure mERP_sp_Get_CSProductScopeMarketSKU(@SchemeID Int)
As
Begin
  Select MarketSKU from tbl_mERP_SchMarketSKUScope Where SchemeID = @SchemeID
End
