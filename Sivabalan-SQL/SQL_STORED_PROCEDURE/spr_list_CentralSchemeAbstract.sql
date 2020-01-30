Create Procedure spr_list_CentralSchemeAbstract(@ActivityCode nVarChar(50), @FromDate DateTime, @ToDate DateTime)
As
Begin

Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)        
Create table #tmpActivityCode(ActivityCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
If @ActivityCode='%' Or @ActivityCode = 'ALL'
  Insert into #tmpActivityCode select Distinct ActivityCode From tbl_mERP_SchemeAbstract
Else      
  Insert into #tmpActivityCode select * from dbo.sp_SplitIn2Rows(@ActivityCode,@Delimeter)


Declare @TRANDATE DateTime
Select Top 1 @TRANDATE = dbo.StripTimeFromDate(Transactiondate) From Setup
Select CSAbs.SchemeID, "Scheme Sr.No" = CSAbs.SchemeID, "Scheme Code" = CSAbs.CS_RecSchID, "Activity Code" = CSAbs.ActivityCode, 
 "Description" = CSAbs.Description, "Scheme Type" = CSType.SchemeType, "Applicable_On" = SchAppType.ApplicableOn,
 "Item Group" = SchItemGrp.ItemGroup, "Scheme From" = CSAbs.SchemeFrom, "Scheme To" = CSAbs.SchemeTo,
 "Applicable From" = CSAbs.ActiveFrom, "Applicable To" = CSAbs.ActiveTo, "Downloaded On" = CSAbs.DownLoadedOn, 
 "Applied On" = CSAbs.AppliedOn,
 "Claimable" =  Case IsNull(RFAApplicable,0) When 1 Then 'Yes' Else 'No' End, 
 "No Of lines/Invoice" = CSAbs.SKUCount, 
 "Status" = Case When @TRANDATE Between ActiveFrom And ActiveTo then 'Active'
                 When @TRANDATE > ActiveTo then 'Expired' End,
 "Active" = Case CSAbs.Active When 1 Then 'Yes' Else 'No' End,
 "Budget" = IsNull(Budget,0),
 "Expiry Date" = CSAbs.ExpiryDate
From tbl_mERP_SchemeAbstract CSAbs, tbl_mERP_SchemeType CSType,
 tbl_mERP_SchemeApplicableType SchAppType, tbl_mERP_SchemeItemGroup SchItemGrp
Where
 CSAbs.ActiveFrom Between @FromDate And @ToDate and
 CSabs.ActivityCode IN (Select ActivityCode COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpActivityCode) and 
 CSType.ID = CSAbs.SchemeType and
 SchAppType.ID = CSAbs.ApplicableOn and
 SchItemGrp.ID = CSAbs.ItemGroup and
 CSAbs.ActiveFrom <= @TRANDATE
Order by Csabs.SchemeId 

Drop table #tmpActivityCode
End
