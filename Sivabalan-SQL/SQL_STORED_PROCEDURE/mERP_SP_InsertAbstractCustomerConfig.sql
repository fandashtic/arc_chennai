Create Procedure mERP_SP_InsertAbstractCustomerConfig (@ID int, @Flag int)
As
	Declare @ErrorMessage as Nvarchar(500)
	--Declare @SMSConfig int

-- OCG Config Update Process: JIRAID: FITC-4355 Start*********************************************************************************************************************
	IF Exists(select 'X' from  tbl_mERP_RecConfigAbstract where ID = @ID and MenuName = N'OperationalCategoryGroup' And Isnull(Status,0) = 0)
	Begin		


		IF Not Exists(select 'X' from tbl_merp_Configabstract where screenCode = 'OCGDS')
		Begin
			Set @ErrorMessage = 'OCG Configuration Not Found IN MERP.'
			Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID
			Exec mERP_sp_Update_OCGErrorStatus @ID,@ErrorMessage
			GOTO OUT
		End
		
		If Exists (select Top 1 'X' From tbl_mERP_RecConfigAbstract Where ID = @ID and Isnull(Status,0) = 0 And FLAG = Null And MenuName = N'OperationalCategoryGroup')
		Begin
			Set @ErrorMessage = 'Blank OCGFLAG Not Alowed To Process ID : [' + Cast(@ID as Nvarchar(10)) + ']'
			Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'OperationalCategoryGroup'
			Exec mERP_sp_Update_OCGErrorStatus @ID,@ErrorMessage
			GOTO OUT
		End

		If @Flag Not In (0,1)
		Begin
			Set @ErrorMessage = 'Invalid OCGFLAG Value Received ID : [' + Cast(@ID as Nvarchar(10)) + ']'
			Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'OperationalCategoryGroup'
			Exec mERP_sp_Update_OCGErrorStatus @ID,@ErrorMessage
			GOTO OUT
		End

		If (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS') = 1 And (@Flag = 0)
		Begin
			Set @ErrorMessage = 'OCGFLAG already enabled cannot be disabled. ID : [' + Cast(@ID as Nvarchar(10)) + ']'
			Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'OperationalCategoryGroup'
			Exec mERP_sp_Update_OCGErrorStatus @ID,@ErrorMessage
			GOTO OUT
		End
		Else If (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS') = 0 And @Flag = 1
		Begin
			Update tbl_merp_Configabstract Set Flag = 1 where screenCode = 'OCGDS' And Isnull(Flag,0) = 0 
			Exec sp_ChangeDefaultParameterforOCG
			Update tbl_mERP_RecConfigAbstract set Status = 32 Where ID = @ID And MenuName = N'OperationalCategoryGroup'
			GOTO OUT
		End
		Else If (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS') = 1 And @Flag = 1
		Begin
			Update tbl_mERP_RecConfigAbstract set Status = 32 Where ID = @ID And MenuName = N'OperationalCategoryGroup'
			GOTO OUT
		End
		Else If (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS') = 0 And @Flag = 0
		Begin
			Update tbl_mERP_RecConfigAbstract set Status = 32 Where ID = @ID And MenuName = N'OperationalCategoryGroup'
			GOTO OUT
		End
		GOTO OUT
	End
	-- OCG Config Update Process: JIRAID: FITC-4355 End**********************************************************************************************************************
	-- LEAN Update Process*********************************************************************************************************************
	Else IF Exists(select 'X' from  tbl_mERP_RecConfigAbstract where ID = @ID and MenuName = N'LEAN_INVT' And Isnull(Status,0) = 0)
		Begin		

			IF Not Exists(select 'X' from tbl_merp_Configabstract where screenCode = 'LEAN_INVT')
			Begin
				Set @ErrorMessage = 'LEAN_INVT Not Found IN MERP.'
				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID
				Exec mERP_sp_Update_LeanErrorStatus @ID,@ErrorMessage
				GOTO OUT
			End
			
			If Exists (select Top 1 'X' From tbl_mERP_RecConfigAbstract Where ID = @ID and Isnull(Status,0) = 0 And FLAG = Null And MenuName = N'LEAN_INVT')
			Begin
				Set @ErrorMessage = 'Blank LEAN_INVT Not Allowed To Process ID : [' + Cast(@ID as Nvarchar(10)) + ']'
				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'LEAN_INVT'
				Exec mERP_sp_Update_LeanErrorStatus @ID,@ErrorMessage
				GOTO OUT
			End

			If @Flag Not In (0,1)
			Begin
				Set @ErrorMessage = 'Invalid LEAN_INVT Value Received ID : [' + Cast(@ID as Nvarchar(10)) + ']'
				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'LEAN_INVT'
				Exec mERP_sp_Update_LeanErrorStatus @ID,@ErrorMessage
				GOTO OUT
			End

			Update tbl_merp_Configabstract Set Flag = @Flag where screenCode = 'LEAN_INVT' 
			Update tbl_mERP_RecConfigAbstract set Status = 32 Where ID = @ID And MenuName = N'LEAN_INVT'
			GOTO OUT
		End
	-- LEAN Config Update Process: End**********************************************************************************************************************
	-- SMS Alert Process*********************************************************************************************************************
	Else IF Exists(select 'X' from  tbl_mERP_RecConfigAbstract where ID = @ID and MenuName = N'SMSALERT' And Isnull(Status,0) = 0)
		Begin		

			IF Not Exists(select 'X' from tbl_merp_Configabstract where screenCode = 'SMSALERT')
			Begin
				Set @ErrorMessage = 'SMSALERT Not Found IN MERP.'
				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID
				Exec mERP_sp_Update_SMSAlertErrorStatus @ID,@ErrorMessage
				GOTO OUT
			End
			
			If Exists (select Top 1 'X' From tbl_mERP_RecConfigAbstract Where ID = @ID and Isnull(Status,0) = 0 And FLAG = Null And MenuName = N'SMSALERT')
			Begin
				Set @ErrorMessage = 'Blank SMSALERT Not Allowed To Process ID : [' + Cast(@ID as Nvarchar(10)) + ']'
				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'SMSALERT'
				Exec mERP_sp_Update_SMSAlertErrorStatus @ID,@ErrorMessage
				GOTO OUT
			End

			If @Flag Not In (0,1)
			Begin
				Set @ErrorMessage = 'Invalid SMSALERT Value Received ID : [' + Cast(@ID as Nvarchar(10)) + ']'
				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'SMSALERT'
				Exec mERP_sp_Update_SMSAlertErrorStatus @ID,@ErrorMessage
				GOTO OUT
			End
			--As per Project team, below validation is not required
--			Select @SMSConfig= Flag from tbl_merp_Configabstract where screenCode = 'SMSALERT' 
--			If @Flag =0 And @SMSConfig=1
--			BEGIN
--				Set @ErrorMessage = 'Active SMSALERT can not be deactivated. Received ID : [' + Cast(@ID as Nvarchar(10)) + ']'
--				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'SMSALERT'
--				Exec mERP_sp_Update_SMSAlertErrorStatus @ID,@ErrorMessage
--				GOTO OUT
--			END
--			If @Flag =1 And @SMSConfig=1
--			BEGIN
--				Set @ErrorMessage = 'SMSALERT is already active. Received ID : [' + Cast(@ID as Nvarchar(10)) + ']'
--				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'SMSALERT'
--				Exec mERP_sp_Update_SMSAlertErrorStatus @ID,@ErrorMessage
--				GOTO OUT
--			END
			
			Update tbl_merp_Configabstract Set Flag = @Flag where screenCode = 'SMSALERT' 
			Update tbl_mERP_RecConfigAbstract set Status = 32 Where ID = @ID And MenuName = N'SMSALERT'
			GOTO OUT
		End
	-- SMS Alert Update Process: End**********************************************************************************************************************
	-- DFRFLAG Update Process*********************************************************************************************************************
	Else IF Exists(select 'X' from  tbl_mERP_RecConfigAbstract where ID = @ID and MenuName = N'DFRFLAG' And Isnull(Status,0) = 0)
		Begin		

			IF Not Exists(select 'X' from tbl_merp_Configabstract where screenCode = 'DFRFLAG')
			Begin
				Set @ErrorMessage = 'DFRFLAG Not Found IN MERP.'
				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID
				Exec mERP_sp_Update_LeanErrorStatus @ID,@ErrorMessage
				GOTO OUT
			End
			
			If Exists (select Top 1 'X' From tbl_mERP_RecConfigAbstract Where ID = @ID and Isnull(Status,0) = 0 And FLAG = Null And MenuName = N'DFRFLAG')
			Begin
				Set @ErrorMessage = 'Blank DFRFLAG Not Allowed To Process ID : [' + Cast(@ID as Nvarchar(10)) + ']'
				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'DFRFLAG'
				Exec mERP_sp_Update_LeanErrorStatus @ID,@ErrorMessage
				GOTO OUT
			End

			If @Flag Not In (0,1)
			Begin
				Set @ErrorMessage = 'Invalid DFRFLAG Value Received ID : [' + Cast(@ID as Nvarchar(10)) + ']'
				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'DFRFLAG'
				Exec mERP_sp_Update_LeanErrorStatus @ID,@ErrorMessage
				GOTO OUT
			End
			
			Update tbl_merp_Configabstract Set Flag = @Flag where screenCode = 'DFRFLAG' 
			Update tbl_mERP_RecConfigAbstract set Status = 32 Where ID = @ID And MenuName = N'DFRFLAG'
			if @Flag = 0
			begin
			  Update ReportData set Inactive =1  where ID = 1421
			end
			else
			begin
			  Update ReportData set Inactive =0  where ID = 1421
			end
			GOTO OUT
		End
	-- DFRFLAG Update Process: End**********************************************************************************************************************
	-- WLVFLAG Update Process*********************************************************************************************************************
	Else IF Exists(select 'X' from  tbl_mERP_RecConfigAbstract where ID = @ID and MenuName = N'WLVFLAG' And Isnull(Status,0) = 0)
		Begin		

			IF Not Exists(select 'X' from tbl_merp_Configabstract where screenCode = 'WLVFLAG')
			Begin
				Set @ErrorMessage = 'WLVFLAG Not Found IN MERP.'
				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID
				Exec mERP_sp_Update_LeanErrorStatus @ID,@ErrorMessage
				GOTO OUT
			End
			
			If Exists (select Top 1 'X' From tbl_mERP_RecConfigAbstract Where ID = @ID and Isnull(Status,0) = 0 And FLAG = Null And MenuName = N'WLVFLAG')
			Begin
				Set @ErrorMessage = 'Blank WLVFLAG Not Allowed To Process ID : [' + Cast(@ID as Nvarchar(10)) + ']'
				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'WLVFLAG'
				Exec mERP_sp_Update_LeanErrorStatus @ID,@ErrorMessage
				GOTO OUT
			End

			If @Flag Not In (0,1)
			Begin
				Set @ErrorMessage = 'Invalid WLVFLAG Value Received ID : [' + Cast(@ID as Nvarchar(10)) + ']'
				Update tbl_mERP_RecConfigAbstract set Status = 64 Where ID = @ID And MenuName = N'WLVFLAG'
				Exec mERP_sp_Update_LeanErrorStatus @ID,@ErrorMessage
				GOTO OUT
			End

			Update tbl_merp_Configabstract Set Flag = @Flag where screenCode = 'WLVFLAG' 
			Update tbl_mERP_RecConfigAbstract set Status = 32 Where ID = @ID And MenuName = N'WLVFLAG'
			if @Flag = 0
			begin
			  Update ReportData set Inactive =1  where ID = 1420
			end
			else 
			begin
			  Update ReportData set Inactive =0  where ID = 1420
			end
			GOTO OUT
	End
	-- WLVFLAG Update Process: End**********************************************************************************************************************
	Else
	Begin
		Update CA Set Flag = @Flag
		from tbl_mERP_ConfigAbstract CA Inner join tbl_mERP_RecConfigAbstract RCA
		On CA.Screenname = RCA.MenuName
		Where RCA.ID = @ID

		update tbl_mERP_RecConfigAbstract set Status = Status | 32 Where ID = @ID
	End
OUT:
