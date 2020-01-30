Create Procedure mERP_sp_Save_DSPMetric_TargetDefn_NOA(@PMetricID Int, @PMDSTypeID Int, @PMParamID Int, @SalesmanID Int, 
                @NOACount int, @DSCGMapID Int, @PMTargetDefnID Int=0, @LogonUser nVarchar(50),@MaxPoints Decimal(18,6))
As
Begin

	Declare @DSTypeID Int

  /*Set Active Flag as 0 if Target Defined already*/
  If @PMTargetDefnID = 0
  Begin
    Select @PMTargetDefnID = TargetDefnID From tbl_merp_NOA_TargetDefn 
    Where PMID = @PMetricID And PMDSTypeID = @PMDSTypeID And ParamID = @PMParamID --And FocusID = @PMFocusID 
	And SalesManId = @SalesmanID And Active = 1
  End

  If @PMTargetDefnID > 0
  Begin
    Update tbl_merp_NOA_TargetDefn Set Active= 0, ModifiedDate = Getdate() Where TargetDefnID = @PMTargetDefnID
  End

  Select @DSTypeID = 0
  Select @DSTypeID = isNull(DSTypeID,0) From DSType_Details Where DSTypeCtlPos = 1 And SalesmanID = @SalesmanID
	  	 

  Insert into tbl_merp_NOA_TargetDefn(PMID, PMDSTypeID, ParamID, --FocusID, 
  SalesmanID, DSTypeCGMapID, NOACount, LogonUser,DSTypeID,AutoPostFlag,MaxPoints) Values
  (@PMetricID, @PMDSTypeID, @PMParamID, --@PMFocusID, 
	@SalesmanID, @DSCGMapID, @NOACount, @LogonUser,@DSTypeID,1,@MaxPoints)
  Select @@Identity 


IF @@Identity > 0
Begin	
	Insert Into tbl_merp_NOA_TargetDefn_Detail(TargetDefnID,OutletID,Target)
	Select @@Identity,* From dbo.FN_Get_OutletDSTarget_NOA(@PMetricID,@PMDSTypeID,@PMParamID,@SalesmanID)
End

End
