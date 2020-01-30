CREATE PROCEDURE [dbo].[spr_total_sales_detail](@Dummy int, @FROMDATE datetime, @TODATE datetime)
as
Begin
	Declare @MLSalesReturnSaleable NVarchar(50)
	Declare @MLSalesReturnDamages NVarchar(50)
	Declare @MLRetailInvoice NVarchar(50)
	Declare @MLRetailSalesReturnSaleable NVarchar(50)
	Declare @MLRetailSalesReturnDamage NVarchar(50)
	Declare @MLInvoice NVarchar(50)
	Set @MLSalesReturnSaleable = dbo.LookupDictionaryItem(N'Sales Return Saleable', Default)
	Set @MLSalesReturnDamages = dbo.LookupDictionaryItem(N'Sales Return Damages', Default)
	Set @MLRetailInvoice = dbo.LookupDictionaryItem(N'Retail Invoice', Default)
	Set @MLRetailSalesReturnSaleable = dbo.LookupDictionaryItem(N'Retail Sales Return Saleable', Default)
	Set @MLRetailSalesReturnDamage = dbo.LookupDictionaryItem(N'Retail Sales Return Damage', Default)
	Set @MLInvoice = dbo.LookupDictionaryItem(N'Invoice', Default)
        
	SELECT 	InvoiceAbstract.InvoiceID, "InvoiceID" = CASE ISNULL(GSTFLAG,0) WHEN 0 THEN VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar)  ELSE ISNULL(InvoiceAbstract.GSTFullDocID,'') END,
		"Doc Reference"=DocReference,
		"Type" = case InvoiceType
		WHEN 4 THEN 
		Case Status & 32 
		WHEN 0 THEN
		@MLSalesReturnSaleable
		Else
		@MLSalesReturnDamages
		End
		WHEN 2 THEN @MLRetailInvoice
		WHEN 5 THEN @MLRetailSalesReturnSaleable
		WHEN 6 THEN @MLRetailSalesReturnDamage
		ELSE @MLInvoice
		END,
		"Net Value (%c)" = case InvoiceType 
		WHEN 4 THEN 
		0 - (InvoiceAbstract.NetValue - IsNull(Freight,0))
		WHEN 5 THEN 
		0 - (InvoiceAbstract.NetValue - IsNull(Freight,0))
		WHEN 6 THEN 
		0 - (InvoiceAbstract.NetValue - IsNull(Freight,0))
		ELSE
		InvoiceAbstract.NetValue - IsNull(Freight,0)
		END,
		"Net Value+Freight (%c)" = case InvoiceType 
		WHEN 4 THEN 
		0 - InvoiceAbstract.NetValue
		WHEN 5 THEN 
		0 - InvoiceAbstract.NetValue
		WHEN 6 THEN 
		0 - InvoiceAbstract.NetValue
		ELSE 
		InvoiceAbstract.NetValue
		END,
		"Balance (%c)" = case InvoiceType 
		WHEN 4 THEN	
		0 - IsNull(InvoiceAbstract.Balance,0)
		WHEN 5 THEN	
		0 - IsNull(InvoiceAbstract.Balance,0)
		WHEN 6 THEN	
		0 - IsNull(InvoiceAbstract.Balance,0)
		ELSE
		IsNull(InvoiceAbstract.Balance,0)
		END,
		"Roundoff Net Value" = case InvoiceType 
		WHEN 4 THEN
		0 - (InvoiceAbstract.NetValue + RoundOffAmount)
		WHEN 5 THEN
		0 - (InvoiceAbstract.NetValue + RoundOffAmount)
		WHEN 6 THEN
		0 - (InvoiceAbstract.NetValue + RoundOffAmount)
		ELSE
		InvoiceAbstract.NetValue + RoundOffAmount
		END
	FROM 	InvoiceAbstract, VoucherPrefix
	WHERE 	(InvoiceAbstract.Status & 128) = 0 AND
		InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND 
		VoucherPrefix.TranID = 'INVOICE'
	Order By InvoiceAbstract.InvoiceType, InvoiceAbstract.DocumentID
End    
