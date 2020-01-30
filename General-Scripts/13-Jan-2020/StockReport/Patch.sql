IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'DeliveryDetails')
BEGIN
	DROP TABLE DeliveryDetails
END
GO
Create Table DeliveryDetails
(
	Id Int Identity(1,2),
	Date DateTime,
	CustomerID Nvarchar(255),
	InvoiceId int,
	Person Nvarchar(255),
	TruckNo Nvarchar(255),
	Status Int Default 0
)
GO
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'TransactionByDay')
BEGIN
	DROP TABLE [TransactionByDay]
END
GO
CREATE TABLE [dbo].[TransactionByDay](
	[TransactionDate] [datetime] NULL,
	[Product_Code] [nvarchar](255) NULL,
	[CategoryGroup] [nvarchar](255) NULL,
	[Brand] [nvarchar](255) NULL,
	[Varient] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[Family] [nvarchar](255) NULL,
	[Batch_Code] [nvarchar](255) NULL,
	[Batch_Number] [nvarchar](255) NULL,
	[Expairy] [datetime] NULL,
	[UOMQty] [decimal](18, 6) NULL, 
	[IsDamage] [Int] NULL, 
	[DamagesReason] [nvarchar](255) NULL,
	[ReceivedAgeing] [int] NULL,
	[Opening] [decimal](18, 6) NULL,
	[Opening_Rate] [decimal](18, 6) NULL,
	[Opening_Value] [decimal](18, 6) NULL,
	[Purchase] [decimal](18, 6) NULL,
	[Purchase_Rate] [decimal](18, 6) NULL,
	[Purchase_Value] [decimal](18, 6) NULL,
	[Purchase_Discount] [decimal](18, 6) NULL,
	[Purchase_DiscPerUnit] [decimal](18, 6) NULL,
	[Purchase_DISCTYPE] [decimal](18, 6) NULL,
	[Purchase_InvDiscPerc] [decimal](18, 6) NULL,
	[Purchase_InvDiscAmtPerUnit] [decimal](18, 6) NULL,
	[Purchase_InvDiscAmount] [decimal](18, 6) NULL,
	[Purchase_OtherDiscPerc] [decimal](18, 6) NULL,
	[Purchase_OtherDiscAmtPerUnit] [decimal](18, 6) NULL,
	[Purchase_OtherDiscAmount] [decimal](18, 6) NULL,
	[TransferIn] [decimal](18, 6) NULL,
	[TransferIn_Rate] [decimal](18, 6) NULL,
	[TransferIn_Value] [decimal](18, 6) NULL,
	[SaleReturn] [decimal](18, 6) NULL,
	[SaleReturn_Rate] [decimal](18, 6) NULL,
	[SaleReturn_PurchaseValue] [decimal](18, 6) NULL,
	[SaleReturn_Value] [decimal](18, 6) NULL,
	[Sales] [decimal](18, 6) NULL,
	[Sales_Rate] [decimal](18, 6) NULL,
	[Sales_PurchaseValue] [decimal](18, 6) NULL,
	[Sales_Value] [decimal](18, 6) NULL,
	[PruchaseReturn] [decimal](18, 6) NULL,
	[PruchaseReturn_Rate] [decimal](18, 6) NULL,
	[PruchaseReturn_Value] [decimal](18, 6) NULL,
	[TransferOut] [decimal](18, 6) NULL,
	[TransferOut_Rate] [decimal](18, 6) NULL,
	[TransferOut_Value] [decimal](18, 6) NULL,
	[Damage_Destroy] [decimal](18, 6) NULL,
	[Damage_Destroy_Rate] [decimal](18, 6) NULL,
	[Damage_Destroy_Value] [decimal](18, 6) NULL,
	[Closing] [decimal](18, 6) NULL,
	[Closing_Rate] [decimal](18, 6) NULL,
	[Closing_Value] [decimal](18, 6) NULL
) ON [PRIMARY]
GO
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'fn_Arc_GetPaymentType')
BEGIN
    DROP FUNCTION [fn_Arc_GetPaymentType]
END
GO
CREATE  FUNCTION fn_Arc_GetPaymentType(@PaymentMode Int)    
RETURNS NVarchar(255)    
As    
Begin    
	Declare @PaymentType as Nvarchar(255)
	Set @PaymentType = (select Top 1 value from paymentmode Where PaymentType =@PaymentMode)
	RETURN ISNULL(@PaymentType , '--')   
End    
GO
 --Select * from V_ARC_Items_BatchDetails T WHERE T.Product_Code = 'FD2125N' AND CAST(T.Batch_Code AS VARCHAR(255)) = '06A300719-30'
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Items_BatchDetails')
BEGIN
    DROP VIEW V_ARC_Items_BatchDetails
END
GO
Create View V_ARC_Items_BatchDetails
AS
SELECT 
	I.Product_Code,
	I.ProductName,
	'' CategoryGroup,
	'' Brand,
	'' Varient,
	'' Category,	
	'' Family,
	B.Batch_Code,
	B.Batch_Number,
	B.Quantity,
	B.GRN_ID,
	B.Expiry,
	(CASE WHEN ISNULL(B.Damage, 0) > 0 THEN 1 ELSE 0 END) IsDamage,
	B.DamagesReason,
	B.UOMQty
from Items I WITH (NOLOCK)
FULL OUTER JOIN Batch_Products B WITH (NOLOCK) ON B.Product_Code = I.Product_Code
GO
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Purchase_ItemDetails')
BEGIN
    DROP VIEW V_ARC_Purchase_ItemDetails
END
GO
Create View V_ARC_Purchase_ItemDetails
AS
select DISTINCT
	BA.BillID,
	BA.GRNID,
	BA.BillDate,
	BA.CreationTime [BillRecivedDate],
	BA.PaymentDate,
	BA.ODNumber,
	BA.InvoiceReference,
	BD.Product_Code,
	BD.Batch [Batch_Number],
	BD.Quantity,
	BD.PurchasePrice,
	BD.Discount,
	BD.DiscPerUnit,
	BD.DISCTYPE,
	BD.InvDiscPerc,
	BD.InvDiscAmtPerUnit,
	BD.InvDiscAmount,
	BD.OtherDiscPerc,
	BD.OtherDiscAmtPerUnit,
	BD.OtherDiscAmount,
	BD.NetPTS
FROM BillAbstract BA WITH (NOLOCK)
JOIN BillDetail BD WITH (NOLOCK) ON BD.BillID = BA.BillID
--Where dbo.StripTimeFromDate(BA.BillDate) Between '01-Jan-2020' And '04-Jan-2020'
GO
 --Select * from V_ARC_Sale_ItemDetails Where dbo.StripTimeFromDate(InvoiceDate) Between '01-Jan-2020' And '01-Jan-2020'
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Sale_ItemDetails')
BEGIN
    DROP VIEW V_ARC_Sale_ItemDetails
END
GO
Create View V_ARC_Sale_ItemDetails
AS
Select Distinct 
	IA.InvoiceID,
	IA.InvoiceDate, 
	IA.GSTFullDocID,
	ID.Product_Code,
	ID.Batch_Code,
	ID.Batch_Number,
	ID.Quantity,
	ID.PurchasePrice,
	ID.SalePrice
From
InvoiceAbstract IA WITH (NOLOCK),
InvoiceDetail ID WITH (NOLOCK)
Where 
IA.InvoiceType in(1, 3)
And IA.InvoiceID = ID.InvoiceID
--And dbo.StripTimeFromDate(IA.InvoiceDate) Between '01-Jan-2020' And '01-Jan-2020'
Go
 --Select * from V_ARC_SaleReturn_ItemDetails Where dbo.StripTimeFromDate(InvoiceDate) Between '01-Jan-2020' And '04-Jan-2020'
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_SaleReturn_ItemDetails')
BEGIN
    DROP VIEW V_ARC_SaleReturn_ItemDetails
END
GO
Create View V_ARC_SaleReturn_ItemDetails
AS
Select Distinct 
	IA.InvoiceID,
	IA.InvoiceDate, 
	IA.GSTFullDocID,
	ID.Product_Code,
	ID.Batch_Code,
	ID.Batch_Number,
	ID.Quantity,
	ID.PurchasePrice,
	ID.SalePrice
From
InvoiceAbstract IA WITH (NOLOCK),
InvoiceDetail ID WITH (NOLOCK)
Where 
((IA.InvoiceType in(4) and isnull(IA.Status,0) & 128 = 0)
OR (IA.InvoiceType = 4 and isnull(IA.Status,0) & 32 = 0 and isnull(IA.Status,0) & 128 = 0))
--And dbo.StripTimeFromDate(IA.InvoiceDate) Between '01-Jan-2020' And '01-Jan-2020'
And IA.InvoiceID = ID.InvoiceID
GO
--Exec ARC_Update_TransactionByDay '2019-08-07 00:00:00.000' 
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_Update_TransactionByDay_Product')
BEGIN
	DROP PROC [ARC_Update_TransactionByDay_Product]
END
GO
CREATE procedure [dbo].[ARC_Update_TransactionByDay_Product] (@TransactionDate DATETIME, @Product_Code Nvarchar(255), @Batch_Number Nvarchar(255))
As
Begin
	PRINT @TransactionDate
	Declare @Previous_TransactionDate DATETIME
	DECLARE @Day INT
	SET @Day = DATEDIFF(day, (SELECT TOP 1 OpeningDate FROM SETUP WITH (NOLOCK)), Getdate())
	SET @Previous_TransactionDate = DATEADD(D, -1,@TransactionDate)

	SELECT Product_Code, Batch_Number, Quantity, PurchasePrice,
				 Discount, DiscPerUnit, DISCTYPE, InvDiscPerc, InvDiscAmtPerUnit,
				 InvDiscAmount, OtherDiscPerc, OtherDiscAmtPerUnit, OtherDiscAmount, NetPTS 
	INTO #V_ARC_Purchase_ItemDetails
	FROM V_ARC_Purchase_ItemDetails WITH (NOLOCK) 
	WHERE dbo.StripTimeFromDate(BillDate) = dbo.StripTimeFromDate(@TransactionDate)
	AND Product_Code = @Product_Code and Batch_Number = @Batch_Number

	SELECT Product_Code, Batch_Number, SUM(Quantity) Quantity, SUM(PurchasePrice) PurchasePrice, SUM(SalePrice) SalePrice 
	INTO #V_ARC_SaleReturn_ItemDetails
	FROM V_ARC_SaleReturn_ItemDetails WITH (NOLOCK) 
	WHERE dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@TransactionDate)
	AND Product_Code = @Product_Code and Batch_Number = @Batch_Number
	GROUP BY Product_Code, Batch_Number

	SELECT Product_Code, Batch_Number, SUM(Quantity) Quantity, SUM(PurchasePrice) PurchasePrice, SUM(SalePrice) SalePrice 
	INTO #V_ARC_Sale_ItemDetails
	FROM V_ARC_Sale_ItemDetails WITH (NOLOCK) 
	WHERE dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@TransactionDate)
	AND Product_Code = @Product_Code and Batch_Number = @Batch_Number
	GROUP BY Product_Code, Batch_Number
	
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
		AND Product_Code = @Product_Code and Batch_Number = @Batch_Number

		UPDATE T 
		SET 
			T.Opening = ISNULL(P.Closing, 0),
			T.Opening_Rate = ISNULL(P.Closing_Rate, 0),
			T.Opening_Value = ISNULL(P.Closing_Value, 0)
		FROM TransactionByDay T WITH (NOLOCK)
		JOIN  #TransactionByDay_Previous P
		ON P.Product_Code = T.Product_Code AND CAST(P.Batch_Number AS NVARCHAR(255))= CAST(T.Batch_Number AS NVARCHAR(255))
		WHERE dbo.StripTimeFromDate(T.TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)
		AND T.Product_Code = @Product_Code and T.Batch_Number = @Batch_Number

		DROP TABLE #TransactionByDay_Previous
	END

	-- Update Purchase Data

	IF EXISTS(SELECT Top 1 1 FROM #V_ARC_Purchase_ItemDetails)
	BEGIN 
		UPDATE T 
		SET 
			T.Purchase = P.Quantity,
			T.Purchase_Rate = P.PurchasePrice,
			T.Purchase_Value = P.NetPTS,
			T.Purchase_Discount = P.Discount,
			T.Purchase_DiscPerUnit = P.DiscPerUnit,
			T.Purchase_DISCTYPE = P.DISCTYPE,
			T.Purchase_InvDiscPerc = P.InvDiscPerc,
			T.Purchase_InvDiscAmtPerUnit = P.InvDiscAmtPerUnit,
			T.Purchase_InvDiscAmount = P.InvDiscAmount,
			T.Purchase_OtherDiscPerc = P.OtherDiscPerc,
			T.Purchase_OtherDiscAmtPerUnit = P.OtherDiscAmtPerUnit,
			T.Purchase_OtherDiscAmount = P.OtherDiscAmount

		FROM TransactionByDay T WITH (NOLOCK)
		JOIN #V_ARC_Purchase_ItemDetails P
		ON P.Product_Code = T.Product_Code AND CAST(P.Batch_Number AS NVARCHAR(255))= CAST(T.Batch_Number AS NVARCHAR(255))		
		WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)
		AND ISNULL(T.IsDamage, 0) = 0
		AND T.Product_Code = @Product_Code and T.Batch_Number = @Batch_Number
	END
	
	-- Update Sales Return Data
	IF EXISTS(SELECT Top 1 1 FROM #V_ARC_SaleReturn_ItemDetails)
	BEGIN 
		UPDATE T 
		SET 
			T.SaleReturn = P.Quantity,
			T.SaleReturn_PurchaseValue = P.PurchasePrice,
			T.SaleReturn_Value = P.SalePrice

		FROM TransactionByDay T WITH (NOLOCK)
		JOIN  #V_ARC_SaleReturn_ItemDetails P
		ON P.Product_Code = T.Product_Code AND CAST(P.Batch_Number AS NVARCHAR(255))= CAST(T.Batch_Number AS NVARCHAR(255))
		WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)
		AND ISNULL(T.IsDamage, 0) = 0
		AND T.Product_Code = @Product_Code and T.Batch_Number = @Batch_Number
	END

	-- Update Sales Data
	IF EXISTS(SELECT Top 1 1 FROM #V_ARC_Sale_ItemDetails)
	BEGIN
		UPDATE T 
		SET 
			T.Sales = P.Quantity,
			T.Sales_PurchaseValue = P.PurchasePrice,
			T.Sales_Value = P.SalePrice

		FROM TransactionByDay T WITH (NOLOCK)
		JOIN #V_ARC_Sale_ItemDetails P
		ON P.Product_Code = T.Product_Code AND CAST(P.Batch_Number AS NVARCHAR(255))= CAST(T.Batch_Number AS NVARCHAR(255))
		WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)
		AND ISNULL(T.IsDamage, 0) = 0
		AND T.Product_Code = @Product_Code and T.Batch_Number = @Batch_Number
	END

	UPDATE T 
	SET 
		T.Closing = ISNULL(T.Opening, 0) + 
		(ISNULL(T.Purchase, 0) +  ISNULL(T.TransferIn, 0) +  ISNULL(T.SaleReturn, 0)) -
		(ISNULL(T.Sales, 0) +  ISNULL(T.PruchaseReturn, 0) +  ISNULL(T.TransferOut, 0) +  ISNULL(T.Damage_Destroy, 0)),				
		T.Closing_Rate = Case When ISNULL(T.Purchase_Rate, 0) > 0 THEN ISNULL(T.Purchase_Rate, 0) ELSE ISNULL(T.Opening_Rate, 0) END,
		T.Closing_Value = Case When ISNULL(T.Purchase_Value, 0) > 0 THEN ISNULL(T.Purchase_Value, 0) ELSE ISNULL(T.Opening_Value, 0) END

	FROM TransactionByDay T WITH (NOLOCK)
	WHERE dbo.StripTimeFromDate(TransactionDate) = dbo.StripTimeFromDate(@TransactionDate)
	AND T.Product_Code = @Product_Code and T.Batch_Number = @Batch_Number

	DROP TABLE #V_ARC_Purchase_ItemDetails
	DROP TABLE #V_ARC_SaleReturn_ItemDetails
	DROP TABLE #V_ARC_Sale_ItemDetails
END
GO

--Exec ARC_StockValue 2019
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_StockValue')
BEGIN
	DROP PROC [ARC_StockValue]
END
GO
CREATE procedure [dbo].[ARC_StockValue] (@StartYear Char(5) = 2019)
As
Begin
	Declare @MonthEndDates AS TAble([Year] Nvarchar(5), [MonthName] Nvarchar(50), MonthEndDate DATETIME)

	Declare @I AS int = 1
	Declare @IsYes AS int = 0
	Declare @Date AS DateTime
	While(@IsYes = 0)
	Begin
		Set @Date = DateAdd(d, -1, DateAdd(m, @i, '01-Jan-'+ @StartYear))
	
		IF(DATEDIFF(d, @Date, GETDATE()) <= 1)
		BEGIN
			Set @Date = DateAdd(d, -1, Getdate())
		END

		Insert Into @MonthEndDates([Year], [MonthName], MonthEndDate)

		Select DATENAME(year,@Date), DATENAME(month,@Date), @Date
		IF(MONTH(GETDATE()) = MONTH(@Date) AND  YEAR(GETDATE()) = YEAr(@Date))
		BEGIN
			SET @IsYes = 1
		END

		SET @i = @i + 1
	END

	select 1, M.Year, M.MonthName, T.TransactionDate,
	T.Product_Code,
	I.ProductName,
	T.CategoryGroup,
	T.Brand,
	T.Varient,
	T.Category,
	T.Family,
	T.Batch_Code,
	T.Batch_Number,
	T.Expairy,
	T.UOMQty,
	T.IsDamage,
	T.DamagesReason,
	T.ReceivedAgeing,
	T.Opening,
	T.Opening_Rate,
	T.Opening_Value,
	T.Purchase,
	T.Purchase_Rate,
	T.Purchase_Value,
	T.Purchase_Discount,
	T.Purchase_DiscPerUnit,
	T.Purchase_DISCTYPE,
	T.Purchase_InvDiscPerc,
	T.Purchase_InvDiscAmtPerUnit,
	T.Purchase_InvDiscAmount,
	T.Purchase_OtherDiscPerc,
	T.Purchase_OtherDiscAmtPerUnit,
	T.Purchase_OtherDiscAmount,
	T.TransferIn,
	T.TransferIn_Rate,
	T.TransferIn_Value,
	T.SaleReturn,
	T.SaleReturn_Rate,
	T.SaleReturn_PurchaseValue,
	T.SaleReturn_Value,
	T.Sales,
	T.Sales_Rate,
	T.Sales_PurchaseValue,
	T.Sales_Value,
	T.PruchaseReturn,
	T.PruchaseReturn_Rate,
	T.PruchaseReturn_Value,
	T.TransferOut,
	T.TransferOut_Rate,
	T.TransferOut_Value,
	T.Damage_Destroy,
	T.Damage_Destroy_Rate,
	T.Damage_Destroy_Value,
	T.Closing,
	T.Closing_Rate,
	T.Closing_Value
	from TransactionByDay T With (NOlock) 
	JOiN @MonthEndDates M ON dbo.StripTimeFromDate(M.MonthEndDate) = dbo.StripTimeFromDate(T.TransactionDate)
	JOiN Items I With (NOlock) On I.Product_Code = T.Product_Code
	Order By T.TransactionDate, I.ProductName ASC

	Delete From @MonthEndDates
END
GO
-- Verify that the stored procedure does not already exist.  
IF OBJECT_ID ( 'usp_GetErrorInfo', 'P' ) IS NOT NULL   
    DROP PROCEDURE usp_GetErrorInfo;  
GO  
  
-- Create procedure to retrieve error information.  
CREATE PROCEDURE usp_GetErrorInfo  
AS  
SELECT  
    ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS ErrorMessage;  
GO 

Truncate table TransactionByDay
Declare @TransactionDate DATETIME
DECLARE @Days INT
DECLARE @Day INT
SET @Day = 1
Set @TransactionDate = '2019-07-01 00:00:00.000'
SET @Days = DATEDIFF(day, @TransactionDate, Getdate())

While(@Day <= @Days)
BEGIN
	Insert Into TransactionByDay (TransactionDate, Product_Code,CategoryGroup,Brand,Varient,Category,Family,Batch_Code,Batch_Number)
	select Distinct @TransactionDate, Product_Code,CategoryGroup,Brand,Varient,Category,Family,Batch_Code,Batch_Number from V_ARC_Items_BatchDetails WITH (NOLOCK)
	--Where Product_Code = '1636' and Batch_Number = '7H1190187T-150'

	SET @Day = @Day + 1
	Set @TransactionDate = DATEADD(D,1,@TransactionDate)
END
GO

IF OBJECT_ID('tempdb..#BATCH') IS NOT NULL   DROP TABLE #BATCH

Create Table #BATCH(Id int Identity(1,1), Product_Code Nvarchar(255) , Batch_Number  Nvarchar(255))
Insert INTO #BATCH (Product_Code, Batch_Number)
select Distinct Product_Code, Batch_Number 
from Batch_Products Where ISNULL(UOMQty ,0) > 0
--AND Product_Code = '1003' and Batch_Number = '722190141M-20'

--select * from #BATCH

Declare @Id as Int
Set @Id = 1
Declare  @Product_Code Nvarchar(255)
Declare @Batch_Number Nvarchar(255)

While(@Id <= (Select Max(Id) From #BATCH))
BEGIN
	SELECT @Product_Code = Product_Code, @Batch_Number = Batch_Number FROM #BATCH Where Id =@Id

	Declare @TransactionDate DATETIME
	DECLARE @Days INT
	DECLARE @Day INT

	SET @Day = 1
	Set @TransactionDate = '2019-07-01 00:00:00.000'
	SET @Days = DATEDIFF(day, @TransactionDate, Getdate())

	While(@Day <= @Days)
	BEGIN
		Print @TransactionDate
		BEGIN TRY
			Exec ARC_Update_TransactionByDay_Product @TransactionDate, @Product_Code, @Batch_Number
		END TRY
		BEGIN CATCH
			EXECUTE usp_GetErrorInfo;
		END CATCH
		SET @Day = @Day + 1
		Set @TransactionDate = DATEADD(D,1,@TransactionDate)
	END

	SET @Id = @Id + 1
END

Drop Table #BATCH
GO

