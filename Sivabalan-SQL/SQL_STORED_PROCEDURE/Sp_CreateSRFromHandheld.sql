Create Procedure Sp_CreateSRFromHandheld @SalesmanID int,@LogID int = 0
AS
BEGIN
	BEGIN TRY
	
	Declare @VoucherPrefix nvarchar(255)
	Declare @Flag int

	-- To get voucher prefix
	Create Table #Prefix(PrefixName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	insert into #Prefix(PrefixName)
	Exec sp_get_VoucherPrefix 'SALES RETURN'	
	Select @VoucherPrefix = PrefixName From #Prefix
	
	Set dateformat dmy
	Declare @DayCloseDate Datetime
	Select @DayCloseDate=dbo.StripDateFromTime(LastInventoryUpload) from Setup


	Declare @ReturnNumber nvarchar(200)
	Declare @DocumentDate Datetime
	Declare @BillID nvarchar(100)
	Declare @SR_BeatID int
	Declare @SR_CustomerID nvarchar(30)
	Declare @Processed int
	Declare @C_CustomerID nvarchar(30)
	Declare @S_SalesmanID int
	Declare @CustomerCategory int
	Declare @SRCount int

	Declare @InvConfigValue int
	Declare @Error nvarchar(500)
	Declare @WarningMessage nvarchar(500)
	Declare @isValid int	

	Create Table #tmpSalesman(BeatID int, BeatName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
			SalesmanID int,	SalesmanName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
			CustomerID  nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerName  nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Create Table #tmpValid (PC nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
		UOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  IPC nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		IUOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)	

	Select distinct SR.[ReturnNumber], SR.[DocumentDate], SR.[BillID],   
	SR.[SALESMANID] 'SR_SALESMANID',               
	SR.[BeatID] 'SR_BeatID',              
	SR.[OUTLETID] 'SR_CustID', SR.[Processed],     
	Isnull(c.Customerid, '') 'C_Customerid',               
	Isnull(s.SalesmanID, 0) 'S_SalesmanID',              
	c.CustomerCategory 'C_CustomerCategory',    
	(Select Count(*)     
		From (select distinct t.ReturnNumber, t.OutletId, t.BeatID, t.SalesmanID, t.DocumentDate from Stock_Return t               
			Where t.ReturnNumber = SR.ReturnNumber) a) 'Count'    
	Into #tmpSR From Stock_Return SR              
		left outer join Customer c On c.CustomerID = SR.[OUTLETID]              
		left outer join Salesman s On Cast(s.SalesmanID as nvarchar)= SR.[SALESMANID]              
	Where SR.[Processed] = 0  and SR.SalesManID = @SalesmanID             
	Order by SR.[DocumentDate]

	Alter Table #tmpSR Add Rejected Int

	Create Table #DaycloseConfig(InvConfigValue int,FAConfigValue int)
	Insert into #DaycloseConfig(InvConfigValue,FAConfigValue)
	Exec mERP_GetCloseDay_Config

	Declare SR Cursor For Select ReturnNumber, DocumentDate, BillID, SR_BeatID, SR_CustID, Processed, C_Customerid, 
							S_SalesmanID, C_CustomerCategory, Count From #tmpSR
	Open SR
	Fetch From SR Into @ReturnNumber, @DocumentDate, @BillID, @SR_BeatID, @SR_CustomerID, @Processed, @C_CustomerID, 
				@S_SalesmanID, @CustomerCategory, @SRCount				
	While @@FETCH_STATUS = 0
	BEGIN		
		Set @WarningMessage = ''
		
		IF isnull(@ReturnNumber,'') = ''
		BEGIN				
			Set @Error= 'Return Number [' + @ReturnNumber + '] - is empty.'
			BEGIN TRAN					
			Exec sp_han_updateSR @ReturnNumber, 2
			Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextSR
		END		

		IF isnull(@SRCount, 0) > 1
		BEGIN				
			Set @Error= 'Return Number [' + @ReturnNumber + '] is duplicate.'
			BEGIN TRAN					
			Exec sp_han_updateSR @ReturnNumber, 2
			Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextSR
		END		

		Select Top 1 @InvConfigValue=InvConfigValue from #DaycloseConfig		
		/* BackDated SO Validation*/
		If (Select count(*) from dbo.fn_HasAdminPassword_SR(@ReturnNumber,@DocumentDate,@InvConfigValue) where ErrorNumber=0)>=1
		BEGIN
			Select @Error= ErrorDescription from dbo.fn_HasAdminPassword_SR(@ReturnNumber,@DocumentDate,@InvConfigValue) where ErrorNumber=0
			if (isnull(@Error,'') <>'')
			BEGIN
				BEGIN TRAN					
				Exec sp_han_updateSR @ReturnNumber, 2
				Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
				exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
				COMMIT TRAN
				Goto NextSR
			END
		END

		/*Customer ID Validation*/
		If isnull(@SR_CustomerID,'') = ''
		BEGIN
			Set @Error= 'Return Number [' + @ReturnNumber + '] - CustomerID is empty.'
			BEGIN TRAN					
			Exec sp_han_updateSR @ReturnNumber, 2
			Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextSR
		END

		IF (Select Case When isnull(@SR_CustomerID,'') = isnull(@C_Customerid,'') Then 0  Else 1 End) = 1
		BEGIN
			Set @Error= 'Customer ID is invalid in Return Number [' + @ReturnNumber + ']'
			BEGIN TRAN					
			Exec sp_han_updateSR @ReturnNumber, 2
			Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextSR
		END				
	
		IF isnull(@CustomerCategory, 0) > 3 or isnull(@CustomerCategory, 0) < 1
		BEGIN
			Set @Error= 'Customer Category is invalid in Return Number [' + @ReturnNumber + ']'
			BEGIN TRAN					
			Exec sp_han_updateSR @ReturnNumber, 2
			Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextSR
		END	

		/*Salesman ID Validation*/
		IF (Select Case When isnull(@SalesmanID,'') = isnull(@S_SalesmanID,'') Then 0  Else 1 End) = 1
		BEGIN
			Set @Error= 'SalesMan ID is invalid in Return Number [' + @ReturnNumber + ']'
			BEGIN TRAN					
			Exec sp_han_updateSR @ReturnNumber, 2
			Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextSR
		END				

		/*Beat ID Validation*/
		If isnull(@SR_BeatID,0) <= 0
		BEGIN
			Set @Error= 'Return Number [' + @ReturnNumber + '] - BeatID is empty.'
			BEGIN TRAN					
			Exec sp_han_updateSR @ReturnNumber, 2
			Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextSR
		END	
			
		IF Not Exists(Select BeatId from Beat Where BeatId = @SR_BeatID)
		BEGIN
			Set @Error= 'Beat ID is invalid in Return Number [' + @ReturnNumber + ']'
			BEGIN TRAN					
			Exec sp_han_updateSR @ReturnNumber, 2
			Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextSR
		END

		If (Isnull((Select Count(*) from Beat_SalesMan where SalesmanID = @SalesmanID and CustomerID = @SR_CustomerID), 0) = 0) 
				or @SR_BeatID = 0 or not exists (Select * from Beat where BeatID = @SR_BeatID)  
	
			Insert Into #tmpSalesman(BeatID, BeatName, SalesmanID, SalesmanName, CustomerID, CustomerName)
			Select @SR_BeatID 'BeatID', '' 'BeatName', 0 'Beat_SalesMan',  
				(Select SalesMan_Name from SalesMan where SalesManID = @SalesmanID) 'SalesManName',  '' 'Beat_Cust',  
				(Select Company_Name from Customer where CustomerID = @SR_CustomerID) 'CustomerName'  
		Else  
			Insert Into #tmpSalesman(BeatID, BeatName, SalesmanID, SalesmanName, CustomerID, CustomerName)
			Select B.BeatID 'BeatID', B.[Description] 'BeatName', BS.SalesmanId 'Beat_SalesMan',         
				(Select SalesMan_Name from SalesMan where SalesManID = @SalesmanID) 'SalesManName',  BC.CustomerID 'Beat_Cust',    
				(Select Company_Name from Customer where CustomerID = @SR_CustomerID) 'CustomerName'         
			From Beat B        
			Left Outer join Beat_SalesMan BS On BS.BeatId = @SR_BeatID and BS.SalesManID = @SalesManID         
			Left Outer join Beat_SalesMan BC On BC.BeatId = @SR_BeatID and BC.CustomerID = @SR_CustomerID        
			Where B.BeatID = @SR_BeatID        

	
		IF Exists(Select 'x' From #tmpSalesman Where isnull(BeatID,0) = 0)
		BEGIN
			Set @Error= 'Beat ID is invalid in Return Number ' + @ReturnNumber
			BEGIN TRAN					
			Exec sp_han_updateSR @ReturnNumber, 2
			Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextSR
		END		
		ELSE IF Exists(Select 'x' From #tmpSalesman Where isnull(SalesmanID,0) = 0)
		BEGIN
			Set @Error= 'Return Number [' + @ReturnNumber + '] - Salesman is not defined to Beat'
			BEGIN TRAN					
			Exec sp_han_updateSR @ReturnNumber, 2
			Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextSR
		END		
		ELSE IF Exists(Select 'x' From #tmpSalesman Where isnull(CustomerID,'') = '')
		BEGIN
			Set @Error= 'Return Number [' + @ReturnNumber + '] - Outlet is not defined to Beat'
			BEGIN TRAN					
			Exec sp_han_updateSR @ReturnNumber, 2
			Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
			COMMIT TRAN
			Goto NextSR
		END		

		Set @isValid = 0

		Insert Into #tmpValid(PC, UOM, IPC, IUOM)         
		Exec sp_han_ValidateStockReturn @ReturnNumber

		Declare @PC nvarchar(100)
		Declare @UOM nvarchar(100)
		Declare @IPC nvarchar(100)
		Declare @IUOM nvarchar(100)
		Declare @ErrValid nvarchar(500)

		Declare ValidSR Cursor For Select PC, UOM, IPC, IUOM From #tmpValid
		Open ValidSR
		Fetch Next From ValidSR Into @PC, @UOM, @IPC, @IUOM
		While @@Fetch_Status = 0
		BEGIN
			Set @ErrValid = ''
			IF isnull(@IPC, '') <> ''
			BEGIN
				Set @ErrValid= isnull(@IPC,'')
				BEGIN TRAN												
				exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@ErrValid,@SalesmanID
				COMMIT TRAN				
			END
		
			IF isnull(@IUOM, '') <> ''
			BEGIN
				Set @ErrValid= isnull(@IUOM,'')
				BEGIN TRAN																
				exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@ErrValid,@SalesmanID
				COMMIT TRAN		
			END

			Set @isValid = @isValid + 1
			Fetch Next From ValidSR Into @PC, @UOM, @IPC, @IUOM
		END
		Close ValidSR
		Deallocate ValidSR
		
		IF @isValid > 0
		BEGIN
			BEGIN TRAN
			Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
			Exec sp_han_updateSR @ReturnNumber, 2			
			COMMIT TRAN	
			Goto NextSR				
		END				

		Select SR.[ReturnNumber], SR.[Product_Code] 'ITEMID', SR.[Quantity] 'SRQty'      
		,isnull(SR.Price,0) 'SR_Price',isnull(SR.Total_value,0) 'SR_Totalvalue'      
		,isnull(SR.ReturnType,0) 'SR_ReturnType',isnull(SR.Reason,0) 'SR_Reason'      
		,isnull(SR.CategoryGroupID,0) 'SR_CategoryGroupID' ,u.[Description] 'SR_UOM_Desc'                                
		,IsNull(u.[UOM], 0) 'UOM_ID' ,IsNull(u.[Description], '') 'UOM_Desc'                          
		,IsNull(i.Product_Code, '') 'Item_Code' ,IsNull(i.UOM, 0) 'Item_UOM'                          
		,IsNull(i.UOM1, 0) 'Item_UOM1' ,IsNull(i.UOM2, 0) 'Item_UOM2'      
		Into #tmpSRDetail From Stock_Return SR                               
		Inner Join Items i On i.Product_Code = SR.[Product_Code]                              
		Inner Join ItemCategories ic On i.CategoryID = ic.Categoryid             
		Left Outer Join UOM u On u.UOM = SR.[UOM]        
		Where SR.[ReturnNumber] = @ReturnNumber                            
		Order by SR.ReturnNumber, SR.Product_Code, SR.Quantity, SR.UOM   

		Declare @ITEMID nvarchar(30)
		Declare @SRQty Decimal(18,6)
		Declare @SR_ReturnType int
		Declare @SR_Reason int
		Declare @UOM_ID int
		Declare @Item_UOM int
		Declare @Item_UOM1 int
		Declare @Item_UOM2 int
		Declare @ErrLog nvarchar(500)

		Declare SRDetail Cursor For Select ITEMID, SRQty, SR_ReturnType, SR_Reason, UOM_ID, Item_UOM, Item_UOM1, Item_UOM2 From #tmpSRDetail
		Open SRDetail
		Fetch Next From SRDetail Into @ITEMID, @SRQty, @SR_ReturnType, @SR_Reason, @UOM_ID, @Item_UOM, @Item_UOM1, @Item_UOM2
		While @@Fetch_Status = 0
		BEGIN
			Set @ErrLog = ''
			IF (@UOM_ID <> @Item_UOM and @UOM_ID <> @Item_UOM1 and @UOM_ID <> @Item_UOM2) or @UOM_ID = 0
			BEGIN
				Set @ErrLog= 'UOMID is invalid in Return Number ' + @ReturnNumber + ' for the Item Code - ' + @ITEMID
				BEGIN TRAN					
				Exec sp_han_updateSR @ReturnNumber, 2
				Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
				exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@ErrLog,@SalesmanID
				COMMIT TRAN
				Goto NextSR
			END

			IF isnull(@SRQty, 0) <=0 
			BEGIN
				Set @ErrLog= 'Quantity is invalid in Return Number [' + @ReturnNumber + ']'
				BEGIN TRAN					
				Exec sp_han_updateSR @ReturnNumber, 2
				Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
				exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@ErrLog,@SalesmanID
				COMMIT TRAN
				Goto NextSR
			END

			IF @SR_ReturnType > 2 or @SR_ReturnType < 1
			BEGIN
				Set @ErrLog= 'Return ID is invalid in Return Number [' + @ReturnNumber + ']'
				BEGIN TRAN					
				Exec sp_han_updateSR @ReturnNumber, 2
				Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
				exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@ErrLog,@SalesmanID
				COMMIT TRAN
				Goto NextSR
			END

			Declare @Reason_Type_ID int
			Set @Reason_Type_ID = 0
			If @SR_ReturnType = 1
			Begin
				Select Top 1 @Reason_Type_ID = Reason_Type_ID From ReasonMaster Where Reason_SubType = 1 and Reason_Type_ID = @SR_Reason
			End
			Else If @SR_ReturnType = 2	
			Begin
				Select Top 1 @Reason_Type_ID = Reason_Type_ID From ReasonMaster Where Reason_SubType = 2 and Reason_Type_ID = @SR_Reason
			End		

			IF @Reason_Type_ID = 0 
			BEGIN
				Set @ErrLog= 'Reason ID is invalid in Return Number [' + @ReturnNumber + '] for the Item Code - [' + @ITEMID + ']'
				BEGIN TRAN					
				Exec sp_han_updateSR @ReturnNumber, 2
				Update #tmpSR Set Rejected=1 Where ReturnNumber=@ReturnNumber
				exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@ErrLog,@SalesmanID
				COMMIT TRAN
				Goto NextSR
			END			
			
			Fetch Next From SRDetail Into @ITEMID, @SRQty, @SR_ReturnType, @SR_Reason, @UOM_ID, @Item_UOM, @Item_UOM1, @Item_UOM2
		END
		Close SRDetail
		Deallocate SRDetail

		Drop Table #tmpSRDetail	
	
		Begin Tran		

		Declare @ColStatus int
		Create Table #UpdateSR(ColStatus int)
		insert into #UpdateSR(ColStatus)
		Exec sp_han_updateSR @ReturnNumber, 3
		Select Top 1 @ColStatus=ColStatus from #UpdateSR
		Drop Table #UpdateSR

		If @ColStatus <= 0
		BEGIN
			Set @Error='Return Number [' + @ReturnNumber + '] Unable to save Sale Return .'
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@Error,@SalesmanID
			Exec sp_han_updateSR @ReturnNumber, 2					
			--GOTO NextSR								
		END		
		Commit Tran

		NextSR:
			Truncate Table #tmpValid
			Truncate Table #tmpSalesman			
		Fetch Next from SR Into @ReturnNumber, @DocumentDate, @BillID, @SR_BeatID, @SR_CustomerID, @Processed, @C_CustomerID, 
				@S_SalesmanID, @CustomerCategory, @SRCount
	END
	Close SR
	Deallocate SR

	Drop Table #Prefix
	Drop Table #tmpSalesman
	Drop Table #tmpSR
	Drop Table #DaycloseConfig
	Drop Table #tmpValid

	END TRY
	BEGIN CATCH
		Declare @ErrorNo nvarchar(2000)
		Set @ErrorNo=@@Error
		If @@TRANCOUNT >0
		BEGIN
			ROLLBACK TRAN
		END
		--Deadlock Error
		If @ErrorNo='1205'
			exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted','Deadlocked... Application will retry to process',@SalesmanID
		If @ErrorNo<>'1205'
		BEGIN
			Declare @err nvarchar(4000)
			Set @err='Error Executing the procedure: '+cast(@ErrorNo as nvarchar(2000))		
			Update Stock_Return Set Processed=2 Where ReturnNumber=@ReturnNumber
			Exec sp_han_InsertErrorlog @ReturnNumber,3,'Information','Aborted',@err,@SalesmanID
		END
	END CATCH	
END
