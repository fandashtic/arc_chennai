CREATE PROCEDURE spr_ser_Market_TurnOver_Ratio(@ProductHierarchy nVarchar(100), @Period nVarchar(50))
AS
DECLARE @LastPeriodSale Decimal(18,6)
DECLARE @CurrentPeriodSale Decimal(18,6)
DECLARE @LastPeriodFromDate DateTime
DECLARE @LastPeriodToDate DateTime
DECLARE @CurrentDate DateTime
DECLARE @NoOfMonths INT

Create Table #tempCategory(CategoryID int, CategoryName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #TempTrunOverRatio(CategoryID INT, CategoryName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
LastPeriodSale Decimal(18,6), CurrentPeriodSale Decimal(18,6))

-- EXEC sp_GetProductHierarchy @ProductHierarchy

IF @ProductHierarchy = '%'
BEGIN
	INSERT INTO #tempCategory(CategoryID, CategoryName)
	SELECT CategoryID, Category_Name FROM ItemCategories
END
ELSE
BEGIN
	INSERT INTO #tempCategory(CategoryID, CategoryName)
	SELECT CategoryID, Category_Name FROM ItemCategories, ItemHierarchy 
	WHERE ItemCategories.Level = ItemHierarchy.HierarchyId And
	ItemHierarchy.HierarchyName Like @ProductHierarchy
END

SELECT  @CurrentDate = GetDate()

IF @Period = 'Quarterly'
BEGIN
SELECT @LastPeriodFromDate = DateAdd(m, -6, GetDate()), @LastPeriodToDate = DateAdd(m, -3, GetDate())
SET @NoOfMonths = 3
END
ELSE IF @Period = 'Half Yearly'
BEGIN
SELECT @LastPeriodFromDate = DateAdd(m, -12, GetDate()), @LastPeriodToDate = DateAdd(m, -6, GetDate())
SET @NoOfMonths = 6
END
ELSE IF @Period = 'Yearly'
BEGIN
SELECT @LastPeriodFromDate = DateAdd(m, -24, GetDate()), @LastPeriodToDate = DateAdd(m, -12, GetDate())
SET @NoOfMonths = 12
END
ELSE
BEGIN
SELECT @LastPeriodFromDate = DateAdd(m, -2, GetDate()), @LastPeriodToDate = DateAdd(m, -1, GetDate())
SET @NoOfMonths = 1
END

INSERT INTO #TempTrunOverRatio SELECT Items.CategoryID, CategoryName, 
Sum(Case when InvoiceAbstract.InvoiceType>=4 and InvoiceAbstract.InvoiceType<=6 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END), 0
FROM InvoiceAbstract, InvoiceDetail, Items, #tempCategory
WHERE Items.CategoryID = #tempCategory.CategoryID
And InvoiceDetail.Product_Code = Items.Product_Code
And InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
And (InvoiceAbstract.Status & 128 ) = 0  
And InvoiceDate between @LastPeriodFromDate And @LastPeriodToDate
GROUP BY Items.CategoryID, CategoryName



INSERT INTO #TempTrunOverRatio SELECT Items.CategoryID, CategoryName, 
sum(isnull(serviceinvoicedetail.NetValue,0)),0
FROM ServiceInvoiceAbstract, ServiceInvoiceDetail, Items,#tempCategory
WHERE Items.CategoryID = #tempCategory.CategoryID
And ServiceInvoiceDetail.SpareCode = Items.Product_Code
And ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID
And Isnull(ServiceInvoiceAbstract.Status,0) & 192  = 0  
And ISnull(serviceinvoicedetail.sparecode,'')<>''
And ServiceInvoiceDate between @LastPeriodFromDate And @LastPeriodToDate
GROUP BY Items.CategoryID, CategoryName


INSERT INTO #TempTrunOverRatio SELECT Items.CategoryID, CategoryName,  0, 
Sum(Case when InvoiceAbstract.InvoiceType>=4 and InvoiceAbstract.InvoiceType<=6
then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END)
FROM InvoiceAbstract, InvoiceDetail, Items, #tempCategory
WHERE Items.CategoryID = #tempCategory.CategoryID
 And InvoiceDetail.Product_Code = Items.Product_Code
 And InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
 And (InvoiceAbstract.Status & 128 ) = 0  
 And InvoiceDate between @LastPeriodToDate And @CurrentDate
GROUP BY Items.CategoryID, CategoryName




INSERT INTO #TempTrunOverRatio SELECT Items.CategoryID, CategoryName,  0, 
Sum(serviceInvoiceDetail.NetValue)
FROM ServiceInvoiceAbstract, serviceInvoiceDetail, Items, #tempCategory
WHERE Items.CategoryID = #tempCategory.CategoryID
And serviceInvoiceDetail.spareCode = Items.Product_Code
And serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID
And Isnull(serviceInvoiceAbstract.Status,0) & 192  = 0  
And ISnull(serviceinvoicedetail.sparecode,'')<>''
And serviceInvoiceDate between @LastPeriodToDate And @CurrentDate
GROUP BY Items.CategoryID, CategoryName



SELECT CategoryID, "Category Name" = CategoryName, "Last Period Sale" = Sum(LastPeriodSale),
"Current Period Sale" = Sum(CurrentPeriodSale), 
"Turn over Ratio" = CASE WHEN Sum(CurrentPeriodSale) <> 0 AND Sum(LastPeriodSale) <> 0 THEN 
(CASE (Sum(LastPeriodSale) / Sum(CurrentPeriodSale)) 
WHEN 1 THEN
0
ELSE
(Sum(LastPeriodSale) / Sum(CurrentPeriodSale)) END)
ELSE 0 END,
"Growth in (%)" = (Case Sum(LastPeriodSale) 
WHEN 0 THEN 
100 
ELSE 
(CASE Sum(CurrentPeriodSale)/ Sum(LastPeriodSale) 
WHEN 1 THEN 
0 
ELSE 
(Sum(CurrentPeriodSale)/ Sum(LastPeriodSale) * 100) - 100
END) END) 
FROM #TempTrunOverRatio Group By CategoryID, CategoryName

DROP TABLE #tempCategory
DROP TABLE #TempTrunOverRatio



