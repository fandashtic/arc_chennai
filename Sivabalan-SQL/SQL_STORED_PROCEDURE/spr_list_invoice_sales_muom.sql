CREATE procedure [dbo].[spr_list_invoice_sales_muom](@ITEMCODE nvarchar(15),   
            @UOM nvarchar(100),  
                                 @FROMDATE DATETIME,  
                           @TODATE DATETIME)  
AS  
Begin

	DECLARE @INV AS nvarchar(50)  
	DECLARE @INVAMND AS nvarchar(50)  

	If @UOM = N'Base UOM' 
		Set @UOM = N'Sales UOM'

	SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'  
	SELECT @INVAMND = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE AMENDMENT'  
	SELECT InvoiceDetail.InvoiceID,   
	"InvoiceID" =  Case ISNULL(InvoiceAbstract.GSTFlag,0) When 0 then
	CASE InvoiceAbstract.InvoiceType  
	WHEN 1 THEN  
	@INV  
	ELSE  
	@INVAMND  
	END  
	 + CAST(InvoiceAbstract.DocumentID AS nvarchar)
	 Else ISNULL(InvoiceAbstract.GSTFullDocID,'') END,  
	"Doc Reference"=DocReference,  
	"Invoice Type" = case InvoiceAbstract.InvoiceType  
	WHEN 2 THEN N'Retail Invoice'  
	ELSE N'Trade Invoice'   
	END,   
	  
	"Invoice Date" = InvoiceAbstract.InvoiceDate,   
	"CustomerID" = InvoiceAbstract.CustomerID,  
	"Customer Name" = Customer.Company_Name,  
	"Quantity" = CAST(Sum(Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity  
									When N'UOM1' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM1_Conversion)  
									When N'UOM2' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM2_Conversion) End) AS nvarchar)  
	+ N' ' + CAST(UOM.Description AS nvarchar),   
	"Conversion Factor" = CAST(CAST(Sum(InvoiceDetail.Quantity * Items.ConversionFactor) AS   
	  
	Decimal(18,6)) AS nvarchar)  
	+ N' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),  
	 "Reporting UOM" = Cast(Sum(dbo.sp_Get_ReportingQty(ISNULL(InvoiceDetail.Quantity, 0), Items.ReportingUnit)) As nvarchar)   
	--   SubString(  
	--    CAST(CAST(SUM(ISNULL(InvoiceDetail.Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1,   
	--    CharIndex('.', CAST(CAST(SUM(ISNULL(InvoiceDetail.Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)  
	--   + '.' +   
	--   CAST(Sum(Cast(ISNULL(InvoiceDetail.Quantity, 0) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS nvarchar)  
	  + N' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),  
	  
	-- "Reporting UOM" = CAST(CAST(SUM(InvoiceDetail.Quantity / (case Items.ReportingUnit WHEN 0 THEN 1   
	  
	-- ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)  
	-- + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),  
	"Batch" = Batch_Products.Batch_Number,  
	"PKD" = Batch_Products.PKD,  
	"Expiry" = Batch_Products.Expiry,  
	"Sale Price" = ISNULL(InvoiceDetail.SalePrice,0),  
	"Net Value (%c)" = ISNULL(SUM(InvoiceDetail.Amount), 0)  
	FROM InvoiceAbstract
	Inner Join InvoiceDetail On InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
	Inner Join  Items On InvoiceDetail.Product_Code =  Items.Product_Code  
	Left Outer Join UOM On (Case @UOM When N'Sales UOM' Then Items.UOM When N'UOM1' Then Items.UOM1 When N'UOM2' Then Items.UOM2 End) = UOM.UOM  
	Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID  
	Left Outer Join Batch_Products On InvoiceDetail.Batch_Code = Batch_Products.Batch_Code  
	Left Outer Join  Customer On InvoiceAbstract.CustomerID = Customer.CustomerID  
	WHERE InvoiceDetail.Product_Code = @ITEMCODE  AND (InvoiceAbstract.InvoiceType <>4 ) AND InvoiceAbstract.Status & 128 = 0  
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE   
	GROUP BY InvoiceDetail.InvoiceID, InvoiceAbstract.DocumentID, InvoiceAbstract.CustomerID,   
	InvoiceType, Customer.Company_Name,
	InvoiceAbstract.InvoiceDate,InvoiceAbstract.DocReference,  
	InvoiceDetail.SalePrice, ConversionTable.ConversionUnit, Items.ReportingUOM,   
	UOM.Description, Batch_Products.Batch_Number, Batch_Products.PKD, Batch_Products.Expiry,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID 

End    
