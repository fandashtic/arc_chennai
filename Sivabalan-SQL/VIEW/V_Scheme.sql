Create VIEW V_Scheme
([SchemeID], [SchemeName], [SchemeType], [ValidFrom], [ValidTo], [SchemeDescription], [HasSlabs], [CreationDate],
[ModifiedDate], [Customer], [Active])
AS
SELECT cast(SubGrp.GroupID as varchar(5))+cast(TSA.SchemeID+10000 as varchar(25)),
cast(TSA.Description as varchar(100)),
dbo.fn_han_Get_SchemeType(TSSD.UOM,TSO.QPS,ApplicableOn,TSSD.SlabType,0) AS 'SchemeType',
TSA.ActiveFrom, TSA.ActiveTo, cast(TSA.Description as varchar(100)), 1, TSA.AppliedOn,TSA.AppliedOn, 1, TSA.Active
FROM tbl_mERP_SchemeAbstract TSA
inner join tbl_mERP_SchemeSlabDetail TSSD on TSA.SchemeID=TSSD.SchemeID
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = TSSD.GroupID And SubGrp.SchemeID = TSSD.SchemeID
And TSSD.GroupID In(Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where SchemeID = TSSD.SchemeID And GroupID = SubGrp.GroupID)
inner join tbl_mERP_SchemeOutlet TSO on TSO.SchemeID=TSSD.SchemeID and TSO.GroupID=TSSD.GroupID
and TSSD.SlabId =
(
--select top 1 SlabID from tbl_mERP_SchemeSlabDetail
Select Min(SlabID) SlabID From tbl_mERP_SchemeSlabDetail
where SchemeId = TSA.SchemeID and GroupId =TSSD.GroupID And Isnull(TSSD.UOM,0) <> 5
--order by SlabID
)
where TSA.SchemeType not in( 3, 4, 5 ) and TSA.Active = 1
and convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between TSA.activefrom and TSA.activeto
and IsNull(TSA.schemestatus, 0) In ( 0, 1 )
And Isnull(TSSD.UOM,0) <> 5
Union

SELECT cast(SubGrp.GroupID as varchar(5))+cast(TSA.SchemeID+10000 as varchar(25)),
cast(TSA.Description as varchar(100)),
dbo.fn_han_Get_SchemeType(TSSD.UOM,TSO.QPS,ApplicableOn,TSSD.SlabType,0) AS 'SchemeType',
TSA.ActiveFrom, TSA.ActiveTo, cast(TSA.Description as varchar(100)), 1, TSA.AppliedOn,TSA.AppliedOn, 1, TSA.Active
FROM tbl_mERP_SchemeAbstract TSA
inner join tbl_mERP_SchemeSlabDetail TSSD on TSA.SchemeID=TSSD.SchemeID
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = TSSD.GroupID And SubGrp.SchemeID = TSSD.SchemeID
And TSSD.GroupID In(Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where SchemeID = TSSD.SchemeID And GroupID = SubGrp.GroupID)
inner join tbl_mERP_SchemeOutlet TSO on TSO.SchemeID=TSSD.SchemeID and TSO.GroupID=TSSD.GroupID
and TSSD.SlabId =
(
--select top 1 SlabID from tbl_mERP_SchemeSlabDetail
Select Min(SlabID) SlabID From tbl_mERP_SchemeSlabDetail
where SchemeId = TSA.SchemeID and GroupId =TSSD.GroupID
--order by SlabID
)
where TSA.SchemeType not in( 3, 4, 5 ) and TSA.Active = 1
and convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between TSA.activefrom and TSA.activeto
and IsNull(TSA.schemestatus, 0) In ( 2 )
And Isnull(TSSD.UOM,0) <> 5
Union

SELECT TSA.SchemeID,
cast(TSA.Description as varchar(100)),
dbo.fn_han_Get_SchemeType(0,0,TSA.SchemeType,0,0) AS 'SchemeType',
SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo, cast(TSA.Description as varchar(100)), 1, TSA.AppliedOn,TSA.AppliedOn, 1, TSA.Active
FROM tbl_mERP_SchemeAbstract TSA inner join tbl_mERP_SchemePayoutPeriod SPP on TSA.Schemeid=SPP.Schemeid
WHERE TSA.SchemeType = 3 and TSA.Active = 1 and convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between SPP.PayoutPeriodFrom AND SPP.PayoutPeriodTo

union

SELECT distinct cast(SubGrp.GroupID as varchar(5))+cast(TSA.SchemeID+10000 as varchar(25)),
cast(TSA.Description as varchar(100)),
dbo.fn_han_Get_SchemeType(0,0,TSA.ApplicableOn,0,4) AS 'SchemeType',
TSA.ActiveFrom, TSA.ActiveTo, cast(TSA.Description as varchar(100)), 1, TSA.AppliedOn,TSA.AppliedOn, 1, TSA.Active
FROM tbl_mERP_SchemeAbstract TSA
inner join tbl_mERP_SchemeSlabDetail TSSD on TSA.SchemeID=TSSD.SchemeID
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = TSSD.GroupID And SubGrp.SchemeID = TSSD.SchemeID
And TSSD.GroupID In(Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where SchemeID = TSSD.SchemeID And GroupID = SubGrp.GroupID)
WHERE TSA.SchemeType = 4 and TSA.Active = 1
and convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between TSA.activefrom and TSA.activeto
and IsNull(TSA.schemestatus, 0) In ( 0, 1 )
And Isnull(TSSD.UOM,0) <> 5
Union

SELECT distinct cast(SubGrp.GroupID as varchar(5))+cast(TSA.SchemeID+10000 as varchar(25)),
cast(TSA.Description as varchar(100)),
dbo.fn_han_Get_SchemeType(0,0,TSA.ApplicableOn,0,4) AS 'SchemeType',
TSA.ActiveFrom, TSA.ActiveTo, cast(TSA.Description as varchar(100)), 1, TSA.AppliedOn,TSA.AppliedOn, 1, TSA.Active
FROM tbl_mERP_SchemeAbstract TSA
inner join tbl_mERP_SchemeSlabDetail TSSD on TSA.SchemeID=TSSD.SchemeID
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = TSSD.GroupID And SubGrp.SchemeID = TSSD.SchemeID
And TSSD.GroupID In(Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where SchemeID = TSSD.SchemeID And GroupID = SubGrp.GroupID)
WHERE TSA.SchemeType = 4 and TSA.Active = 1
and convert(datetime, convert(varchar(10), getdate(), 103 ), 103) between TSA.activefrom and TSA.activeto
and IsNull(TSA.schemestatus, 0) In ( 2 )
And Isnull(TSSD.UOM,0) <> 5
