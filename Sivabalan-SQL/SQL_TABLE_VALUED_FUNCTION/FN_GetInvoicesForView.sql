Create Function FN_GetInvoicesForView()
Returns 
@TmpOutput Table (InvoiceDate Datetime, InvoiceID int, DocumentID nvarchar(510) Collate SQL_Latin1_General_CP1_CI_AS, 
	DocumentReference nvarchar(510) Collate SQL_Latin1_General_CP1_CI_AS, Order_ID nvarchar(510) Collate SQL_Latin1_General_CP1_CI_AS,
	OrderReference nvarchar(510) Collate SQL_Latin1_General_CP1_CI_AS, InvoiceAmount Decimal(18,6), 
	CustomerID nvarchar(30) Collate SQL_Latin1_General_CP1_CI_AS, BeatID int, SalesmanID int, 
	ItemCode nvarchar(30) Collate SQL_Latin1_General_CP1_CI_AS, Quantity_in_Base_UOM Decimal(18,6), Quantity_in_UOM1 Decimal(18,6), 
	Quantity_in_UOM2 Decimal(18,6),	Price_in_Base_UOM Decimal(18,6), Price_in_UOM1 Decimal(18,6), Price_in_UOM2 Decimal(18,6), 
	Value Decimal(18,6), Status int, Modified_Date Datetime)
BEGIN

	Declare @CurrentDate Datetime
	Set @CurrentDate = dbo.StripTimeFromDate(Cast(GetDate() as Datetime))

	IF EXISTS (Select 'x' From HHViewLog Where dbo.StripTimeFromDate(Date) = @CurrentDate)
		Insert Into @TmpOutput
			([InvoiceDate], [InvoiceID], [DocumentId], [DocumentReference], [Order_ID], [OrderReference], [InvoiceAmount], 	[CustomerID], 
			[BeatID], [SalesmanID], [ItemCode], [Quantity_in_Base_UOM],	[Quantity_in_UOM1], [Quantity_in_UOM2], [Price_in_Base_UOM], 
			[Price_in_UOM1], [Price_in_UOM2], [Value],[Status],[Modified_Date])
		Select InvoiceDate, InvoiceID, DocumentID, DocumentReference, Order_ID,	OrderReference, InvoiceAmount, CustomerID, 
			BeatID, SalesmanID, ItemCode, Quantity_in_Base_UOM, Quantity_in_UOM1, Quantity_in_UOM2,	Price_in_Base_UOM,
			Price_in_UOM1, Price_in_UOM2, Value, Status, Modified_Date From Tmp_VInvoice
	
	ELSE
	BEGIN
		Insert Into @TmpOutput
			([InvoiceDate], [InvoiceID], [DocumentId], [DocumentReference], [Order_ID], [OrderReference], [InvoiceAmount], 	[CustomerID], 
			[BeatID], [SalesmanID], [ItemCode], [Quantity_in_Base_UOM],	[Quantity_in_UOM1], [Quantity_in_UOM2], [Price_in_Base_UOM], 
			[Price_in_UOM1], [Price_in_UOM2], [Value],[Status],[Modified_Date])
		SELECT InvoiceAbstract.InvoiceDate, InvoiceAbstract.InvoiceID, 
				--Isnull(Prefix, '') + Cast (InvoiceAbstract.DocumentID as nvarchar), 
				case when isnull(InvoiceAbstract.GSTFlag,0)>0  then Isnull(GSTFullDocID,'') else Isnull(Prefix, '') + Cast (InvoiceAbstract.DocumentID as nvarchar(255)) end, 
				InvoiceAbstract.DocReference ,
				"Order_ID" = Isnull(Ord.ORDERNUMBER, ''), Isnull(S.DocumentReference, ''), InvoiceAbstract.NetValue,
				InvoiceAbstract.CustomerID, InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, 
				InvoiceDetail.Product_Code, InvoiceDetail.Quantity, 
				(case  when Isnull(UOM1_Conversion, 0) = 0 then 0 else InvoiceDetail.Quantity / UOM1_Conversion end), 	
				(case  when Isnull(UOM2_Conversion, 0) = 0 then 0 else InvoiceDetail.Quantity / UOM2_Conversion end), 	
				SalePrice, SalePrice * isnull(UOM1_Conversion, 0),	SalePrice * isnull(Items.UOM2_Conversion,0), Amount ,
				"Status" =
						(case when (isnull(InvoiceAbstract.Status,0) & 128 ) = 0 and InvoiceAbstract.Invoicetype = 1 then 1 
							when  (isnull(InvoiceAbstract.Status,0) & 128 ) <> 0 or 
								(isnull(InvoiceAbstract.Status,0) & 64 ) <> 0 then 3 					
							when  (isnull(InvoiceAbstract.Status,0) & 128 ) = 0 and InvoiceAbstract.Invoicetype = 3 then 2 	
						end),
				"Date"  = 
					(case when  (isnull(InvoiceAbstract.Status,0) & 64 ) <> 0	then InvoiceAbstract.canceldate
						else InvoiceAbstract.CreationTime end)			
			FROM  InvoiceAbstract 
			Inner Join InvoiceDetail On InvoiceAbstract.InvoiceId = InvoiceDetail.InvoiceID
			Inner Join Items On InvoiceDetail.Product_code = Items.Product_code 
			Left Outer Join SoAbstract S On S.SoNumber = Cast(Isnull(InvoiceAbstract.SONumber, '0') as int) 
			Left Outer Join (Select Distinct ORDERNUMBER, SALEORDERID From Order_Details Where IsNull(SALEORDERID, 0) <> 0) Ord on Ord.SALEORDERID = Isnull(InvoiceAbstract.SONumber, 0)
			Left Outer Join VoucherPrefix On VoucherPrefix.TranID =
				(Case 	when InvoiceAbstract.InvoiceType = 1 then  'INVOICE' 
					when InvoiceAbstract.InvoiceType = 3 then 'INVOICE AMENDMENT'
					when InvoiceAbstract.InvoiceType = 2 then 'RETAIL INVOICE' 
					when InvoiceAbstract.InvoiceType = 4 then 'SALES RETURN' 
				end) 
			and VoucherPrefix.TranID in ('INVOICE', 'RETAIL INVOICE', 'SALES RETURN', 'INVOICE AMENDMENT')
			inner join 
			(SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
				on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS
			on HHS.Salesmanid=InvoiceAbstract.Salesmanid  
			Where InvoiceAbstract.InvoiceType in (1,3) 
			And InvoiceAbstract.InvoiceDate between DateAdd(m,-3,Getdate()) and Getdate()
	END
	Return
END
