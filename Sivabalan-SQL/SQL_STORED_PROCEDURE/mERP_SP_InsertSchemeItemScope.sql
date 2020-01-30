Create Procedure mERP_SP_InsertSchemeItemScope
(
@SchemeID int,
@Category nVarchar(4000)=NULL,
@SubCategory nVarchar(4000)=NULL,
@MSKU nVarchar(4000) =NULL,
@SKU nVarchar(4000)=NULL
)
As
If (IsNull(@Category,'') = '')
 Set @Category = 'ALL'

If (IsNull(@SubCategory,'') = '')
 Set @SubCategory = 'ALL'

If (IsNull(@MSKU,'') = '')
 Set @MSKU = 'ALL'

If (IsNull(@SKU,'') = '')
 Set @SKU = 'ALL'

Insert Into tbl_mERP_RecdSchProductScope(CS_SchemeID, CS_Category, CS_SubCategory, CS_MarketSKU, CS_SKUCode )
values(@SchemeID, @Category, @SubCategory, @MSKU, @SKU)
