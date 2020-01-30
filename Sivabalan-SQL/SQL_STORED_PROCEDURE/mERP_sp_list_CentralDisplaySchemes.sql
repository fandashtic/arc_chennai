Create procedure mERP_sp_list_CentralDisplaySchemes(@SCR_MODE INT, @SchemeCode nVarChar(50), @FromDate DateTime, @ToDate DateTime,  @PAYOUT INT = 0, @BUDGET INT = 0)  
 As  
 Begin
 IF @SCR_MODE = 0 or @SCR_MODE = 1
   Begin
   Declare @tmpBudgetPayout Table(SchemeID Int, PayoutPeriodID Int, AllocatedAmount Decimal(18,6), PendingAmount Decimal(18,6))
   /* 0 - ALL
     1 - ALLOCATED
     2 - PARTIAL
     3 - NOT ALLOCATED  */
   IF @BUDGET = 1
     Insert into @tmpBudgetPayout
     Select BP.SchemeID, BP.PayoutPeriodID, Sum(BP.AllocatedAmount) 'AllocatedAmount', Sum(BP.PendingAmount) 'PendingAmount'
     From   tbl_mERP_DispSchBudgetPayout BP, tbl_meRP_SchemePayoutPeriod PP
     Where  BP.SchemeID = PP.SchemeID And BP.PayoutPeriodID = PP.ID And --PP.Status & 128 = 128 And 
     IsNull(PP.Status,0) & 128 = (Case @PAYOUT When 0 Then IsNull(PP.Status,0)&128 When 1 Then 0 When 2 Then 128 End)
     Group By BP.SchemeID, BP.PayoutPeriodID
     Having Sum(IsNull(BP.AllocatedAmount,0)) >= (Select IsNull(Budget,0) From tbl_mErp_SchemeAbstract Where SchemeID = BP.SchemeID)
   Else IF @BUDGET = 2 
     Insert into @tmpBudgetPayout
     Select PP.SchemeID, IsNull(BP.PayoutPeriodID,0), Sum(IsNull(BP.AllocatedAmount,0)) 'AllocatedAmount', Sum(IsNull(BP.PendingAmount,0)) 'PendingAmount'
     From tbl_mERP_DispSchBudgetPayout BP, tbl_meRP_SchemePayoutPeriod PP
     Where BP.SchemeID = PP.SchemeID And BP.PayoutPeriodID = PP.ID And --PP.Status & 128 = 0 And
     IsNull(PP.Status,0) & 128 = (Case @PAYOUT When 0 Then IsNull(PP.Status,0)&128 When 1 Then 0 When 2 Then 128 End)
     Group By PP.SchemeID, IsNull(BP.PayoutPeriodID,0)
     Having Sum(IsNull(BP.AllocatedAmount,0)) < (Select IsNull(Budget,0) From tbl_mErp_SchemeAbstract Where SchemeID = PP.SchemeID) And 
     Sum(IsNull(BP.AllocatedAmount,0)) > 0
   Else If @BUDGET = 3
     Insert into @tmpBudgetPayout
     Select PP.SchemeID, PP.ID, Sum(IsNull(BP.AllocatedAmount,0)) 'AllocatedAmount', Sum(IsNull(BP.PendingAmount,0)) 'PendingAmount'
     From  tbl_mERP_DispSchBudgetPayout BP
	 Right Outer Join  tbl_mERP_SchemePayoutPeriod PP On PP.SchemeID = BP.SchemeID And PP.ID = BP.PayoutPeriodID 
     Where PP.Active = Case @SCR_MODE When 0 Then PP.Active Else 1 End 		
       And PP.ID not In (Select IsNull(PayoutPeriodID,0) as 'PayoutPeriodID' From tbl_mERP_DispSchBudgetPayout where SchemeID = PP.SchemeID)
       And IsNull(PP.Status,0) & 128 = (Case @PAYOUT When 0 Then IsNull(PP.Status,0)&128 When 1 Then 0 When 2 Then 128 End)
     Group By PP.SchemeID, PP.ID
     Having Sum(IsNull(BP.AllocatedAmount,0)) = 0
   Else
     Insert into @tmpBudgetPayout
     Select Distinct PP.SchemeID, PP.ID, 0, 0 From tbl_mERP_SchemePayoutPeriod PP, tbl_mERP_DispSchCapPerOutlet CpO
     Where  CpO.SchemeID = PP.SchemeID And --PP.Active = 1 And
	 PP.Active = Case @SCR_MODE When 0 Then PP.Active Else 1 End  and
     IsNull(PP.Status,0) & 128 = (Case @PAYOUT When 0 Then IsNull(PP.Status,0)&128 When 1 Then 0 When 2 Then 128 End)


Select CSAbstract.SchemeID,  
    CSAbstract.CS_RecSchID,  
    CSAbstract.ActivityCode,  
    CSAbstract.Description,  
    CSAbstract.SchemeFrom,  
    CSAbstract.SchemeTo,  
    "PayoutPeriod" = convert(nvarchar(12),PP.PayoutPeriodFrom,103) + N'-'+ convert(nvarchar(12),PP.PayoutPeriodTo,103),
    "PayoutStatus" =  Case When (IsNull(PP.Status,0) & 128) = 0 Then 'Active' When (IsNull(PP.Status,0) & 192) = 192  Then 'Closed' Else 'Expired' End,
    "RecdStatus" = Case IsNull(CSAbstract.SchemeStatus,0) When 0 Then 'New' When 1 then 'CR' When 2 Then 'Drop' End,
    PP.ID as 'PayoutPeriodID'
   From tbl_mERP_SchemeAbstract CSAbstract, tbl_mERP_SchemeType CSType, tbl_mERP_SchemePayoutPeriod PP, @tmpBudgetPayout tmpPayout
   Where  
    CSType.ID = 3 
	-- And CSAbstract.ViewDate Between @FromDate And @ToDate
    And  ((@FromDate Between CSAbstract.ViewDate And CSAbstract.SchemeTo)  Or 
          (@ToDate Between CSAbstract.ViewDate And CSAbstract.SchemeTo) Or 
          (CSAbstract.ViewDate Between @FromDate And @ToDate) Or
          (CSAbstract.SchemeTo Between @FromDate And @ToDate))
    And CSType.ID  = CSAbstract.SchemeType 
    And  CSAbstract.CS_RecSchID = Case @SchemeCode When N'%' Then CSAbstract.CS_RecSchID Else @SchemeCode End
    -- And dbo.StripTimeFromDate(CSAbstract.ActiveFrom) <= (Select Top 1 dbo.StripTimeFromDate(Transactiondate) From Setup)
   And dbo.StripTimeFromDate(CSAbstract.ViewDate) <= (Select Top 1 dbo.StripTimeFromDate(Transactiondate) From Setup)
--    And CSAbstract.Active = Case @FILTER WHEN 0 THEN CSAbstract.Active WHEN 1 THEN 1 WHEN 2 THEN 0 END  
    And CSAbstract.SchemeID = PP.SchemeID  
    And CSAbstract.SchemeID = tmpPayout.SchemeID
    And PP.ID = tmpPayout.PayoutPeriodID
    --And IsNull(PP.Active,0) = 1 
	And IsNull(PP.Active,0) = Case @SCR_MODE When 0 Then PP.Active Else 1 End 
    And CSAbstract.Active = Case @SCR_MODE When 0 Then CSAbstract.Active Else 1 End 
   Order by  
    CSAbstract.ActivityCode, PP.ID
   End
 Else If @SCR_MODE = 2   /* Cr Note Generation */
   Begin
   Declare @TRANDATE DateTime
   Select Top 1 @TRANDATE = dbo.StripTimeFromDate(Transactiondate) From Setup

   Select Distinct CSAbstract.SchemeID,  
    CSAbstract.CS_RecSchID,  
    CSAbstract.ActivityCode,  
    CSAbstract.Description,  
    CSAbstract.SchemeFrom,  
    CSAbstract.SchemeTo,  
    "PayoutPeriod" = convert(nvarchar(12),PP.PayoutPeriodFrom,103) + N'-'+ convert(nvarchar(12),PP.PayoutPeriodTo,103), 
    "SchemeStatus" = Case When @TRANDATE Between SchemeFrom And SchemeTo then 'Active'
                    When @TRANDATE > SchemeTo then 'Expired' End,
    "RecdStatus" = Case IsNull(CSAbstract.SchemeStatus,0) When 0 Then 'New' When 1 then 'CR' When 2 Then 'Drop' End,
--   "PayoutStatus" =  Case IsNull(CSAbstract.PayoutStatus,0) When 0 Then 'Active' Else 'Expired' End,
   PP.ID as 'PayoutPeriodID'
   From tbl_mERP_SchemeAbstract CSAbstract, tbl_mERP_SchemeType CSType, tbl_mERP_SchemePayoutPeriod PP
   Where CSType.ID = 3 
    And CSType.ID  = CSAbstract.SchemeType 
    And CSAbstract.CS_RecSchID = Case @SchemeCode When N'%' Then CSAbstract.CS_RecSchID Else @SchemeCode End
    And dbo.StripTimeFromDate(CSAbstract.SchemeFrom) <= @TRANDATE
    And CSAbstract.SchemeID = PP.SchemeID  
    And PP.PayoutPeriodTo < @TRANDATE --And PP.Status & 128 = 0 
    And IsNull(PP.Active,0) = 1
   Order by  
    CSAbstract.ActivityCode, PP.ID
   End
 End

