Create Procedure mERP_Sp_SaveReceivedLocks (@ScreenName nvarchar(100),@EnableMargin int) 
As
Begin

Declare @Recdidentity int
Declare @MarginNotUpdated int

Insert into tbl_mERP_RecConfigAbstract(Menuname,flag, Status) 
Values (@ScreenName,@EnableMargin, 0)
Select @RecdIdentity = @@Identity

IF (IsNull(@ScreenName, '') = N'MARGINSCRN')
Begin
	If (IsNull(@EnableMargin,0) < 0) Or (IsNull(@EnableMargin,0) > 1)   
	Begin        
		Insert Into tbl_mERP_RecdErrMessages (TransactionType, ErrMessage, KeyValue, ProcessDate)  
		Values('MARGINSCRN', 'Purchase Margin cannot be negative or Greater than One', Null, GetDate())  
		Update tbl_mERP_RecConfigAbstract Set Status = Status | 64 where ID = @RecdIdentity
	End

	If (IsNull(@EnableMargin,0) = 0) Or (IsNull(@EnableMargin,0) = 1)   
	Begin
		Update tbl_mERP_ConfigAbstract set Flag=@EnableMargin  where ScreenCode=N'MAR01' and ScreenName=N'MARGINSCRN'  
		Update tbl_mERP_RecConfigAbstract Set Status = Status | 32 where ID = @RecdIdentity
	End
End

IF (IsNull(@ScreenName, '') = N'DispSchOLClsWiseBudget')
Begin
	If (IsNull(@EnableMargin,0) < 0) Or (IsNull(@EnableMargin,0) > 1)   
	Begin        
		Insert Into tbl_mERP_RecdErrMessages (TransactionType, ErrMessage, KeyValue, ProcessDate)  
		Values('DispSchOLClsWiseBudget', 'PDispSchOLClsWiseBudget cannot be negative or Greater than One', Null, GetDate())  
		Update tbl_mERP_RecConfigAbstract Set Status = Status | 64 where ID = @RecdIdentity
	End

	If (IsNull(@EnableMargin,0) = 0) Or (IsNull(@EnableMargin,0) = 1)   
	Begin
		Update tbl_mERP_ConfigAbstract set Flag=@EnableMargin  where ScreenCode=N'DISP_SCH_OLCLS_BUDGET' and ScreenName=N'DispSchOLClsWiseBudget'  
		Update tbl_mERP_RecConfigAbstract Set Status = Status | 32 where ID = @RecdIdentity
	End
End

IF (IsNull(@ScreenName, '') = N'EnableAEOLClassMap')
Begin
	If (IsNull(@EnableMargin,0) < 0) Or (IsNull(@EnableMargin,0) > 1)   
	Begin        
		Insert Into tbl_mERP_RecdErrMessages (TransactionType, ErrMessage, KeyValue, ProcessDate)  
		Values('EnableAEOLClassMap', 'EnableAEOLClassMap cannot be negative or Greater than One', Null, GetDate())  
		Update tbl_mERP_RecConfigAbstract Set Status = Status | 64 where ID = @RecdIdentity
	End

	If (IsNull(@EnableMargin,0) = 0) Or (IsNull(@EnableMargin,0) = 1)   
	Begin
		Update tbl_mERP_ConfigAbstract set Flag=@EnableMargin  where ScreenCode=N'ENABLEAEOLCLSMAP' and ScreenName=N'EnableAEOLClassMap'  
		Update tbl_mERP_RecConfigAbstract Set Status = Status | 32 where ID = @RecdIdentity
	End
End

IF (IsNull(@ScreenName, '') = N'CUST_CAT_HAND_IMPLOCK')
Begin
	If (IsNull(@EnableMargin,0) < 0) Or (IsNull(@EnableMargin,0) > 1)
	Begin
		Insert Into tbl_mERP_RecdErrMessages (TransactionType, ErrMessage, KeyValue, ProcessDate)
		Values('CUST_CAT_HAND_IMPLOCK', 'Customer CatHandler Import cannot be negative or Greater than One', Null, GetDate())
		Update tbl_mERP_RecConfigAbstract Set Status = Status | 64 where ID = @RecdIdentity
	End
	If (IsNull(@EnableMargin,0) = 0) Or (IsNull(@EnableMargin,0) = 1)   
	Begin
		Update tbl_mERP_ConfigAbstract set Flag=@EnableMargin  where ScreenCode=N'IMPCH01' and ScreenName=N'Import Category Handler'  
		Update tbl_mERP_RecConfigAbstract Set Status = Status | 32 where ID = @RecdIdentity
	End
End
IF (IsNull(@ScreenName, '') = N'OLCLASSEnabled')
Begin
	If (IsNull(@EnableMargin,0) < 0) Or (IsNull(@EnableMargin,0) > 1)
	Begin
		Insert Into tbl_mERP_RecdErrMessages (TransactionType, ErrMessage, KeyValue, ProcessDate)
		Values('OLCLASSEnabled', 'OLCLASS Enable cannot be negative or Greater than One', Null, GetDate())
		Update tbl_mERP_RecConfigAbstract Set Status = Status | 64 where ID = @RecdIdentity
	End
	If (IsNull(@EnableMargin,0) = 0) Or (IsNull(@EnableMargin,0) = 1)   
	Begin
		Update tbl_mERP_ConfigAbstract set Flag=@EnableMargin  where ScreenCode=N'OLCLASS' and ScreenName=N'OLCLASSEnabled'  
		Update tbl_mERP_RecConfigAbstract Set Status = Status | 32 where ID = @RecdIdentity
	End
End
End

