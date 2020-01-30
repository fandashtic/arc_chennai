--Exec ARC_Update_StockOpeningClosing '2019-08-07 00:00:00.000' 
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_Update_StockOpeningClosing')
BEGIN
	DROP PROC [ARC_Update_StockOpeningClosing]
END
GO
CREATE procedure [dbo].[ARC_Update_StockOpeningClosing] (@TransactionDate DATETIME)
As
Begin
	PRINT ' Start ' + cast(@TransactionDate as varchar)

	Declare @Previous_TransactionDate DATETIME
	-- Update Opening Stock
	SET @Previous_TransactionDate = DATEADD(D, -1,@TransactionDate)
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
	
	UPDATE T 
	SET 
		T.Closing = ISNULL(T.Opening, 0) + 
		(ISNULL(T.Purchase, 0) +  ISNULL(T.TransferIn, 0) +  ISNULL(T.SaleReturn, 0)) -
		(ISNULL(T.Sales, 0) +  ISNULL(T.PruchaseReturn, 0) +  ISNULL(T.TransferOut, 0) +  ISNULL(T.Damage_Destroy, 0)),				
		T.Closing_Rate = 
						(Case 
							When ISNULL(Purchase_Rate, 0) > 0 THEN ISNULL(Purchase_Rate, 0) 
							When ISNULL(SaleReturn_Rate, 0) > 0 THEN ISNULL(SaleReturn_Rate, 0) 
							ELSE ISNULL(Opening_Rate, 0)
						END),
		T.Closing_Value = 

		ISNULL((ISNULL(T.Opening, 0) + 
		(ISNULL(T.Purchase, 0) +  ISNULL(T.TransferIn, 0) +  ISNULL(T.SaleReturn, 0)) -
		(ISNULL(T.Sales, 0) +  ISNULL(T.PruchaseReturn, 0) +  ISNULL(T.TransferOut, 0) +  ISNULL(T.Damage_Destroy, 0))), 0) *

		ISNULL((Case  
					When ISNULL(Purchase_Rate, 0) > 0 THEN ISNULL(Purchase_Rate, 0) 
					When ISNULL(SaleReturn_Rate, 0) > 0 THEN ISNULL(SaleReturn_Rate, 0) 
					ELSE ISNULL(Opening_Rate, 0)
				END), 0)


	FROM TransactionByDay T WITH (NOLOCK)
	WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)

	PRINT ' End ' + cast(@TransactionDate as varchar)
END
GO