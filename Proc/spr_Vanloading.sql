--exec spr_Vanloading '2020-01-21 00:00:00','2020-01-21 23:59:59','TN66AB9220-AS-01','%'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'spr_Vanloading')
BEGIN
    DROP PROC [spr_Vanloading]
END
GO
CREATE procedure [dbo].[spr_Vanloading] (@FromDATE DATETIME,@ToDATE DATETIME,@Van Nvarchar(255),@UOM Nvarchar(10) = '%')
As
Begin
	Set DateFormat DMY
	Declare @VanList as Table (Van Nvarchar(255))

	If @Van = '%'
	Begin
		Insert Into @VanList Select Distinct Isnull(DocSerialType,'') From InvoiceAbstract Where Isnull(DocSerialType,'') <> ''
	End
	Else
	Begin
		Insert Into @VanList Select Distinct Isnull(DocSerialType,'') From InvoiceAbstract Where Isnull(DocSerialType,'') <> '' And Isnull(DocSerialType,'') Like @Van
	End

	CREATE TABLE #Temp(
	Van nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	ProductName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	FreeQuantity Decimal(18,6),
	SalableQuantity Decimal(18,6),
	UOM1 Decimal(18,6),
	UOM2 Decimal(18,6))

	SELECT IA.DocSerialType ,B.BrandName,ID.Product_Code,I.ProductName,
	(CASE WHEN ISNULL(ID.SalePrice , 0) = 0 THEN ID.Quantity ELSE 0 END) FreeQuantity,
	CASE WHEN ISNULL(ID.SalePrice, 0) = 0 THEN 0 ELSE ID.Quantity END SalableQuantity,
	I.UOM1_Conversion, I.UOM2_Conversion
	INTO #Data
	FROM InvoiceDetail ID WITH (NOLOCK),
	Items I WITH (NOLOCK),
	Brand B WITH (NOLOCK),
	InvoiceAbstract IA WITH (NOLOCK)
	WHERE ID.Product_Code = I.Product_Code And
	IA.DocSerialType in (Select Distinct Van From @VanList) And
	ID.InvoiceID = IA.InvoiceID And
	Convert(Nvarchar(10),IA.InvoiceDate,103) between @Fromdate and @Todate And
	(IA.Status & 128) = 0 AND
	IA.InvoiceType in (1,3) AND
	I.BrandID = B.BrandID


	Insert Into #Temp
	SELECT DocSerialType ,BrandName,Product_Code,ProductName,
	SUM(FreeQuantity) FreeQuantity,
	SUM(SalableQuantity) SalableQuantity,
	UOM1_Conversion, UOM2_Conversion
	FROM #Data WITH (NOLOCK)
	GROUP BY BrandName,Product_Code, ProductName,DocSerialType ,UOM1_Conversion, UOM2_Conversion
	order by BrandName


	select Van,Category,Product_Code ItemCode, ProductName ItemName, 
	(Case When (Cast((cast(FreeQuantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) = 0 Then Null Else (Cast((cast(FreeQuantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) End) [Salable CFC],	
	((FreeQuantity - (Cast((cast(FreeQuantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int) * cast(UOM1 as Decimal(18,6)))) / UOM2) [Salable Loose Pack] , 		
	CAST((ISNULL(FreeQuantity, 0) / ISNULL(UOM2, 1)) as Decimal(18,6)) [Total Salable Packs],

	(Case When (Cast((cast(SalableQuantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) = 0 Then Null Else (Cast((cast(SalableQuantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) End) [Free CFC],
	((SalableQuantity - (Cast((cast(SalableQuantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int) * cast(UOM1 as Decimal(18,6)))) / UOM2) [Free Loose Pack] , 	
	CAST((ISNULL(SalableQuantity, 0) / ISNULL(UOM2, 1)) as Decimal(18,6)) [Total Free Packs],

	NULL [Wapas Packs],
	NULL [Wapas CFC]
	Into #Restult
	From #temp WITH (NOLOCK)

	SELECt * FROM (
	SELECt 1 ID, * FROM #Restult
	UNION ALL
	SELECT 2 ID, '','','','',
	SUM([Salable CFC]), SUM([Salable Loose Pack]),SUM([Total Salable Packs]),
	SUM([Free CFC]), SUM([Free Loose Pack]),SUM([Total Free Packs]),
	SUM(ISNULL([Wapas Packs], 0)),SUM(ISNULL([Wapas CFC], 0)) FROM #Restult  WITH (NOLOCK)) S
	Order by S.ID, S.Van, S.Category Asc

	Drop table #temp
	Drop table #Data
End
SET QUOTED_IDENTIFIER OFF
GO

