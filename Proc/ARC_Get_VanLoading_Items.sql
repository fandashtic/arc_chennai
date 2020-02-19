--exec ARC_Get_VanLoading_Items '2020-01-21 00:00:00','2020-01-21 23:59:59','TN66AB9220-AS-01','%'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_VanLoading_Items')
BEGIN
    DROP PROC [ARC_Get_VanLoading_Items]
END
GO
CREATE procedure [dbo].[ARC_Get_VanLoading_Items] (@FromDATE DATETIME,@ToDATE DATETIME,@Van Nvarchar(255),@UOM Nvarchar(10) = '%')
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

	Exec SP_ARC_ResolveProduct_Mappings

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
	ISNULL(CAST((Case When (Cast((cast(FreeQuantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) = 0 Then Null Else (Cast((cast(FreeQuantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) End)AS INT), 0) [Free CFC],	
	ISNULL(CAST(((FreeQuantity - (Cast((cast(FreeQuantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int) * cast(UOM1 as Decimal(18,6)))) / UOM2) AS INT), 0) [Free Loose Pack] ,
	ISNULL(CAST(CAST((ISNULL(FreeQuantity, 0) / ISNULL(UOM2, 1)) as Decimal(18,6))AS INT), 0) [Total Free Packs],

	ISNULL(CAST((Case When (Cast((cast(SalableQuantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) = 0 Then Null Else (Cast((cast(SalableQuantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) End)AS INT), 0) [Salable CFC],
	ISNULL(CAST(((SalableQuantity - (Cast((cast(SalableQuantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int) * cast(UOM1 as Decimal(18,6)))) / UOM2)AS INT), 0) [Salable Loose Pack] , 	
	ISNULL(CAST(CAST((ISNULL(SalableQuantity, 0) / ISNULL(UOM2, 1)) as Decimal(18,6))AS INT), 0) [Total Salable Packs]
	Into #Restult
	From #temp WITH (NOLOCK)

	SELECT *, 
	ISNULL([Free CFC], 0) + ISNULL([Salable CFC], 0) [Total CFC], 
	ISNULL([Free Loose Pack], 0) +  ISNULL([Salable Loose Pack], 0) [Total Loose Pack], 
	ISNULL([Total Free Packs], 0) + ISNULL([Total Salable Packs], 0) [Total Packs],
	NULL [Wapas Packs],
	NULL [Wapas CFC]
	INTO #WithTotals
	FROM #Restult WITH (NOLOCK)

	SELECt * FROM (
	SELECt 1 ID, * FROM #WithTotals
	UNION ALL
	SELECT 2 ID, '','','','',	
	ISNULL(SUM([Free CFC]), 0), 
	ISNULL(SUM([Free Loose Pack]), 0), 
	ISNULL(SUM([Total Free Packs]), 0), 
	ISNULL(SUM([Salable CFC]), 0), 
	ISNULL(SUM([Salable Loose Pack]), 0), 
	ISNULL(SUM([Total Salable Packs]), 0), 

	ISNULL(SUM([Total CFC]), 0), 
	ISNULL(SUM([Total Loose Pack]), 0), 
	ISNULL(SUM([Total Packs]), 0), 

	ISNULL(SUM(ISNULL([Wapas Packs], 0)), 0), 
	ISNULL(SUM(ISNULL([Wapas CFC], 0)), 0)
	FROM #WithTotals  WITH (NOLOCK)) S
	Order by S.ID, S.Van, S.Category Asc

	Drop table #temp
	Drop table #Data
End
SET QUOTED_IDENTIFIER OFF
GO

