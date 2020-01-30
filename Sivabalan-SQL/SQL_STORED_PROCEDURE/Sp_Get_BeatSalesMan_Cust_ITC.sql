Create Procedure Sp_Get_BeatSalesMan_Cust_ITC  
(  
@SONumber Int,
@nFormMode int = 0     
)  
As 
Begin 
	Declare  @GroupID nVarchar(1000)
	Declare @CustomerID NVarchar(30)
    Declare @BeatID Int
	Declare @ForumSC Int 
	Declare @SalesManID Int 
	Declare @SlsManID Int
	
	Select @ForumSC = IsNull(ForumSC,0) From SoAbstract Where SoNumber = @SONumber  
	Create Table #tmpGrpID(GroupID Int)
	Create Table #tmpDSHandle(SalesmanID Int,GroupID nVarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpCGID(GrpID Int)




	if @ForumSC = 0  And @nFormMode <> 7
	Begin  
		
		Select @CustomerID = IsNull(CustomerID,0),@GroupID = IsNull(GroupID,0) ,@SalesManID =IsNull(SalesManID,0) , @BeatID = IsNull(BeatID,0)
		From SoAbstract Where SoNumber = @SONumber  


		Insert Into #tmpCGID
		Select * From dbo.sp_splitIn2Rows(@GroupID,',')


		Insert Into #tmpDSHandle
		Select @SalesManID,dbo.mERP_fn_Get_GrpIDSInAsc(@SalesmanID)

		

		If (Select Count(*) From #tmpDSHandle DS,Beat_Salesman BS,SalesMan SM  
			Where  
			BS.CustomerID = @CustomerID  
			--And (DS.GroupID In( Select GrpID From #tmpCGID) Or IsNull(DS.GroupID,0) = 0)
			And (DS.GroupID = @GroupID Or IsNull(DS.GroupID,'0') = '0')
			And BS.SalesManID = @SalesManID
			And BS.BeatID = @BeatID
			And BS.SalesManID = DS.SalesManID  
			And SM.SalesManID = DS.SalesManID) > 0
			Select
			TOP 1 BS.SalesManID,SM.SalesMan_Name,BS.BeatID  
			From  
			#tmpDSHandle DS,Beat_Salesman BS,SalesMan SM  
			Where  
			BS.CustomerID = @CustomerID  
			--And (DS.GroupID In( Select GrpID From #tmpCGID) Or IsNull(DS.GroupID,0) = 0)
			And (DS.GroupID = @GroupID Or IsNull(DS.GroupID,'0') = '0')
			And BS.SalesManID = @SalesManID
			And BS.BeatID = @BeatID
			And BS.SalesManID = DS.SalesManID  
			And SM.SalesManID = DS.SalesManID  
			order by SM.SalesMan_Name
		Else
		If (Select count(*) From #tmpDSHandle DS,Beat_Salesman BS,SalesMan SM  
			Where  
			BS.CustomerID = @CustomerID  
			And DS.GroupID = @GroupID 
			And BS.SalesManID = @SalesManID
			And BS.SalesManID = DS.SalesManID  
			And SM.SalesManID = DS.SalesManID) > 0 
			--When the group and salesman in soabstract is mapped in the dshandle table then that salesman will be loaded
			Select
			TOP 1 BS.SalesManID,SM.SalesMan_Name,BS.BeatID  
			From  
			#tmpDSHandle DS,Beat_Salesman BS,SalesMan SM  
			Where  
			BS.CustomerID = @CustomerID  
			--And DS.GroupID In( Select GrpID From #tmpCGID) 
			And DS.GroupID = @GroupID 
			And BS.SalesManID = @SalesManID
			And BS.SalesManID = DS.SalesManID  
			And SM.SalesManID = DS.SalesManID  
			order by SM.SalesMan_Name
			Else
			Begin
			--When the group and salesman in soabstract  is not mapped then it checks for any other salesman 
			--for that customer is mapped if so it displays that salesman details
			--When there is a salesman for the customer for whom all categories are mapped 
			--then that salesman will be displayed	
			--When more than one salesman is mapped for the same categorygroup then the salesman will be taken in the order
			--of their name ascending wise
			
			
			Create Table #tmpSMCG(SMID Int,GroupID nVarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS,DispOrd Int)
			Declare Cur_Salesman Cursor For 
			Select 
				BS.SalesManID 
			From 
				Beat_Salesman BS
			Where
				BS.CustomerID = @CustomerID


			Declare @GrpID nVarchar(1000)

			Open  Cur_Salesman
			Fetch From Cur_Salesman Into @SlsManID
			While @@Fetch_Status = 0
			Begin	
				Set @GrpID = ''
				Select  @GrpID =  dbo.mERP_fn_Get_GrpIDSInAsc(@SlsManID)
				If @GrpID = @GroupID 
					Insert Into #tmpSMCG
					Select @SlsManID,@GrpID,1
				Else if @GrpID = '0'
					Insert Into #tmpSMCG
					Select @SlsManID,@GrpID,3
				Else
				Begin
					Truncate Table #tmpGrpID
					Insert Into #tmpGrpID
					Select * From dbo.sp_splitIn2Rows(@GrpID,',')

					If Not Exists(Select * From #tmpCGID Where GrpID Not In(Select * From #tmpGrpID))
					Insert Into #tmpSMCG
					Select @SlsManID,@GrpID,2

				End
				Fetch From Cur_Salesman Into @SlsManID
			End

			Close Cur_Salesman
			Deallocate Cur_Salesman
			
			
			
			Select TOP 1 
			BS.SalesManID,SM.SalesMan_Name,BS.BeatID  
			From  
			#tmpSMCG DS,Beat_Salesman BS,SalesMan SM 
			Where  
			BS.CustomerID = @CustomerID  And
			BS.SalesmanID = DS.SMID And
			SM.SalesmanID = BS.SalesmanID 
			order by DispOrd,SM.SalesMan_Name asc

			

		End
	End  
	Else  
		Select    
		BS.SalesManID,SM.SalesMan_Name,BS.BeatID    
		From    
		DSHandle DS,Beat_Salesman BS,SalesMan SM    
		Where    
		1 = 0    

	Drop Table #tmpGrpID
	Drop Table #tmpDSHandle
	Drop Table #tmpCGID
End

