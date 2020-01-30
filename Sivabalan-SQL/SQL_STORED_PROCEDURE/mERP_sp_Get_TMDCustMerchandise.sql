Create Procedure mERP_sp_Get_TMDCustMerchandise
				(@Zone as nVarchar(2000),
				 @Salesman nVarchar(2000),
				 @Beat nVarchar (2000),
				 @Active Int = 0
				)
As
Begin
	
	Declare @Delimeter as Char(1)
	Declare @MerchandiseID as Int
	Declare @Merchandise as nVarchar(500)
	Declare @strSQL as nVarchar(4000)


	Set @Delimeter= ','

	
	Create Table #tmpSalesMan(SalesmanID int)
	Create Table #tmpBeat(BeatID int)
	Create Table #tmpZone(ZoneID Int)

	Create table #tmpCustMerchandise([Customer Code] nVarchar(255),[Customer Name] nVarchar(500))


	If @Zone = N'%' 
	Begin
		Insert Into #tmpZone Select ZoneID From tbl_mERP_Zone Where Active = 1
	End
	Else If  @Zone = N'' 
	Begin
		Insert Into #tmpZone Select ZoneID From tbl_mERP_Zone Where Active = 1
		Insert Into #tmpZone Select 0
	End
	Else
	Begin
		Insert Into #tmpZone Select ZoneID From tbl_mERP_Zone Where ZoneID In(select * from dbo.sp_SplitIn2Rows(@Zone, @Delimeter))
	End


	If @Salesman = N'%' 
	Begin
		Insert into #tmpSalesMan Select SalesmanID From Salesman Where Active = 1
	End
	Else If  @Salesman = N''     
	Begin
		Insert into #tmpSalesMan Select SalesmanID From Salesman Where Active = 1
		Insert into #tmpSalesMan Select 0
	End
	Else
	Begin
		Insert into #tmpSalesMan Select SalesmanID From Salesman Where SalesmanID in (select * from dbo.sp_SplitIn2Rows(@Salesman, @Delimeter))
	End


	If @Beat = N'%' 
	Begin
		Insert into #tmpBeat Select BeatID From Beat Where Active = 1
	End
	Else If  @Beat = N''
	Begin
		Insert into #tmpBeat Select BeatID From Beat Where Active = 1
		Insert into #tmpBeat Select 0
	End
	Else
	Begin
		Insert into #tmpBeat Select BeatID From Beat Where BeatID in (select * from dbo.sp_SplitIn2Rows(@Beat, @Delimeter)) 
	End


	

	Insert Into #tmpCustMerchandise
	Select Distinct C.CustomerID ,C.Company_Name 
	From 
		Customer C,Beat_Salesman BS,Salesman SM,Beat B
	Where 
		C.Active = (Case @Active When 0 Then C.Active When 1 Then 1 When 2 Then 0 End) And 
		C.CustomerID = BS.CustomerID And 
		SM.SalesmanID = BS.SalesmanID And
		B.BeatID = BS.BeatID And
		isNull(BS.CustomerID,'') <> '' And
		isNull(BS.SalesmanID,0) <> 0 And
		isNull(BS.BeatID,0) <> 0 And 
		SM.SalesmanID In (Select SalesmanID From #tmpSalesMan) And 
		B.BeatID In (Select BeatID From #tmpBeat) And
		isNull(C.ZoneID,0) In(Select ZoneID From #tmpZone)

	Order By C.Company_Name 


	Declare Cur_Merchandise Cursor For
	Select MerchandiseID,Merchandise From Merchandise Where Active = 1
	Open Cur_Merchandise
	Fetch From Cur_Merchandise Into @MerchandiseID,@Merchandise 
	While @@Fetch_Status = 0
	Begin
		Set @strSQL = ''
		
		Set @strSQL = 'Alter Table #tmpCustMerchandise Add [' +  Cast(@Merchandise as nVarchar(150)) + '] nVarchar(5)'
	
		Exec sp_Executesql @strSQL
		
		Set @strSQL = ''

		Set @strSQL = 'Update #tmpCustMerchandise Set [' +  Cast(@Merchandise as nVarchar(150)) + '] 
					  = isNull((Select Case isNull(CustomerID,N'''') When N'''' Then  N''No''  Else  N''Yes'' End From CustMerchandise Where CustomerID =   
					  #tmpCustMerchandise.[Customer Code]   And MerchandiseID = ' 
					  + Cast(@MerchandiseID as nVarchar(10)) + '),N''No'')'


		Exec sp_Executesql @strSQL



		Fetch Next From Cur_Merchandise Into @MerchandiseID,@Merchandise 
	End
	Close Cur_Merchandise
	Deallocate Cur_Merchandise

	
	Select Count(*) From #tmpCustMerchandise

	Select * From #tmpCustMerchandise




End

