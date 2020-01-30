Create Procedure mERP_sp_view_CSDisplayAbstract (@SchemeID Int, @PayoutID Int)
As
Begin
Declare @RFAStatus Int
IF @PayoutID = 0 
  Begin
    SET @PayoutID = (Select Top 1 ID From tbl_merp_SchemePayoutPeriod Where SchemeID = @SchemeID)
  End 

Select @RFASTatus = IsNull(ClaimRFA,0) From tbl_merp_SchemePayoutPeriod Where SchemeID = @SchemeID And ID = @PayoutID

Select CSAbs.SchemeID, CSAbs.CS_RecSchID, CSAbs.ActivityCode, CSAbs.Description,
 CSType.ID as 'SchTypeID', CSType.SchemeType,
 "PayoutFrequency" = IsNull(CsAbs.PayoutFrequency,0),
 "PayoutFreqDesc" = Case CsAbs.PayoutFrequency when 0 Then 'Monthly'
 when 1 Then 'Quarterly'
 when 2 then 'Half Yearly'
 when 3 then 'Yearly'
 when 4 then 'End of Period' End,
 CSAbs.SchemeFrom, CSAbs.SchemeTo,
 CSAbs.DownLoadedOn, CSAbs.AppliedOn,
 "Budget" = IsNull(CSAbs.Budget,0), 
 CSAbs.RFAApplicable,
 "RFAClaimYesNo" = Case CSAbs.RFAApplicable When 1 Then 'Yes' Else 'No' End, 
 "BudgetOverRun" = IsNull(CsAbs.BudgetOverRun,0),  
 "BudgetOverRunYesNo" = Case CsAbs.BudgetOverRun When 1 Then 'Yes' Else 'No' End, 
 "UniformAllocFlag" = IsNull(UniformAllocFlag,0), 
 "CurrentStatus" = @RFASTatus,
 "CurrentStatusDesc" = Case @RFASTatus When 0 Then 'Active' Else 'Expired' End,
 "SchemeStatus" = Case IsNull(CSAbs.SchemeStatus,0) When 0 Then 'New' When 1 then 'CR' When 2 Then 'Drop' End,
-- "Active" = Case When @TRANDATE Between ActiveFrom And ActiveTo then 'Active'
-- When @TRANDATE > ActiveTo then 'Expired' End,
 "Active" = Case CSAbs.Active When 1 Then 'Yes' Else 'No' End,
  CSAbs.ExpiryDate,CSCat.Category  
From tbl_mERP_SchemeAbstract CSAbs 
join tbl_mERP_SchemeType CSType on CSType.ID = CSAbs.SchemeType 
left join tbl_mERP_Display_SchCategory CSCat on CSAbs.SchemeID = CSCat.SchemeID 
Where CSAbs.SchemeID = @SchemeID
 
End
