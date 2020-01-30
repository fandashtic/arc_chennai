CREATE PROCEDURE spr_ser_list_sales_by_item_percentage(@FROMDATE DATETIME,  
          @TODATE DATETIME, @CusType nVarchar(50))  
AS  
DECLARE @NETVAL AS Decimal(18,6);  
DECLARE @SERNETVAL AS Decimal(18,6)
DECLARE @TOTALNETVAL AS Decimal(18,6)

  
IF @CusType = 'Trade'  
BEGIN  
  
	SELECT  @NETVAL = Round(SUM(Amount), 2) FROM InvoiceAbstract, InvoiceDetail  
	WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
		AND InvoiceDate BETWEEN @FROMDATE AND @TODATE 
		AND InvoiceAbstract.InvoiceType in (1,3)  
		AND (InvoiceAbstract.Status & 128) = 0
	 
	SELECT InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,   
	"Item Name" = Items.ProductName, "Sales Percentage" = Round((Sum(Amount) / (case @NETVAL when 0 then 1 else @NETVAL end)) * 100,2)  
	--"Item Name" = Items.ProductName, "Sales Percentage" = Round(Sum(Amount),2)  
	FROM InvoiceAbstract, InvoiceDetail, Items  
	WHERE  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
	 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
	 AND InvoiceDetail.Product_Code = Items.Product_Code AND InvoiceAbstract.InvoiceType NOT IN (2,4,5,6)  
	 AND (InvoiceAbstract.Status & 128) = 0  
	GROUP BY InvoiceDetail.Product_Code, Items.ProductName  

END  
ELSE  
BEGIN  

Create Table #SalesItemInvoice(Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
Itemcode nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
[ItemName] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[SalesPercentage] decimal(18,6))


	SELECT  @NETVAL = Round(SUM(Amount), 2) FROM InvoiceAbstract, InvoiceDetail  
	WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
		AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND InvoiceAbstract.InvoiceType = 2  
		AND (InvoiceAbstract.Status & 128) = 0  
	
	SELECT  @SERNETVAL = ISNULL((SELECT Round(SUM(serviceinvoicedetail.NetValue), 2)          
	FROM ServiceInvoiceDetail, serviceInvoiceAbstract,items
	WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  
		AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                       
		AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                       
		AND serviceInvoiceDetail.sparecode = items.product_code  
		AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  
		AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)                       
	
	set @TOTALNETVAL = @NETVAL + @SERNETVAL
	
	Insert into #SalesItemInvoice
	
	  
		SELECT InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,   
		"Item Name" = Items.ProductName, 
		"Sales Percentage" = Round(SUM(Amount), 2)
		FROM InvoiceAbstract, InvoiceDetail,Items  
		WHERE  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
		AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
		AND InvoiceDetail.Product_Code = Items.Product_Code AND InvoiceAbstract.InvoiceType = 2   
		AND (InvoiceAbstract.Status & 128) = 0  
		GROUP BY InvoiceDetail.Product_Code, Items.ProductName  
	
	
	Insert into #SalesItemInvoice
	
		SELECT ServiceInvoiceDetail.SpareCode, "Item Code" = ServiceInvoiceDetail.SpareCode,   
		--"Item Name" = Items.ProductName, "Sales Percentage" = Round((Sum(ServiceInvoiceAbstract.NetValue) / (case @SERNETVAL when 0 then 1 else @SERNETVAL end)) * 100,2)  
		"Item Name" = Items.ProductName, "Sales Percentage" = Round(Sum(ServiceInvoicedetail.NetValue),2)  
		FROM ServiceInvoiceAbstract, ServiceInvoiceDetail, Items  
		WHERE  ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID   
		AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN @FROMDATE AND @TODATE  
		AND ServiceInvoiceDetail.SpareCode = Items.Product_Code AND ServiceInvoiceAbstract.ServiceInvoiceType IN (1)  
		AND Isnull(ServiceInvoiceAbstract.Status,0) & 192  = 0  
		AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  
		GROUP BY ServiceInvoiceDetail.SpareCode, Items.ProductName  
	
	
	Select "Code" = Code,"ItemCode" = Itemcode,"Item Name" = itemName,
	"Sales Percentage" = Round((Sum(SalesPercentage) / (case @TOTALNETVAL when 0 then 1 else @TOTALNETVAL end)) * 100,2)  
	from #SalesItemInvoice
	Group by Code,Itemcode,ItemName
Drop table #SalesItemInvoice
END  

