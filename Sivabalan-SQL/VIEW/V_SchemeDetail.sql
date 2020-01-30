CREATE VIEW V_SchemeDetail
(	[SchemeID], [StartValue], [EndValue], [FreeValue],[FreeItem],
[FromIteminBaseUOM],
[ToIteminBaseUOM], [FromIteminBaseUOM1], [ToIteminBaseUOM1], [FromIteminBaseUOM2],
[ToIteminBaseUOM2],
[StartQuantityinUOM],
[StartQuantityinUOM1],
[StartQuantityinUOM2],
[EndQuantityinUOM],
[EndQuantityinUOM1],
[EndQuantityinUOM2],
[FreeQuantityinUOM],
[FreeQuantityinUOM1],
[FreeQuantityinUOM2],
[FreeUOM]
)
AS
SELECT  cast(SubGrp.GroupID as varchar(5))+cast(TSA.SchemeID+10000 as varchar(25)),TSD.SlabStart, TSD.SlabEnd,
(Case When TSD.Slabtype = 3 then TSD.Volume else TSD.Value end),
SkuCode
,1 'FromIteminBaseUOM'
,1 'ToIteminBaseUOM'
,1 'FromIteminBaseUOM1'
,1 'ToIteminBaseUOM1'
,1 'FromIteminBaseUOM2'
,1 'ToIteminBaseUOM2'
,1 'StartQuantityinUOM'
,1 'StartQuantityinUOM1'
,1 'StartQuantityinUOM2'
,1 'EndQuantityinUOM'
,1 'EndQuantityinUOM1'
,1 'EndQuantityinUOM2'
,1 'FreeQuantityinUOM'
,1 'FreeQuantityinUOM1'
,1 'FreeQuantityinUOM2'
,(case Convert(Varchar(1), IsNull(TSD.FreeUOM,'')) when 1 then 0 when 2 then 1 when 3 then 2 end) 'FreeUOM'
FROM (select * From  tbl_mERP_SchemeAbstract Where convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between activefrom and activeto And active = 1 And
SchemeType Not In (4, 5) And IsNull(schemestatus, 0) In ( 0, 1, 2 ))  TSA
Inner Join  tbl_mERP_SchemeSlabDetail  TSD On TSA.SchemeID = TSD.SchemeID
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = TSD.GroupID And SubGrp.SchemeID = TSD.SchemeID
And TSD.GroupID In(Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where SchemeID = TSD.SchemeID And GroupID = SubGrp.GroupID)
Left Outer Join
(Select SkuCode, SlabID From  tbl_mERP_SchemeFreeSKU   Inner join Items
On SkuCode = Items.Product_code where Items.Active = 1) FreeSku On TSD.SlabID = FreeSkU.SlabID
where  isnull(TSD.GroupID,0)<>0
And Isnull(TSD.UOM,0) <> 5
union

SELECT  cast(SubGrp.GroupID as varchar(5))+cast(TSA.SchemeID+10000 as varchar(25)),TSD.SlabStart, TSD.SlabEnd, TSD.Value,  '' 'FreeItem'
,1 'FromIteminBaseUOM'
,1 'ToIteminBaseUOM'
,1 'FromIteminBaseUOM1'
,1 'ToIteminBaseUOM1'
,1 'FromIteminBaseUOM2'
,1 'ToIteminBaseUOM2'
,1 'StartQuantityinUOM'
,1 'StartQuantityinUOM1'
,1 'StartQuantityinUOM2'
,1 'EndQuantityinUOM'
,1 'EndQuantityinUOM1'
,1 'EndQuantityinUOM2'
,1 'FreeQuantityinUOM'
,1 'FreeQuantityinUOM1'
,1 'FreeQuantityinUOM2'
-- ,1 'FreeUOM'
,(case Convert(Varchar(1), IsNull(TSD.UOM,'')) when 1 then 0 when 2 then 1 when 3 then 2 end) 'FreeUOM'
FROM  (select * From  tbl_mERP_SchemeAbstract Where convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between activefrom and activeto
And Active = 1 and SchemeType = 4 And IsNull(schemestatus, 0) In ( 0, 1, 2 ))  TSA
Inner Join  tbl_mERP_SchemeSlabDetail TSD  On TSA.SchemeID = TSD.SchemeID
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = TSD.GroupID And SubGrp.SchemeID = TSD.SchemeID
And TSD.GroupID In(Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where SchemeID = TSD.SchemeID And GroupID = SubGrp.GroupID)
where   isnull(TSD.GroupID,0)<>0
And Isnull(TSD.UOM,0) <> 5
