CREATE PROCEDURE sp_get_CatMappedDSTypeID_Ref(@SalManID Int,@RefID Int)
AS  
 Begin
Declare @RefInvID Int
Declare @DSTypeID Int
Declare @xDSTypeID Int
	If Exists (Select Column_Name From INFORMATION_SCHEMA.COLUMNS Where Table_Name = 'DSType_Master' And Column_Name = 'Flag')
		Begin			
			--Select @DSTypeID=ISNULL(DSD.DSTypeId,0)  From DSType_Master DSM 
			--Join DSType_Details DSD On DSM.DSTypeId = DSD.DSTypeId And DSD.SalesManID = @SalManID
			--Where IsNull(DSM.Flag,0) <> 0 And DSM.DSTypeCtlPos = 1 And DSM.Active = 1
			
			Set @RefInvID = @RefID 
			Create Table #tmpRootInv (InvID Int,InvType Int,InvDSTypeID Int)
			more:
			If Exists(Select 'x' From InvoiceAbstract Where InvoiceID = @RefInvID )
			Begin
				Insert Into #tmpRootInv (InvID ,InvType,InvDSTypeID ) Select InvoiceID,InvoiceType,DSTypeID  From InvoiceAbstract Where InvoiceID = @RefInvID 
				Set @RefInvID = ISNULL((Select InvoiceReference From InvoiceAbstract Where InvoiceID = @RefInvID),0)
				If IsNull(@RefInvID,0) > 0 
					Goto more
			End

			Select @xDSTypeID=ISNULL(InvDSTypeID,0) from #tmpRootInv Where InvType = 1

			Drop Table #tmpRootInv
			
			Select @DSTypeID=ISNULL(DSM.DSTypeId,0)  From DSType_Master DSM 			
			Where IsNull(DSM.Flag,0) <> 0 And DSM.DSTypeCtlPos = 1 And DSM.Active = 1
			And DSM.DSTypeId = @xDSTypeID			

			Select DSTypeId=IsNull(@DSTypeID,0)
						
		End
	Else
		Begin
			Select DSTypeId=-1
		End
 End
