CREATE PROCEDURE spr_ser_Market_TurnOver_Ratio_Detail(@CategoryID INT, @ProductHierarchy nVarchar(100), 
@Period nVarchar(50))
AS
DECLARE @LastPeriodSale Decimal(18,6)
DECLARE @CurrentPeriodSale Decimal(18,6)
DECLARE @LastPeriodFromDate DateTime
DECLARE @LastPeriodToDate DateTime
DECLARE @CurrentDate DateTime

Create Table #TempTrunOverRatio(Product_Code nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, Product_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
LastPeriodSale Decimal(18,6), CurrentPeriodSale Decimal(18,6))

SELECT  @CurrentDate = GetDate()

IF @Period = 'Quarterly'
BEGIN
SELECT @LastPeriodFromDate = DateAdd(m, -6, GetDate()), @LastPeriodToDate = DateAdd(m, -3, GetDate())
END
ELSE IF @Period = 'Half Yearly'
BEGIN
SELECT @LastPeriodFromDate = DateAdd(m, -12, GetDate()), @LastPeriodToDate = DateAdd(m, -6, GetDate())
END
ELSE IF @Period = 'Yearly'
BEGIN
SELECT @LastPeriodFromDate = DateAdd(m, -24, GetDate()), @LastPeriodToDate = DateAdd(m, -12, GetDate())
END
ELSE
BEGIN
SELECT @LastPeriodFromDate = DateAdd(m, -2, GetDate()), @LastPeriodToDate = DateAdd(m, -1, GetDate())
END

INSERT INTO #TempTrunOverRatio SELECT Items.Product_Code, Items.ProductName, 
Sum(Case when InvoiceAbstract.InvoiceType>=4 and InvoiceAbstract.InvoiceType<=6 then 0 - InvoiceDetail.Amount 
ELSE InvoiceDetail.Amount END), 0
FROM InvoiceAbstract, InvoiceDetail, Items
WHERE Items.CategoryID = @CategoryID
 And InvoiceDetail.Product_Code = Items.Product_Code
 And InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
 And (InvoiceAbstract.Status & 128 ) = 0  
 And InvoiceDate between @LastPeriodFromDate And @LastPeriodToDate
GROUP BY Items.Product_Code, Items.ProductName


INSERT INTO #TempTrunOverRatio SELECT Items.Product_Code, Items.ProductName, 
sum(isnull(serviceinvoicedetail.NetValue,0)),0
FROM ServiceInvoiceAbstract, ServiceInvoiceDetail, Items
WHERE Items.CategoryID = @CategoryID
And ServiceInvoiceDetail.SpareCode = Items.Product_Code
And ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID
And Isnull(ServiceInvoiceAbstract.Status,0) & 192  = 0  
And ISnull(serviceinvoicedetail.sparecode,'')<>''
And ServiceInvoiceDate between @LastPeriodFromDate And @LastPeriodToDate
GROUP BY Items.Product_Code, Items.ProductName


INSERT INTO #TempTrunOverRatio SELECT Items.Product_Code, Items.ProductName, 0,
Sum(Case when InvoiceAbstract.InvoiceType>=4 and InvoiceAbstract.InvoiceType<=6
then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END)
FROM InvoiceAbstract, InvoiceDetail, Items
WHERE Items.CategoryID = @CategoryID
And InvoiceDetail.Product_Code = Items.Product_Code
And InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
And (InvoiceAbstract.Status & 128 ) = 0  
And InvoiceDate between @LastPeriodToDate And @CurrentDate
GROUP BY Items.Product_Code, Items.ProductName


INSERT INTO #TempTrunOverRatio SELECT Items.Product_Code, Items.ProductName, 0,
Sum(ServiceInvoiceDetail.NetValue)
FROM ServiceInvoiceAbstract, ServiceInvoiceDetail, Items
WHERE Items.CategoryID = @CategoryID
And ServiceInvoiceDetail.SpareCode = Items.Product_Code
And ServiceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID
And Isnull(serviceInvoiceAbstract.Status,0) & 192  = 0  
And ISnull(serviceinvoicedetail.sparecode,'')<>''
And serviceInvoiceDate between @LastPeriodToDate And @CurrentDate
GROUP BY Items.Product_Code, Items.ProductName



SELECT "Product Code" = Product_Code, "Product Name" = Product_Name, "Last Period Sale" = Sum(LastPeriodSale),
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
(Sum(CurrentPeriodSale)/ Sum(LastPeriodSale) * 100)- 100
END) END)
FROM #TempTrunOverRatio Group By Product_Code, Product_Name

DROP TABLE #TempTrunOverRatio


