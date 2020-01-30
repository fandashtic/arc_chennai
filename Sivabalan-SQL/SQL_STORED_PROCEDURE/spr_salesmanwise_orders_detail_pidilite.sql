
CREATE PROCEDURE spr_salesmanwise_orders_detail_pidilite (@SalesmanID int,  
      @FROMDATE datetime,  
       @TODATE datetime)  
AS  
SELECT  SODetail.Product_Code, "Item Code" = SODetail.Product_Code, "Item Name" = Items.ProductName,   
 "Batch" = Batch_Number, 
	--"Net Value (%c)"= isnull(sum(SODetail.SalePrice * SODetail.Quantity),0), 
  "Net Value (%c)"= isnull(sum(
      (SODetail.SalePrice * SODetail.Quantity) + 
			((SODetail.SalePrice * SODetail.Quantity) * (SODetail.TaxSuffered/100)) + 
		  (((SODetail.SalePrice * SODetail.Quantity) + ((SODetail.SalePrice * SODetail.Quantity) * (SODetail.TaxSuffered/100))) * (SaleTax/100))
			),0),
	"Quantity" = SUM(Quantity),
  "Reporting UOM" = SUM(Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),
  "Conversion Factor" = SUM(Quantity * IsNull(ConversionFactor, 0))

FROM SOAbstract, SODetail, Items  
WHERE  SOAbstract.SalesmanID = @SalesmanID AND  
 SOAbstract.SONumber = SODetail.SONumber AND  
 SODetail.Product_Code = Items.Product_Code AND  
 SOAbstract.SODate BETWEEN @FROMDATE AND @TODATE AND  
 (SOAbstract.Status & 128 ) = 0  
GROUP BY SODetail.Product_Code, Items.ProductName, SODetail.Batch_Number


