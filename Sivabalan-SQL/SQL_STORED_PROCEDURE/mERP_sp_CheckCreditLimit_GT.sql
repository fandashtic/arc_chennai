Create Procedure mERP_sp_CheckCreditLimit_GT(@CustomerID nVarchar(255), @GroupInfo as nVarchar(2000), @InvValue Decimal(18,6), @InvoiceID Int = 0)
As
	if (SELECT isnull(CreditLimit,-1) FROM Customer WHERE CustomerID=@CustomerID)<>-1
	BEGIN
		Declare @Outstanding decimal(18,6)
		Declare @Balance Decimal(18,2)	
		Declare @CrLimit Decimal(18,2)
		Declare @CustCrLimitInfo decimal(18,6)
		Declare @Value decimal(18,6)
		Declare @CGCrLimitInfo nVarchar(255)
		Declare @CGCrLimit Decimal(18,6)
		Declare @TempGroupInfo nVarchar(255)
		Declare @GroupId Int
		Declare @GroupInvValue Decimal(18,6)
		Declare @RowCount Int

		Set @Value=0

		Create Table #TempGroup(ID Int Identity, GroupInfo nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, GroupID Int, 
				GroupName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
				CrLimitValue decimal(18,6),Value decimal(18,6))
		Insert Into #TempGroup Select ItemValue, '', '', 0,0 From dbo.sp_SplitIn2Rows(@GroupInfo, '|')
			
		--Overall Cr.Limit checking
		Select @CrLimit = CreditLimit From Customer Where CustomerID = @CustomerID
		Select @Outstanding = dbo.mERP_fn_GetCustOutStandingBalance(@CustomerID, @InvoiceID)
		Set @Balance = 0 - (@Outstanding - @InvValue)
		
		If @Balance > @CrLimit 
			Select @CustCrLimitInfo = @CrLimit, @Value=@Balance 
		Else
			Set @CustCrLimitInfo = 0 


		If @GroupInfo = '0'--If 'All Categories' selected then consider overall validation
		Begin
			If @CustCrLimitInfo <> 0 and @Value <> 0
			Select 0, 'All Categories', @CustCrLimitInfo,@value
		End
		Else
		Begin
			--If CG wise CreditLimit not defined then consider overll validation
			Select Top 1 @CGCrLimit = CreditLimit From CustomerCreditLimit Where CustomerID = @CustomerID 
			If @CGCrLimit < 0 
			Begin
				if @CustCrLimitInfo <> 0 and @Value <> 0
					Begin
						Select 0, 'All Categories', @CustCrLimitInfo,@Value
					End
			END
			Else	--If CGwise CreditLimit defined then check for CGwise value assigned
			Begin
				Set @RowCount = 1
				Declare GroupCursor Cursor For Select GroupInfo From #TempGroup
				Open GroupCursor
				Fetch From GroupCursor Into @TempGroupInfo
				While @@Fetch_Status = 0
				Begin	
					Select @GroupInvValue = SubString(@TempGroupInfo,CharIndex('',@TempGroupInfo)+1,Len(@TempGroupInfo))	
					Select @GroupId = SubString(@TempGroupInfo,0,CharIndex('',@TempGroupInfo))	
					Select @CrLimit = CreditLimit From CustomerCreditLimit Where CustomerID = @CustomerID And GroupID = @GroupId
					Select @Outstanding = dbo.mERP_fn_GetCGOutstandingBalance(@CustomerID, @GroupId, @InvoiceID)
					Set @Balance = 0 - (@Outstanding - @GroupInvValue)
					
					If @Balance > @CrLimit 
						--Select @CGCrLimitInfo = Cast(@CrLimit as nVarchar) + '(' + Cast(@Balance as nVarchar) + ')'
						Update #TempGroup Set GroupID = @GroupId, CrLimitValue = @CrLimit, Value = @Balance,
							GroupName = (Select GroupName From ProductCategoryGroupAbstract Where GroupID = @GroupId )
							Where ID = @RowCount
					Else
						Update #TempGroup Set GroupID = @GroupId Where ID = @RowCount


					Set @RowCount = @RowCount + 1
					

					Fetch From GroupCursor Into @TempGroupInfo
				End
				Close GroupCursor		
				Deallocate GroupCursor
				Select GroupID,GroupName,CrLimitValue,Value From #TempGroup where Value <> 0 
			End
		End
		Drop Table #TempGroup
	END
