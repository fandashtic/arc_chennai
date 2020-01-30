Create procedure mERP_sp_list_RFASchemeAlertsCustomersCnt_diplay(@DSchemeID nVarchar(4000))  
As    
Begin  

	SET NOCOUNT ON
	Set Dateformat DMY
	/* Only Display Scheme will be considered in this SP*/
	/* QPS free item is handled in the another SP mERP_sp_list_RFASchemeAlertsCustomersCnt_QPSFree*/
  
	Declare @SchemeID int  
	  
	Create table #DispSchemeID(ID Int Identity(1,1), SchemeID nVarchar(255))  
	Insert Into #DispSchemeID  
	Select * from dbo.sp_SplitIn2Rows(@DSchemeID, ',')  
	  
	Create table #TempSchemeID(ID Int identity(1,1), SchemeID int, PayoutID int)  
	Truncate table #TempSchemeID  
	  
	Create table #TempDisplaySchemeIDs(ID Int identity(1,1), SchemeID int, PayoutID int)  
	Truncate table #TempDisplaySchemeIDs  
	  
	Declare @SchPayID nVarchar(100)  
	  
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
	  
	Insert Into #TempDisplaySchemeIDs(SchemeID, PayoutID)  
	Select T.SchemeID, PayoutID From #TempSchemeID T Inner Join tbl_merp_SchemeAbstract SA ON T.SchemeID = SA.SchemeID  
	and SA.Schemetype = 3  
	   
	Declare @OLClassID int  
	Declare @cntCustomers int  
	Declare @PayoutID int  
	Declare @TotalcntCustomers int  
	Declare @CRNoteRaisedCustomers int  
	Declare @CntCustomersNOtCreated int  
	Declare @DispSchemeDesc nVarchar(1000)  
	Declare @QPSSchemeDesc nVarchar(1000)  

	/* Close Day Validation Starts*/
	/*Store Lastinventory upload date*/  
	Declare @Lastinventoryupload datetime   
	Select top 1 @Lastinventoryupload  = dbo.stripdatefromtime(isnull(Lastinventoryupload,getdate())) from Setup  
	Declare @CNAdj Table(CreditID int,DocumentReference nvarchar(255)) 
	Declare @TempOutput Table(ActivityCode nVarchar(255),SchDesc nVarchar(1000), SchemeID int, PayoutID int)
	/* Close Day Validation Ends*/
  
	Create table #DisplaySchemetmp(ID Int Identity(1,1), ActivityCode nVarchar(255),  SchDesc nVarchar(1000),  TotalCustomersCnt Int, CreditNoteCustomers Int, CntCustomersNOtCreated int, SchemeID int,Schemetype nVarchar(100),PayoutID int)  
	/* To handle multiple credit notes for the same customer and for the same PayoutPeriod (CR are stored as comman seperated value in table)*/
	Create Table #OverallDocRef (ID int identity(1,1),DocReference nvarchar(255))
	Create Table #TmpDocRef (ID int identity(1,1),DocReference nvarchar(255),CreditId int)
	Declare @DocRef as nvarchar(255)
	Declare @i as int
	Declare @Count as int
	  
	Declare @Channel nVarchar(255)  
	Declare @Outlettype nVarchar(255)  
	Declare @SubOutlettype nVarchar(255)  
	Declare @ActivityCode nVarchar(255)  
	Declare @OutletCode nVarchar(255)  
	Declare @TempOutletCode nVarchar(255)  

	Declare SchemeCur Cursor For    
	Select SchemeID, PayoutID From #TempDisplaySchemeIDs Order By ID  
	Open SchemeCur  
	Fetch From SchemeCur Into @SchemeID, @payoutID  
	While @@Fetch_Status = 0  
	Begin 

		/*Since DocRef is stored in comma sepearted value we are using the #TmpDocRef table */ 
		Truncate Table #TmpDocRef
		Truncate Table #OverallDocRef
		set @i=1
		set @Count=0

		insert into #OverallDocRef(DocReference)
		Select isnull(DocReference,'') from  tbl_mERP_DispSchBudgetPayout DS where DS.SchemeID = @SchemeID   
		and DS.CRNoteRaised = 1 and DS.PayoutPeriodID = @PayoutID  
		Select @Count = count(*) from  tbl_mERP_DispSchBudgetPayout DS where DS.SchemeID = @SchemeID   
		and DS.CRNoteRaised = 1 and DS.PayoutPeriodID = @PayoutID  

		While @i < = @Count
		BEGIN
			Select @DocRef=DocReference From #OverallDocRef where ID=@i
			Insert into #TmpDocRef(DocReference)
			Select * From dbo.sp_splitin2Rows(@DocRef,',')
			Set @i= @i + 1 
		END
		Set @ActivityCode  = ''  
		Select @ActivityCode = ActivityCode, @DispSchemeDesc = Description  from tbl_merp_SchemeAbstract where SchemeID = @SchemeID   

	    update T  set CreditID =CN.CreditID from #TmpDocRef T,CreditNote CN where T.DocReference=CN.DocumentReference
        And isnull(CN.PayoutID,0) = @payoutID
        And isnull(CN.Flag,0)=1

		Set @cntCustomers = 0  
		Set @TotalcntCustomers = 0  
	  
		Set @OlclassID = 0  
		Set @cntCustomers = 0  
		/* Total count of Customers allocated and credit note raised*/ 
		Select @cntCustomers = Count(*) from tbl_mERP_DispSchBudgetPayout where SchemeID = @SchemeID and payoutPeriodID = @payoutID And CRNoteRaised = 1 
		
		/* To handle multiple credit notes for the same customer and for the same PayoutPeriod (CR are stored as comman seperated value in table)*/
		set @i=1
		set @Count=0
		Set @TempOutletCode=''
	    Set @CRNoteRaisedCustomers=0
		Select @count= count(*) from #TmpDocRef

		/* Total count of credit note raised */
		while @i<= @Count
		BEGIN
			Set @OutletCode =''
			Select @OutletCode = DS.OutletCode from tbl_mERP_DispSchBudgetPayout DS,CreditNote CN where   
			DS.SchemeID = @SchemeID     
			and DS.CRNoteRaised = 1 and DS.PayoutPeriodID = @PayoutID    
			And CN.CreditID = (Select rtrim(ltrim(Temp.CreditID)) from #TmpDocRef Temp Where Id= @i)
			And DS.payoutPeriodID=CN.PayoutID  
			And DS.OutletCode=CN.CustomerID
			And isnull(CN.Balance,0)=0  
			And isnull(CN.Flag,0)=1 Order by DS.OutletCode
			/* Below checking is done to address the point :	
				If Budget Value is 100 and at first time credit note is generated for 50 Rs. and second time 
				it is created for 50 Rs.
			*/
			if @OutletCode <> ''
			BEGIN

				If @TempOutletCode <> @OutletCode And (Select isnull(CN.Balance,0) from CreditNote CN where CN.CreditID = (Select rtrim(ltrim(Temp.CreditID)) from #TmpDocRef Temp Where Id= @i))=0
				BEGIN
					Set @CRNoteRaisedCustomers =isnull(@CRNoteRaisedCustomers,0)+1
					Set @TempOutletCode=@OutletCode
				END
				ELSE IF @TempOutletCode = @OutletCode And (Select isnull(CN.Balance,0) from CreditNote CN where CN.CreditID = (Select rtrim(ltrim(Temp.CreditID)) from #TmpDocRef Temp Where Id= @i))<>0
				BEGIN
					/* To avoid Negative Count*/
					If isnull(@CRNoteRaisedCustomers,0)-1 > 0
					BEGIN
						Set @CRNoteRaisedCustomers =isnull(@CRNoteRaisedCustomers,0)-1
					END
				END 
			END
			Set @i= @i + 1 
		END
		 
		

		/* @TotalcntCustomers will be always zero */ 
		Set @TotalcntCustomers = @TotalcntCustomers + @cntCustomers  

		/* Total count of Customers allocated  > credit note raised customer */
		If IsNull(@TotalcntCustomers,0) > IsNull(@CRNoteRaisedCustomers,0)  
		Begin  
			/* Credit Note not raised customers*/
			Set @CntCustomersNotCreated = IsNull(@TotalcntCustomers,0) - IsNull(@CRNoteRaisedCustomers,0)  
		End  


		/* If there is any customers for whom credit note is not raised, show them*/ 
		If IsNull(@CntCustomersNOtCreated,0) > 0   
		Begin  
			Insert Into #DisplaySchemetmp(ActivityCode, SchDesc, TotalCustomersCnt, CreditNoteCustomers, CntCustomersNOtCreated, SchemeID, Schemetype,PayoutID)  
			Select @ActivityCode, @DispSchemeDesc, IsNull(@TotalcntCustomers,0), IsNull(@CRNoteRaisedCustomers,0), IsNull(@CntCustomersNOtCreated,0), @SchemeID, 'Display',@PayoutID  
		End  
	  
		Fetch Next From SchemeCur Into @SchemeID, @payoutID  
	End   
	Close SchemeCur  
	Deallocate SchemeCur  

	Select ID, ActivityCode, SchDesc,  Schemetype, TotalCustomersCnt, CreditNoteCustomers, cntCustomersNotCreated, SchemeID,PayoutID from #DisplaySchemetmp 
	where TotalCustomersCnt <> CreditNoteCustomers  

	/* Close Day Validation starts*/
	/* Credit Notes which are fully adjusted ONLY will be considered in the below steps*/


	Declare SchemeCur_CloseDay Cursor For      
	Select SchemeID, PayoutID From #TempDisplaySchemeIDs 
	Where PayoutID not in (
	Select PayoutID from #DisplaySchemetmp 
	where TotalCustomersCnt <> CreditNoteCustomers)  Order By ID    

	Open SchemeCur_CloseDay    
	Fetch From SchemeCur_CloseDay Into @SchemeID, @payoutID    
	While @@Fetch_Status = 0    
	Begin  
	
		/*Since DocRef is stored in comma sepearted value we are using the #TmpDocRef table */ 
		Truncate Table #TmpDocRef
		Truncate Table #OverallDocRef
		set @i=1
		set @Count=0

		insert into #OverallDocRef(DocReference)
		Select isnull(DocReference,'') from  tbl_mERP_DispSchBudgetPayout DS where DS.SchemeID = @SchemeID   
		and DS.CRNoteRaised = 1 and DS.PayoutPeriodID = @PayoutID  
		Select @Count = count(*) from  tbl_mERP_DispSchBudgetPayout DS where DS.SchemeID = @SchemeID   
		and DS.CRNoteRaised = 1 and DS.PayoutPeriodID = @PayoutID  


		While @i < = @Count
		BEGIN
			Select @DocRef=DocReference From #OverallDocRef where ID=@i
			Insert into #TmpDocRef(DocReference)
			Select * From dbo.sp_splitin2Rows(@DocRef,',')
			Set @i= @i + 1 
		END

	    update T  set CreditID =CN.CreditID from #TmpDocRef T,CreditNote CN where T.DocReference=CN.DocumentReference
        And isnull(CN.PayoutID,0) = @payoutID
        And isnull(CN.Flag,0)=1
		
		/*Delete the previous Records*/  
		Delete from @CNAdj   

		Set @ActivityCode  = ''  
		Select @ActivityCode = ActivityCode,@DispSchemeDesc = Description from tbl_merp_SchemeAbstract where SchemeID = @SchemeID   

		insert into @CNAdj(CreditID,DocumentReference)  
		Select CreditID,isnull(CN.DocumentReference,'') from tbl_mERP_DispSchBudgetPayout DS,CreditNote CN where   
		DS.SchemeID = @SchemeID     
		and DS.CRNoteRaised = 1 and DS.PayoutPeriodID = @PayoutID    
		And CN.CreditID in (Select rtrim(ltrim(CreditID)) from #TmpDocRef)
		And DS.payoutPeriodID=CN.PayoutID  
		And DS.OutletCode=CN.CustomerID  
		And isnull(CN.Balance,0)=0  
		And isnull(CN.Flag,0)=1  
		
		
		/* Checking for Inventory configuration*/  
		if (Select isnull(Flag,0) from tbl_merp_configdetail where screencode='CLSDAY01' and controlname='InventoryLock') = 1   
		BEGIN 
			Create Table #tmpI(adjref nvarchar(255),invdate datetime,CreditID int)
			
			Declare @t nvarchar(255)
			Declare @dt datetime
			Declare Allinv cursor for select AdjRef,invoicedate from invoiceabstract Where   
			 isnull(status,0)& 192 = 0
			and isnull(adjref,'') <> ''
			and dbo.stripdatefromtime(invoicedate)>=(select payoutperiodfrom from tbl_merp_schemepayoutperiod where Id=@PayoutID)
			open Allinv
			fetch from Allinv into @t,@dt
			while @@fetch_status=0
			begin
				insert into #tmpI(adjref)	
				(Select * From dbo.sp_splitin2Rows(@t,','))
				update #tmpI set invdate=@dt where invdate is null
				fetch next from Allinv into @t,@dt
			end
			close Allinv
			deallocate Allinv
			update #tmpI set adjref= ltrim(rtrim(adjref)) 
			update #tmpI set invdate=dbo.stripdatefromtime(invdate)
			update T Set CreditID = CN.CreditID From #tmpI T,CreditNote CN where CN.DocumentReference=T.adjref and CN.PayoutID in 
			(Select payoutID from #TempDisplaySchemeIDs)
			/*Invoice abstract*/  
			if (Select max(invdate) from #tmpI Where   
			AdjRef in(select documentreference from @CNAdj))> @Lastinventoryupload
			BEGIN
				insert into @TempOutput (ActivityCode,SchDesc,SchemeID,PayoutID)
				Select @ActivityCode,@DispSchemeDesc,@SchemeID,@PayoutID

			END  
		    drop table #tmpI
		END  
		/* Checking for FA configuration*/  
		if (Select isnull(Flag,0) from tbl_merp_configdetail where screencode='CLSDAY01' and controlname='FinancialLock') = 1  
		BEGIN  
			If (
			/*Collections*/  
			Select dbo.stripdatefromtime(max(C.DocumentDate)) from Collections C, CollectionDetail CD Where C.DocumentID=CD.CollectionID  
			And CD.DocumentID in(Select CreditID from @CNAdj)  
			And CD.DocumentType=2 And(IsNull(C.Status, 0) & 128) = 0)> @Lastinventoryupload   /*Credit Note*/  
			BEGIN
				insert into @TempOutput (ActivityCode,SchDesc,SchemeID,PayoutID)
				Select @ActivityCode,@DispSchemeDesc,@SchemeID,@PayoutID
			END  
			/*Manual Journal*/  
			If (
			Select dbo.stripdatefromtime(max(GJ.TransactionDate)) from Generaljournal GJ  
			where GJ.DocumentReference in(Select CreditID from @CNAdj)  
			And GJ.DocumentType=35 and isnull(status,0) <> 128             
			and isnull(status,0) <> 192)> @Lastinventoryupload   
			BEGIN
				insert into @TempOutput (ActivityCode,SchDesc,SchemeID,PayoutID)
				Select @ActivityCode,@DispSchemeDesc,@SchemeID,@PayoutID
			END  
		END  
		Fetch Next From SchemeCur_CloseDay Into @SchemeID, @payoutID    
	End  
	Close SchemeCur_CloseDay  
	Deallocate SchemeCur_CloseDay  
	/* Close Day Validation Ends*/

	Select distinct ActivityCode,SchDesc,SchemeID,PayoutID from @TempOutput
	Drop Table #OverallDocRef
	Drop table #DisplaySchemetmp  
	Drop table #DispSchemeID  
	Drop table #TempSchemeID  
	Drop table #TempDisplaySchemeIDs  
	Drop Table #TmpDocRef

	SET NOCOUNT OFF
End  
