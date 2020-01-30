Create Procedure mERP_sp_List_OLClass_Cust_Export(@SalesManLst nVarchar(2000) = '', @BeatLst nVarchar(2000) = '', 
@FilterType Int = 0 ,@Active int = 0)   
As  
Begin  
	
	Declare @RowCnt as Int
	Declare @MaxCnt as Int
	Declare @CustID nVarchar(500)
	Declare @SlsmanName nVarchar(500)
	Declare @Allslsman as nVarchar(3000)		

	Create table #TmpCustActive(Active int)   
	Create Table #TempCustomer(RowNo Int Identity,CustomerID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,   
							 CustomerName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,   
							 CustomerType nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
							 Active nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
							 BillingAddress nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
							 BeatDesc nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
							 Salesman nVarchar(3000) COLLATE SQL_Latin1_General_CP1_CI_AS Default  ''
                             )  

	if @Active=0	
	Begin 
		Insert into #TmpCustActive values(1)
		Insert into #TmpCustActive values(0)
	End
	Else if @Active=2
		Insert into #TmpCustActive values(0)	
	Else
		Insert into #TmpCustActive values(@Active)	


	If @FilterType = 0   
	Begin  
		Insert into #TempCustomer(CustomerID,CustomerName,CustomerType,Active,BillingAddress,BeatDesc)
		Select 
			C.CustomerID, C.Company_Name as 'CustomerName',CC.ChannelDesc,
			Case C.Active When 0 Then 'No' Else 'Yes' End,
			C.BillingAddress,  B.Description		
		From 
			Customer  C left outer join Beat b on  C.DefaultBeatID = B.BeatID 
			inner join Customer_Channel CC on  C.ChannelType=CC.ChannelType 
		Where 
			C.Active in (select Active from #TmpCustActive)
			And C.CustomerCategory = 2
			Order by B.Description, Company_Name
	End  



	/* To update all the salesman for the customer */
	Set @RowCnt = 1
	Select @MaxCnt = Count(*) From #TempCustomer
	While @RowCnt <= @MaxCnt
	Begin
		Set @CustID = ''
		Select @CustID = CustomerID From #TempCustomer Where RowNo = @RowCnt
		Declare Cur_Slsman Cursor For
		select Distinct S.SalesMan_name from Beat_salesman B,salesman S where CustomerID = @CustID and S.SalesmanID=B.SalesmanID 
		Open Cur_Slsman
		Fetch From Cur_Slsman Into @SlsmanName 
		While @@Fetch_Status = 0
		Begin
			If Len(@Allslsman) = 0 
				Set @Allslsman = @SlsmanName
			Else
				Set @Allslsman = @Allslsman + ',' + @SlsmanName
			Fetch From Cur_Slsman Into @SlsmanName
		End
		Close Cur_Slsman
		DeAllocate Cur_Slsman
		Update #TempCustomer Set Salesman = @Allslsman Where CustomerID = @CustID
		Set @Allslsman = ''
		Set @SlsmanName = ''
		Set @RowCnt = @RowCnt + 1
	End


	/* First Return the count of Records */
	Select Count(*) From  #TempCustomer

	
	/* Next Return the actual records */
	Select * From #TempCustomer



  
  
  Drop table #TempCustomer         
End

