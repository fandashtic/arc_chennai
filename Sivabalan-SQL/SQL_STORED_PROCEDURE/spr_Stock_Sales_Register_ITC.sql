CREATE PROCEDURE spr_Stock_Sales_Register_ITC(@Manufacturer nvarchar(2550), @Item nvarchar(2550),
@UOM nvarchar(50), @FROMDATE datetime,@TODATE datetime )
as
Declare @Delimeter as Char(1)
Set @Delimeter=Char(15)
Declare @MLUOM NVarchar(50)
Set @MLUOM = dbo.LookupDictionaryItem(@UOM, Default)

If @UOM = N'Base UOM'
Set @UOM = N'Sales UOM'

Declare @tmpMfr table(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Declare @tmpItem table(ProductCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @Manufacturer='%'
Insert into @tmpMfr select Manufacturer_Name from Manufacturer
Else
Insert into @tmpMfr select * from dbo.sp_SplitIn2Rows(@Manufacturer,@Delimeter)

if @Item='%'
Insert into @tmpItem select product_code from Items
Else
Insert into @tmpItem select * from dbo.sp_SplitIn2Rows(@Item,@Delimeter)

declare @NEXT_DATE datetime
DECLARE @CORRECTED_DATE datetime
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS nvarchar) + '/' + CAST(DATEPART(mm, @TODATE) as nvarchar) + '/' + cast(DATEPART(yyyy, @TODATE) AS nvarchar)
SET  @NEXT_DATE = CAST(DATEPART(dd, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar) + '/' + CAST(DATEPART(mm, dbo.Fn_GetOperartingDate(GETDATE())) as nvarchar) + '/' + cast(DATEPART(yyyy, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar)

if @UOM = 'Sales UOM'  Or @UOM = 'UOM 1' Or @UOM = 'UOM 2'
begin
SELECT  Items.Product_Code + ',' + @MLUOM + ',' + @Manufacturer + ',' + @Item ,
"Item Code" = Items.Product_Code,
"Item Name" = ProductName,
"Category Name" = ItemCategories.Category_Name,
--"Sales UOM" = UOM.Description,    -- changed
"Sales UOM" = CASE @UOM WHEN 'Sales UOM' THEN  UOM.Description
WHEN 'UOM 1' THEN (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM1)
ELSE (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM2)
END,
--"Total Opening Quantity" = cast (ISNULL(Opening_Quantity, 0) as Decimal(18,6)),

"Total Opening Quantity" = CASE @UOM WHEN 'Sales UOM' THEN  cast (ISNULL(Opening_Quantity, 0) as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast (ISNULL(Opening_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast (ISNULL(Opening_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

--"Saleable Opening Quantity" = cast (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) as Decimal(18,6)),
"Saleable Opening Quantity" =
CASE @UOM	WHEN 'Sales UOM' THEN  cast (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

--"Free Opening Quantity" = cast (ISNULL(Free_Saleable_Quantity, 0) as Decimal(18,6)),
"Free Opening Quantity" =
CASE @UOM WHEN 'Sales UOM' THEN  cast (ISNULL(Free_Saleable_Quantity, 0) as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast (ISNULL(Free_Saleable_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast (ISNULL(Free_Saleable_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
--"Damage Opening Quantity" = cast (ISNULL(Damage_Opening_Quantity, 0) as Decimal(18,6)),
"Damage Opening Quantity" =
CASE @UOM	WHEN 'Sales UOM' THEN  cast (ISNULL(Damage_Opening_Quantity, 0) as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast (ISNULL(Damage_Opening_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast (ISNULL(Damage_Opening_Quantity, 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"(%c) Opening Value" = cast (ISNULL(Opening_Value, 0) as Decimal(18,6)),

"Purchase" =  CASE @UOM	WHEN 'Sales UOM' THEN cast ( ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)
FROM GRNAbstract, GRNDetail
WHERE
(IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And
(IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0 AND
GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And
GRNAbstract.GRNID = GRNDetail.GRNID AND
GRNDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast ( ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)
FROM GRNAbstract, GRNDetail
WHERE
(IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And
(IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0 AND
GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And
GRNAbstract.GRNID = GRNDetail.GRNID AND
GRNDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast ( ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)
FROM GRNAbstract, GRNDetail
WHERE
(IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And
(IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0 AND
GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And
GRNAbstract.GRNID = GRNDetail.GRNID AND
GRNDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"Free Purchase" =	 CASE @UOM	WHEN 'Sales UOM' THEN cast ( ISNULL((SELECT SUM(FreeQty)
FROM GRNAbstract, GRNDetail
WHERE
(IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And
(IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0 AND
GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And
GRNAbstract.GRNID = GRNDetail.GRNID AND
GRNDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))

WHEN 'UOM 1' THEN Cast(cast ( ISNULL((SELECT SUM(FreeQty)
FROM GRNAbstract, GRNDetail
WHERE
(IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And
(IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0 AND
GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And
GRNAbstract.GRNID = GRNDetail.GRNID AND
GRNDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))  / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE			   Cast(cast ( ISNULL((SELECT SUM(FreeQty)
FROM GRNAbstract, GRNDetail
WHERE
(IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And
(IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0 AND
GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And
GRNAbstract.GRNID = GRNDetail.GRNID AND
GRNDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))  / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"Total Sales Return" =  CASE @UOM	WHEN 'Sales UOM' THEN cast ( ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType In (4, 5, 6))
AND (InvoiceAbstract.Status & 128) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))

WHEN 'UOM 1' THEN Cast(cast ( ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType In (4, 5, 6))
AND (InvoiceAbstract.Status & 128) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))  / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast ( ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType In (4, 5, 6))
AND (InvoiceAbstract.Status & 128) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))  / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"Sales Return Saleable" = CASE @UOM	WHEN 'Sales UOM' THEN cast ( ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 4)
AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) +
ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 5)
AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast ( ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 4)
AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) +
ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 5)
AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))  / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast ( ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 4)
AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) +
ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 5)
AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))  / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"Sales Return Damages" = CASE @UOM	WHEN 'Sales UOM' THEN cast ( ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 4)
AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) +
ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 6)
AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast ( ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 4)
AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) +
ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 6)
AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast ( ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 4)
AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) +
ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 6)
AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Total Issues" = CASE @UOM	WHEN 'Sales UOM' THEN cast (ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 2)
AND (InvoiceAbstract.Status & 128) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0)
+ ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract
WHERE
(IsNull(DispatchAbstract.Status,0) & 320) = 0
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0)  as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast (ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 2)
AND (InvoiceAbstract.Status & 128) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0)
+ ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract
WHERE
(IsNull(DispatchAbstract.Status,0) & 320) = 0
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0)  as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast (ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 2)
AND (InvoiceAbstract.Status & 128) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0)
+ ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract
WHERE
(IsNull(DispatchAbstract.Status,0) & 320) = 0
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0)  as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"Saleable Issues" =  CASE @UOM	WHEN 'Sales UOM' THEN cast(ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
InvoiceAbstract.InvoiceType = 2
AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0
AND InvoiceDetail.SalePrice <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
+ ISNULL((SELECT SUM(Quantity)
FROM DispatchDetail, DispatchAbstract
WHERE
(DispatchAbstract.Status & 320) = 0
And DispatchDetail.SalePrice > 0
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0)
WHEN 'UOM 1' THEN Cast(cast(ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
InvoiceAbstract.InvoiceType = 2
AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0
AND InvoiceDetail.SalePrice <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
+ ISNULL((SELECT SUM(Quantity)
FROM DispatchDetail, DispatchAbstract
WHERE
(DispatchAbstract.Status & 320) = 0
And DispatchDetail.SalePrice > 0
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast(ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
InvoiceAbstract.InvoiceType = 2
AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0
AND InvoiceDetail.SalePrice <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
+ ISNULL((SELECT SUM(Quantity)
FROM DispatchDetail, DispatchAbstract
WHERE
(DispatchAbstract.Status & 320) = 0
And DispatchDetail.SalePrice > 0
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"Free Issues" = CASE @UOM	WHEN 'Sales UOM' THEN cast (ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 2)
AND (InvoiceAbstract.Status & 128) = 0
AND ISNULL(InvoiceDetail.SalePrice, 0) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
+ ISNULL((SELECT SUM(Quantity)
FROM DispatchDetail, DispatchAbstract
WHERE
(DispatchAbstract.Status & 320) = 0
And (DispatchDetail.SalePrice = 0
OR DispatchDetail.FlagWord = 1)
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0)

WHEN 'UOM 1' THEN Cast(cast (ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 2)
AND (InvoiceAbstract.Status & 128) = 0
AND ISNULL(InvoiceDetail.SalePrice, 0) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
+ ISNULL((SELECT SUM(Quantity)
FROM DispatchDetail, DispatchAbstract
WHERE
(DispatchAbstract.Status & 320) = 0
And (DispatchDetail.SalePrice = 0
OR DispatchDetail.FlagWord = 1)
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast (ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 2)
AND (InvoiceAbstract.Status & 128) = 0
AND ISNULL(InvoiceDetail.SalePrice, 0) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
+ ISNULL((SELECT SUM(Quantity)
FROM DispatchDetail, DispatchAbstract
WHERE
(DispatchAbstract.Status & 320) = 0
And (DispatchDetail.SalePrice = 0
OR DispatchDetail.FlagWord = 1)
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"Purchase Return" = CASE @UOM	WHEN 'Sales UOM' THEN cast ( ISNULL((SELECT SUM(Quantity)
FROM AdjustmentReturnDetail, AdjustmentReturnAbstract
WHERE
(ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0
AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
AND AdjustmentReturnDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast ( ISNULL((SELECT SUM(Quantity)
FROM AdjustmentReturnDetail, AdjustmentReturnAbstract
WHERE
(ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0
AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
AND AdjustmentReturnDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast ( ISNULL((SELECT SUM(Quantity)
FROM AdjustmentReturnDetail, AdjustmentReturnAbstract
WHERE
(ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0
AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
AND AdjustmentReturnDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"Adjustments" = CASE @UOM	WHEN 'Sales UOM' THEN cast ( ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract
WHERE
ISNULL(AdjustmentType,0) in (1, 3)
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And Product_Code = Items.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID), 0) as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast ( ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract
WHERE
ISNULL(AdjustmentType,0) in (1, 3)
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And Product_Code = Items.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast ( ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract
WHERE
ISNULL(AdjustmentType,0) in (1, 3)
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And Product_Code = Items.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"Stock Transfer Out" = CASE @UOM	WHEN 'Sales UOM' THEN cast ( IsNull((Select Sum(Quantity)
From StockTransferOutAbstract, StockTransferOutDetail
Where
StockTransferOutAbstract.Status & 192 = 0
And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
And StockTransferOutDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast ( IsNull((Select Sum(Quantity)
From StockTransferOutAbstract, StockTransferOutDetail
Where
StockTransferOutAbstract.Status & 192 = 0
And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
And StockTransferOutDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast ( IsNull((Select Sum(Quantity)
From StockTransferOutAbstract, StockTransferOutDetail
Where
StockTransferOutAbstract.Status & 192 = 0
And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
And StockTransferOutDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"Stock Transfer In" = CASE @UOM	WHEN 'Sales UOM' THEN cast ( IsNull((Select Sum(Quantity)
From StockTransferInAbstract, StockTransferInDetail
Where
StockTransferInAbstract.Status & 192 = 0
And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
And StockTransferInDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast ( IsNull((Select Sum(Quantity)
From StockTransferInAbstract, StockTransferInDetail
Where
StockTransferInAbstract.Status & 192 = 0
And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
And StockTransferInDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast ( IsNull((Select Sum(Quantity)
From StockTransferInAbstract, StockTransferInDetail
Where
StockTransferInAbstract.Status & 192 = 0
And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
And StockTransferInDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Stock Destruction" = CASE @UOM	WHEN 'Sales UOM' THEN cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)
From StockDestructionAbstract, StockDestructionDetail,ClaimsNote
Where ClaimsNote.Status & 1 <> 0
and Items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpItem)
And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate
And StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial
And StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID
And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)
From StockDestructionAbstract, StockDestructionDetail,ClaimsNote
Where ClaimsNote.Status & 1 <> 0
and Items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpItem)
And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate
And StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial
And StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID
And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)
From StockDestructionAbstract, StockDestructionDetail,ClaimsNote
Where ClaimsNote.Status & 1 <> 0
and Items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpItem)
And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate
And StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial
And StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID
And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"Total On Hand Qty" = CASE @UOM	WHEN 'Sales UOM' THEN cast (CASE when (@TODATE < @NEXT_DATE) THEN ISNULL((Select Opening_Quantity FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products WHERE Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0 And
VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND
VanStatementDetail.Product_Code = Items.Product_Code))
end as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast (CASE when (@TODATE < @NEXT_DATE) THEN ISNULL((Select Opening_Quantity FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products WHERE Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0 And
VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND
VanStatementDetail.Product_Code = Items.Product_Code))
end as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast (CASE when (@TODATE < @NEXT_DATE) THEN ISNULL((Select Opening_Quantity FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products WHERE Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0 And
VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND
VanStatementDetail.Product_Code = Items.Product_Code))
end as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"On Hand Saleable Qty" = CASE @UOM	WHEN 'Sales UOM' THEN cast (CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Free, 0) = 0 And
IsNull(Damage, 0) = 0  And
Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
VanStatementDetail.SalePrice <> 0
AND (VanStatementAbstract.Status & 128) = 0
And VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code)) end  as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast (CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Free, 0) = 0 And
IsNull(Damage, 0) = 0  And
Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
VanStatementDetail.SalePrice <> 0
AND (VanStatementAbstract.Status & 128) = 0
And VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code)) end  as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast (CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Free, 0) = 0 And
IsNull(Damage, 0) = 0  And
Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
VanStatementDetail.SalePrice <> 0
AND (VanStatementAbstract.Status & 128) = 0
And VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code)) end  as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"On Hand Free Qty" = CASE @UOM	WHEN 'Sales UOM' THEN cast (CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select IsNull(Free_Saleable_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Free, 0) = 1 And
IsNull(Damage, 0) = 0  And
Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0
And VanStatementDetail.SalePrice = 0
AND VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code)) end  as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast (CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select IsNull(Free_Saleable_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Free, 0) = 1 And
IsNull(Damage, 0) = 0  And
Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0
And VanStatementDetail.SalePrice = 0
AND VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code)) end  as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast (CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select IsNull(Free_Saleable_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Free, 0) = 1 And
IsNull(Damage, 0) = 0  And
Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0
And VanStatementDetail.SalePrice = 0
AND VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code)) end  as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"On Hand Damage Qty" = CASE @UOM	WHEN 'Sales UOM' THEN cast (CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select IsNull(Damage_Opening_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Damage, 0) > 0  And
Product_Code = Items.Product_Code), 0)) end  as Decimal(18,6))
WHEN 'UOM 1' THEN Cast(cast (CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select IsNull(Damage_Opening_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Damage, 0) > 0  And
Product_Code = Items.Product_Code), 0)) end  as Decimal(18,6)) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(cast (CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select IsNull(Damage_Opening_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Damage, 0) > 0  And
Product_Code = Items.Product_Code), 0)) end  as Decimal(18,6)) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"(%c) On Hand Value" = cast ( CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select Opening_Value
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)
FROM Batch_Products
WHERE Product_Code = Items.Product_Code) +
(SELECT ISNULL(SUM(Pending * PurchasePrice), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0
AND VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code))
END as Decimal(18,6))

FROM Items
Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
Left Outer Join UOM On Items.UOM = UOM.UOM
Inner Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID
Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID
WHERE
IsNull(Items.Active,0) = 1 And
OpeningDetails.Opening_Date = @FROMDATE AND
Manufacturer.Manufacturer_Name in (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpMfr) and
items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpItem)
--And Items.Product_Code = '1000'
end
-- changed
Else if @UOM = 'Conversion Factor'
Begin
SELECT  Items.Product_Code + ',' + @MLUOM + ',' + @Manufacturer + ',' + @Item ,
"Item Code" = Items.Product_Code,
"Item Name" = ProductName,
"Category Name" = ItemCategories.Category_Name,
"Conversion Units" = ConversionTable.ConversionUnit,
"Total Opening Quantity" = cast (ISNULL(Opening_Quantity, 0) *  ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),
"Saleable Opening Quantity" = cast ((ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)) *  ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),
"Free Opening Quantity" = cast (ISNULL(Free_Saleable_Quantity, 0) *  ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),
"Damage Opening Quantity" = cast (ISNULL(Damage_Opening_Quantity, 0) *  ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),
"(%c) Opening Value" = cast ( ISNULL(Opening_Value, 0) as Decimal(18,6)),

"Purchase" = cast (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)
FROM GRNAbstract, GRNDetail
WHERE
(IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And
(IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0 AND
GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And
GRNAbstract.GRNID = GRNDetail.GRNID AND
GRNDetail.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"Free Purchase" = cast (ISNULL((SELECT SUM(FreeQty)
FROM GRNAbstract, GRNDetail
WHERE
(IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And
(IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0  AND
GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And
GRNAbstract.GRNID = GRNDetail.GRNID AND
GRNDetail.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"Total Sales Return" = cast(ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType In (4, 5, 6))
AND (InvoiceAbstract.Status & 128) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"Sales Return Saleable" = cast(ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 4)
AND (InvoiceAbstract.Status & 128) = 0  And (InvoiceAbstract.Status & 32) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) +
ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 5)
AND (InvoiceAbstract.Status & 128) = 0  --And (InvoiceAbstract.Status & 32) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"Sales Return Damages" = cast(ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 4)
AND (InvoiceAbstract.Status & 128) = 0  And (InvoiceAbstract.Status & 32) <> 0
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) +
ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 6)
AND (InvoiceAbstract.Status & 128) = 0  --And (InvoiceAbstract.Status & 32) <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"Total Issues" = cast ((ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 2)
AND (InvoiceAbstract.Status & 128) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0)
+ ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract
WHERE
(IsNull(DispatchAbstract.Status,0) & 320) = 0
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0)) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"Saleable Issues" = cast((ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
InvoiceAbstract.InvoiceType = 2
AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0
AND InvoiceDetail.SalePrice <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0)
+ ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract
WHERE
(IsNull(DispatchAbstract.Status,0) & 320) = 0
AND DispatchDetail.SalePrice > 0
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0)) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"Free Issues" = cast ((ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 2)
AND (InvoiceAbstract.Status & 128) = 0
AND ISNULL(InvoiceDetail.SalePrice, 0) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0)
+ ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract
WHERE
(IsNull(DispatchAbstract.Status,0) & 320) = 0
AND (DispatchDetail.FlagWord = 1 OR DispatchDetail.SalePrice = 0)
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0)) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"Purchase Return" = cast (ISNULL((SELECT SUM(Quantity)
FROM AdjustmentReturnDetail, AdjustmentReturnAbstract
WHERE
(ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0
AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
AND AdjustmentReturnDetail.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"Adjustments" = cast (ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract WHERE ISNULL(AdjustmentType,0) in (1, 3) And Product_Code = Items.Product_Code AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),
"Stock Transfer Out" = cast (IsNull((Select Sum(Quantity)
From StockTransferOutAbstract, StockTransferOutDetail
Where
StockTransferOutAbstract.Status & 192 = 0
And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
And StockTransferOutDetail.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"Stock Transfer In" = cast (IsNull((Select Sum(Quantity)
From StockTransferInAbstract, StockTransferInDetail
Where
StockTransferInAbstract.Status & 192 = 0
And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
And StockTransferInDetail.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0 )as Decimal(18,6)),

"Stock Destruction" = cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)
From StockDestructionAbstract, StockDestructionDetail,ClaimsNote
Where
ClaimsNote.Status & 1 <> 0
and Items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpItem)
And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate
And StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial
And StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID
And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)),

"Total On Hand Qty" = cast ((CASE when (@TODATE < @NEXT_DATE) THEN ISNULL((Select Opening_Quantity FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products WHERE Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0 And
VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND
VanStatementDetail.Product_Code = Items.Product_Code)) end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"On Hand Saleable Qty" = cast ((CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Free, 0) = 0
And IsNull(Damage, 0) = 0
And Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0
And VanStatementDetail.SalePrice <> 0
AND VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code)) end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"On Hand Free Qty" = cast ((CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select IsNull(Free_Saleable_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Free, 0) = 1
And IsNull(Damage, 0) = 0
And Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0
And VanStatementDetail.SalePrice = 0
AND VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code)) end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"On Hand Damage Qty" = cast ((CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select IsNull(Damage_Opening_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Damage, 0) > 0
And Product_Code = Items.Product_Code), 0)) end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),

"(%c) On Hand Value" = cast ((CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select Opening_Value
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)
FROM Batch_Products
WHERE Product_Code = Items.Product_Code) +
(SELECT ISNULL(SUM(Pending * PurchasePrice), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0
AND VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code)) end) as Decimal(18,6))
--    * ISNULL(Items.ConversionFactor, 0))
FROM Items
Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID
Inner Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID
Inner Join ItemCategories On  Items.CategoryID = ItemCategories.CategoryID
WHERE
IsNull(Items.Active,0) = 1  And
OpeningDetails.Opening_Date = @FROMDATE  AND
Manufacturer.Manufacturer_Name in (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpMfr) and
items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpItem)end
else
begin
SELECT Items.Product_Code + ',' + @MLUOM + ',' + @Manufacturer + ',' + @Item ,
"Item Code" = Items.Product_Code,
"Item Name" = ProductName,
"Category Name" = ItemCategories.Category_Name,
"Reporting UOM" =  UOM.Description,  -- changed
"Total Opening Quantity" = cast (ISNULL(Opening_Quantity, 0) /
(CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),

"Saleable Opening Quantity" = cast ((ISNULL(Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) /
(CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),

"Free Opening Quantity" = cast (IsNull(Free_Saleable_Quantity, 0) /
(CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0)
END) as Decimal(18,6)),

"Damage Opening Quantity" = cast (IsNull(Damage_Opening_Quantity, 0)
/ (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)) ,

"(%c) Opening Value" = cast (ISNULL(Opening_Value, 0) as Decimal(18,6)) ,
"Purchase" = cast (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)
FROM GRNAbstract, GRNDetail
WHERE
(IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0
And (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0
AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE
And GRNAbstract.GRNID = GRNDetail.GRNID
AND GRNDetail.Product_Code = Items.Product_Code), 0)
/  (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0)
END ) as Decimal(18,6)),

"Free Purchase" = cast (ISNULL((SELECT Sum(FreeQty)
FROM GRNAbstract, GRNDetail
WHERE
(IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0
And (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0
AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE
And GRNAbstract.GRNID = GRNDetail.GRNID
AND GRNDetail.Product_Code = Items.Product_Code), 0)
/  (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0)
END ) as Decimal(18,6)),


"Total Sales Return" = cast (ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType In (4, 5, 6))
AND (InvoiceAbstract.Status & 128) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0)
/ (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0)
END) as Decimal(18,6)),

"Sales Return Saleable" = cast ((ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 4)
AND (InvoiceAbstract.Status & 128) = 0  And (InvoiceAbstract.Status & 32) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) +
ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 5)
AND (InvoiceAbstract.Status & 128) = 0  --And (InvoiceAbstract.Status & 32) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0))
/ (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0)
END) as Decimal(18,6)),

"Sales Return Damages" = cast ((ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 4)
AND (InvoiceAbstract.Status & 128) = 0  And (InvoiceAbstract.Status & 32) <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0) +
ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 6)
AND (InvoiceAbstract.Status & 128) = 0  --And (InvoiceAbstract.Status & 32) <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0))
/ (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0)
END) as Decimal(18,6)),

"Total Issues" = cast ((ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 2)
AND (InvoiceAbstract.Status & 128) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0)
+ ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract
WHERE
(IsNull(DispatchAbstract.Status,0) & 320) = 0
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0))
/ (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),


"Saleable Quantity" = cast((ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
InvoiceAbstract.InvoiceType = 2
AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0
AND InvoiceDetail.SalePrice <> 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0)
+ ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract
WHERE
DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND (IsNull(DispatchAbstract.Status,0) & 320) = 0
AND DispatchDetail.Product_Code = Items.Product_Code
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchDetail.SalePrice > 0), 0))

/  (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0)
END ) as Decimal(18,6)),

"Free Issues" = cast ((ISNULL((SELECT SUM(Quantity)
FROM InvoiceDetail, InvoiceAbstract
WHERE
(InvoiceAbstract.InvoiceType = 2)
AND (InvoiceAbstract.Status & 128) = 0
AND ISNULL(InvoiceDetail.SalePrice, 0) = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
AND InvoiceDetail.Product_Code = Items.Product_Code), 0)
+ ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract
WHERE
(IsNull(DispatchAbstract.Status,0) & 320) = 0
AND (DispatchDetail.FlagWord = 1 OR DispatchDetail.SalePrice = 0)
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = Items.Product_Code), 0))
/ (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),

"Purchase Return" = cast (ISNULL((SELECT SUM(Quantity)
FROM AdjustmentReturnDetail, AdjustmentReturnAbstract
WHERE
(ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0
AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
AND AdjustmentReturnDetail.Product_Code = Items.Product_Code), 0)
/ (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0) END)as Decimal(18,6)),

"Adjustments" = cast (ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract
WHERE
ISNULL(AdjustmentType,0) in (1, 3)
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And Product_Code = Items.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
), 0)
/ (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0) END)as Decimal(18,6)),

"Stock Transfer Out" = cast (IsNull((Select Sum(Quantity)
From StockTransferOutAbstract, StockTransferOutDetail
Where
StockTransferOutAbstract.Status & 192 = 0
And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)
/ (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),

"Stock Transfer In" = cast (IsNull((Select Sum(Quantity)
From StockTransferInAbstract, StockTransferInDetail
Where
StockTransferInAbstract.Status & 192 = 0
And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
And StockTransferInDetail.Product_Code = Items.Product_Code), 0)
/ (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),

"Stock Destruction" = cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)
From StockDestructionAbstract, StockDestructionDetail,ClaimsNote
Where  ClaimsNote.Status & 1 <> 0
and Items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpItem)
And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate
And StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial
And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID
And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)),

"Total On Hand Qty" = cast ((CASE when (@TODATE < @NEXT_DATE) THEN ISNULL((Select Opening_Quantity FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products WHERE Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0
AND VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code))
end )

/ (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0)
END) as Decimal(18,6)),

"On Hand Saleable Qty" = cast (CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Free, 0) = 0
And IsNull(Damage, 0) = 0
And Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0
And VanStatementDetail.SalePrice <> 0
AND VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code)) end / (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0)
END) as Decimal(18,6)),

"On Hand Free Qty" = cast (CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select IsNull(Free_Saleable_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Free, 0) = 1
And IsNull(Damage, 0) = 0
And Product_Code = Items.Product_Code), 0) +
(SELECT ISNULL(SUM(Pending), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0
And VanStatementDetail.SalePrice = 0
AND VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code)) end / (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0)
END) as Decimal(18,6)),

"On Hand Damage Qty" = cast (CASE
when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select IsNull(Damage_Opening_Quantity, 0)
FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
(ISNULL((SELECT SUM(Quantity)
FROM Batch_Products
WHERE
IsNull(Damage, 0) > 0
And Product_Code = Items.Product_Code), 0)) end / (CASE ISNULL(Items.ReportingUnit, 0)
WHEN 0 THEN
1
ELSE
ISNULL(Items.ReportingUnit, 0)
END) as Decimal(18,6)),

"(%c) On Hand Value" = cast (CASE when (@TODATE < @NEXT_DATE) THEN
ISNULL((Select Opening_Value FROM OpeningDetails
WHERE
Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)
AND OpeningDetails.Product_Code = Items.Product_Code), 0)
ELSE
((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)
FROM Batch_Products
WHERE Product_Code = Items.Product_Code) +
(SELECT ISNULL(SUM(Pending * PurchasePrice), 0)
FROM VanStatementDetail, VanStatementAbstract
WHERE
(VanStatementAbstract.Status & 128) = 0
AND VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
And VanStatementDetail.Product_Code = Items.Product_Code
)) END as Decimal(18,6))

FROM Items
Left Outer Join OpeningDetails  On Items.Product_Code = OpeningDetails.Product_Code
Left Outer Join UOM On Items.ReportingUOM = UOM.UOM
Inner Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID
Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID
WHERE
IsNull(Items.Active,0) = 1 And
Manufacturer.Manufacturer_Name in (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpMfr) and
items.product_code in (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpItem) and
OpeningDetails.Opening_Date = @FROMDATE
end

