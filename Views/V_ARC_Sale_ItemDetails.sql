 --Select * from V_ARC_Sale_ItemDetails Where dbo.StripTimeFromDate(InvoiceDate) Between '01-Jan-2020' And '01-Jan-2020'
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Sale_ItemDetails')
BEGIN
    DROP VIEW V_ARC_Sale_ItemDetails
END
GO
Create View V_ARC_Sale_ItemDetails
AS
Select  
	IA.InvoiceID,
	IA.InvoiceDate, 
	IA.CustomerID,
	IA.SalesmanID,
	IA.BeatID,
	IA.GSTFullDocID,
	IA.DocSerialType,
	IA.DocReference,
	IA.GoodsValue,
	IA.GrossValue,
	IA.NetValue,
	IA.InvoiceType,
	IA.Status,
	ID.Product_Code,
	ID.Batch_Code,
	ID.Batch_Number,
	ID.Quantity,
	ID.PTS PurchasePrice,
	ID.SalePrice,
	(ISNULL(ID.Quantity, 0) * ISNULL(ID.SalePrice, 0)) [GrossAmount],
	((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)- (((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100)) [TaxableValue],
	ID.TaxAmount,
	ID.Amount,
	ID.STPayable,
	ROUND(ID.Amount - ((ISNULL(ID.Quantity, 0) * ISNULL(ID.SalePrice, 0)) + ISNULL(ID.TaxAmount, 0)), 0)  [AmountDiff]
From
InvoiceAbstract IA WITH (NOLOCK),
InvoiceDetail ID WITH (NOLOCK)
Where ((isnull(IA.Status,0) & 32) = 0 AND (IA.Status & 128) = 0) AND IA.InvoiceType in (1,2,3)    
And IA.InvoiceID = ID.InvoiceID
--And dbo.StripTimeFromDate(IA.InvoiceDate) Between '01-Jan-2020' And '01-Jan-2020'
Go