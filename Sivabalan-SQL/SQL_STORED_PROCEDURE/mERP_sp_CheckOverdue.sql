Create Procedure mERP_sp_CheckOverdue(@CustomerID nVarchar(255), @GroupInfo as nVarchar(2000), @CurrDate as DateTime, @InvoiceID Int = 0)
As
	
	Set DateFormat DMY	
	Declare @OverdueAmount Decimal(18, 2)
	Declare @CGCrTerm Int
	Declare @TempGroupID Int
	
	Create Table #TempGroup(GroupID Int, OverdueValue Decimal(18,2))
	Insert Into #TempGroup Select ItemValue, 0 From dbo.sp_SplitIn2Rows(@GroupInfo, '|')

	Select  @OverdueAmount = isNull(Sum(Case InvoiceType When 4 Then 0-IsNull(Balance,0)  
		When 5 then 0-IsNull(Balance,0) When 6 Then 0-IsNull(Balance,0)    
		Else IsNull(Balance,0) End),0) 
		From InvoiceAbstract 
		Where Invoicetype In (1, 2, 3, 4, 5, 6)   
		And (Status & 128) =0 
		And CustomerId=@CustomerID 
		And dbo.StripDateFromTime(PaymentDate) < dbo.StripDateFromTime(@CurrDate)
		And Balance <> 0  
		And InvoiceID <> @InvoiceID


	
	If @OverdueAmount <= 0 
		Set @OverdueAmount = 0

	If @GroupInfo = '0'
		Select 0, @OverdueAmount
	Else
	Begin
		Select Top 1 @CGCrTerm	= CreditTermDays From CustomerCreditLimit Where CustomerID = @CustomerID
		If @CGCrTerm < 0 
			Select 0, @OverdueAmount
		Else
		Begin
			Declare GroupCursor Cursor For Select GroupID From #TempGroup
			Open GroupCursor
			Fetch From GroupCursor Into @TempGroupID
			While @@Fetch_Status = 0
			Begin
				Select  @OverdueAmount = isNull(Sum(Case IA.InvoiceType 
					When 4 Then 0- IsNull((ID.Amount/IA.NetValue*IA.Balance), 0)  
					When 5 then 0-IsNull((ID.Amount/IA.NetValue*IA.Balance), 0) 
					When 6 Then 0-IsNull((ID.Amount/IA.NetValue*IA.Balance), 0)
					Else IsNull((ID.Amount/IA.NetValue*IA.Balance), 0) End),0)
					From InvoiceAbstract IA, InvoiceDetail ID  
					Where IA.Invoicetype In (1, 2, 3, 4, 5, 6)   
					And (IA.Status & 128) =0 
					And IA.CustomerId=@CustomerID 
					And dbo.StripDateFromTime(IA.PaymentDate) < dbo.StripDateFromTime(@CurrDate)   
					And IA.Balance <> 0  
					And IA.InvoiceID = ID.InvoiceID
					And IA.InvoiceID <> @InvoiceID
					And ID.GroupID = @TempGroupID
					--Group By IA.InvoiceType
				If @OverdueAmount > 0
					Update #TempGroup Set OverdueValue = @OverdueAmount Where GroupID = @TempGroupID 				

				Fetch From GroupCursor Into @TempGroupID
			End	
			Close GroupCursor
			Deallocate GroupCursor
			Select * From #TempGroup
		End
	End
	Drop Table #TempGroup
