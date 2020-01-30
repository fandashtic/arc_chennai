--Exec ARC_Update_TransactionByDay '2019-08-07 00:00:00.000' 
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_Update_TransactionByDay')
BEGIN
	DROP PROC [ARC_Update_TransactionByDay]
END
GO
CREATE procedure [dbo].[ARC_Update_TransactionByDay] (@TransactionDate DATETIME)
As
Begin
	PRINT @TransactionDate
	Declare @Previous_TransactionDate DATETIME
	DECLARE @Day INT
	SET @Day = DATEDIFF(day, (SELECT TOP 1 OpeningDate FROM SETUP WITH (NOLOCK)), Getdate())
	SET @Previous_TransactionDate = DATEADD(D, -1,@TransactionDate)

	--IF EXISTS (SELECT TOP 1 1 FROM TransactionByDay WITH (NOLOCK) WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate))
	--BEGIN
	--	DELETE D FROM TransactionByDay D WITH (NOLOCK) WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)
	--END

	--Insert Into TransactionByDay (TransactionDate, Product_Code,CategoryGroup,Brand,Varient,Category,Family,Batch_Code,Batch_Number)
	--select Distinct @TransactionDate, Product_Code,CategoryGroup,Brand,Varient,Category,Family,Batch_Code,Batch_Number from V_ARC_Items_BatchDetails WITH (NOLOCK)

	--SELECT Product_Code, Batch_Number, Quantity, PurchasePrice,
	--			 Discount, DiscPerUnit, DISCTYPE, InvDiscPerc, InvDiscAmtPerUnit,
	--			 InvDiscAmount, OtherDiscPerc, OtherDiscAmtPerUnit, OtherDiscAmount, NetPTS 
	--INTO #V_ARC_Purchase_ItemDetails
	--FROM V_ARC_Purchase_ItemDetails WITH (NOLOCK) 
	--WHERE dbo.StripTimeFromDate(BillDate) = dbo.StripTimeFromDate(@TransactionDate)
	--AND Product_Code = 'FD2125N' and Batch_Number = '06A300719-30'

	--SELECT Product_Code, Batch_Number, SUM(Quantity) Quantity, SUM(PurchasePrice) PurchasePrice, SUM(SalePrice) SalePrice 
	--INTO #V_ARC_SaleReturn_ItemDetails
	--FROM V_ARC_SaleReturn_ItemDetails WITH (NOLOCK) 
	--WHERE dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@TransactionDate)
	----AND Product_Code = 'FD2125N' and Batch_Number = '06A300719-30'
	--GROUP BY Product_Code, Batch_Number

	--SELECT Product_Code, Batch_Number, SUM(Quantity) Quantity, SUM(PurchasePrice) PurchasePrice, SUM(SalePrice) SalePrice 
	--INTO #V_ARC_Sale_ItemDetails
	--FROM V_ARC_Sale_ItemDetails WITH (NOLOCK) 
	--WHERE dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@TransactionDate)
	----AND Product_Code = 'FD2125N' and Batch_Number = '06A300719-30'
	--GROUP BY Product_Code, Batch_Number

	--SELECT * FROM #V_ARC_Purchase_ItemDetails
	--SELECT * FROM #V_ARC_SaleReturn_ItemDetails
	--SELECT * FROM #V_ARC_Sale_ItemDetails

	--RETURN;

	-- Update OPening Data
	IF(@Day = 0)
	BEGIN
		UPDATE T 
		SET 
			T.Opening = 0,
			T.Opening_Rate = 0,
			T.Opening_Value = 0
		FROM TransactionByDay T WITH (NOLOCK)
		WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)
	END
	ELSE
	BEGIN
		SELECT * INTO #TransactionByDay_Previous
		FROM TransactionByDay T WITH (NOLOCK)
		WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@Previous_TransactionDate)

		UPDATE T 
		SET 
			T.Opening = ISNULL(P.Closing, 0),
			T.Opening_Rate = ISNULL(P.Closing_Rate, 0),
			T.Opening_Value = ISNULL(P.Closing_Value, 0)
		FROM TransactionByDay T WITH (NOLOCK)
		JOIN  #TransactionByDay_Previous P
		ON P.Product_Code = T.Product_Code AND CAST(P.Batch_Number AS NVARCHAR(255))= CAST(T.Batch_Number AS NVARCHAR(255))
		WHERE dbo.StripTimeFromDate(T.TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)

		DROP TABLE #TransactionByDay_Previous
	END

	-- Update Purchase Data

	--IF EXISTS(SELECT Top 1 1 FROM #V_ARC_Purchase_ItemDetails)
	--BEGIN 
	--	UPDATE T 
	--	SET 
	--		T.Purchase = P.Quantity,
	--		T.Purchase_Rate = P.PurchasePrice,
	--		T.Purchase_Value = P.NetPTS,
	--		T.Purchase_Discount = P.Discount,
	--		T.Purchase_DiscPerUnit = P.DiscPerUnit,
	--		T.Purchase_DISCTYPE = P.DISCTYPE,
	--		T.Purchase_InvDiscPerc = P.InvDiscPerc,
	--		T.Purchase_InvDiscAmtPerUnit = P.InvDiscAmtPerUnit,
	--		T.Purchase_InvDiscAmount = P.InvDiscAmount,
	--		T.Purchase_OtherDiscPerc = P.OtherDiscPerc,
	--		T.Purchase_OtherDiscAmtPerUnit = P.OtherDiscAmtPerUnit,
	--		T.Purchase_OtherDiscAmount = P.OtherDiscAmount

	--	FROM TransactionByDay T WITH (NOLOCK)
	--	JOIN #V_ARC_Purchase_ItemDetails P
	--	ON P.Product_Code = T.Product_Code AND CAST(P.Batch_Number AS NVARCHAR(255))= CAST(T.Batch_Number AS NVARCHAR(255))		
	--	WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)
	--	AND ISNULL(T.IsDamage, 0) = 0
	--END
	
	---- Update Sales Return Data
	--IF EXISTS(SELECT Top 1 1 FROM #V_ARC_SaleReturn_ItemDetails)
	--BEGIN 
	--	UPDATE T 
	--	SET 
	--		T.SaleReturn = P.Quantity,
	--		T.SaleReturn_PurchaseValue = P.PurchasePrice,
	--		T.SaleReturn_Value = P.SalePrice

	--	FROM TransactionByDay T WITH (NOLOCK)
	--	JOIN  #V_ARC_SaleReturn_ItemDetails P
	--	ON P.Product_Code = T.Product_Code AND CAST(P.Batch_Number AS NVARCHAR(255))= CAST(T.Batch_Number AS NVARCHAR(255))
	--	WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)
	--	AND ISNULL(T.IsDamage, 0) = 0
	--END

	---- Update Sales Data
	--IF EXISTS(SELECT Top 1 1 FROM #V_ARC_Sale_ItemDetails)
	--BEGIN
	--	UPDATE T 
	--	SET 
	--		T.SaleReturn = P.Quantity,
	--		T.SaleReturn_PurchaseValue = P.PurchasePrice,
	--		T.SaleReturn_Value = P.SalePrice

	--	FROM TransactionByDay T WITH (NOLOCK)
	--	JOIN #V_ARC_Sale_ItemDetails P
	--	ON P.Product_Code = T.Product_Code AND CAST(P.Batch_Number AS NVARCHAR(255))= CAST(T.Batch_Number AS NVARCHAR(255))
	--	WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)
	--	AND ISNULL(T.IsDamage, 0) = 0
	--END

	UPDATE T 
	SET 
		T.Closing = ISNULL(T.Opening, 0) + 
		(ISNULL(T.Purchase, 0) +  ISNULL(T.TransferIn, 0) +  ISNULL(T.SaleReturn, 0)) -
		(ISNULL(T.Sales, 0) +  ISNULL(T.PruchaseReturn, 0) +  ISNULL(T.TransferOut, 0) +  ISNULL(T.Damage_Destroy, 0)),				
		T.Closing_Rate = Case When ISNULL(T.Purchase_Rate, 0) > 0 THEN ISNULL(T.Purchase_Rate, 0) ELSE ISNULL(T.Opening_Rate, 0) END,
		T.Closing_Value = 
		(ISNULL(T.Opening, 0) + 
		(ISNULL(T.Purchase, 0) +  ISNULL(T.TransferIn, 0) +  ISNULL(T.SaleReturn, 0)) -
		(ISNULL(T.Sales, 0) +  ISNULL(T.PruchaseReturn, 0) +  ISNULL(T.TransferOut, 0) +  ISNULL(T.Damage_Destroy, 0))) *
		(Case When ISNULL(T.Purchase_Rate, 0) > 0 THEN ISNULL(T.Purchase_Rate, 0) ELSE ISNULL(T.Opening_Rate, 0) END)

	FROM TransactionByDay T WITH (NOLOCK)
	WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)

	--select 1, * 
	--FROM TransactionByDay T WITH (NOLOCK)
	--WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)
	--AND T.Product_Code = 'FD2125N' AND T.Batch_Number = '06A300719-30'
	Print @TransactionDate
END
GO