CREATE VIEW   [V_SpecialCategory_item]
([Special_Cat_Code],[Product_Code],[CategoryID],[PrimaryUOM])
AS
Select
cast(SubGrp.GroupID as varchar(5))+cast(TSI.SchemeID+10000 as varchar(10))
,TSI.Product_code
,TSI.CategoryID
,(Case Isnull(TSSD.UOM, 0) when 1 then TSI.UOM when 2 then TSI.UOM1 when 3 then TSI.UOM2 when 4 then TSI.UOM else null end)
from --dbo.fn_han_Get_SchemesItems(2)
(
Select ScPrdMap.SchemeId SchemeID, ScPrdMap.ProductScopeId ProductScopeID,
ItmCtg.Product_Code Product_code, Itm_CategoryId CategoryID, ItmCtg.Uom, ItmCtg.Uom1, ItmCtg.Uom2
From (
Select ItcDiv.CategoryId DivId, ItcDiv.Category_Name DivName,
ItcSubC.CategoryId SubCId, ItcSubC.Category_Name SubCName,
ItcMkt.CategoryId MktId, ItcMkt.Category_Name MktName,
Itm.CategoryId Itm_CategoryId, Itm.Product_Code, Itm.Uom, Itm.Uom1, Itm.Uom2
From ItemCategories ItcDiv
Join ItemCategories ItcSubC on ItcDiv.CategoryId = ItcSubC.ParentId
Join ItemCategories ItcMkt on ItcSubC.CategoryId = ItcMkt.ParentId
Join Items Itm on ItcMkt.CategoryId = Itm.CategoryId
where Itm.Active = 1
And Itm.Product_Code in (select Distinct Item_Code from V_Item_Master)
) ItmCtg
Join (
Select SchAbs.SchemeId SchemeId, SchPrd.ProductScopeId ProductScopeId,
SchPrd.Category SchDiv_Category, SchPrd.Sub_Category SchSubC_Category,
SchPrd.Market_Sku SchMkt_Category, SchPrd.Product_Code SchItm_Category
From tbl_mERP_SchemeAbstract SchAbs
Join SchemeProducts SchPrd On SchAbs.SchemeID = SchPrd.SchemeID and SchPrd.Active = 1
Where SchAbs.ItemGroup = 2 and SchAbs.SchemeType In (1,2,3,4) and SchAbs.Active = 1
and convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between SchAbs.activefrom and SchAbs.activeto
and IsNull(SchAbs.schemestatus, 0) In ( 0, 1 )

Union

Select SchAbs.SchemeId SchemeId, SchPrd.ProductScopeId ProductScopeId,
SchPrd.Category SchDiv_Category, SchPrd.Sub_Category SchSubC_Category,
SchPrd.Market_Sku SchMkt_Category, SchPrd.Product_Code SchItm_Category
From tbl_mERP_SchemeAbstract SchAbs
Join SchemeProducts SchPrd On SchAbs.SchemeID = SchPrd.SchemeID and SchPrd.Active = 1
Where SchAbs.ItemGroup = 2 and SchAbs.SchemeType In (1,2,3,4) and SchAbs.Active = 1
and convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between SchAbs.activefrom and SchAbs.activeto
and IsNull(SchAbs.schemestatus, 0) In ( 2 )
) ScPrdMap
On
ScPrdMap.SchDiv_Category = ItmCtg.DivName
and ScPrdMap.SchSubC_Category = ItmCtg.SubCName
and ScPrdMap.SchMkt_Category = ItmCtg.MktName
and ScPrdMap.SchItm_Category = ItmCtg.Product_Code
)
TSI inner join
tbl_mERP_SchemeSlabDetail TSSD on TSI.SchemeID = TSSD.SchemeID
Inner Join
tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = TSSD.GroupID And SubGrp.SchemeID = TSSD.SchemeID
And TSSD.GroupID In(Select Max(SubGroupID) From
tbl_mERP_SchemeSubGroup Where SchemeID = TSSD.SchemeID And GroupID = SubGrp.GroupID)

and TSSD.SlabId = (select top 1 SlabID from
tbl_mERP_SchemeSlabDetail where SchemeId = TSI.SchemeID and GroupId = TSSD.GroupId order by SlabID)
Where Isnull(TSSD.UOM,0) <> 5
