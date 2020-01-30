Create Procedure mERP_sp_Save_DSPMetric_TargetDefn(@PMetricID Int, @PMDSTypeID Int, @PMParamID Int, --@PMFocusID Int, 
				@SalesmanID Int, 
                @TargetValue Decimal(18,6), @Maxpoints Decimal(18,6), @DSCGMapID Int, @PMTargetDefnID Int=0, @LogonUser nVarchar(50)
				,@GrowthPerc Decimal(18,6) = 0,@ProposedTargetValue Decimal(18,6) = 0,@Last3MonthsAverageSales Decimal(18,6) = 0,
				@OriginalTarget Decimal(18,6) = 0)
As
Begin

	Declare @DSTypeID Int

  /*Set Active Flag as 0 if Target Defined already*/
  If @PMTargetDefnID = 0
  Begin
    Select @PMTargetDefnID = TargetDefnID From tbl_mERP_PMetric_TargetDefn 
    Where PMID = @PMetricID And PMDSTypeID = @PMDSTypeID And ParamID = @PMParamID --And FocusID = @PMFocusID 
	And SalesManId = @SalesmanID And Active = 1
  End

  If @PMTargetDefnID > 0
  Begin
    Update tbl_mERP_PMetric_TargetDefn Set Active= 0, ModifiedDate = Getdate() Where TargetDefnID = @PMTargetDefnID
  End

  Select @DSTypeID = 0
  Select @DSTypeID = isNull(DSTypeID,0) From DSType_Details Where DSTypeCtlPos = 1 And SalesmanID = @SalesmanID
	
  	
  

  Insert into tbl_mERP_PMetric_TargetDefn(PMID, PMDSTypeID, ParamID, --FocusID, 
  SalesmanID, DSTypeCGMapID, Target, MaxPoints, LogonUser,DSTypeID,GrowthPerc,ProposedTargetValue,AvgSales,AutoPostFlag,OriginalTarget) Values
  (@PMetricID, @PMDSTypeID, @PMParamID, --@PMFocusID, 
	@SalesmanID, @DSCGMapID, @TargetValue, @Maxpoints, @LogonUser,@DSTypeID,@GrowthPerc,@ProposedTargetValue,@Last3MonthsAverageSales,1,@OriginalTarget)
  Select @@Identity 

End
