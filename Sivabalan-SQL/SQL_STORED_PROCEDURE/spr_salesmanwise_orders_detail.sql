
CREATE PROCEDURE spr_salesmanwise_orders_detail(@SalesmanID int,  
      @FROMDATE datetime,  
       @TODATE datetime)  
AS  
SELECT  SODetail.Product_Code, "Item Code" = SODetail.Product_Code, "Item Name" = Items.ProductName,   
 "Batch" = Batch_Number, 
	"Net Value (%c)"= isnull(sum(SODetail.SalePrice * SODetail.Quantity),0), 
	"Quantity" = SUM(Quantity)  

FROM SOAbstract, SODetail, Items  
WHERE  SOAbstract.SalesmanID = @SalesmanID AND  
 SOAbstract.SONumber = SODetail.SONumber AND  
 SODetail.Product_Code = Items.Product_Code AND  
 SOAbstract.SODate BETWEEN @FROMDATE AND @TODATE AND  
 (SOAbstract.Status & 128 ) = 0  
GROUP BY SODetail.Product_Code, Items.ProductName, SODetail.Batch_Number


