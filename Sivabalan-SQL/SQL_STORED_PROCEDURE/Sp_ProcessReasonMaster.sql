Create Procedure Sp_ProcessReasonMaster
As
Begin
	Set Dateformat DMY
	Declare @RecdID int,@ID int,@Reason nvarchar(255),@Type nvarchar(50),@Active int
	Declare @ErrorMsg as nvarchar(400)
	Declare @Sales_Return as nvarchar(50)
	Declare @Godown_Damage as nvarchar(50)

	Set @Sales_Return = 'Market Return'
	Set @Godown_Damage = 'Godown Damage'	

	Create Table #tmpRecDoc(RecDocID int)
	Insert into #tmpRecDoc(RecDocID)
	Select RecdID from RecdReasonAbstract where isnull(status,0)=0
	
	/*Process Begins*/
	Declare AllDocs Cursor For Select RecDocID from #tmpRecDoc
	Open AllDocs
	Fetch from AllDocs into @RecdID
	While @@fetch_status=0
	BEGIN
		Declare RM Cursor For Select ID,Reason,Type,Active from RecdReasonDetail where RecdID=@RecdID
		Open RM
		Fetch from RM into @ID,@Reason,@Type,@Active
		While @@fetch_status=0
		BEGIN
			if @Type not in ('Invoice Amendment', 'Invoice Cancellation', 'Sales Return Saleable', 'Sales Return Damage', 'Godown Damage', 'Godown Damage Arrival')
			BEGIN
				Set @ErrorMsg = ''
				Set @ErrorMsg='Type ('+cast(@Type as nvarchar(50))+ ') is invalid'  
				Exec mERP_sp_Update_ReasonErrorStatus @RecdID, @ErrorMsg
				update R set Status = 2,modifieddate=getdate() From RecdReasonDetail R
				Where R.ID =@ID And
				isnull(status,0)=0
				GOTO NextDoc
			END
			
			if @Type in ('Invoice Amendment', 'Invoice Cancellation')
			BEGIN
				if exists (select 'x'from InvoiceReasons where Type=Rtrim(ltrim(@Type)) and Reason=Rtrim(ltrim(@Reason)) and Active=@Active)
				BEGIN
					Set @ErrorMsg = ''
					Set @ErrorMsg='Warning: Reason ('+cast(@Reason as nvarchar(255))+ ') '+cast(@Type as nvarchar(50))+ ') and active combination already exists'
					Exec mERP_sp_Update_ReasonErrorStatus @RecdID, @ErrorMsg
					update R set Status = 1,modifieddate=getdate() From RecdReasonDetail R
					Where R.ID =@ID And
					isnull(status,0)=0
					GOTO NextDoc				
				END
				if not exists (select 'x'from InvoiceReasons where Type=Rtrim(ltrim(@Type)) and Reason=Rtrim(ltrim(@Reason)))
				BEGIN			
					insert into InvoiceReasons(RecdID,Reason,Type,Active)
					Select @RecdID,Rtrim(ltrim(@Reason)),Rtrim(ltrim(@Type)),@Active
					Update RecdReasonDetail set status =1 where ID=@ID
				END
				ELSE
				BEGIN
					update InvoiceReasons set Active=@Active,ModifiedDate=getdate() where Type=Rtrim(ltrim(@Type)) and Reason=Rtrim(ltrim(@Reason))
					Update RecdReasonDetail set status =1 where ID=@ID
				END	
			END

			if @Type in ('Sales Return Saleable', 'Sales Return Damage', 'Godown Damage', 'Godown Damage Arrival')
			BEGIN
				
				If @Type = 'Sales Return Saleable'
				BEGIN 
					if exists (select 'x'from ReasonMaster where Reason_Type = @Sales_Return and Reason_SubType=1 and Reason_Description=Rtrim(ltrim(@Reason)) and Active=@Active)
					BEGIN
						Set @ErrorMsg = ''
						Set @ErrorMsg='Warning: Reason ('+cast(@Reason as nvarchar(255))+ ') ('+cast(@Type as nvarchar(50))+ ') and active combination already exists'
						Exec mERP_sp_Update_ReasonErrorStatus @RecdID, @ErrorMsg
						update R set Status = 1,modifieddate=getdate() From RecdReasonDetail R
						Where R.ID =@ID And
						isnull(status,0)=0
						GOTO NextDoc				
					END			

					if not exists (select 'x'from ReasonMaster where Reason_Type = @Sales_Return and Reason_SubType=1 and Reason_Description=Rtrim(ltrim(@Reason)))
					BEGIN			
						Insert into ReasonMaster(Reason_Type, Reason_SubType, Reason_Description, Screen_Applicable, Active)
						Select @Sales_Return, 1, Rtrim(ltrim(@Reason)), Rtrim(ltrim(@Type)), @Active
						Update RecdReasonDetail set status =1 where ID=@ID
					END
					ELSE
					BEGIN
						Update ReasonMaster Set Active=@Active, ModifiedDate=getdate() Where Reason_Type = @Sales_Return and Reason_SubType=1 and Reason_Description=Rtrim(ltrim(@Reason))
						Update RecdReasonDetail set status =1 where ID=@ID
					END				
				END
				Else If @Type = 'Sales Return Damage'

				BEGIN 
					if exists (select 'x'from ReasonMaster where Reason_Type = @Sales_Return and Reason_SubType=2 and Reason_Description=Rtrim(ltrim(@Reason)) and Active=@Active)
					BEGIN
						Set @ErrorMsg = ''
						Set @ErrorMsg='Warning: Reason ('+cast(@Reason as nvarchar(255))+ ') ('+cast(@Type as nvarchar(50))+ ') and active combination already exists'
						Exec mERP_sp_Update_ReasonErrorStatus @RecdID, @ErrorMsg
						update R set Status = 1,modifieddate=getdate() From RecdReasonDetail R
						Where R.ID =@ID And
						isnull(status,0)=0
						GOTO NextDoc				
					END			

					if not exists (select 'x'from ReasonMaster where Reason_Type = @Sales_Return and Reason_SubType=2 and Reason_Description=Rtrim(ltrim(@Reason)))
					BEGIN			
						Insert into ReasonMaster(Reason_Type, Reason_SubType, Reason_Description, Screen_Applicable, Active)
						Select @Sales_Return, 2, Rtrim(ltrim(@Reason)), Rtrim(ltrim(@Type)), @Active
						Update RecdReasonDetail set status =1 where ID=@ID
					END
					ELSE
					BEGIN
						Update ReasonMaster Set Active=@Active, ModifiedDate=getdate() Where Reason_Type = @Sales_Return and Reason_SubType=2 and Reason_Description=Rtrim(ltrim(@Reason))
						Update RecdReasonDetail set status =1 where ID=@ID
					END				
				END

				Else If @Type = 'Godown Damage'
				BEGIN 
					if exists (select 'x'from ReasonMaster where Reason_Type = @Godown_Damage and Reason_SubType=3 and Reason_Description=Rtrim(ltrim(@Reason)) and Active=@Active)
					BEGIN
						Set @ErrorMsg = ''
						Set @ErrorMsg='Warning: Reason ('+cast(@Reason as nvarchar(255))+ ') ('+cast(@Type as nvarchar(50))+ ') and active combination already exists'
						Exec mERP_sp_Update_ReasonErrorStatus @RecdID, @ErrorMsg
						update R set Status = 1,modifieddate=getdate() From RecdReasonDetail R
						Where R.ID =@ID And
						isnull(status,0)=0
						GOTO NextDoc				
					END			

					if not exists (select 'x'from ReasonMaster where Reason_Type = @Godown_Damage and Reason_SubType=3 and Reason_Description=Rtrim(ltrim(@Reason)))
					BEGIN			
						Insert into ReasonMaster(Reason_Type, Reason_SubType, Reason_Description, Screen_Applicable, Active)
						Select @Godown_Damage, 3, Rtrim(ltrim(@Reason)), 'Stock Conversion to Damage', @Active
						Update RecdReasonDetail set status =1 where ID=@ID
					END
					ELSE
					BEGIN
						Update ReasonMaster Set Active=@Active, ModifiedDate=getdate() Where Reason_Type = @Godown_Damage and Reason_SubType=3 and Reason_Description=Rtrim(ltrim(@Reason))
						Update RecdReasonDetail set status =1 where ID=@ID
					END				
				END

				Else If @Type = 'Godown Damage Arrival'
				BEGIN 
					if exists (select 'x'from ReasonMaster where Reason_Type = @Godown_Damage and Reason_SubType=4 and Reason_Description=Rtrim(ltrim(@Reason)) and Active=@Active)
					BEGIN
						Set @ErrorMsg = ''
						Set @ErrorMsg='Warning: Reason ('+cast(@Reason as nvarchar(255))+ ') ('+cast(@Type as nvarchar(50))+ ') and active combination already exists'
						Exec mERP_sp_Update_ReasonErrorStatus @RecdID, @ErrorMsg
						update R set Status = 1,modifieddate=getdate() From RecdReasonDetail R
						Where R.ID =@ID And
						isnull(status,0)=0
						GOTO NextDoc				
					END			

					if not exists (select 'x'from ReasonMaster where Reason_Type = @Godown_Damage and Reason_SubType=4 and Reason_Description=Rtrim(ltrim(@Reason)))
					BEGIN			
						Insert into ReasonMaster(Reason_Type, Reason_SubType, Reason_Description, Screen_Applicable, Active)
						Select @Godown_Damage, 4, Rtrim(ltrim(@Reason)), 'Stock Conversion to Damage', @Active
						Update RecdReasonDetail set status =1 where ID=@ID
					END
					ELSE
					BEGIN
						Update ReasonMaster Set Active=@Active, ModifiedDate=getdate() Where Reason_Type = @Godown_Damage and Reason_SubType=4 and Reason_Description=Rtrim(ltrim(@Reason))
						Update RecdReasonDetail set status =1 where ID=@ID
					END				
				END

			END

NextDoc:
			Fetch Next from RM into @ID,@Reason,@Type,@Active
		END
		Close RM
		Deallocate RM
		Update RecdReasonAbstract set Status=1 where RecdID=@RecdID
		Fetch Next from AllDocs into @RecdID
	END
	Close AllDocs
	Deallocate AllDocs

	/*Process Ends*/
	Drop Table #tmpRecDoc
End
