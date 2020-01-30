Create Procedure mERP_Sp_ProcessWDSKUList
As  
Begin  
	Set Dateformat DMY    
	Declare @Errmessage nVarchar(4000)    
	Declare @ErrStatus int    
	Declare @MaxID int
	Declare @RecDocId nvarchar(255)
	Declare @TmpRecDocId nvarchar(255)
	Declare @PreviousID int
	Declare @PreviousActiveStatus int
	Declare @PreviousAlertStatus int
	Declare @Isdeactivated int
	set @Isdeactivated=0
	
	Select @MaxId=isnull(max(ID),0) from WDSKUList
	set @TmpRecDocId=''

	/*Check each WDSKUList */
	Declare Cur_WDSKUList Cursor For Select distinct DocumentId from Recd_WDSKUList where isnull(Status,0) = 0 Order by 1
	Open Cur_WDSKUList
	Fetch from Cur_WDSKUList into @RecDocId
	While @@fetch_status = 0 
	Begin
		/* Proces the recd SKU portfolio*/    
		Set @ErrStatus = 0    
		Set @Errmessage = N''  

		/* ID column should have same value for the same Effective From date*/
		if @TmpRecDocId <> @RecDocId
		Begin
			set @TmpRecDocId=@RecDocId
			set @MaxId = @MaxId+1
			/*To address the JIRA ID - FITC-4032*/
			/*Modified date is updated for all the previous entries instead of last one is addressed*/
			select @PreviousID=isnull(max(ID),0) from WDSKUList where
			dbo.stripdatefromtime(effectivefromdate)in
			(select dbo.stripdatefromtime(effectivefromdate) from Recd_WDSKUList Where isnull(Status,0) = 0 and DocumentID=@RecDocId) 
			
			set @Isdeactivated=1
			/*To restore the previous status*/
			Select @PreviousActiveStatus=isnull(Active,0),@PreviousAlertStatus=isnull(Alertstatus,0) from WDSKUList Where ID = @PreviousID

			/* Deactive the existing data for the same effective from date*/    
			update WDSKUList set Active=0,Alertstatus=0, Modifieddate=getdate() Where ID = @PreviousID

			/* Effective from date Validation starts */     
			/* Previous Effective From Date validation*/
			--Check whether there is active entry in WDSKUList table before checking for EffectiveFromdate
			if exists (Select count (*) from WDSKUList where isnull(active,0)=1)
			Begin
				If (Select top 1 dbo.stripdatefromtime(EffectiveFromdate) from Recd_WDSKUList where DocumentID=@RecDocId)< (Select max(EffectiveFromDate) from WDSKUList where isnull(active,0)=1) 
				Begin    
					/* Checking whether datapost is completed for received Effectivefromdate*/
					/* If yes, then dont allow to process the received SKUOPT else allow it*/
					Declare @WDSKUListID int
					Declare @EffectiveFromdate Datetime

					select top 1 @EffectiveFromdate= dbo.stripdatefromtime(EffectiveFromdate) from Recd_WDSKUList where DocumentID=@RecDocId				
					Select top 1 @WDSKUListID = ID from WDSKUList where dbo.stripdatefromtime(EffectiveFromdate)=@EffectiveFromdate and isnull(active,0)=1

					if (isnull(@WDSKUListID,0) = (Select top 1 WDSKUListID from tbl_SKUOpt_Monthly where isnull(status,0)=1)) or
					(isnull(@WDSKUListID,0) = (Select top 1 WDSKUListID from tbl_SKUOpt_Incremental where isnull(status,0)=1))
					BEGIN
						-- Update the error log     
						Set @Errmessage = 'Received EffectiveFromdate is lesser than existing maximum EffectiveFromdate'    
						Set @ErrStatus = 1    
						Goto SkipSKU    
					END
				End  
			End  
			/* Effective from date Validation Ends */
		End	
	
		/* Move the data into main table */    
		insert into WDSKUList(ID,EFFECTIVEFROMDATE,CATEGORYGROUP,ZMAX,ZMIN,FORM,Active,AlertStatus)
		Select @MaxId,EFFECTIVEFROMDATE,CATEGORYGROUP,ZMAX,ZMIN,FORM,Active,1 from Recd_WDSKUList where DocumentID=@RecDocId
		
		update WDSKUList set FORM=replace(FORM,'&lt;','<') where Id=@MaxId
		update WDSKUList set FORM=replace(FORM,'&gt;','>') where Id=@MaxId

		Update Recd_WDSKUList Set Status = 1 where DocumentID=@RecDocId And Status = 0  

		SkipSKU:    
		If (@ErrStatus = 1)    
		Begin    
			Set @Errmessage = 'WDSKUList:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage)       
			Update Recd_WDSKUList Set Status = 2 Where DocumentID=@RecDocId    
			Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)        
			Values('WDSKUList', @Errmessage,  cast(@RecDocId as varchar), getdate())      

			/* Restoring previous status*/
			if @Isdeactivated=1
			Begin
				update WDSKUList set Active=@PreviousActiveStatus,Alertstatus=@PreviousAlertStatus, Modifieddate=getdate() Where ID = @PreviousID				
			End
		End    
		set @Isdeactivated=0
		Fetch Next From Cur_WDSKUList into @RecDocId    
	End    
	Close Cur_WDSKUList    
	Deallocate Cur_WDSKUList    
End  
