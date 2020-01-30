Create Procedure mERP_Sp_ProcessLPScoreDetail
As
Begin
  Set Dateformat DMY  
  Declare @KeyValue nVarchar(255)  
  Declare @Errmessage nVarchar(4000)  
  Declare @ErrStatus int  
  Declare @LPID int, @DocID int  
  Declare @LP_Period nVarchar(10)  
  Declare @LPDate as datetime    
  Declare @FromDate datetime  
  Declare @ValidToDate datetime   
  Declare @TranDate DateTime   
  Select @TranDate = dbo.StriptimeFromDate(TransactionDate) From Setup  
  Declare Cur_LPScore Cursor For  
  Select RecdId,DocumentID from LP_RecdDocAbstract Where DocType =N'LPSCORE' and Status = 0 Order by 1  
  Open Cur_LPScore  
  Fetch Next From Cur_LPScore into @LPID, @DocID  
  While @@Fetch_Status = 0  
  Begin  
    /* Proces the recd LP Score detail */  
    Set @ErrStatus = 0  
    Set @Errmessage = N'' 
	/* CLOType Enable / Disable Validation Start */
	Declare @CLOType as Int
	Declare @CLOTypeScore as Int
	Set @CLOType = (Select Isnull(Flag,0) From tbl_merp_configabstract Where ScreenCode = 'CLOType' And ScreenName = 'CLOType')
	Set @CLOTypeScore = (Select Count(*) From LP_RecdScoreDetail Where RecdID = @LPID And Isnull(Program_Type,'') <> '')
	
	If @CLOType = 0 And Isnull(@CLOTypeScore,0) <> 0
	Begin
        Set @Errmessage = 'Unable to Process LP. Due to CLOType Disabled. LP RecdID : ' + Cast(@LPID as Nvarchar)  
        Set @ErrStatus = 1  
        Goto SkipLP  
	End
	Else
	If @CLOType = 1 And Isnull(@CLOTypeScore,0) = 0
	Begin
        Set @Errmessage = 'Unable to Process LP. Due to CLOType Enabled. LP RecdID : ' + Cast(@LPID as Nvarchar)  
        Set @ErrStatus = 1  
        Goto SkipLP  
	End
	/* CLOType Enable / Disable Validation End */ 

/* validate Duplicate Customer received in same XML Start :*/
	Declare @DupCust as table (ID Int,Period Nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Program_Type Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Status Int)
	insert Into @DupCust
	Select Distinct max(ID),Period,CustomerId,Program_Type,0 From LP_RecdScoreDetail 
	Where RecdID = @LPID 
	And Isnull(Status,0) = 0 
	Group By RecdID,Period,CustomerId,Program_Type

	Update @DupCust Set Status = 2 Where Id Not In (Select max(ID) From @DupCust Group By CustomerId)

	Declare @DupID as Int
	Declare @DupPeriod as Nvarchar(25)
	Declare @DupCustomerId as Nvarchar(255)
	Declare @DupProgram_Type as Nvarchar(255)

	Declare Cur_DupCust Cursor for
	Select R.ID,R.Period,R.CustomerId,R.Program_Type From LP_RecdScoreDetail R,@DupCust D 
	Where R.Period = D.Period
	And R.CustomerId = D.CustomerId
	And R.Program_Type = D.Program_Type
	And Isnull(D.Status,0) = 2
	And Isnull(R.Status,0) = 0
	Open Cur_DupCust
	Fetch from Cur_DupCust into @DupID,@DupPeriod,@DupCustomerId,@DupProgram_Type
	While @@fetch_status =0
		Begin
			Update LP_RecdScoreDetail Set Status = 2 Where RecdID = @LPID And Period = @DupPeriod And CustomerID = @DupCustomerId And Program_Type = @DupProgram_Type   
			Set @Errmessage = 'LP Score:- ' + 'Duplicate Customer Received For the ID : '+ Cast(@LPID as nvarchar(10)) +' Period : '+ cast( @DupPeriod as Nvarchar) +' CustomerID:' + cast( @DupCustomerId as Nvarchar)  + ' Program_Type : ' + cast( @DupProgram_Type as Nvarchar)
			Set @KeyValue = 'LPSCORE | ' + Cast(@LPID as nvarchar(10))  
			Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
			Values('LPScore', @Errmessage,  @KeyValue, getdate())
			Fetch Next from Cur_DupCust into @DupID,@DupPeriod,@DupCustomerId,@DupProgram_Type
		End
	Close Cur_DupCust
	Deallocate Cur_DupCust

	Delete From @DupCust
/* validate Duplicate Customer received in same XML End. */

	/* CustomerWise PeriodWise and ProgramType Wise Validation Start */

	Declare @N_Period as Nvarchar(255)
	Declare @N_CustomerID as Nvarchar(255)
	Declare @N_ProgramType as Nvarchar(255)

	Declare Cur_LP Cursor for
	Select Distinct Period,CustomerID,Program_Type From LP_RecdScoreDetail Where RecdID = @LPID And Isnull(Status,0) = 0 
	Open Cur_LP
	Fetch from Cur_LP into @N_Period,@N_CustomerID,@N_ProgramType
	While @@fetch_status =0
		Begin

			/* Validate recd customer with Customer master */
			If Isnull((Select Count(CustomerID) From Customer Where CustomerID = @N_CustomerID),0) = 0
			Begin
				Set @Errmessage = 'LP Score:- ' +  'Invalid customer. Period : '+ cast( @N_Period as Nvarchar) + ' CustomerID:' + cast( @N_CustomerID as Nvarchar) + ' Program_Type : ' + cast( @N_ProgramType as Nvarchar)
				Set @KeyValue = 'LPSCORE | ' + Cast(@LPID as nvarchar(10))  
				Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
				Values('LPScore', @Errmessage,  @KeyValue, getdate())
				Update LP_RecdScoreDetail Set Status = 2 Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType  
				GOTo NextCustomer
			End

			/* Trandate should not be Greater than GraceDate */
			If IsNull((Select Count(Distinct Period) From LP_RecdScoreDetail Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType and dbo.StripTimeFromDate(GraceDate) < @TranDate),0) > 0   
			Begin  
			   -- Update the error log   
				Set @Errmessage = 'LP Score:- ' +  'Transaction Date should be lesser than the Grace_Date. Period : '+ cast( @N_Period as Nvarchar) + ' CustomerID:' + cast( @N_CustomerID as Nvarchar) + ' Program_Type : ' + cast( @N_ProgramType as Nvarchar)
				Set @KeyValue = 'LPSCORE | ' + Cast(@LPID as nvarchar(10))  
				Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
				Values('LPScore', @Errmessage,  @KeyValue, getdate())
				Update LP_RecdScoreDetail Set Status = 2 Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType  
				GOTo NextCustomer
			End

			/* Remove the existing data for the same period from LPScore */  
			If IsNull((Select Count(*) From LP_ScoreDetail Where Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType), 0 ) <> 0
			Begin
				Delete From LP_ScoreDetail Where Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType  
			End

	NextCustomer:
			Fetch Next from Cur_LP into @N_Period,@N_CustomerID,@N_ProgramType
		End
	Close Cur_LP
	Deallocate Cur_LP

	/* CustomerWise PeriodWise and ProgramType Wise Validation End */

	/* Check for Valid Entry in RecdLPScore and Skip if 0 entries exists */
	If IsNull((Select Count(*) From LP_RecdScoreDetail Where RecdID = @LPID and Status = 0),0) = 0
	Begin
		Set @Errmessage = 'LP Score:- ' +  'No valid customer found in LP Score. RecdID: ' + cast( @LPID as Nvarchar)
		Set @ErrStatus = 1
		Goto SkipLP
	End


    /* Set the active status as 0 for rest of the data exists*/
	If (select Count(*) From LP_ScoreDetail Where Active = 1) > 0
--	  Update LP_ScoreDetail Set Active = 0 Where Active = 1 And CustomerID in (Select Distinct CustomerID From LP_RecdScoreDetail Where RecdID = @LPID And Status = 0)

    /* As Per ITC Request Existing data De-Actiovation is consider only Period and Program_Type. It is not validate CustomerWise : 20/12/2013 */
	Update T Set T.Active = 0 From LP_ScoreDetail T,
	(Select Distinct Period,Program_Type From LP_RecdScoreDetail Where RecdID = @LPID and Status = 0) T1
	Where T.Period = T1.Period
	And T.Program_Type = T1.Program_Type

    Declare @Count as Int  
    /* Move the data into main table */  
    Insert into LP_ScoreDetail (Period, CustomerID,  MembershipNo, Tier, SequenceNo, [Type], Particular, Description, PointsEarned, GraceDate,Program_Type)  
    Select Period, CustomerID,  MembershipNo, Tier, SequenceNo, [Type], Particular, Description, PointsEarned, GraceDate,Program_Type
    From LP_RecdScoreDetail Where RecdID = @LPID And Status = 0
    Select @Count = @@RowCount
 
    If IsNull(@Count,0) <> 0   
    Begin  
      Update LP_RecdScoreDetail Set Status = 1 Where RecdID = @LPID And Status = 0
      Update LP_RecdDocAbstract Set Status = 1 Where RecdID = @LPID
    End  

SkipLP:  
    If (@ErrStatus = 1)  
		Begin  
			Set @Errmessage = 'LP Score:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage)  
			Set @KeyValue = 'LPSCORE | ' + Cast(@LPID as nvarchar(10))   
			Update LP_RecdDocAbstract Set Status = 2 Where RecdID = @LPID  
			Update LP_RecdScoreDetail Set Status = 2 Where RecdID = @LPID  
			Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
			Values('LPScore', @Errmessage,  @KeyValue, getdate())    
		End  
    Fetch Next From Cur_LPScore into @LPID, @DocID  
  End  
  Close Cur_LPScore  
  Deallocate Cur_LPScore  
End
