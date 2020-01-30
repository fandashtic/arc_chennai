CREATE PROCEDURE spr_pipeline_sales_stock(@PERIOD nVARCHAR(15))          
AS          
DECLARE @AGG INT          
DECLARE @FROMDATE DATETIME          
DECLARE @TODATE DATETIME          
DECLARE @FirstLevel nVARCHAR(100)  
DECLARE @LastLevel nVARCHAR(100)  
DECLARE @Mysql nVARCHAR(4000)  

  
SET @FirstLevel = dbo.GetHierarchyColumn('FIRST')
SET @LastLevel= dbo.GetHierarchyColumn('LAST')          
SET @AGG = cast(substring(@PERIOD,1,2) as int)          
SET @FROMDATE = CAST(DATEPART(dd, GETDATE()) AS varchar) + '/' + CAST(DATEPART(mm, GETDATE()) as varchar) + '/' + cast(DATEPART(yyyy, GETDATE()) AS varchar)                  
SET @FROMDATE = DATEADD(m, (0- cast(substring(@PERIOD,1,2) as int)), @FROMDATE)          
SET @TODATE = CAST(DATEPART(dd, GETDATE()) AS varchar) + '/' + CAST(DATEPART(mm, GETDATE()) as varchar) + '/' + cast(DATEPART(yyyy, GETDATE()) AS varchar)          
SET  @TODATE = DATEADD(d, 1, @TODATE)          
          
CREATE TABLE  #PIPELINE (Product_Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, quantity decimal(18,6),Value Decimal(18,6))          
INSERT INTO #PIPELINE           
SELECT InvoiceDetail.Product_Code, Sum(InvoiceDetail.quantity),Sum(InvoiceDetail.Amount)            
FROM InvoiceDetail, InvoiceAbstract          
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND          
InvoiceDate BETWEEN @FROMDATE AND @TODATE AND          
InvoiceType <> 4 AND Status & 128  = 0         
GROUP BY InvoiceDetail.Product_Code          
          
INSERT INTO #PIPELINE           
SELECT InvoiceDetail.Product_Code,Sum(0 - InvoiceDetail.quantity), Sum(0 - InvoiceDetail.Amount)           
FROM InvoiceDetail, InvoiceAbstract          
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND          
InvoiceDate BETWEEN @FROMDATE AND @TODATE AND          
InvoiceType = 4 AND Status & 128  = 0           
GROUP BY InvoiceDetail.Product_Code          
          
SELECT  Items.Product_Code,        
"Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(items.categoryid),        
"Product Hierarchy Last Level"= itemcategories.category_Name,        
"Item Code"= Items.Product_code,          
"Item Name" = Items.ProductName,           
"Closing Stock Qty" = (select (select IsNull(sum(batch_products.quantity),0)      
                            from  batch_products  where       
                            batch_products.product_code = Items.Product_Code) +       
                            (select Isnull(sum(VanStatementDetail.pending),0) from      
                            VanStatementDetail  where       
                            VanStatementDetail.product_code = Items.Product_Code)),
"Closing Stock Value (%c)" = IsNull((select sum(batch_products.Quantity * IsNull(Batch_Products.PurchasePrice, 0))
                            from  batch_products  where       
                            batch_products.product_code = Items.Product_Code 
							and Batch_Products.Quantity > 0
							and IsNull(batch_products.free, 0) <> 1 ), 0) +       
                            IsNull((select Sum(Isnull(VanStatementDetail.Pending,0) * VanStatementDetail.PurchasePrice) from      
                            VanStatementDetail  where       
                            VanStatementDetail.product_code = Items.Product_Code), 0),    
"Total Sales Qty" = (SELECT isnull(Sum(Pip.quantity),0) FROM #PIPELINE Pip WHERE Pip.Product_code COLLATE SQL_Latin1_General_CP1_CI_AS= Items.Product_Code),
"Sales Value (%c)" = ISNULL((SELECT Sum(Pip.Value) FROM #PIPELINE Pip WHERE Pip.Product_code COLLATE SQL_Latin1_General_CP1_CI_AS= Items.Product_Code),0),           
"Average Daily Sale (%c)" = CAST(ISNULL((SELECT ISNULL(Sum(Pip.Value),0) FROM #PIPELINE Pip WHERE Pip.Product_code COLLATE SQL_Latin1_General_CP1_CI_AS= Items.Product_Code) / @AGG,0) / 30 AS Decimal(18,6)),           
"Pipeline Stocks (Days)" = cast((CASE(ISNULL((SELECT ISNULL(Sum(Pip.Value),0) FROM #PIPELINE Pip WHERE Pip.Product_code COLLATE SQL_Latin1_General_CP1_CI_AS= Items.Product_Code) / @AGG,0))           
WHEN 0 THEN 0          
ELSE cast(isnull((dbo.GetPipeQty(Items.Product_Code) / ISNULL((SELECT ISNULL(Sum(Pip.Value),0) FROM #PIPELINE Pip WHERE Pip.Product_code COLLATE SQL_Latin1_General_CP1_CI_AS= Items.Product_Code) / @AGG,0)) ,0) as Decimal(18,6)) * 30          
END) AS Decimal(18,6)) into #temp1 
FROM  Items, itemcategories        
WHERE itemcategories.categoryid = items.categoryid           
GROUP BY itemcategories.category_Name,Items.Product_Code, Items.ProductName,items.categoryid

SET @Mysql = 'SELECT [Product_Code], [Product Hierarchy First Level] As "' + @FirstLevel + '", ' + 
  		'[Product Hierarchy Last Level] As "' + @LastLevel + '", [Item Code], [Item Name], [Closing Stock Qty] , [Closing Stock Value (%c)],' +
		'[Total Sales Qty], [Sales Value (%c)] , [Average Daily Sale (%c)],[Pipeline Stocks (Days)] FROM #Temp1'
EXEC(@MySql)
DROP TABLE #Temp1

