--select * from dbo.fn_Arc_Get_GSTPurchase('2019-09-01 00:00:00','2019-09-30 23:59:59')
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'fn_Arc_Get_GSTPurchase')
BEGIN
    DROP FUNCTION fn_Arc_Get_GSTPurchase
END
GO
Create Function fn_Arc_Get_GSTPurchase(@FROMDATE datetime, @TODATE datetime)  
Returns  
	@Final Table 
	(	
		[InvoiceNo]	NVarchar(255),
		[InvoiceDate]	Datetime,
		[InvoiceValue]	Decimal(18,6),		
		[TaxableValue] Decimal(18,6)		
	)
AS  
BEGIN	
	Declare @TempInward as Table 
	(
	[GSTINOfTheSupplier] Nvarchar(30),
		[InvoiceNo]	NVarchar(100),
		[InvoiceDate]	Datetime,
		[InvoiceValue]	Decimal(18,6),
		[Rate] Decimal(18,6),
		[TaxableValue] Decimal(18,6),
		[IGSTAmount]	Decimal(18,6),
		[CGSTAmount]	Decimal(18,6),
		[SGSTAmount]	Decimal(18,6),
		[CessAmount]	Decimal(18,6),
		[PlaceofSupply] Nvarchar(100),
		[TaxCode] int
	)
	Declare @TempBillAbstract as Table
	(
		BillID int,
		BillDate	Datetime,
		VendorID	Nvarchar(100),
		Value decimal (18,6),
		TaxAmount decimal (18,6),
		GSTIN Nvarchar(100),
		ODNumber Nvarchar(100),
		FromStatecode int,
		ToStatecode int,
		StateType int,
		Status Int
	)
	--Manual Invoice
	Insert Into @TempBillAbstract(BillID,BillDate,VendorID,Value,TaxAmount,GSTIN,ODNumber,FromStatecode,ToStatecode,StateType,Status)
	Select BA.BillID ,BA.BillDate ,BA.VendorID ,Value,TaxAmount,Isnull(BA.GSTIN,'') GSTIN,Isnull(BA.ODNumber,'') ODNumber,
	ISNULL(BA.FromStatecode,0) FromStatecode,ISNULL(BA.ToStatecode,0) ToStatecode  , Isnull(BA.StateType,0),Isnull(BA.Status,0)
	from BillAbstract BA
	where BillDate BETWEEN dbo.StripTimeFromDate(@FROMDATE)  AND dbo.StripTimeFromDate(@TODATE)
	AND (Isnull(BA.Status,0) & 128) = 0
	AND VendorID Not In (Select Distinct VendorID from InvoiceAbstractReceived) 

	--Online Invoices
	Insert Into @TempBillAbstract(BillID,BillDate,VendorID,Value,TaxAmount,GSTIN,ODNumber,FromStatecode,ToStatecode,StateType,Status)
	Select BA.BillID ,IAR.InvoiceDate ,BA.VendorID ,Value,TaxAmount,Isnull(BA.GSTIN,''),Isnull(BA.ODNumber,''),
	ISNULL(BA.FromStatecode,0),ISNULL(BA.ToStatecode,0),Isnull(BA.StateType,0),Isnull(BA.Status,0)
	from BillAbstract BA Inner Join InvoiceAbstractReceived IAR On IAR.DocumentID =BA.InvoiceReference 
	Where IAR.InvoiceID = (Select Top 1 RecdInvoiceID from GRNAbstract where BillID = BA.BillID )
	And IAR.InvoiceDate BETWEEN dbo.StripTimeFromDate(@FROMDATE) AND  dbo.StripTimeFromDate(@TODATE)
	AND (Isnull(BA.Status,0) & 128) = 0		
	
	Insert Into @TempInward([InvoiceNo],[InvoiceDate],[InvoiceValue],[TaxableValue])
	Select 	
	ISNULL(BA.ODNumber,''),-- invoice no  
	BA.BillDate, -- invoice date	 	
	(BA.Value + BA.TaxAmount),  -- invoice value	
	bldt.Amount--TaxableValue
	From @TempBillAbstract  BA JOIN BillDetail bldt On BA.BillID = bldt.BillID
	
	INSERT INTO @Final([InvoiceNo], [InvoiceDate], [InvoiceValue], [TaxableValue])
	Select 
	[InvoiceNo],
	[InvoiceDate],
	SUM([InvoiceValue]),	
	Sum([TaxableValue])
	From @TempInward T
	Group By T.InvoiceNo, [InvoiceDate]

	RETURN
END
GO
