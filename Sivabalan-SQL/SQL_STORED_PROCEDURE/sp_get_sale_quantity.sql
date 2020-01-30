CREATE PROCEDURE sp_get_sale_quantity (	@n AS INTEGER,
					@m AS INTEGER,
					@CATEGORY AS nvarchar(50),
					@MANUFACTURER AS nvarchar(50),
					@BRAND AS nvarchar(50))
AS
DECLARE @YESTERDAY DATETIME
DECLARE @YESTERDAY2 DATETIME
DECLARE @LASTWEEKDAY DATETIME
DECLARE @LASTMONTHDAY DATETIME
DECLARE @LASTNDAY DATETIME

SET DATEFORMAT dmy
SET @YESTERDAY = DATEADD(dd, 0 - 1, GetDate())
SET @YESTERDAY = CAST(DATEPART(dd, @YESTERDAY) AS nvarchar) + '/' + CAST(DATEPART(mm, @YESTERDAY) as nvarchar) + '/' + cast(DATEPART(yyyy, @YESTERDAY) AS nvarchar)
SET @LASTWEEKDAY = DATEADD(dd, 0 - 7, GetDate())
SET @LASTWEEKDAY = CAST(DATEPART(dd, @LASTWEEKDAY) AS nvarchar) + '/' + CAST(DATEPART(mm, @LASTWEEKDAY) AS nvarchar) + '/' + CAST(DATEPART(yyyy, @LASTWEEKDAY) AS nvarchar)
SET @LASTMONTHDAY = DATEADD(dd, 0 - 30, GetDate())
SET @LASTMONTHDAY = CAST(DATEPART(dd, @LASTMONTHDAY) AS nvarchar) + '/' + CAST(DATEPART(mm, @LASTMONTHDAY) AS nvarchar) + '/' + CAST(DATEPART(yyyy, @LASTMONTHDAY) AS nvarchar)
IF @m = 0
	SET @LASTNDAY = DATEADD(dd, 0 - @n, GetDate())
ELSE IF @m = 1
	SET @LASTNDAY = DATEADD(wk, 0 - @n, GetDate())
ELSE IF @m = 2
	SET @LASTNDAY = DATEADD(mm, 0 - @n, GetDate())
SET @LASTNDAY = CAST(DATEPART(dd, @LASTNDAY) AS nvarchar) + '/' + CAST(DATEPART(mm, @LASTNDAY) AS nvarchar) + '/' + CAST(DATEPART(yyyy, @LASTNDAY) AS nvarchar)
SET @YESTERDAY2 = DATEADD(hh, 23, @YESTERDAY)
SET @YESTERDAY2 = DATEADD(n, 59, @YESTERDAY2)
SET @YESTERDAY2 = DATEADD(ss, 59, @YESTERDAY2)

SELECT "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName, 
	"Stock Norm" = Items.StockNorm,
	"Lot Size" = items.MinOrderQty,
	"Last n day's Sale" = ISNULL((SELECT SUM(Quantity) FROM InvoiceAbstract, InvoiceDetail
	WHERE InvoiceAbstract.Status & 128 = 0 AND
	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND
	InvoiceAbstract.InvoiceType <> 4 AND
	InvoiceAbstract.InvoiceDate BETWEEN @LASTNDAY AND @YESTERDAY2 AND
	InvoiceDetail.Product_Code = Items.Product_Code GROUP BY InvoiceDetail.Product_Code), 0),
	"Yesterday's Sale" = ISNULL((SELECT SUM(Quantity) FROM InvoiceAbstract, InvoiceDetail 
	WHERE InvoiceAbstract.Status & 128 = 0 AND
	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND 
	InvoiceAbstract.InvoiceType <> 4 AND 
	InvoiceAbstract.InvoiceDate BETWEEN @YESTERDAY AND @YESTERDAY2 AND
	InvoiceDetail.Product_Code = Items.Product_Code), 0),
	"Last Week's Sale" = ISNULL((SELECT SUM(Quantity) FROM InvoiceAbstract, InvoiceDetail
	WHERE InvoiceAbstract.Status & 128 = 0 AND
	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND
	InvoiceAbstract.InvoiceType <> 4 AND
	InvoiceAbstract.InvoiceDate BETWEEN @LASTWEEKDAY AND @YESTERDAY2 AND
	InvoiceDetail.Product_Code = Items.Product_Code GROUP BY InvoiceDetail.Product_Code), 0),
	"Last Month's Sale" = ISNULL((SELECT SUM(Quantity) FROM InvoiceAbstract, InvoiceDetail
	WHERE InvoiceAbstract.Status & 128 = 0 AND
	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND
	InvoiceAbstract.InvoiceType <> 4 AND
	InvoiceAbstract.InvoiceDate BETWEEN @LASTMONTHDAY AND @YESTERDAY2 AND
	InvoiceDetail.Product_Code = Items.Product_Code GROUP BY InvoiceDetail.Product_Code), 0)
FROM Items, ItemCategories, Manufacturer, Brand
WHERE Items.CategoryID = ItemCategories.CategoryID AND
Items.ManufacturerID = Manufacturer.ManufacturerID AND
Items.BrandID = Brand.BrandID AND
Brand.BrandName LIKE @BRAND AND
Manufacturer.Manufacturer_Name LIKE @MANUFACTURER AND
ItemCategories.Category_Name LIKE @CATEGORY AND
Items.Active = 1 AND
ItemCategories.Active = 1 AND
Manufacturer.Active = 1 AND
Brand.Active = 1

