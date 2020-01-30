CREATE PROCEDURE spr_list_sales_by_item_percentage_volume(@FROMDATE DATETIME,
	           @TODATE DATETIME, @CusType nvarchar(50), @MesType nvarchar(50))
AS
DECLARE @NETVAL AS Decimal(18,6);

IF @CusType = 'Trade'
BEGIN
SELECT  @NETVAL = Case @MesType When 'Value' Then Sum(Case IsNull(InvoiceAbstract.InvoiceType, 0)
                   When 4 Then -1 Else 1 End * Round(IsNull(Amount, 0), 2))
                                When 'Volume' Then  Sum(Case IsNull(InvoiceAbstract.InvoiceType, 0)
                   When 4 Then -1 Else 1 End * IsNull(Quantity, 0)) End
FROM InvoiceAbstract, InvoiceDetail
WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND InvoiceAbstract.InvoiceType in (1, 3, 4)
	AND (IsNULL(InvoiceAbstract.Status, 0) & 192) = 0

SELECT InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code, 
"Item Name" = Items.ProductName, "Sales Percentage" = 
  Case @MesType When 'Value' Then (Sum(Case IsNull(InvoiceAbstract.InvoiceType, 0)
                   When 4 Then -1 Else 1 End * Round(IsNull(Amount, 0), 2)) / (Case @NETVAL When 0 Then 1 Else @NETVAL End)) * 100 
                When 'Volume' Then  (Sum(Case IsNull(InvoiceAbstract.InvoiceType, 0)
                   When 4 Then -1 Else 1 End * IsNull(Quantity, 0)) / (Case @NETVAL When 0 Then 1 Else @NETVAL End)) * 100 End
FROM InvoiceAbstract, InvoiceDetail, Items
WHERE 	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
	AND InvoiceDetail.Product_Code = Items.Product_Code AND InvoiceAbstract.InvoiceType IN (1, 3, 4)
	AND (IsNull(InvoiceAbstract.Status, 0) & 192) = 0

GROUP BY InvoiceDetail.Product_Code, Items.ProductName
END
ELSE
BEGIN
SELECT  @NETVAL = Case @MesType When 'Value' Then Sum(Case IsNull(InvoiceAbstract.InvoiceType, 0)
                   When 4 Then -1 Else 1 End * Round(IsNull(Amount, 0), 2))
                                When 'Volume' Then  Sum(Case IsNull(InvoiceAbstract.InvoiceType, 0)
                   When 4 Then -1 Else 1 End * IsNull(Quantity, 0)) End FROM InvoiceAbstract, InvoiceDetail
WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND InvoiceAbstract.InvoiceType = 2
	AND (IsNull(InvoiceAbstract.Status, 0) & 192) = 0

SELECT InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code, 
"Item Name" = Items.ProductName, "Sales Percentage" = 
Case @MesType When 'Value' Then (Sum(Case IsNull(InvoiceAbstract.InvoiceType, 0)
                   When 4 Then -1 Else 1 End * Round(IsNull(Amount, 0), 2)) / (Case @NETVAL When 0 Then 1 Else @NETVAL End)) * 100 
                When 'Volume' Then  (Sum(Case IsNull(InvoiceAbstract.InvoiceType, 0)
                   When 4 Then -1 Else 1 End * IsNull(Quantity, 0)) / (Case @NETVAL When 0 Then 1 Else @NETVAL End)) * 100 End
FROM InvoiceAbstract, InvoiceDetail, Items
WHERE 	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
	AND InvoiceDetail.Product_Code = Items.Product_Code AND InvoiceAbstract.InvoiceType = 2 
	AND (IsNull(InvoiceAbstract.Status, 0) & 192) = 0

GROUP BY InvoiceDetail.Product_Code, Items.ProductName
END


