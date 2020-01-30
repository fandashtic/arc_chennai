create view [dbo].[V_SpecialCategory]
([Special_Cat_Code],[CategoryType],[Description],[CreationDate],[SchemeID],[Active])
AS
SELECT	cast(SubGrp.GroupID as varchar(5))+cast(TSA.SchemeID+10000 as varchar(25)),1,
cast(TSA.Description as varchar(100)), TSA.AppliedOn, cast(SubGrp.GroupID as varchar(5))+cast(TSA.SchemeID+10000 as varchar(25)), TSA.active
FROM tbl_mERP_SchemeAbstract TSA inner join tbl_mERP_SchemeSlabDetail TSSD on TSA.SchemeID=TSSD.SchemeID
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = TSSD.GroupID And SubGrp.SchemeID = TSSD.SchemeID
And TSSD.GroupID In(Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where SchemeID = TSSD.SchemeID And GroupID = SubGrp.GroupID)
and TSSD.SlabId = (
--select top 1 SlabID from tbl_mERP_SchemeSlabDetail
Select Min(SlabID) SlabID From tbl_mERP_SchemeSlabDetail
where SchemeId  = TSA.SchemeID and GroupId = TSSD.GroupID
--order by SlabID
)
WHERE TSA.ItemGroup = 2 and TSA.Active = 1
and convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between TSA.activefrom and TSA.activeto
and IsNull(TSA.schemestatus, 0) In ( 0, 1 )
And Isnull(TSSD.UOM,0) <> 5
Union

SELECT	cast(SubGrp.GroupID as varchar(5))+cast(TSA.SchemeID+10000 as varchar(25)),1,
cast(TSA.Description as varchar(100)), TSA.AppliedOn, cast(SubGrp.GroupID as varchar(5))+cast(TSA.SchemeID+10000 as varchar(25)), TSA.active
FROM tbl_mERP_SchemeAbstract TSA inner join tbl_mERP_SchemeSlabDetail TSSD on TSA.SchemeID=TSSD.SchemeID
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = TSSD.GroupID And SubGrp.SchemeID = TSSD.SchemeID
And TSSD.GroupID In(Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where SchemeID = TSSD.SchemeID And GroupID = SubGrp.GroupID)
and TSSD.SlabId = (
--select top 1 SlabID from tbl_mERP_SchemeSlabDetail
Select Min(SlabID) SlabID From tbl_mERP_SchemeSlabDetail
where SchemeId  = TSA.SchemeID and GroupId = TSSD.GroupID
--order by SlabID
)
WHERE TSA.ItemGroup = 2 and TSA.Active = 1
and convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between TSA.activefrom and TSA.activeto
and IsNull(TSA.schemestatus, 0) In ( 2 )
And Isnull(TSSD.UOM,0) <> 5
