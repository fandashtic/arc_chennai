Create procedure mERP_sp_display_pendingoutlets(@DSchemeID nVarchar(4000),@NotinSchemeID nVarchar(4000))  
As    
Begin  
	/* We have introduced @NotinSchemeID to avoid showing same activity code in Pending and Genearted alert screen while 
		submitting RFA */
	SET NOCOUNT ON
	Set Dateformat DMY
  
	Declare @SchemeID int  
	Declare @SchPayID nVarchar(100)  
	Declare @SchNOTPayID nVarchar(100) 
    Declare @PayoutID int
	Declare @ActivityCode nVarchar(255)
	Declare @DispSchemeDesc nVarchar(1000)
	Declare @TotalCustomer int
	Declare @Generated int
	
	Create table #DispSchemeID(ID Int Identity(1,1), SchemeID nVarchar(255))  
	Insert Into #DispSchemeID  
	Select * from dbo.sp_SplitIn2Rows(@DSchemeID, ',')  

	Create Table #DispNotSchemeID (ID Int Identity(1,1), SchemeID nVarchar(255)) 
	Insert Into #DispNotSchemeID  
	Select * from dbo.sp_SplitIn2Rows(@NotinSchemeID, ',')  
	  
	Create table #TempSchemeID(ID Int identity(1,1), SchemeID int, PayoutID int)  
	Truncate table #TempSchemeID  

	Create table #TempNotSchemeID(ID Int identity(1,1), SchemeID int, PayoutID int)  
	Truncate table #TempNotSchemeID 
	  
	Create table #TempDisplaySchemeIDs(ID Int identity(1,1), SchemeID int, PayoutID int)  
	Truncate table #TempDisplaySchemeIDs  
	  
	Declare PayCur Cursor for  
	Select SchemeID from #DispSchemeID Order By ID  
	  
	Open PayCur  
	Fetch from payCur Into @SchPayID  
	While @@Fetch_Status = 0    
	Begin    
		Insert Into #TempSchemeID(SchemeID, PayoutID)  
		Select * from dbo.merp_fn_SplitIn2Cols_Disp(@SchPayID, '|')  
		Fetch Next from payCur Into @SchPayID  
	End  
	Close PayCur  
	Deallocate Paycur  


	Declare NOTPayCur Cursor for  
	Select SchemeID from #DispNotSchemeID Order By ID  
	  
	Open NOTPayCur  
	Fetch from NOTpayCur Into @SchNOTPayID  
	While @@Fetch_Status = 0    
	Begin    
		Insert Into #TempNotSchemeID(SchemeID, PayoutID)  
		Select * from dbo.merp_fn_SplitIn2Cols_Disp(@SchNOTPayID, '|')  
		Fetch Next from NOTPayCur Into @SchNOTPayID  
	End  
	Close NOTPayCur  
	Deallocate NOTPaycur  

	  
	Insert Into #TempDisplaySchemeIDs(SchemeID, PayoutID)  
	Select T.SchemeID, PayoutID From #TempSchemeID T Inner Join tbl_merp_SchemeAbstract SA ON T.SchemeID = SA.SchemeID  
	and SA.Schemetype = 3  
	
	Create table #DisplaySchemetmp(ActivityCode nVarchar(255),  SchDesc nVarchar(1000),  TotalCustomersCnt Int, CrNoteGeneratedCnt int, Pending int)  

	Declare SchemeCur Cursor For    
	Select SchemeID, PayoutID From #TempDisplaySchemeIDs where schemeID not in (Select distinct SchemeID from #TempNotSchemeID)
	And PayoutID not in (Select distinct payoutID from #TempNotSchemeID) Order By ID  
	Open SchemeCur  
	Fetch From SchemeCur Into @SchemeID, @payoutID  
	While @@Fetch_Status = 0  
	Begin 
		Set @ActivityCode  = ''  
		Set @DispSchemeDesc = ''
		Select @TotalCustomer=isnull(count(distinct outletcode),0) from tbl_mERP_DispSchBudgetPayout where   
			SchemeID = @SchemeID     
			And PayoutPeriodID = @PayoutID 
		Select @Generated=isnull(count(distinct outletcode),0) from tbl_mERP_DispSchBudgetPayout where   
			SchemeID = @SchemeID     
			And PayoutPeriodID = @PayoutID 
			And isnull(CRNoteRaised,0)=1
		Select @ActivityCode = ActivityCode, @DispSchemeDesc = Description  from tbl_merp_SchemeAbstract where SchemeID = @SchemeID   
		Insert Into #DisplaySchemetmp(ActivityCode, SchDesc, TotalCustomersCnt, CrNoteGeneratedCnt,Pending)  
		Select @ActivityCode,@DispSchemeDesc,@TotalCustomer,@Generated,(@TotalCustomer-@Generated)
		Where (@TotalCustomer-@Generated) > 0
		Fetch Next From SchemeCur Into @SchemeID, @payoutID  
	End   
	Close SchemeCur  
	Deallocate SchemeCur  
	Select * from #DisplaySchemetmp
	Drop table #DispSchemeID
	Drop Table #TempSchemeID
	Drop Table #TempDisplaySchemeIDs
	Drop Table #DisplaySchemetmp
	Drop Table #DispNotSchemeID
	Drop Table #TempNotSchemeID
	SET NOCOUNT OFF
End  
