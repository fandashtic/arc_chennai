CREATE PROCEDURE Spr_list_cancelled_invoices_MUOM(@Fromdate datetime,@Todate datetime,@SalesMan Nvarchar(4000),@UOM Nvarchar(255))
AS
Begin
	Set DateFormat DMY
	DECLARE @INV AS nvarchar(50)
	Declare @AMENDED nVarchar(50)
	Declare @CANCELLED nVarchar(50)
	Declare @Delimeter as nVarchar(10)
	Set @Delimeter = char(15)

	SElect @AMENDED = dbo.LookupDictionaryItem(N'Amended',Default)
	SElect @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled',Default)
	SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'

	Create Table #TmpDS (SalesmanID Int)

	CREATE TABLE #Temp(
		[ID] Int NULL,
		[InvoiceID] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Date] DateTime NULL,
		[Payment Date] DateTime NULL,
		[Credit Term] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CustomerID] Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Customer Name] Nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Gross Value] Decimal(18, 6) NULL,
		[Trade Discount%] Nvarchar(31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Trade Discount(Rs.)] Decimal(38, 13) NULL,
		[Addl Discount] Nvarchar(31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Addl Discount(Rs.)] Decimal(38, 13) NULL,
		[Freight] Decimal(18, 6) NULL,
		[Net Value] Decimal(18, 6) NULL,
		[Reference] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Status] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Balance] Decimal(18, 6) NULL,
		[Branch] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Beat] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Salesman] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Adj Ref] Nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[GSTIN of Outlet] nvarchar (30),
        [Outlet State Code] int,
		[Adjusted Amount] Decimal(18,6) NULL,
		Reason  Nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,		
		CancelReasonID Int)

	If @SalesMan = '%'
	Begin
		Insert Into #TmpDS Select SalesmanID From Salesman
	End
	Else
	Begin
		Insert Into #TmpDS    
		Select SalesmanID From Salesman Where Salesman_Name In (Select * From dbo.sp_splitin2Rows(@SalesMan,@Delimeter))    
	End

	Insert Into #Temp
	SELECT  InvoiceID ID, 
		"InvoiceID" = case isnull(InvoiceAbstract.GSTFlag,0) When 0 
		Then @INV + CAST(DocumentID AS nvarchar) 
		Else ISNULL(InvoiceAbstract.GSTFullDocID,'')END,
		"Date" = InvoiceDate, 
		"Payment Date" = PaymentDate,
		"Credit Term" = CreditTerm.Description, 
		"CustomerID" = InvoiceAbstract.CustomerID,
		"Customer Name" = Customer.Company_Name,
		"Gross Value" = GrossValue, 
		"Trade Discount%" = CAST(DiscountPercentage AS nvarchar) + N'%', 
		"Trade Discount(Rs.)" = GrossValue * (DiscountPercentage /100),
		"Addl Discount" = CAST(AdditionalDiscount AS nvarchar) + N'%',
		"Addl Discount(Rs.)" = GrossValue * (AdditionalDiscount / 100),
		Freight, "Net Value" = NetValue, 
		"Reference" = 
		(CASE Status & 15
			WHEN 1 THEN N''
			WHEN 2 THEN N''
			WHEN 4 THEN N''
			WHEN 8 THEN N''	END)
		+ CAST(NewReference AS nvarchar), 
		"Status" = Case 
		WHEN (Status & 64) <> 0 THEN @CANCELLED
		WHEN (Status & 128) <> 0 Then @AMENDED
		ELSE N''
		END,
		"Balance" = InvoiceAbstract.Balance,
		"Branch" = ClientInformation.Description,
		"Beat" = Beat.Description,
		"Salesman" = Salesman.Salesman_Name,
		"Adj Ref" = dbo.GetAdjustments(Cast(InvoiceAbstract.PaymentDetails As Int), InvoiceAbstract.InvoiceID),
		"GSTIN of Outlet" = InvoiceAbstract.GSTIN,
		"Outlet State Code" = InvoiceAbstract.ToStateCode,
		"Adjusted Amount" = (Select Sum(AdjustedAmount) From CollectionDetail
		Where CollectionID = Cast(PaymentDetails As Int) And 
		DocumentID <> InvoiceAbstract.InvoiceID
		And InvoiceAbstract.SalesmanID in (Select Distinct SalesmanID From #TmpDS)),
		Null,
		InvoiceAbstract.CancelReasonID
	FROM InvoiceAbstract
	Inner Join Customer On 	InvoiceAbstract.CustomerID = Customer.CustomerID 
	Left Outer Join CreditTerm On 	InvoiceAbstract.CreditTerm = CreditTerm.CreditID
	Left Outer Join ClientInformation On InvoiceAbstract.ClientID = ClientInformation.ClientID
	Left Outer Join Beat On 	InvoiceAbstract.BeatID = Beat.BeatID 
	Left Outer Join Salesman On 	InvoiceAbstract.SalesmanID = Salesman.SalesmanID 
	WHERE   InvoiceType in (1,3,4) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
	(InvoiceAbstract.Status & 64) = 64
	And InvoiceAbstract.SalesmanID in (Select Distinct SalesmanID From #TmpDS)

	Union
	SELECT  InvoiceID, 
		"InvoiceID" = Case isnull(InvoiceAbstract.GSTFlag,0) When 0 
		Then @INV + CAST(DocumentID AS nvarchar) 
		Else ISNULL(InvoiceAbstract.GSTFullDocID,'')END, 
		"Date" = InvoiceDate,
		"Payment Date" = PaymentDate,
		"Credit Term" = Null, 
		"CustomerID" = InvoiceAbstract.CustomerID,
		"Customer Name" = Customer.Company_Name,
		"Gross Value" = GrossValue, 
		"Trade Discount%" = CAST(DiscountPercentage AS nvarchar) + N'%', 
		"Trade Discount(Rs.)" = GrossValue * (DiscountPercentage /100),
		"Addl Discount" = CAST(AdditionalDiscount AS nvarchar) + N'%',
		"Addl Discount(Rs.)" = GrossValue * (AdditionalDiscount / 100),
		Freight, "Net Value" = NetValue, 
		"Reference" = CAST(NewReference AS nvarchar), 
		"Status" = Case 
		WHEN (Status & 64) <> 0 THEN @CANCELLED
		WHEN (Status & 128) <> 0 Then @AMENDED
		ELSE N''
		END,
		"Balance" = InvoiceAbstract.Balance,
		"Branch" = ClientInformation.Description,
		"Beat" = Null,
		"Salesman" = SalesMan.Salesman_Name,
		"Adj Ref" = Null,
		"GSTIN of Outlet" = InvoiceAbstract.GSTIN,
		"Outlet State Code" = InvoiceAbstract.ToStateCode,
		"Adjusted Amount" = Null,
		Null,
		InvoiceAbstract.CancelReasonID
	FROM InvoiceAbstract
	Left Outer Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
	Left Outer Join ClientInformation On InvoiceAbstract.ClientID = ClientInformation.ClientID 
	Left Outer Join  SalesMan On InvoiceAbstract.SalesManID = Salesman.SalesmanID 
	WHERE   InvoiceType = 2 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
	(InvoiceAbstract.Status & 64) = 64
	And InvoiceAbstract.SalesmanID in (Select Distinct SalesmanID From #TmpDS)
	Order By InvoiceID

	Update T Set T.Reason = IR.Reason From #Temp T,InvoiceReasons IR Where T.CancelReasonID = IR.ID 

	Select 	(cast([ID] as Nvarchar(255)) + ',' + @UOM )ID,[InvoiceID],[Date],[Payment Date],[Credit Term],[CustomerID],[Customer Name],[Gross Value],[Trade Discount%],[Trade Discount(Rs.)]
	[Addl Discount],[Addl Discount(Rs.)],[Freight],[Net Value],[Reference],[Status],[Balance],[Branch],[Beat],[Salesman]
	[Adj Ref],[Adjusted Amount],Reason,[GSTIN of Outlet],[Outlet State Code]
	from #Temp

	Drop Table #Temp
	Drop Table #TmpDS
End
