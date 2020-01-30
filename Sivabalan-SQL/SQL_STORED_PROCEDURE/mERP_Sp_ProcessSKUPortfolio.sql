Create Procedure mERP_Sp_ProcessSKUPortfolio
As  
Begin  
	Set Dateformat DMY    
	Declare @Errmessage nVarchar(4000)    
	Declare @ErrStatus int    
	Declare @ProductLevel int
	Declare @ProductCode nvarchar(255)  
	Declare @MaxID int
	/* For HMSKU starts*/
	Declare @MaxID_HMSKU int
	/* For HMSKU Ends*/
	Declare @RecDocId nvarchar(255)
	/* For HMSKU starts*/
	Declare @RecDocId_HMSKU int
	/* For HMSKU Ends*/
	Declare @TmpRecDocId nvarchar(255)
	Declare @PreviousID int
	/* For HMSKU starts*/
	Declare @PreviousID_HMSKU int
	/* For HMSKU Ends*/
	Declare @Isdeactivated int
	set @Isdeactivated=0
	/* For HMSKU starts*/
	Declare @Isdeactivated_HMSKU int
	set @Isdeactivated_HMSKU=0
	/* For HMSKU Ends*/

	select @MaxID=isnull(max(ID),0) from SKUPortfolio
	select @MaxID_HMSKU=isnull(max(ID),0) from HMSKU

	set @TmpRecDocId=''

	Create Table #customer(ID int,CustomerID nvarchar(15))
	Create Table #Product (ID int,Product nvarchar(255))

	Create table #SKUPortfolio (
	ID int not null,
	EFFECTIVEFROMDATE Datetime not null,
	CUSTOMERID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS not null,
	PRODUCTPRIORITY int not null,
	PRODUCTCODE nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS not null,
	PRODUCTLEVEL int not null,
	ACTIVE int not null,
	AlertStatus int not null)

	Create Table #HMSKU(
	ID int not null,
	EFFECTIVEFROMDATE Datetime not null,
	CUSTOMERID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS not null,
	PRODUCTPRIORITY int not null,
	PRODUCTCODE nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS not null,
	PRODUCTLEVEL int not null,
	ACTIVE int not null,
	AlertStatus int not null)

	/*Check each SKU portfolio */
	Declare Cur_SKUPortfolio Cursor For    
	Select distinct DocumentID from Recd_SKUPortfolio Where isnull(Status,0) = 0 Order by 1    
	Open Cur_SKUPortfolio    
	Fetch From Cur_SKUPortfolio into @RecDocId   
	While @@Fetch_Status = 0    
	Begin 
		Set @ErrStatus = 0    
		Set @Errmessage = N''   
		/* ID column should have same value for the same Effective From date*/
		if @TmpRecDocId <> @RecDocId
		Begin
			set @TmpRecDocId=@RecDocId
			set @MaxId = @MaxId+1
			set @MaxId_HMSKU = @MaxId_HMSKU+1

			set @PreviousID =0
			/*Modified date is updated for all the previous entries instead of last one is addressed*/
			Select @PreviousID=isnull(max(ID),0) from SKUPortfolio Where 
			dbo.stripdatefromtime(effectivefromdate)in
			(select dbo.stripdatefromtime(effectivefromdate) from Recd_SKUPortfolio Where isnull(Status,0) = 0 and DocumentID=@RecDocId And ProductLevel<> 5) 
			if @PreviousID <> 0
			BEGIN
				set @Isdeactivated=1
				/*To restore the previous status*/
				insert into #SKUPortfolio (ID,EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE ,PRODUCTLEVEL,ACTIVE,AlertStatus)
				Select ID,EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE ,PRODUCTLEVEL,ACTIVE,AlertStatus from SKUPortfolio Where ID = @PreviousID
				update SKUPortfolio set active=0,Alertstatus=0 Where ID = @PreviousID
			END

			/* Previous Effective From Date validation*/
			--Check whether there is active entry in SKUPortfolio table before checking for EffectiveFromdate
			if exists (Select count (*) from SKUPortfolio where isnull(active,0)=1)
			Begin
			/* Effective from date Validation starts */ 
				If (Select top 1 dbo.stripdatefromtime(EffectiveFromdate) from Recd_SKUPortfolio where DocumentID=@RecDocId And ProductLevel<> 5)< (Select max(EffectiveFromDate) from SKUPortfolio where isnull(active,0)=1) 
				Begin    
					/* Checking whether datapost is completed for received Effectivefromdate*/
					/* If yes, then dont allow to process the received SKUOPT else allow it*/
					Declare @SKUPortfolioID int
					Declare @EffectiveFromdate Datetime

					select top 1 @EffectiveFromdate= dbo.stripdatefromtime(EffectiveFromdate) from Recd_SKUPortfolio where DocumentID=@RecDocId	And ProductLevel<> 5		
					Select top 1 @SKUPortfolioID = ID from SKUPortfolio where dbo.stripdatefromtime(EffectiveFromdate)=@EffectiveFromdate and isnull(active,0)=1

					if (isnull(@SKUPortfolioID,0) = (Select top 1 SKUportfolioID from tbl_SKUOpt_Monthly where isnull(status,0)=1)) or
					(isnull(@SKUPortfolioID,0) = (Select top 1 SKUportfolioID from tbl_SKUOpt_Incremental where isnull(status,0)=1))
					BEGIN
						-- Update the error log     
						Set @Errmessage = 'Received EffectiveFromdate is lesser than existing maximum EffectiveFromdate'    
						Set @ErrStatus = 1    
						Goto SkipSKU
					END
				End  
			End  
			/* Effective from date Validation Ends */
			/* CustomerID validation starts */
			insert into #customer (ID,CustomerID)
			Select ID,customerId from Recd_SKUPortfolio where DocumentID=@RecDocId And ProductLevel<> 5 and customerid not in (Select CustomerID from Customer)
			-- Update the error log     
			if (Select count(*) from #customer) > 0
			BEGIN
				Update Recd_SKUPortfolio Set Status = 2 Where ID in (Select ID from #customer) And ProductLevel<> 5  
				Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)        
				Select 'SKU Portfolio', 'SKU Portfolio:- CustomerID not found in the database: ' + CustomerID ,  ID, getdate() from #customer
				Delete from #customer
			END
			/* CustomerID validation Ends */
			/* Category validation starts */
			/* Checking category existence*/
			insert into #Product (ID,Product)
			Select ID,ProductCode from Recd_SKUPortfolio where DocumentID=@RecDocId and ProductLevel<> 5 And 
			Productcode not in (Select Category_Name from itemcategories)
			if (Select count(*) from #Product) > 0
			BEGIN
				Update Recd_SKUPortfolio Set Status = 2 Where ID in (Select ID from #Product) and ProductLevel<> 5
				Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)        
				Select 'SKU Portfolio', 'SKU Portfolio:- Category Name not found in the database: ' + Product ,  ID, getdate() from #Product
				Delete from #Product			
			END

			/* Checking category level*/
			insert into #Product (ID,Product)
			Select ID,ProductCode from Recd_SKUPortfolio,itemcategories IC where DocumentID=@RecDocId and ProductLevel<> 5 
			And Productcode = IC.Category_Name
			And ProductLevel <> IC.Level
			if (Select count(*) from #Product) > 0
			BEGIN
				Update Recd_SKUPortfolio Set Status = 2 Where ID in (Select ID from #Product) and ProductLevel<> 5
				Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)        
				Select 'SKU Portfolio', 'SKU Portfolio:- Received Productlevel is not matching with the current category Level: ' + Product ,ID, getdate() from #Product
				Delete from #Product		
			END
			/* Category validation Ends */

			/* Product Validation Starts */
			/* Checking Item existence*/
			set @PreviousID_HMSKU =0
			/*Modified date is updated for all the previous entries instead of last one is addressed*/
			Select @PreviousID_HMSKU=isnull(max(ID),0) from HMSKU Where 
			dbo.stripdatefromtime(effectivefromdate)in
			(select dbo.stripdatefromtime(effectivefromdate) from Recd_SKUPortfolio Where isnull(Status,0) = 0 and DocumentID=@RecDocId and ProductLevel= 5 )
			if @PreviousID_HMSKU <> 0
			BEGIN
				set @Isdeactivated_HMSKU=1
				/*To restore the previous status*/
				insert into #HMSKU (ID,EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE ,PRODUCTLEVEL,ACTIVE,AlertStatus)
				Select ID,EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE ,PRODUCTLEVEL,ACTIVE,AlertStatus from #HMSKU Where ID = @PreviousID_HMSKU
				update HMSKU set active=0,Alertstatus=0 Where ID = @PreviousID_HMSKU
			END

			/* Previous Effective From Date validation*/
			--Check whether there is active entry in SKUPortfolio table before checking for EffectiveFromdate
			if exists (Select count (*) from HMSKU where isnull(active,0)=1)
			Begin
			/* Effective from date Validation starts */ 
				If (Select top 1 dbo.stripdatefromtime(EffectiveFromdate) from Recd_SKUPortfolio where DocumentID=@RecDocId and ProductLevel= 5 )< (Select max(EffectiveFromDate) from HMSKU where isnull(active,0)=1) 
				Begin    
					/* Checking whether datapost is completed for received Effectivefromdate*/
					/* If yes, then dont allow to process the received SKUOPT else allow it*/
					Declare @HMSKUID int
					Declare @EffectiveFromdate_HMSKU Datetime

					select top 1 @EffectiveFromdate_HMSKU= dbo.stripdatefromtime(EffectiveFromdate) from Recd_SKUPortfolio where DocumentID=@RecDocId and ProductLevel= 5 				
					Select top 1 @HMSKUID = ID from HMSKU where dbo.stripdatefromtime(EffectiveFromdate)=@EffectiveFromdate and isnull(active,0)=1

					if isnull(@HMSKUID,0) = (Select top 1 HMSKUID from tbl_SKUOpt_Monthly where isnull(status,0)=1)
					BEGIN
						-- Update the error log     
						Set @Errmessage = 'Received EffectiveFromdate for HMSKU is lesser than existing maximum EffectiveFromdate'    
						Set @ErrStatus = 1    
						Goto SkipSKU
					END
				End  
			End  

			insert into #Product (ID,Product)
			Select ID,ProductCode from Recd_SKUPortfolio where DocumentID=@RecDocId and ProductLevel= 5 And 
			Productcode not in (Select Product_Code from items)
			if (Select count(*) from #Product) > 0
			BEGIN
				Update Recd_SKUPortfolio Set Status = 2 Where ID in (Select ID from #Product) 
				Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)        
				Select 'SKU Portfolio', 'SKU Portfolio:- Item Code not found in the database: ' + Product ,ID, getdate() from #Product
				Delete from #Product				
			END
			/* Product Validation Ends*/
		End
		
		/* Move the data into main table */     
		/* Category */
		insert into SKUPortfolio (ID,EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE,PRODUCTLEVEL,ACTIVE,AlertStatus)
		Select @MaxID,EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE,PRODUCTLEVEL,ACTIVE,1 from Recd_SKUPortfolio where DocumentID=@RecDocId and status = 0
		And ProductPriority<>0
		/* Product */
		insert into HMSKU (ID,EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE,PRODUCTLEVEL,ACTIVE,AlertStatus)
		Select @MaxID_HMSKU,EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE,PRODUCTLEVEL,ACTIVE,1 from Recd_SKUPortfolio where DocumentID=@RecDocId and status = 0
		And ProductPriority=0
		
		Update Recd_SKUPortfolio Set Status = 1 where DocumentID=@RecDocId And Status = 0  

		SkipSKU:    
		If (@ErrStatus = 1)    
		Begin    
			Set @Errmessage = 'SKU Portfolio:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage)       
			Update Recd_SKUPortfolio Set Status = 2 Where DocumentID=@RecDocId
			Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)        
			Values('SKU Portfolio', @Errmessage,  cast(@RecDocId as varchar), getdate())      

			/* Restoring previous status*/
			if @Isdeactivated=1
			Begin
				Delete from SKUPortfolio where ID=@PreviousID
				insert into SKUPortfolio (ID,EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE ,PRODUCTLEVEL,ACTIVE,AlertStatus,modifieddate)
				Select ID,EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE ,PRODUCTLEVEL,ACTIVE,AlertStatus,getdate() from #SKUPortfolio
				Delete from  #SKUPortfolio
			End
			if @Isdeactivated_HMSKU=1
			Begin
				Delete from HMSKU where ID=@PreviousID
				insert into HMSKU (ID,EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE ,PRODUCTLEVEL,ACTIVE,AlertStatus,modifieddate)
				Select ID,EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE ,PRODUCTLEVEL,ACTIVE,AlertStatus,getdate() from #HMSKU
				Delete from  #HMSKU
			End
		End    
		set @Isdeactivated=0
		set @Isdeactivated_HMSKU=0
		Fetch Next From Cur_SKUPortfolio into @RecDocId    
	End    
	Close Cur_SKUPortfolio    
	Deallocate Cur_SKUPortfolio    
End  
