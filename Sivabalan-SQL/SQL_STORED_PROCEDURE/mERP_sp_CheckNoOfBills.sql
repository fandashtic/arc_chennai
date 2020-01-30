Create Procedure mERP_sp_CheckNoOfBills(@CustomerID nVarchar(255), @GroupID as nVarchar(50), @Mode Int = 0  )
As
Begin
	Declare @ActualBillCount Int
	Declare @OverallBillCount Int
	Declare @CustBillCount nVarchar(50) 
	Declare @CGBillCount Int
	Declare @TempGroupID Int 

	Create Table #TempGroup(GroupID Int, GroupName nVarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS, BillValue nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Insert Into #TempGroup Select ItemValue, '', '' From dbo.sp_SplitIn2Rows(@GroupID, '|')
		
	--No.OfBills defined for the Customer
	Select @OverallBillCount = NoOfBillsOutstanding From Customer Where CustomerID = @CustomerID

	--Actual no. of invoices created for the Customer
	Select @ActualBillCount = Count(InvoiceID) 
		From InvoiceAbstract IA
		Where IA.CustomerID = @CustomerID 
		And IsNull(IA.Status,0) & 128 = 0 
		And IsNull(IA.Balance,0) > 0  
		And InvoiceType <> 4
	
	--For invoice we need to consider the current invoice count also
	--For invoice amendment we dont hav to consider
	If @Mode = 0
		Set @ActualBillCount = @ActualBillCount + 1

	If @ActualBillCount > @OverallBillCount
		Select @CustBillCount = Cast(@OverallBillCount as nVarchar) + '(' + Cast(@ActualBillCount as nVarchar) + ')'
	Else
		Set @CustBillCount = ''
	
	If @GroupID = '0' --If 'All Categories' selected then consider overall validation
		Select 0,'All Categories',@CustBillCount
	Else --Groupwise Validation
	Begin
		--If CG wise No. Of Bills not defined then consider overll validation
		Select Top 1 @CGBillCount = NoOfBills From CustomerCreditLimit Where CustomerID = @CustomerID 
		If @CGBillCount < 0 
			Select 0,'All Categories', @CustBillCount
		Else
		Begin
			Declare GroupCursor Cursor For Select GroupID From #TempGroup
			Open GroupCursor
			Fetch From GroupCursor Into @TempGroupID
			While @@Fetch_Status = 0
			Begin
				--No. of Bills assigned for the Group
				Select @CGBillCount = NoOfBills From CustomerCreditLimit Where CustomerID = @CustomerID And GroupID = @TempGroupID
				--No. of Bills created for the Group
				Select @ActualBillCount = Count(Distinct IA.InvoiceID) From InvoiceAbstract IA, InvoiceDetail ID
					Where IA.InvoiceID = ID.InvoiceID
					And IA.CustomerID = @CustomerID
					And IsNull(IA.Status,0) & 128 =0   
					And IsNull(IA.Balance,0) > 0  
					And IA.Invoicetype <> 4  
					And ID.GroupID = @TempGroupID
				--For invoice we need to consider the current invoice count also
				If @Mode = 0
					Set @ActualBillCount = @ActualBillCount + 1
				If @ActualBillCount > @CGBillCount
					Update #TempGroup Set BillValue = Cast(@CGBillCount as nVarchar) + '(' + Cast(@ActualBillCount as nVarchar) + ')',
						GroupName = (Select GroupName From ProductCategoryGroupAbstract Where GroupID = @TempGroupID )
						Where GroupID = @TempGroupID
			Fetch From GroupCursor Into @TempGroupID
			End
			Close GroupCursor		
			Deallocate GroupCursor
			Select * From #TempGroup
		End
	End
End
Drop Table #TempGroup
