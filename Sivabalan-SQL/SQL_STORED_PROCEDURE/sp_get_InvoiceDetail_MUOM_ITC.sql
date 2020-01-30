Create PROCEDURE sp_get_InvoiceDetail_MUOM_ITC(@INVOICENO INT)  
AS
BEGIN
	SELECT InvoiceDetail.Product_Code, Items.ProductName, NULL, InvoiceDetail.Batch_Number,   
	ISNULL(SUM(InvoiceDetail.UOMQty), 0), InvoiceDetail.SalePrice,  
	ISNULL(MAX(InvoiceDetail.TaxCode), 0) + ISNULL(MAX(InvoiceDetail.TaxCode2), 0),   
	ISNULL(MAX(InvoiceDetail.DiscountPercentage), 0),  
	ISNULL(SUM(InvoiceDetail.DiscountValue), 0), ISNULL(SUM(InvoiceDetail.Amount), 0),  
	ISNULL(MAX(InvoiceDetail.TaxSuffered), 0),  
	ISNULL(MAX(InvoiceDetail.TaxSuffered), 0),  
	IsNull(UOM.Description, N''), InvoiceDetail.MRP,  
	ISNULL(MAX(InvoiceDetail.SchemeID), 0) SCHEMEID,
	ISNULL(MAX(InvoiceDetail.SPLCATSchemeID), 0) SPLCATSCHEMEID,
	ISNULL(MAX(InvoiceDetail.FREESERIAL), 0) FREESERIAL,      
	ISNULL(MAX(InvoiceDetail.SPLCATSERIAL), N'') SPLCATSERIAL,      
	ISNULL(AVG(InvoiceDetail.SchemeDiscPercent), 0) SCHEMEDISCPERCENT,      
	ISNULL(SUM(InvoiceDetail.SchemeDiscAmount), 0) SCHEMEDISCAMOUNT,      
	ISNULL(AVG(InvoiceDetail.SPLCATDiscPercent), 0) SPLCATDISCPERCENT,      
	ISNULL(SUM(InvoiceDetail.SPLCATDiscAmount), 0) SPLCATDISCAMOUNT,  
	ISNULL(MAX(InvoiceDetail.SpecialCategoryScheme), 0) SPECIALCATEGORYSCHEME,  
	IsNull((Select SchemeType From Schemes Where Schemes.SchemeId = Min(InvoiceDetail.SchemeID)),N'') SCHEME_INDICATOR ,  
	IsNull((Select SchemeType From Schemes Where Schemes.SchemeId = Min(InvoiceDetail.SPLCATSchemeID)),N'') SPLCATSCHEME_INDICATOR,
	"SPBED" = InvoiceDetail.SalePriceBeforeExciseAmount, "ExciseDuty" = InvoiceDetail.ExciseDuty,  
	IsNull(Sum(TaxSuffAmount),0) TaxSuffAmount, IsNull(Sum(STCredit),0) STCredit, IsNull(Sum(STPayable),0) TaxAmount,
	InvoiceDetail.Serial, InvoiceDetail.OtherCG_Item, "UOMID" = UOM.UOM, "MRP" = Items.MRP, --isNull(TotSchemeAmount,0) TOTSCHEMEAMOUNT
	(ISNULL(SUM(InvoiceDetail.SchemeDiscAmount),0)  + ISNULL(SUM(InvoiceDetail.SPLCATDiscAmount),0)) as TOTSCHEMEAMOUNT ,TAXONQTY
	,isnull(Max(InvoiceDetail.TaxID),0) TAXCode
	FROM InvoiceDetail
	 inner join Items on  InvoiceDetail.Product_Code = Items.Product_Code
	 left outer join UOM  on  InvoiceDetail.UOM = UOM.UOM  
	WHERE InvoiceDetail.InvoiceID = @INVOICENO  
	   
	GROUP BY InvoiceDetail.Product_Code, Items.ProductName,   
	InvoiceDetail.Batch_Number, InvoiceDetail.UOM, UOM.Description, InvoiceDetail.salePrice,InvoiceDetail.MRP,InvoiceDetail.Serial,  
	InvoiceDetail.SalePriceBeforeExciseAmount, InvoiceDetail.ExciseDuty, InvoiceDetail.OtherCG_Item, UOM.UOM, Items.MRP,TotSchemeAmount,TAXONQTY  
	ORDER BY InvoiceDetail.Serial
END

