CREATE PROCEDURE Spr_FreeSalesListing_muom_pidilite ( @FROMDATE DATETIME, 
									         @TODATE DATETIME,
											 @UOM VarChar(100))  
AS  
BEGIN

SELECT INVOICEDETAIL.product_code,INVOICEDETAIL.product_code as "Item Code",ITEMS.productname,
	"Quantity" = SUM(Case 
		when InvoiceAbstract.InvoiceType >=4 and InvoiceAbstract.InvoiceType <=6 then 
		   0 - Case @UOM When 'Sales UOM' Then Invoicedetail.Quantity 
				         When 'UOM1' Then Invoicedetail.Quantity / (Case IsNull(UOM1_Conversion, 1) When 0 Then 1 Else IsNull(UOM1_Conversion, 1) End)
						 When 'UOM2' Then Invoicedetail.Quantity / (Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End) End
		else
              Case @UOM When 'Sales UOM' Then Invoicedetail.Quantity 
				         When 'UOM1' Then Invoicedetail.Quantity / (Case IsNull(UOM1_Conversion, 1) When 0 Then 1 Else IsNull(UOM1_Conversion, 1) End)
						 When 'UOM2' Then Invoicedetail.Quantity / (Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End) End
--		   Invoicedetail.Quantity 
                end ),
	"Reporting UOM" = SUM((Case 
		when InvoiceAbstract.InvoiceType >=4 and InvoiceAbstract.InvoiceType <=6 then 
		   0 - Invoicedetail.Quantity Else Invoicedetail.Quantity End) / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),  
        "Conversion Factor" = Sum((Case 
		when InvoiceAbstract.InvoiceType >=4 and InvoiceAbstract.InvoiceType <=6 then 
		   0 - Invoicedetail.Quantity Else Invoicedetail.Quantity End) * IsNull(ConversionFactor, 0))
	FROM ITEMS,INVOICEABSTRACT,INVOICEDETAIL 
	WHERE ITEMS.PRODUCT_CODE = INVOICEDETAIL.PRODUCT_CODE 
	AND INVOICEABSTRACT.INVOICEID = INVOICEDETAIL.INVOICEID 
	AND INVOICEABSTRACT.Invoicetype in (1,2,3,4,5,6) AND INVOICEDETAIL.Saleprice = 0 
	AND (status & 128) = 0 
	AND INVOICEABSTRACT.invoicedate BETWEEN @FROMDATE AND @TODATE
	group by INVOICEDETAIL.product_code,ITEMS.PRODUCTNAME


END





