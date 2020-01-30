CREATE PROCEDURE spr_list_sales_by_item_percentage(@FROMDATE DATETIME,  
          @TODATE DATETIME, @CusType nVarchar(50))  
AS  
DECLARE @NETVAL AS Decimal(18,6);  
  
IF @CusType = 'Trade'  
BEGIN  
SELECT  @NETVAL = Round(SUM(Amount), 2) FROM InvoiceAbstract, InvoiceDetail  
WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND InvoiceAbstract.InvoiceType in (1,3)  
 AND (InvoiceAbstract.Status & 128) = 0  
  
SELECT InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,   
"Item Name" = Items.ProductName, "Sales Percentage" = Round((Sum(Amount) / (case @NETVAL when 0 then 1 else @NETVAL end)) * 100,2)  
FROM InvoiceAbstract, InvoiceDetail, Items  
WHERE  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
 AND InvoiceDetail.Product_Code = Items.Product_Code AND InvoiceAbstract.InvoiceType NOT IN (2,4,5,6)  
 AND (InvoiceAbstract.Status & 128) = 0  
  
GROUP BY InvoiceDetail.Product_Code, Items.ProductName  
END  
ELSE  
BEGIN  
SELECT  @NETVAL = Round(SUM(Amount), 2) FROM InvoiceAbstract, InvoiceDetail  
WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND InvoiceAbstract.InvoiceType = 2  
 AND (InvoiceAbstract.Status & 128) = 0  
  
SELECT InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,   
"Item Name" = Items.ProductName, "Sales Percentage" = Round((Sum(Amount) / (case @NETVAL when 0 then 1 else @NETVAL end)) * 100,2)  
FROM InvoiceAbstract, InvoiceDetail, Items  
WHERE  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
 AND InvoiceDetail.Product_Code = Items.Product_Code AND InvoiceAbstract.InvoiceType = 2   
 AND (InvoiceAbstract.Status & 128) = 0  
  
GROUP BY InvoiceDetail.Product_Code, Items.ProductName  
END  


