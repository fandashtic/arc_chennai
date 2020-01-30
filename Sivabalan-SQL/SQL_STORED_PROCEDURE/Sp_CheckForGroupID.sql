Create Procedure Sp_CheckForGroupID    
(    
 @Frm Int,    
 @TranID Int = 0    
)    
As 
Begin   
	Declare @SalesmanID Int    
	Declare @GroupID nVarchar(500)    
	Declare @CustomerID NVarChar(30)    
	Declare @BeatID Int    
	Declare @DSHGroupID Int    
	Declare @Result Int  
	Declare @VerifyCustomerID NVarChar(30)    
	Declare @ForumSC Int
	Declare @Cnt Int
	Declare @Exists Int
	
	Create Table #tmpGrpID(GroupID Int,GroupName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpChkGrpID(GroupID Int)

    
	If @Frm=1 -- SO    
		Select    
			@SalesmanID = SalesmanID,@GroupID = GroupId,@CustomerID = CustomerID,@ForumSC = IsNull(ForumSC,0),@BeatID = IsNull(BeatID,0)    
		From    
			SOAbstract    
		Where    
			SONumber = @TranID  

	    
	If @Frm=2 -- Dispatch    
		Select     
			@SalesmanID = SalesmanID,@GroupID = GroupId,@CustomerID = CustomerID,@BeatID = BeatID    
		From     
			DispatchAbstract     
		Where     
			DispatchID = @TranID  
	     
	If @Frm=3 -- Invoice  
		Select     
			@SalesmanID = SalesmanID,@GroupID = GroupId,@CustomerID = CustomerID,@BeatID = BeatID    
		From     
			InvoiceAbstract     
		Where     
			InvoiceID = @TranID  


	/* Inserts All Category Mapped For the salesman */
	Insert Into #tmpGrpID
	Select * From mERP_fn_Get_CGMappedForSalesMan(@SalesmanID)	


	/* Splits the Category Group stored in comma separator and stores
	 in a temporary table */
	Insert Into #tmpChkGrpID
	Select * From dbo.sp_splitIn2Rows(@GroupID,',')
	 
	
	If  IsNull(@GroupID,'-1') = '-1'
	Begin
		Set @Result = 1 -- Shows the Transaction for records before upgrade (validations not needed)
	End
	Else If @GroupID  = '0' --Or IsNull(@GroupID,-1) = -1    
	Begin  
		If (Select Count(*) From #tmpGrpID)  = 0 
			Set @Result = 1 --Show the Transaction    
		Else  
			Set @Result = 0 --Don't show the Transaction  
	End  
	Else     
	Begin    
		If Not Exists(Select GroupID  From #tmpChkGrpID Where GroupID Not In(Select GroupID From #tmpGrpID))
			Set @Result =  1
		Else
		Begin
			if @Frm = 1 And @ForumSC = 0  --Non Forum SC	
			Begin
				if (Select Count(*) From Beat_Salesman Where CustomerID = @CustomerID And BeatID = @BeatID) >0 
				Begin		
					Select @Exists = dbo.mERP_fn_GrpMappedForAnyOtherSalesman(@CustomerID,@GroupID)
					If @Exists = 1
						set @Result =1  
					Else
						set @Result =0
				End
				else
					set @Result =0
			End
			Else
			Begin
				If (Select Count(*) From #tmpGrpID)  = 0 
					Set @Result = 1 --Show the Transaction    
				Else  
					Set @Result = 0 --Don't show the Transaction  
			End
		End
	End
	Select @Result		
End

