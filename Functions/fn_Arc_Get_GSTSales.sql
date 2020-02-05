--select * from dbo.fn_Arc_Get_GSTSales('2019-09-01 00:00:00','2019-09-30 23:59:59')
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'fn_Arc_Get_GSTSales')
BEGIN
    DROP FUNCTION fn_Arc_Get_GSTSales
END
GO
Create Function fn_Arc_Get_GSTSales(@FROMDATE datetime, @TODATE datetime)  
Returns  
	@Final Table 
	(	
		[InvoiceNo]	NVarchar(255),		
		[InvoiceDate]	Datetime,
		[InvoiceValue] Decimal(18,6),		
		[TaxableValue] Decimal(18,6)		
	)
AS  
BEGIN	
	
	DECLARE @TempAbstract AS Table 
	(	
		InvoiceId	int,
		CustomerID NVarchar(255),		
		[InvoiceDate]	Datetime,		
		GSTFullDocID	NVarchar(255),		
		AdditionalDiscount Decimal(18,6),		
		GSTIN	NVarchar(255),		
		ToStateCode	NVarchar(255),		
		DiscountPercentage Decimal(18,6),		
		AddlDiscountValue Decimal(18,6)	
	);

	DECLARE @TempCustomer AS Table 
	(	
		CustomerID	NVarchar(255),
		Company_Name NVarchar(255)	
	)


	DECLARE @TmpInvoiceDetail AS Table 
	(	
		InvoiceID Nvarchar(255), 
		Product_Code Nvarchar(255), 
		SalePrice Decimal(18,6),
		MRPPerPack Decimal(18,6),
		Quantity Decimal(18,6),
		UOMQty Decimal(18,6),
		UOMPrice Decimal(18,6),
		STPayable Decimal(18,6),
		CSTPayable Decimal(18,6),
		DiscountPercentage Decimal(18,6),
		DiscountValue Decimal(18,6),
		Amount Decimal(18,6),
		NetValue Decimal(18,6),
		HSNNumber Nvarchar(255),  
		TaxID INT,
		Serial Nvarchar(255)
	)

	DECLARE @TmpInvoiceDet AS Table 
	(	
		InvoiceID Nvarchar(255), 
		Product_Code Nvarchar(255), 
		SalePrice Decimal(18,6),
		MRPPerPack Decimal(18,6),
		Quantity Decimal(18,6),
		UOMQty Decimal(18,6),
		UOMPrice Decimal(18,6),
		STPayable Decimal(18,6),
		CSTPayable Decimal(18,6),
		DiscountPercentage Decimal(18,6),
		DiscountValue Decimal(18,6),
		Amount Decimal(18,6),
		HSNNumber Nvarchar(255),  
		TaxID INT
	)

	DECLARE @Temp AS Table 
	(	
		InvoiceNo NVarchar(255),
		InvoiceDate DATETIME,
		InvoiceValue Decimal(18,6),
		TaxableValue Decimal(18,6)
	)

	DECLARE @TmpDandDInvAbs AS Table 
	(	
		DandDInvID  NVarchar(255),
		GSTFullDocID NVarchar(255),
		DandDInvDate DATETIME, 
		ClaimAmount  Decimal(18,6),
		GSTIN NVarchar(255),
		ToStatecode NVarchar(255),
		CustomerID NVarchar(255)
	)

	DECLARE @TmpDandDInvDet AS Table 
	(	
		DandDInvID NVarchar(255), 
		SGSTRate Decimal(18,6),
		CGSTRate Decimal(18,6),
		IGSTRate Decimal(18,6),
		TaxType	NVarchar(255)
	)

	DECLARE @TmpDandD AS Table 
	(	
		CustomerID	NVarchar(255),
		Company_Name NVarchar(255)	
	)

	DECLARE @TempCustomer1 AS Table 
	(	
		CustomerID	NVarchar(255),
		Company_Name NVarchar(255)	
	)


	INSERT Into @TempAbstract
	Select Iv.* 
	From InvoiceAbstract Iv(Nolock)
	Where dbo.StripTimeFromDate(Iv.InvoiceDate) BETWEEN dbo.StripTimeFromDate (@FROMDATE) AND dbo.StripTimeFromDate (@TODATE)
	and (Iv.InvoiceType in (1,3))
	and (Iv.Status & 128) = 0

	INSERT Into @TmpInvoiceDetail
	Select ID.*  From InvoiceDetail ID (Nolock),@TempAbstract TA Where ID.InvoiceId = TA.InvoiceId and SalePrice > 0

	INSERT into @TempCustomer 
	select Distinct C.CustomerID ,C.Company_Name from Customer C JOIN @TempAbstract T ON C.CustomerID = T.CustomerID	

	INSERT Into @TmpInvoiceDet(InvoiceID, Product_Code, SalePrice, MRPPerPack, Quantity, UOMQty, UOMPrice, STPayable, CSTPayable, DiscountPercentage, DiscountValue, Amount, HSNNumber, TaxID)
	Select ID.InvoiceID,ID.Product_Code, ID.SalePrice, ID.MRPPerPack, Sum(ID.Quantity) Quantity, Sum(ID.UOMQty) UOMQty, ID.UOMPrice,
	Sum(ID.STPayable) STPayable, Sum(ID.CSTPayable) CSTPayable, Sum(ID.DiscountPercentage) DiscountPercentage,
	Sum(ID.DiscountValue) DiscountValue, Sum(ID.Amount)  Amount, ID.HSNNumber,
	ID.TaxID	
	From @TmpInvoiceDetail ID 
	Inner Join Tax T ON ID.TaxID = T.Tax_Code
	Group By ID.InvoiceID,ID.Product_Code,ID.SalePrice,ID.MRPPerPack,ID.UOMPrice,ID.Serial,ID.HSNNumber,isnull(T.CS_TaxCode,0),ID.TaxID
	Having Sum(ID.UOMQty) > 0

	INSERT Into @Temp(InvoiceNo, InvoiceDate, InvoiceValue, TaxableValue)
	Select 
	IA.GSTFullDocID,
	IA.InvoiceDate,
	Max(IA.NetValue) ,--+ Max(IA.RoundOffAmount),
	(Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)- (((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))))	
	From @TempAbstract IA
	Inner Join @TmpInvoiceDet ID ON IA.InvoiceID = ID.InvoiceID
	Inner Join @TempCustomer Tc on IA.CustomerID = Tc.CustomerID
	Group By IA.InvoiceID, IA.GSTFullDocID, IA.InvoiceDate, IA.GSTIN, IA.ToStateCode,
	IA.DiscountPercentage, IA.AdditionalDiscount, IA.AddlDiscountValue, ID.TaxID, Tc.Company_Name	

	--To get DandD Invoice
	INSERT Into @TmpDandDInvAbs (DandDInvID, GSTFullDocID, DandDInvDate, ClaimAmount, GSTIN, ToStatecode, CustomerID)
	Select DandDInvID, GSTFullDocID, DandDInvDate, ClaimAmount, GSTIN, ToStatecode, CustomerID
	From DandDInvAbstract
	Where dbo.StripTimeFromDate(DandDInvDate) Between dbo.StripTimeFromDate(@FromDate) and dbo.StripTimeFromDate(@ToDate)

	INSERT Into @TmpDandDInvDet (DandDInvID, SGSTRate, CGSTRate, IGSTRate, TaxType)
	Select DD.* From @TmpDandDInvAbs DA
	Join DandDInvDetail DD ON DA.DandDInvID  = DD.DandDInvID

	INSERT into @TempCustomer1 
	select Distinct C1.CustomerID As CustomerID,C1.Company_Name As Company_Name from Customer C1,@TmpDandDInvAbs T where C1.CustomerID = T.CustomerID

	INSERT Into @TmpDandD
	Select 
	DA.GSTFullDocID, 
	DA.DandDInvDate, 
	"InvoiceValue" =  DA.ClaimAmount,
	"TaxableValue" = Sum(isnull(DD.TaxableValue,0))	
	From @TmpDandDInvAbs DA
	Inner Join @TmpDandDInvDet DD ON DA.DandDInvID = DD.DandDInvID
	Inner Join @TempCustomer1 TC ON DA.CustomerID = TC.CustomerID
	Group By DA.DandDInvID, DA.GSTIN, DA.GSTFullDocID, DA.DandDInvDate, DA.ToStatecode, DD.SGSTRate, DD.CGSTRate, DD.IGSTRate, DD.TaxType,TC.Company_Name,DA.ClaimAmount

		--Union All Invoice and DandD Invoice
		INSERT INTO @Final
		Select 
		"Invoice No." = InvoiceNo, 
		"Invoice Date" = InvoiceDate,
		"Invoice Value" = Max(InvoiceValue), 
		"Taxable Value" = Sum(TaxableValue)
		From @Temp
		Group By InvoiceNo, InvoiceDate

		Union ALL

		Select 
		"Invoice No." = GSTFullDocID, 
		"Invoice Date" = DandDInvDate,
		"Invoice Value" = Sum(InvoiceValue), 
		"Taxable Value" = Sum(TaxableValue)
		From @TmpDandD
		Group By GSTFullDocID, DandDInvDate

		----Union All Invoice and DandD Invoice
		--Select 
		--"Invoice No." = InvoiceNo, 
		--"Invoice Date" = InvoiceDate,
		--"Invoice Value" = Max(InvoiceValue), 
		--"Taxable Value" = Sum(TaxableValue)
		--From @Temp
		--Group By InvoiceNo, InvoiceDate
		--Union ALL
		--Select 
		--"Invoice No." = GSTFullDocID, 
		--"Invoice Date" = DandDInvDate,
		--"Invoice Value" = Sum(InvoiceValue), 
		--"Taxable Value" = Sum(TaxableValue)
		--From @TmpDandD
		--Group By GSTFullDocID, DandDInvDate
	RETURN;
END
