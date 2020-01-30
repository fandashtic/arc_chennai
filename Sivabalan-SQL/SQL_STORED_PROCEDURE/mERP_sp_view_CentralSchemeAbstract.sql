Create Procedure mERP_sp_view_CentralSchemeAbstract (@SchemeID Int)
As
Begin
Declare @TRANDATE DateTime
Select Top 1 @TRANDATE = dbo.StripTimeFromDate(Transactiondate) From Setup

Select CSAbs.SchemeID, CSAbs.CS_RecSchID, CSAbs.ActivityCode, CSAbs.Description,
 CSType.ID as 'SchTypeID', CSType.SchemeType,
 SchAppType.ID as 'SchAppTypeID', SchAppType.ApplicableOn,
 SchItemGrp.ID as 'SchItmGrpID', SchItemGrp.ItemGroup,
 CSAbs.SchemeFrom, CSAbs.SchemeTo,
 CSAbs.ActiveFrom, CSAbs.ActiveTo,
 CSAbs.DownLoadedOn, CSAbs.AppliedOn,
 Case CSAbs.Active When 1 Then 'Yes' Else 'No' End 'Active', CSAbs.SKUCount,
 Case 
When (@TRANDATE Between ActiveFrom And ActiveTo) then 'Active'
When (@TRANDATE  < ActiveFrom ) then 'Active'
When @TRANDATE > ActiveTo then 'Expired' End 'Status',
 IsNull(Budget,0) as Budget, RFAApplicable, CSAbs.ExpiryDate,Case SchemeStatus when 2 Then 'Drop' when 1 then 'CR' else 'New' End "SchemeStatus" ,
(Case When isnull(CSAbs.IsMinQty,0) = 1 Then 'Yes' When isnull(CSAbs.IsMinQty,0) = 0 Then 'No' End) "Minrange"
,Case When isnull(CSAbs.Color,'') = '' Then 'ALL' Else isnull(CSAbs.Color,'') End Color
From tbl_mERP_SchemeAbstract CSAbs, tbl_mERP_SchemeType CSType,
 tbl_mERP_SchemeApplicableType SchAppType, tbl_mERP_SchemeItemGroup SchItemGrp
Where
 CSAbs.SchemeID = @SchemeID and
 CSType.ID = CSAbs.SchemeType and
 SchAppType.ID = CSAbs.ApplicableOn and
 SchItemGrp.ID = CSAbs.ItemGroup and
 -- CSAbs.ActiveFrom <= @TRANDATE
CSAbs.ViewDate <= @TRANDATE
End
