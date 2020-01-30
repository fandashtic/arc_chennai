Create Procedure mERP_sp_Save_DSPMetric_TargetDefn_TLC(@PMetricID Int, @PMDSTypeID Int, @PMParamID Int, --@PMFocusID Int, 
				@SalesmanID Int, 
                @TargetValue Decimal(18,6), @Maxpoints Decimal(18,6), @DSCGMapID Int, @PMTargetDefnID Int=0, @LogonUser nVarchar(50))
As
Begin

	Declare @DSTypeID Int

  /*Set Active Flag as 0 if Target Defined already*/
  If @PMTargetDefnID = 0
  Begin
    Select @PMTargetDefnID = TargetDefnID From tbl_merp_PMOutletAch_TargetDefn 
    Where PMID = @PMetricID And PMDSTypeID = @PMDSTypeID And ParamID = @PMParamID --And FocusID = @PMFocusID 
	And SalesManId = @SalesmanID And Active = 1
  End

  If @PMTargetDefnID > 0
  Begin
    Update tbl_merp_PMOutletAch_TargetDefn Set Active= 0, ModifiedDate = Getdate() Where TargetDefnID = @PMTargetDefnID
  End

  Select @DSTypeID = 0
  Select @DSTypeID = isNull(DSTypeID,0) From DSType_Details Where DSTypeCtlPos = 1 And SalesmanID = @SalesmanID
	
  	
  

  Insert into tbl_merp_PMOutletAch_TargetDefn(PMID, PMDSTypeID, ParamID, --FocusID, 
  SalesmanID, DSTypeCGMapID, Target, MaxPoints, LogonUser,DSTypeID,AutoPostFlag) Values
  (@PMetricID, @PMDSTypeID, @PMParamID, --@PMFocusID, 
	@SalesmanID, @DSCGMapID, @TargetValue, @Maxpoints, @LogonUser,@DSTypeID,1)
  Select @@Identity 

End
