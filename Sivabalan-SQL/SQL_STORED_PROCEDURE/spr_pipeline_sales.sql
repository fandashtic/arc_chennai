CREATE PROCEDURE spr_pipeline_sales(@PERIOD nVARCHAR(15))  
AS  
DECLARE @AGG INT  
DECLARE @FROMDATE DATETIME  
DECLARE @TODATE DATETIME  
SET @AGG = cast(substring(@PERIOD,1,2) as int)  
SET @FROMDATE = CAST(DATEPART(dd, GETDATE()) AS varchar) + '/' + CAST(DATEPART(mm, GETDATE()) as varchar) + '/' + cast(DATEPART(yyyy, GETDATE()) AS varchar)  

SET @FROMDATE = DATEADD(m, (0- cast(substring(@PERIOD,1,2) as int)), @FROMDATE)  
SET @TODATE = CAST(DATEPART(dd, GETDATE()) AS varchar) + '/' + CAST(DATEPART(mm, GETDATE()) as varchar) + '/' + cast(DATEPART(yyyy, GETDATE()) AS varchar)  
SET @TODATE = DATEADD(d, 1, @TODATE)  
  
CREATE TABLE  #PIPELINE (Product_Code nvarchar(15), Value Decimal(18,6))  
INSERT INTO #PIPELINE   
SELECT InvoiceDetail.Product_Code, InvoiceDetail.Amount    
FROM InvoiceDetail, InvoiceAbstract  
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
InvoiceDate BETWEEN @FROMDATE AND @TODATE AND  
InvoiceType not in(4,5,6) AND Status & 128  = 0   

INSERT INTO #PIPELINE   
SELECT InvoiceDetail.Product_Code, 0 - InvoiceDetail.Amount   
FROM InvoiceDetail, InvoiceAbstract  
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
InvoiceDate BETWEEN @FROMDATE AND @TODATE AND  
InvoiceType in(4,5,6) AND Status & 128  = 0   
  
SELECT  Items.Product_Code, "Item Name" = Items.ProductName,   
 "On Hand Value (%c)" = dbo.GetPipeQty(Items.Product_Code),  
 "Sales Value (%c)" = ISNULL(sum(#PIPELINE.Value),0),   
 "Average Daily Sale (%c)" = CAST(ISNULL((sum(#PIPELINE.Value) / @AGG),0) / 30 AS Decimal(18,6)),   
 "Pipeline Stocks (Days)" = cast((CASE(ISNULL((sum(#PIPELINE.Value) / @AGG),0))   
 WHEN 0 THEN 0  
 ELSE cast(isnull((dbo.GetPipeQty(Items.Product_Code) / ISNULL((sum(#PIPELINE.Value) / @AGG),0)) ,0) as Decimal(18,6)) * 30  
 END) AS Decimal(18,6))
FROM  Items, #PIPELINE  
WHERE Items.Product_Code collate SQL_Latin1_General_Cp1_CI_AS = #PIPELINE.Product_Code  
GROUP BY Items.Product_Code, Items.ProductName  


