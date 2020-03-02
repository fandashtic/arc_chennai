 --Select * from V_ARC_SaleReturn_ItemDetails Where dbo.StripTimeFromDate(InvoiceDate) Between '01-Jan-2020' And '04-Jan-2020'
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_SaleReturn_ItemDetails')
BEGIN
    DROP VIEW V_ARC_SaleReturn_ItemDetails
END
GO
Create View V_ARC_SaleReturn_ItemDetails
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
	IA.Balance,
	IA.InvoiceType,	
	IA.RoundOffAmount,
	IA.DeliveryStatus,	
	IA.DeliveryDate,
	IA.ReferenceNumber,
	IA.SRInvoiceID,
	IA.NewInvoiceReference,
	case When (Status & 32) <> 0 Then 'Damages' Else 'Salable' End [Type],  
	Case Status & 128 When 0 Then N'' Else 'Cancelled' End [Status], 
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
Where IA.InvoiceType in(4)
AND ISNULL(IA.Status,0) & 128 = 0
--And dbo.StripTimeFromDate(IA.InvoiceDate) Between '01-Jan-2020' And '01-Jan-2020'
And IA.InvoiceID = ID.InvoiceID
GO
