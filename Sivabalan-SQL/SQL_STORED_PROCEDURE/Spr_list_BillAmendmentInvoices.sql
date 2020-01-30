CREATE PROCEDURE Spr_list_BillAmendmentInvoices(@Fromdate datetime,@Todate datetime,@SalesMan Nvarchar(4000),@UOM Nvarchar(255))
AS
Begin

	Set DateFormat DMY
	Declare @DISPATCH AS nvarchar(50)
	Declare @PO AS nvarchar(50)
	Declare @SO AS nvarchar(50)
	Declare @Delimeter as nVarchar(10)
	Set @Delimeter = char(15)

	Select @DISPATCH = Prefix From VoucherPrefix Where TranID = 'DISPATCH'
	Select @PO = Prefix From VoucherPrefix Where TranID = 'PURCHASE ORDER'
	Select @SO = Prefix From VoucherPrefix Where TranID = 'SALE ORDER'

	CREATE TABLE #Temp(
		Details Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		invid int,
		[InvoiceID] Nvarchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Doc Reference] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Date DateTime NULL,
		Customer Nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Gross Value] Decimal(18, 6) NULL,
		Discount Decimal(18, 6) NULL,
		[Trade Disc %] Nvarchar(31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Freight Decimal(18, 6) NULL,
		[Original Invoice - Net Value]  Decimal(18, 6) NULL,
		[Net Value] Decimal(18, 6) NULL,
		[Original Invoice] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Branch Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Balance Decimal(18, 6) NULL,
		Reason Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Count of Amendment] Int NULL,
		DocumentID Int, AmendReasonID Int,ID Int,GSTINofOutlet nvarchar (30),
		OutletStateCode int)
	
	Create Table #TmpDS (SalesmanID Int)

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
	Select  (Cast(InvoiceID as Nvarchar(255)) + ',' + Cast(@UOM as Nvarchar(255))), invoiceid,
		"InvoiceID" = Case isnull(InvoiceAbstract.GSTFlag,0 ) when 0 then VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar) Else ISNULL(InvoiceAbstract.GSTFullDocID,'') END, 
		"Doc Reference"=DocReference,
		"Date" = InvoiceDate, "Customer" = Customer.Company_Name,
		"Gross Value" = GrossValue, "Discount" = DiscountValue, 
		"Trade Disc %" = CAST(AdditionalDiscount AS nvarchar) + '%',
		Freight,
		"Original Inv - Net Value" = null,
		"Net Value" = NetValue,
		"Original Invoice" = NewInvoiceReference, 
		"Branch" = ClientInformation.Description,
		"Balance" = Balance,
		"Reason" = Null,
		"Count of Amendment" = Null,
		InvoiceAbstract.DocumentID,
		InvoiceAbstract.AmendReasonID,
		InvoiceAbstract.InvoiceID,
		"GSTIN OF OUTLET" = InvoiceAbstract.GSTIN,
		"OutletStateCode" = InvoiceAbstract.ToStateCode 
		
	From InvoiceAbstract
	Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
	Inner Join VoucherPrefix On VoucherPrefix.TranID = 'INVOICE AMENDMENT' 
	Left Outer Join ClientInformation On 	InvoiceAbstract.ClientID = ClientInformation.ClientID 
	Where   InvoiceType = 3 AND InvoiceDate BETWEEN @Fromdate AND @Todate AND
		 InvoiceAbstract.Status & 128 <> 128 
		And InvoiceAbstract.SalesManID in (Select Distinct SalesManID From #TmpDS)		

	Update T Set T.Reason = IR.Reason From #Temp T,InvoiceReasons IR Where T.AmendReasonID = IR.ID 

	Update T Set T.[Count of Amendment] = C.Cnt From #Temp T,
	(Select DocumentID,Count(DocumentID) Cnt From InvoiceAbstract Where Isnull(InvoiceType,0) = 3 AND InvoiceDate BETWEEN @Fromdate AND @Todate Group By DocumentID) C
	Where C.DocumentID = T.DocumentID

	Declare @DocumentID as Nvarchar(255)
	Declare @NetValue as Decimal(18,6)
	Declare @Invid int
	Declare @ORGInvoiceid int

	Declare Cur Cursor for
	Select DocumentID,InvID From #Temp
	Open Cur
	Fetch from Cur into @DocumentID,@InvID
	While @@fetch_status =0
		Begin
			Set @ORGInvoiceID = (Select Top 1 InvoiceID from InvoiceAbstract Where cast(DocumentID as nvarchar(25))+cast(CustomerID as nvarchar(15)) = 
			(Select Top 1 cast(DocumentID as nvarchar(25))+cast(CustomerID as nvarchar(15)) from InvoiceAbstract Where InvoiceID = @InvID)
			Order By InvoiceID Asc)

			Set @NetValue = (Select Top 1 NetValue From InvoiceAbstract Where Invoiceid = @ORGInvoiceID)
			Update #Temp Set [Original Invoice - Net Value] =  @NetValue Where DocumentID = @DocumentID and Invid=@InvID
			Set @ORGInvoiceID=0
			Fetch Next from Cur into @DocumentID,@InvID
		End
	Close Cur
	Deallocate Cur

	Select Details,InvoiceID,[Doc Reference],Date,Customer,[Gross Value],Discount,[Trade Disc %],Freight,[Original Invoice - Net Value],[Net Value],[Original Invoice],Branch,Balance,Reason,[Count of Amendment], GSTINofOutlet,OutletStateCode  From #Temp

	Drop Table #Temp
	Drop Table #TmpDS
End
