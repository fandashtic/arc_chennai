Create Procedure mERP_sp_Get_MaxCSProductScope(@SchemeID Int)
As
Begin
 Select Max(RowCnt) From(
 Select Count(Category) 'RowCnt' from tbl_mERP_SchCategoryScope Where SchemeID = @SchemeID
  Union all
 Select  Count(SubCategory) 'RowCnt' from tbl_mERP_SchSubCategoryScope Where SchemeID = @SchemeID
  Union all
 Select  Count(MarketSKU) 'RowCnt' from tbl_mERP_SchMarketSKUScope Where SchemeID = @SchemeID
  Union all
 Select  Count(SKUCode) 'RowCnt' from tbl_mERP_SchSKUCodeScope Where SchemeID = @SchemeID) A
End 
