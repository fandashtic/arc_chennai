CREATE VIEW [dbo].[V_Item_schemes]
([SchemeID],[Product_code],[PrimaryUOM])
AS
select
cast(SubGrp.GroupID as varchar(5))+cast(TSI.SchemeID+10000 as varchar(10))
,TSI.Product_code
,(Case Isnull(TSSD.UOM, 0) when 1 then TSI.UOM when 2 then TSI.UOM1 when 3 then TSI.UOM2 when 4 then 0 else null end)
from dbo.fn_han_Get_SchemesItems(1) TSI inner join tbl_mERP_SchemeSlabDetail TSSD on TSI.SchemeID = TSSD.SchemeID
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = TSSD.GroupID And SubGrp.SchemeID = TSSD.SchemeID
And TSSD.GroupID In(Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where SchemeID = TSSD.SchemeID And GroupID = SubGrp.GroupID)
and TSSD.SlabId = (select top 1 SlabID from tbl_mERP_SchemeSlabDetail where SchemeId = TSI.SchemeID and GroupId = SubGrp.SubGroupId order by SlabID)
Where Isnull(TSSD.UOM,0) <> 5
