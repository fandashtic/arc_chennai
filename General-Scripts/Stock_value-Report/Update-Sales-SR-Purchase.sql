-- Update Purchase Data
UPDATE T 
SET 
	T.Purchase = P.Quantity,
	T.Purchase_Rate = P.PurchasePrice,
	T.Purchase_Value = P.NetAmount,
	T.Purchase_Discount = P.Discount,
	T.Purchase_DiscPerUnit = P.DiscPerUnit,
	--T.Purchase_DISCTYPE = P.DISCTYPE,
	T.Purchase_InvDiscPerc = P.InvDiscPerc,
	T.Purchase_InvDiscAmtPerUnit = P.InvDiscAmtPerUnit,
	T.Purchase_InvDiscAmount = P.InvDiscAmount,
	T.Purchase_OtherDiscPerc = P.OtherDiscPerc,
	T.Purchase_OtherDiscAmtPerUnit = P.OtherDiscAmtPerUnit,
	T.Purchase_OtherDiscAmount = P.OtherDiscAmount
FROM TransactionByDay T WITH (NOLOCK)
JOIN (Select 
			BillDate,
			Product_Code,	
			Batch_Number,	
			SUM(Quantity) Quantity,
			MAX(PurchasePrice) PurchasePrice,
			MAX(Discount) Discount,
			MAX(DiscPerUnit) DiscPerUnit,
			MAX(InvDiscPerc) InvDiscPerc,
			SUM(InvDiscAmtPerUnit) InvDiscAmtPerUnit,
			SUM(InvDiscAmount) InvDiscAmount,	
			SUM(OtherDiscPerc) OtherDiscPerc,
			SUM(OtherDiscAmtPerUnit) OtherDiscAmtPerUnit,
			SUM(OtherDiscAmount) OtherDiscAmount,
			MAX(NetPTS) NetPTS,
			SUM(NetAmount) NetAmount
			from V_ARC_Purchase_ItemDetails WITH (NOLOCK)
			--Where Product_Code = '1786' and Batch_Number = '787190169Y-280' 
			Group By BillDate, Product_Code, Batch_Number) P
ON P.Product_Code = T.Product_Code AND CAST(P.Batch_Number AS NVARCHAR(255))= CAST(T.Batch_Number AS NVARCHAR(255))		
WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(P.BillDate)
AND ISNULL(T.IsDamage, 0) = 0
GO

-- Update Sales Return Data
UPDATE T 
SET 
	T.SaleReturn = P.Quantity,
	T.SaleReturn_PurchaseValue = P.PurchasePrice,
	T.SaleReturn_Value = P.SalePrice
FROM TransactionByDay T WITH (NOLOCK)
JOIN  (SELECT InvoiceDate, Product_Code, Batch_Number, SUM(Quantity) Quantity, MAX(PurchasePrice) PurchasePrice,  MAX(SalePrice) SalePrice 
FROM V_ARC_SaleReturn_ItemDetails WITH (NOLOCK) GROUP BY InvoiceDate, Product_Code, Batch_Number)P
ON P.Product_Code = T.Product_Code AND CAST(P.Batch_Number AS NVARCHAR(255))= CAST(T.Batch_Number AS NVARCHAR(255))
WHERE dbo.StripTimeFromDate(T.TransactionDate) = dbo.StripTimeFromDate(P.InvoiceDate)
AND ISNULL(T.IsDamage, 0) = 0		
GO

-- Update Sales Data
UPDATE T 
SET 
	T.Sales = P.Quantity,
	T.Sales_PurchaseValue = P.PurchasePrice,
	T.Sales_Value = P.SalePrice
FROM TransactionByDay T WITH (NOLOCK)
JOIN (SELECT InvoiceDate, Product_Code, Batch_Number, SUM(Quantity) Quantity, MAX(PurchasePrice) PurchasePrice,  MAX(SalePrice) SalePrice 
FROM V_ARC_Sale_ItemDetails WITH (NOLOCK) GROUP BY InvoiceDate, Product_Code, Batch_Number) P
ON P.Product_Code = T.Product_Code AND CAST(P.Batch_Number AS NVARCHAR(255))= CAST(T.Batch_Number AS NVARCHAR(255))
WHERE dbo.StripTimeFromDate(T.TransactionDate) = dbo.StripTimeFromDate(P.InvoiceDate)
AND ISNULL(T.IsDamage, 0) = 0	
GO
