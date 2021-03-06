--exec ARC_Vanloading_Invoices '2020-02-07 00:00:00','2020-02-07 23:59:59','TN66AB9220-PB-01','%'
--Update ReportData Set ActionData = 'ARC_Vanloading_Invoices' Where Node = 'Vanloading Invoices'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Vanloading_Invoices')
BEGIN
  DROP PROC [ARC_Vanloading_Invoices]
END
GO
CREATE procedure [dbo].[ARC_Vanloading_Invoices]  
(   
	@FROMDATE datetime,  
	@TODATE datetime,  
	@DocType nvarchar(100),  
	@Term Nvarchar(255) = '%'
)   
AS           
Begin 
	DECLARE @INV AS NVARCHAR(50)           
	DECLARE @CASH AS NVARCHAR(50)     
	DECLARE @CREDIT AS NVARCHAR(50)           
	DECLARE @CHEQUE AS NVARCHAR(50)     
	DECLARE @DD AS NVARCHAR(50)     
	SELECT @CASH = DBO.LookUpDictionaryItem(N'Cash',default)     
	SELECT @CREDIT = DBO.LookUpDictionaryItem(N'Credit',default)      
	SELECT @CHEQUE = DBO.LookUpDictionaryItem(N'Cheque',default)     
	SELECT @DD = DBO.LookUpDictionaryItem(N'DD',default)     
	SELECT @INV = Prefix FROM VoucherPrefix WITH (NOLOCK) WHERE TranID = N'INVOICE' 
   
	SELECT * INTO #TaxComponentDetail 
	FROM TaxComponentDetail WITH (NOLOCK)

	DECLARE @CGST AS INT = (SELECT TOP 1 ISNULL(TaxComponent_code, 0) FROM #TaxComponentDetail WITH (NOLOCK) WHERE TaxComponent_desc = 'CGST')
	DECLARE @SGST AS INT= (SELECT TOP 1 ISNULL(TaxComponent_code, 0) FROM #TaxComponentDetail WITH (NOLOCK) WHERE TaxComponent_desc = 'SGST')
	DECLARE @IGST AS INT= (SELECT TOP 1 ISNULL(TaxComponent_code, 0) FROM #TaxComponentDetail WITH (NOLOCK) WHERE TaxComponent_desc = 'IGST')
	DECLARE @CESS AS INT= (SELECT TOP 1 ISNULL(TaxComponent_code, 0) FROM #TaxComponentDetail WITH (NOLOCK) WHERE TaxComponent_desc = 'CESS')
	DECLARE @ADDLCESS AS INT= (SELECT TOP 1 ISNULL(TaxComponent_code, 0) FROM #TaxComponentDetail WITH (NOLOCK) WHERE TaxComponent_desc = 'ADDL CESS')
       
	Declare @Payid as Int   
	Create Table #Term(PaymentId Int)   
	Truncate Table #Term  
	
	if @term = 'Credit'   
	Begin    
		Truncate Table #Term    
		Insert Into #Term Select 0   
	End   
	Else if @term = 'Cash'   
	Begin    
		Truncate Table #Term    
		Insert Into #Term Select 1 
	End   
	Else if @term = 'Cheque'    
	Begin    
		Truncate Table #Term    
		Insert Into #Term Select 2   
	End   
	Else if @term = 'DD'    
	Begin    
		Truncate Table #Term    
		Insert Into #Term   
		Select 3 
	End 
	Else IF @term = '%'   
	Begin    
		Truncate Table #Term    
		Insert Into #Term Select 0    
		Insert Into #Term Select 1    
		Insert Into #Term Select 2    
		Insert Into #Term Select 3   
	End   
  
	select 
		A.InvoiceID,
		A.InvoiceDate,
		A.ProductDiscount,
		A.TotalTaxApplicable,
		A.DiscountPercentage,
		A.AdditionalDiscount,
		A.Freight,		
		A.RoundOffAmount,
		A.NetValue,		
		A.PaymentMode,
		A.DocumentID,
		A.InvoiceType,		
		A.GSTFullDocID,
		A.GoodsValue,		
		A.AdjustedAmount,
		A.Balance,
		A.DocReference,
		A.PrintCount,
		Case WHEN ISNULL(A.LastPrintOn, '') <> '' AND Year(A.LastPrintOn) > 1900 THEN A.LastPrintOn Else null END LastPrintOn,
		A.CustomerID,
		A.SalesmanID,
		A.BeatID,
		A.Status,
		A.DocSerialType,
		A.UserName
	into #InvoiceAbstract  
	FROM InvoiceAbstract A WITH (NOLOCK)        
	WHERE InvoiceType in (1,3)  
	AND dbo.stripTimeFromdate(invoicedate) BETWEEN @FROMDATE AND @TODATE AND         
	(A.Status & 128) = 0 And         
	A.DocSerialType like @DocType       
	and paymentMode in (select Distinct PaymentId FROM #Term WITH (NOLOCK))   

	--select D.* into #invoicedetail  
	--FROM invoicedetail D WITH (NOLOCK)  
	--Join #InvoiceAbstract A ON A.InvoiceID = D.InvoiceID  

	--select InvoiceID	
	--, sum(CGST) CGST
	--, sum(SGST) SGST	
	--, sum(IGST) IGST	
	--, sum(CESS) CESS
	--, sum([ADDL CESS]) [ADDL CESS]
	--iNTO #TaxBreakup
	-- FROM (
	--	SELECT MAX(D.InvoiceID) InvoiceID, 
	--	D.Product_Code	
	--	,"CGST"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@CGST) > 0 then dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@CGST)/100 else 0 end) * ((SUM(D.SalePrice * Items.ReportingUnit))*(D.Quantity / Items.ReportingUnit) - SUM(D.DiscountValue))	
	--	,"SGST"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@SGST) > 0 then dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@SGST)/100 else 0 end) * ((SUM(D.SalePrice * Items.ReportingUnit))*(D.Quantity / Items.ReportingUnit) - SUM(D.DiscountValue))	
	--	,"IGST"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@IGST) > 0 then dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@IGST)/100 else 0 end) * ((SUM(D.SalePrice * Items.ReportingUnit))*(D.Quantity / Items.ReportingUnit) - SUM(D.DiscountValue))	
	--	,"CESS"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@CESS) > 0 then dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@CESS)/100 else 0 end) * ((SUM(D.SalePrice * Items.ReportingUnit))*(D.Quantity / Items.ReportingUnit) - SUM(D.DiscountValue))
	--	,"ADDL CESS"= dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@ADDLCESS) * (D.Quantity)
	--	FROM #InvoiceDetail D WITH (NOLOCK), Items WITH (NOLOCK)
	--	WHERE
	--	D.Product_Code = Items.Product_Code 	
	--	GROUP BY D.InvoiceID,D.Product_Code,
	--	D.SalePrice, D.Quantity,Items.ReportingUnit	)X
	--Group by InvoiceID
 
	SELECT 
	1 [ID],
	InvoiceID InvoiceID1, 	           
	"Date" = InvoiceDate, 
	"Salesman" = S.Salesman_Name, 
	"Beat" = B.Description, 
	"CustomerID" = C.CustomerID,            
	"Customer" = C.Company_Name,   
	"Customer Category" = dbo.fn_Arc_GetCustomerCategory(C.CustomerId),
	"Customer Groupd" = dbo.fn_Arc_GetCustomerGroup(C.CustomerId),
	"GSTIN" = ISNULL(C.GSTIN,''),
	"Goods Value" = GoodsValue,            
	"Product Discount" = ProductDiscount,      
	"Total SalesTax Value" = TotalTaxApplicable,       
	"Trade Discount" = Cast(A.GoodsValue * (DiscountPercentage /100) as Decimal(18,6)),           
	"Addl Discount" = A.GoodsValue * (AdditionalDiscount / 100),           
	 Freight,    
	"Net Value" = NetValue,     
	"Round Off" = RoundOffAmount,           
	"Adjusted Amount" = IsNull(A.AdjustedAmount, 0),           
	"Balance" = A.Balance,           
	"Collected Amount" = NetValue - IsNull(A.AdjustedAmount, 0) - IsNull(A.Balance, 0) + IsNull(RoundOffAmount, 0),  		
	"DsType" = dbo.fn_Get_DSTypeBySalesManId(S.SalesmanId),
	"Document Type" = DocSerialType,   
	"Doc Ref" = A.DocReference,  
	"GSTFullDocID" = A.GSTFullDocID, 
	"Payment Mode" = case IsNull(PaymentMode,0)   
						When 0 Then @Credit          
						When 1 Then @Cash           
						When 2 Then @Cheque    
						When 3 Then @DD           
						Else @Credit       
					End  
	,"OldInvoiceID" = @INV + CAST(DocumentID AS nVARCHAR)     
	--,"CGST"	= (select top 1 [CGST] FROM #TaxBreakup T WITH (NOLOCK) where A.InvoiceID = T.InvoiceID)
	--,"SGST"	= (select top 1 [SGST] FROM #TaxBreakup T WITH (NOLOCK) where A.InvoiceID = T.InvoiceID)
	--,"IGST"	= (select top 1 [IGST] FROM #TaxBreakup T WITH (NOLOCK) where A.InvoiceID = T.InvoiceID)
	--,"CESS"	= (select top 1 [CESS] FROM #TaxBreakup T WITH (NOLOCK) where A.InvoiceID = T.InvoiceID)
	--,"ADDL CESS"	= (select top 1 [ADDL CESS] FROM #TaxBreakup T WITH (NOLOCK) where A.InvoiceID = T.InvoiceID)
    ,"Is Print" = Case ISNULL(A.PrintCount,0) WHEN 0 THEN 'No' Else 'Yes' END
	,"Print Count" = Case ISNULL(A.PrintCount,0) WHEN 0 THEN '' Else ISNULL(A.PrintCount,0) END
	,"Last Print On" = Case WHEN ISNULL(A.LastPrintOn, '') <> '' AND Year(A.LastPrintOn) > 1900 THEN CONVERT(NVARCHAR(15), A.LastPrintOn, 107)  + ' ' + CONVERT(NVARCHAR(10), A.LastPrintOn, 108) Else null END
	, A.UserName
	INTO #FINAL
	FROM #InvoiceAbstract A WITH (NOLOCK)
	Join Customer C WITH (NOLOCK) ON C.CustomerID = A.CustomerID
	Left Join Salesman S WITH (NOLOCK) ON S.SalesManId = A.SalesmanID
	Left Join Beat B WITH (NOLOCK) ON B.BeatID = A.BeatID
	WHERE InvoiceType in (1,3)   
	AND dbo.stripTimeFromdate(invoicedate) BETWEEN @FROMDATE AND @TODATE AND   
	A.CustomerID = C.CustomerID AND     
	(A.Status & 128) = 0 And          
	A.DocSerialType like @DocType        
	and paymentMode in (select Distinct PaymentId FROM #Term WITH (NOLOCK))    
	Order By S.Salesman_Name, B.Description    
	
	SELECT I.CreationTime, I.GSTFullDocID
	INTO #Invoices
	FROM InvoiceAbstract I WITH (NOLOCK)
	JOIN #FINAL F ON F.GSTFullDocID = I.GSTFullDocID

	SELECT *
	,(SELECT CONVERT(NVARCHAR(15), MIN(CreationTime), 107)  + ' ' + CONVERT(NVARCHAR(10), MIN(CreationTime), 108) FROM #Invoices I WITH (NOLOCK) WHERE I.GSTFullDocID = F.GSTFullDocID GROUP BY GSTFullDocID) [Created On]
	,(SELECT CONVERT(NVARCHAR(15), MAX(CreationTime), 107)  + ' ' + CONVERT(NVARCHAR(10), MAX(CreationTime), 108) FROM #Invoices I WITH (NOLOCK) WHERE I.GSTFullDocID = F.GSTFullDocID GROUP BY GSTFullDocID) [Last Update On]
	,"Total Invoices" = X.[Total Invoices]
	FROM #FINAL F WITh (NOLOCK)
	JOIN (SELECT [Document Type], COUNT(GSTFullDocID) [Total Invoices] FROM #FINAL WITH (NOLOCK) GROUP BY [Document Type]) X ON X.[Document Type] = F.[Document Type]
	ORDER BY GSTFullDocID ASC

	Drop Table #Term       	
	Drop Table #FINAL       	
END
GO