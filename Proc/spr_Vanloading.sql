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
Quantity Decimal(18,6),
UOM1 Decimal(18,6),
UOM2 Decimal(18,6))

Insert Into #Temp
SELECT InvoiceAbstract.DocSerialType ,Brand.BrandName,InvoiceDetail.Product_Code,Items.ProductName,Sum(InvoiceDetail.Quantity),items.UOM1_Conversion, items.UOM2_Conversion
FROM InvoiceDetail,Items ,Brand , InvoiceAbstract
WHERE InvoiceDetail.Product_Code = Items.Product_Code And
InvoiceAbstract.DocSerialType in (Select Distinct Van From @VanList) And
InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID And
Convert(Nvarchar(10),InvoiceAbstract.InvoiceDate,103) between @Fromdate and @Todate And
(InvoiceAbstract.Status & 128) = 0 AND
InvoiceAbstract.InvoiceType in (1,3) AND
Items.BrandID = Brand.BrandID
GROUP BY Brand.BrandName,InvoiceDetail.Product_Code, Items.ProductName,InvoiceAbstract.DocSerialType ,items.UOM1_Conversion, items.UOM2_Conversion
order by Brand.BrandName

If @UOM <> N'%'
Begin
	Declare @TempUOM As Table(ID Int Identity(1,1),
	Van nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
	Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
	Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
	ProductName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
	Quantity Decimal(18,6),
	UOM1 Decimal(18,6),
	UOM2 Decimal(18,6))

	Declare @VanName as Nvarchar(255)
	Declare @TotalVanName as Nvarchar(255)

	Declare Cur_van Cursor for
	Select Distinct Van From #Temp Where isnull(Van,'') <> ''
	Open Cur_van
	Fetch from Cur_van into @VanName
	While @@fetch_status =0
		Begin

			Insert Into @TempUOM
			select Van,Category,Product_Code ItemCode, ProductName ItemName, 
			(Case When (Cast((cast(Quantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) = 0 Then Null Else (Cast((cast(Quantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) End) CFC,
			--(Case When Category = 'MT' Then Quantity Else 
			((Quantity - (Cast((cast(Quantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int) * cast(UOM1 as Decimal(18,6)))) / UOM2) 
			--End) 
			[Loose Pack] , 
			--(Case When Category = 'MT' Then Quantity Else 
			cast((Quantity / UOM2) as Decimal(18,6)) 
			--End) 
			[Total Packs] From #temp
			Where Isnull( (Case When (Cast((cast(Quantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) = 0 Then Null Else (Cast((cast(Quantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) End) ,0) <> 0
			And Van = @VanName Order By Category
			
			Set @TotalVanName = 'SUB Total Of ' + @VanName + ' :'
			Insert Into @TempUOM(Van,Quantity,UOM1,UOM2)
			Select @TotalVanName,Sum(isnull(Quantity,0)),Sum(isnull(UOM1,0)),Sum(isnull(UOM2,0)) From @TempUOM
			Where Van = @VanName 
			Group By Van
			Set @TotalVanName = ''

			Fetch Next from Cur_van into @VanName
		End
	Close Cur_van
	Deallocate Cur_van


	Insert Into @TempUOM(Van,Quantity,UOM1,UOM2)
	Select 'Grand Total :',Sum(isnull(Quantity,0)),Sum(isnull(UOM1,0)),Sum(isnull(UOM2,0)) From @TempUOM
	Where Van Like 'Total Of%'

	Select * From @TempUOM Order By ID
	Delete From @TempUOM
End
Else
Begin
	select Van,Category,Product_Code ItemCode, ProductName ItemName, 
	(Case When (Cast((cast(Quantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) = 0 Then Null Else (Cast((cast(Quantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int)) End) CFC,	
	((Quantity - (Cast((cast(Quantity as Decimal(18,6)) / Cast(UOM1 as Decimal(18,6))) as Int) * cast(UOM1 as Decimal(18,6)))) / UOM2) [Loose Pack] , 	
	CAST((ISNULL(Quantity, 0) / ISNULL(UOM2, 1)) as Decimal(18,6)) [Total Packs],
	NULL [Wapas Packs],
	NULL [Wapas CFC]
	Into #Restult
	From #temp WITH (NOLOCK)

	SELECt * FROM (
	SELECt 1 ID, * FROM #Restult
	UNION ALL
	SELECT 2 ID, '','','','',SUM(CFC), SUM([Loose Pack]),SUM([Total Packs]),SUM(ISNULL([Wapas Packs], 0)),SUM(ISNULL([Wapas CFC], 0)) FROM #Restult  WITH (NOLOCK)) S
	Order by S.ID, S.Van, S.Category Asc
End

Drop table #temp
End
SET QUOTED_IDENTIFIER OFF
GO

