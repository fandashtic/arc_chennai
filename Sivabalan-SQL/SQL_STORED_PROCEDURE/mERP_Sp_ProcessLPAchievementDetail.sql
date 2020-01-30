Create Procedure mERP_Sp_ProcessLPAchievementDetail
As
Begin
Set Dateformat DMY
Declare @KeyValue nVarchar(255)
Declare @Errmessage nVarchar(4000)
Declare @ErrStatus int
Declare @LPID int , @DocID int
Declare @LPCodeMapCnt int, @LPTargetCnt int
Declare @LP_Period nVarchar(10)
Declare @FromDate datetime
Declare @ValidToDate datetime
Declare @TranDate DateTime
Select @TranDate = dbo.StripTimeFromDate(TransactionDate) From Setup

Declare @MaxId as Int

/* Proces the recd LP Achievement detail */
Declare Cur_LPTarget Cursor For
Select RecdId,DocumentID from LP_RecdDocAbstract Where DocType =N'LPACHIEVEMENT' and Status = 0 Order by 1
Open Cur_LPTarget
Fetch Next From Cur_LPTarget into @LPID, @DocID
While @@Fetch_Status = 0
Begin

Select @MaxId = max(Isnull(ID,0)) From LP_AchievementDetail

Set @ErrStatus = 0
Set @Errmessage = N''
Set @LPCodeMapCnt = 0
Set @LPTargetCnt = 0
/* CLOType Enable / Disable Validation Start */
Declare @CLOType as Int
Declare @CLOTypeAbstract as Int
Declare @CLOTypeProduct as Int
Set @CLOType = (Select Isnull(Flag,0) From tbl_merp_configabstract Where ScreenCode = 'CLOType' And ScreenName = 'CLOType')
Set @CLOTypeAbstract = (Select Count(*) From LP_RecdAchievementDetail Where RecdID = @LPID And Isnull(Program_Type,'') <> '')
Set @CLOTypeProduct = (Select Count(*) From LP_RecdCodeMap Where RecdID = @LPID And Isnull(Program_Type,'') <> '')

If @CLOType = 0 And (Isnull(@CLOTypeAbstract,0) <> 0 OR Isnull(@CLOTypeProduct,0) <> 0)
Begin
Set @Errmessage = 'Unable to Process LP. Due to CLOType Disabled. LP RecdID : ' + Cast(@LPID as Nvarchar)
Set @ErrStatus = 1
Goto SkipLP
End
Else
If @CLOType = 1 And (Isnull(@CLOTypeAbstract,0) = 0 OR Isnull(@CLOTypeProduct,0) = 0)
Begin
Set @Errmessage = 'Unable to Process LP. Due to CLOType Enabled. LP RecdID : ' + Cast(@LPID as Nvarchar)
Set @ErrStatus = 1
Goto SkipLP
End
/* CLOType Enable / Disable Validation End */

/* CustomerWise PeriodWise and ProgramType Wise Validation Start */

Declare @N_Period as Nvarchar(255)
Declare @N_CustomerID as Nvarchar(255)
Declare @N_ProgramType as Nvarchar(255)

Declare Cur_LP Cursor for
Select Period,CustomerID,Program_Type From LP_RecdAchievementDetail Where RecdID = @LPID And Isnull(Status,0) = 0
Open Cur_LP
Fetch from Cur_LP into @N_Period,@N_CustomerID,@N_ProgramType
While @@fetch_status =0
Begin
/* Validate recd customer with Customer master */
If Isnull((Select Count(CustomerID) From Customer Where CustomerID = @N_CustomerID),0) = 0
Begin
Set @Errmessage = 'Invalid customer. Period : '+ cast( @N_Period as Nvarchar) + ' CustomerID:' + cast( @N_CustomerID as Nvarchar) + ' Program_Type : ' + cast( @N_ProgramType as Nvarchar)
Set @KeyValue = 'LPACHIEVEMENT | ' + Cast(@LPID as nvarchar(10))
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('LPAchievement', @Errmessage,  @KeyValue, getdate())
Update LP_RecdAchievementDetail Set Status = 2 Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType
GOTo NextCustomer
End

/* Validate CustomerWise Target From & Target To Start */

Declare @TmpCust as table (
ID Int,
CustomerId Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
TargetFrom DateTime,
TargetTo DateTime,Status Int)

Insert Into @TmpCust
Select Distinct max(ID),CustomerId,TargetFrom,TargetTo,0 From LP_RecdAchievementDetail
Where RecdID = @LPID And Isnull(Status,0) = 0 And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType
Group By RecdID,CustomerId,TargetFrom,TargetTo

Update @TmpCust Set Status = 2 Where ID Not In (
Select Distinct ID From LP_RecdAchievementDetail T,
(Select Top 1 Period,TargetFrom,TargetTO From LP_RecdAchievementDetail Where ID in(Select Max(ID) From @TmpCust)) T1
Where T.Period = T1.Period And T.TargetFrom = T1.TargetFrom And T.TargetTO = t1.TargetTO)

Update LP_RecdAchievementDetail Set Status = 2 Where ID Not In (
Select Distinct ID From LP_RecdAchievementDetail T,
(Select Top 1 Period,TargetFrom,TargetTO From LP_RecdAchievementDetail Where ID in(Select Max(ID) From @TmpCust)) T1
Where T.Period = T1.Period And T.TargetFrom = T1.TargetFrom And T.TargetTO = t1.TargetTO)
And RecdID = @LPID And Isnull(Status,0) = 0 And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType

Declare @ID as Int
Declare Cur_Dup Cursor for
Select ID From @TmpCust Where isnull(Status,0) = 2
Open Cur_Dup
Fetch from Cur_Dup into @ID
While @@fetch_status =0
Begin
Set @Errmessage = 'Duplicate Target data Received For the ID : '+ Cast(@ID as nvarchar(10)) +' Period : '+ cast( @N_Period as Nvarchar) +' CustomerID:' + cast( @N_CustomerID as Nvarchar)  + ' Program_Type : ' + cast( @N_ProgramType as Nvarchar)
Set @KeyValue = 'LPACHIEVEMENT | ' + Cast(@LPID as nvarchar(10))
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('LPAchievement', @Errmessage,  @KeyValue, getdate())

Fetch Next from Cur_Dup into @ID
End
Close Cur_Dup
Deallocate Cur_Dup

Delete From @TmpCust

/* Validate CustomerWise Target From & Target To End */


/*Achievement product should exists in Product Scope Info provided*/
If Exists(Select Distinct ProductScope From LP_RecdAchievementDetail Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType
and ProductScope not in (Select Distinct ProductScope From LP_RecdCodeMap Where RecdID = @LPID And Period = @N_Period And Program_Type = @N_ProgramType))
Begin
Set @Errmessage = 'Productscope Not exists. Period : '+ cast( @N_Period as Nvarchar) +' CustomerID:' + cast( @N_CustomerID as Nvarchar)  + ' Program_Type : ' + cast( @N_ProgramType as Nvarchar)
Set @KeyValue = 'LPACHIEVEMENT | ' + Cast(@LPID as nvarchar(10))
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('LPAchievement', @Errmessage,  @KeyValue, getdate())
Update LP_RecdAchievementDetail Set Status = 2 Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType
GOTo NextCustomer
End


/* Target_From_Date < Target_To_Date validation on Achievement Info*/
If Exists(Select Period, CustomerID,Program_Type, SequenceNo, Min(TargetFrom), Min(TargetTo)
From LP_RecdAchievementDetail Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID  And Program_Type = @N_ProgramType
Group By Period, CustomerID,Program_Type, SequenceNo
Having Min(TargetFrom) > Min(TargetTo))
Begin
Set @Errmessage = 'Target_To_Date should greater than Target_From_Date. Period : '+ cast( @N_Period as Nvarchar) +' CustomerID:' + cast( @N_CustomerID as Nvarchar)  + ' Program_Type : ' + cast( @N_ProgramType as Nvarchar)
Set @KeyValue = 'LPACHIEVEMENT | ' + Cast(@LPID as nvarchar(10))
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('LPAchievement', @Errmessage,  @KeyValue, getdate())
Update LP_RecdAchievementDetail Set Status = 2 Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType
GOTo NextCustomer
End

/* Achieved_To_Date validation on Achievement Info*/
If Exists(Select Period, CustomerID,Program_Type, SequenceNo, Min(AchievedTo), Min(TargetTo)
From LP_RecdAchievementDetail Where RecdID = @LPID and IsNull(PrintFlag,0) = 0 And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType
Group By Period, CustomerID,Program_Type, SequenceNo
Having Min(AchievedTo) < Min(TargetFrom) Or Min(AchievedTo) > Min(TargetTo))
Begin
Set @Errmessage = 'Achieved_To_Date should fall between Target_From_Date and Target_To_Date. Period : '+ cast( @N_Period as Nvarchar) +' CustomerID:' + cast( @N_CustomerID as Nvarchar) + ' Program_Type : ' + cast( @N_ProgramType as Nvarchar)
Set @KeyValue = 'LPACHIEVEMENT | ' + Cast(@LPID as nvarchar(10))
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('LPAchievement', @Errmessage,  @KeyValue, getdate())
Update LP_RecdAchievementDetail Set Status = 2 Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType
GOTo NextCustomer
End

/* Grace_Date > Target_To_Date validation on Achievement Info*/
If Exists(Select Period, CustomerID,Program_Type, SequenceNo, Min(AchievedTo), Min(GraceDate)
From LP_RecdAchievementDetail Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType
Group By Period, CustomerID,Program_Type, SequenceNo
Having Min(GraceDate) < Min(TargetTo))
Begin
Set @Errmessage = 'Grace_Date should greater than Target_To_Date. Period : '+ cast( @N_Period as Nvarchar) +' CustomerID:' + cast( @N_CustomerID as Nvarchar)  + ' Program_Type : ' + cast( @N_ProgramType as Nvarchar)
Set @KeyValue = 'LPACHIEVEMENT | ' + Cast(@LPID as nvarchar(10))
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('LPAchievement', @Errmessage,  @KeyValue, getdate())
Update LP_RecdAchievementDetail Set Status = 2 Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType
GOTo NextCustomer
End

/* Transaction Date and  Grace_Date validation on Achievement*/
If (Select dateDiff(Day, @TranDate, (Select Max(GraceDate) From LP_RecdAchievementDetail Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType))) < 0
Begin
Set @Errmessage = 'Transaction Date should be lesser than the Grace_Date. Period : '+ cast( @N_Period as Nvarchar) +' CustomerID:' + cast( @N_CustomerID as Nvarchar)  + ' Program_Type : ' + cast( @N_ProgramType as Nvarchar)
Set @KeyValue = 'LPACHIEVEMENT | ' + Cast(@LPID as nvarchar(10))
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('LPAchievement', @Errmessage,  @KeyValue, getdate())
Update LP_RecdAchievementDetail Set Status = 2 Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType
GOTo NextCustomer
End

/* Print and Label validation on Achievement*/
--If Exists(Select [Print],LABEL  From LP_RecdAchievementDetail Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType And isnull(LABEL,'') ='')
--Begin
--	Set @Errmessage = 'LABEL should not be blank . Period : '+ cast( @N_Period as Nvarchar) +' CustomerID:' + cast( @N_CustomerID as Nvarchar)  + ' Program_Type : ' + cast( @N_ProgramType as Nvarchar)
--	Set @KeyValue = 'LPACHIEVEMENT | ' + Cast(@LPID as nvarchar(10))
--	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
--	Values('LPAchievement', @Errmessage,  @KeyValue, getdate())
--	Update LP_RecdAchievementDetail Set Status = 2 Where RecdID = @LPID And Period = @N_Period And CustomerID = @N_CustomerID And Program_Type = @N_ProgramType
--	GOTo NextCustomer
--End

NextCustomer:
Fetch Next from Cur_LP into @N_Period,@N_CustomerID,@N_ProgramType
End
Close Cur_LP
Deallocate Cur_LP

/* CustomerWise PeriodWise and ProgramType Wise Validation End */

/* validate Duplicate Customer received in same XML Start :*/
Declare @DupCust as table (ID Int,Period Nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Program_Type Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Status Int)
insert Into @DupCust
Select Distinct max(ID),Period,CustomerId,Program_Type,0 From LP_RecdAchievementDetail
Where RecdID = @LPID
And Isnull(Status,0) = 0
Group By RecdID,Period,CustomerId,Program_Type

Update @DupCust Set Status = 2 Where Id Not In (Select max(ID) From @DupCust Group By CustomerId)

Declare @DupID as Int
Declare @DupPeriod as Nvarchar(25)
Declare @DupCustomerId as Nvarchar(255)
Declare @DupProgram_Type as Nvarchar(255)

Declare Cur_DupCust Cursor for
Select R.ID,R.Period,R.CustomerId,R.Program_Type From LP_RecdAchievementDetail R,@DupCust D
Where R.Period = D.Period
And R.CustomerId = D.CustomerId
And R.Program_Type = D.Program_Type
And Isnull(D.Status,0) = 2
And Isnull(R.Status,0) = 0
Open Cur_DupCust
Fetch from Cur_DupCust into @DupID,@DupPeriod,@DupCustomerId,@DupProgram_Type
While @@fetch_status =0
Begin
Update LP_RecdAchievementDetail Set Status = 2 Where RecdID = @LPID And Period = @DupPeriod And CustomerID = @DupCustomerId And Program_Type = @DupProgram_Type
Set @Errmessage = 'Duplicate Customer Received For the ID : '+ Cast(@LPID as nvarchar(10)) +' Period : '+ cast( @DupPeriod as Nvarchar) +' CustomerID:' + cast( @DupCustomerId as Nvarchar)  + ' Program_Type : ' + cast( @DupProgram_Type as Nvarchar)
Set @KeyValue = 'LPACHIEVEMENT | ' + Cast(@LPID as nvarchar(10))
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('LPAchievement', @Errmessage,  @KeyValue, getdate())
Fetch Next from Cur_DupCust into @DupID,@DupPeriod,@DupCustomerId,@DupProgram_Type
End
Close Cur_DupCust
Deallocate Cur_DupCust

Delete From @DupCust
/* validate Duplicate Customer received in same XML End. */

/* Check for Valid Entry in RecdLPAchievement and Skip if 0 entry exists */
If IsNull((Select Count(*) From LP_RecdAchievementDetail Where RecdID = @LPID and Status = 0),0) = 0
Begin
Set @Errmessage = 'No valid customer found in LP Achievement LP RecdID : ' + Cast(@LPID as Nvarchar)
Set @ErrStatus = 1
Goto SkipLP
End

/* CR1 - UAT Observation, Whan AchievedTo Date is Null, Update it as TargetFromDate-1 and Set the PrintFlag as 1 */
/*
If Exists(Select Period, CustomerID From LP_RecdAchievementDetail Where RecdID = @LPID And Isnull(Status,0) = 0 and AchievedTo Is Null and CustomerID = @N_CustomerID and program_type=CustomerID = @N_CustomerIDGroup By Period, CustomerID)
Begin
*/
Update LP_RecdAchievementDetail Set AchievedTo = DateAdd(Day,-1,TargetFrom), PrintFlag = 1 Where AchievedTo Is Null and RecdID = @LPID
/*
End
*/
Declare @TmpLPData as Table (Period Nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,ProgramType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert Into @TmpLPData Select Distinct Period,Program_Type
From LP_RecdCodeMap Where RecdID = @LPID

Declare @Period as Nvarchar(10)
Declare @ProgramType as Nvarchar(255)

Declare Cur Cursor for
Select Period,ProgramType From @TmpLPData
Open Cur
Fetch from Cur into @Period,@ProgramType
While @@fetch_status =0
Begin
/* Remove existing data for the same period from LPCodeMap */
If IsNull((Select Count(*) From LP_ItemCodeMap Where Period = @Period And Program_Type = @ProgramType), 0 ) <> 0
Begin
Delete From LP_ItemCodeMap Where Period = @Period  And Program_Type = @ProgramType
End

Fetch Next from Cur into @Period,@ProgramType
End
Close Cur
Deallocate Cur

Delete From @TmpLPData

Declare @TmpLPAch as Table (Period Nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,ProgramType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert Into @TmpLPAch Select Distinct Period,CustomerID,Program_Type
From LP_RecdAchievementDetail Where RecdID = @LPID And Isnull(Status,0) = 0

Declare @A_Period as Nvarchar(10)
Declare @A_CustomerID as Nvarchar(255)
Declare @A_ProgramType as Nvarchar(255)

Declare CurAch Cursor for
Select Period,CustomerID,ProgramType From @TmpLPAch
Open CurAch
Fetch from CurAch into @A_Period,@A_CustomerID,@A_ProgramType
While @@fetch_status =0
Begin
/* Remove existing data for the same period from LPAchievement */
If IsNull((Select Count(*) From LP_AchievementDetail Where Period = @A_Period And CustomerID = @A_CustomerID And Program_Type = @A_ProgramType), 0 ) <> 0
Begin
Delete From LP_AchievementDetail Where Period = @A_Period And CustomerID = @A_CustomerID And Program_Type = @A_ProgramType
End

Fetch Next from CurAch into @A_Period,@A_CustomerID,@A_ProgramType
End
Close CurAch
Deallocate CurAch

Delete From @TmpLPAch

/* Move the data into main table */
Insert into LP_ItemCodeMap (Period, ProductScope, ProductCode, ProductLevel,Program_Type)
Select Period, ProductScope, ProductCode, ProductLevel,Program_Type From LP_RecdCodeMap Where RecdID = @LPID
Select @LPCodeMapCnt = @@RowCount

/* As Per ITC Request Existing data De-Actiovation is consider only Period and Program_Type. It is not validate CustomerWise : 20/12/2013 */
--	Update LP_AchievementDetail Set Active = 0 Where CustomerId in (Select Distinct CustomerId From LP_RecdAchievementDetail Where RecdID = @LPID and Status = 0)

Update T Set T.Active = 0 From LP_AchievementDetail T,
(Select Distinct Period,Program_Type From LP_RecdAchievementDetail Where RecdID = @LPID and Status = 0) T1
Where T.Period = T1.Period
And T.Program_Type = T1.Program_Type

Insert into LP_AchievementDetail (Period, TargetFrom, TargetTo, AchievedTo, CustomerID, SequenceNo, ProductScope, TargetVal, AchievedVal, GraceDate, PrintFlag,Program_Type,[PRINT],LABEL)
Select Period, TargetFrom, TargetTo, AchievedTo, CustomerID, SequenceNo, ProductScope, TargetVal, AchievedVal, GraceDate, PrintFlag ,Program_Type,[PRINT],LABEL
From LP_RecdAchievementDetail Where RecdID = @LPID and Status = 0 Order by 1
Select @LPTargetCnt = @@RowCount

If ((Select @LPCodeMapCnt) <> 0) and ((Select @LPTargetCnt) <> 0 )
Begin
Update LP_RecdAchievementDetail Set Status = 1 Where RecdID = @LPID  and Status = 0
Update LP_RecdDocAbstract Set Status = 1 Where RecdID = @LPID
End

/* LP Log Insert Process Start: */
Declare @Closedate as datetime
Declare @TargetToDate as datetime
Declare @LPDate as dateTime
Select top 1 @Closedate = lastinventoryupload from setup

Declare @L_Period as Nvarchar(10)
Declare @L_CustomerID as Nvarchar(255)
Declare @L_ProgramType as Nvarchar(255)

Declare @LPLog as Table (Period Nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Program_Type Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,AchievedTo DateTime,FromDate DateTime,Todate DateTime,TargetFrom DateTime,TargetTo DateTime)
Insert Into @LPLog (Period,CustomerID,Program_Type,AchievedTo,FromDate,ToDate,TargetFrom,TargetTo)
select Distinct Period,CustomerID,Program_Type,AchievedTo,TargetFrom,TargetTo,
Cast((Convert(Nvarchar(10),DateAdd(d,+1,AchievedTo),103)) as DateTime)
,Convert(Nvarchar(10),(Case When @Closedate > TargetTo Then TargetTo Else @Closedate End),103)
From LP_AchievementDetail Where ID > Isnull(@MaxId,0) and Isnull(Active,0) = 1

Declare CurLPlog Cursor for
Select Period,CustomerID,Program_Type From @LPLog
Open CurLPlog
Fetch from CurLPlog into @L_Period,@L_CustomerID,@L_ProgramType
While @@fetch_status =0
Begin
Delete From LPLog Where Period = @L_Period And CustomerID = @L_CustomerID And Program_Type = @L_ProgramType
Fetch Next from CurLPlog into @L_Period,@L_CustomerID,@L_ProgramType
End
Close CurLPlog
Deallocate CurLPlog

Update LPLog set Active = 0 Where CustomerID in (select Distinct CustomerID From @LPLog) And isnull(Active,0) = 1

Insert Into LPLog (Period,FromDate,ToDate,Active,CustomerID,Program_Type)
Select Distinct Period,TargetFrom,TargetTo,1,CustomerID,Program_Type From @LPLog

Delete From @LPLog

/* LP Log Insert Process End. */

SkipLP:
If (@ErrStatus = 1)
Begin
Set @KeyValue = 'LPACHIEVEMENT | ' + Cast(@LPID as nvarchar(10))
Update LP_RecdDocAbstract Set Status = 2 Where RecdID = @LPID
Update LP_RecdAchievementDetail Set Status = 2 Where RecdID = @LPID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('LPAchievement', @Errmessage,  @KeyValue, getdate())
End

Fetch Next From Cur_LPTarget into @LPID, @DocID
End
Close Cur_LPTarget
Deallocate Cur_LPTarget
End
