CREATE procedure spr_list_itemwise_damageditems_pidilite(@fromdate datetime, @todate datetime)    
AS    
  
Create Table #temp    
(Product_Code nvarchar(20), ProductName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Quantity Decimal(18,6))    
Insert into #temp select items.product_code, items.productname,  sum(invoicedetail.quantity)     
from invoiceabstract, invoicedetail, items    
where invoiceabstract.invoiceid = invoicedetail.invoiceid    
and invoicedetail.product_code = items.product_code    
and invoiceabstract.invoicetype = 4 and invoiceabstract.status & 32 <>0 
and invoiceabstract.status & 128 = 0
and invoiceabstract.invoicedate between @fromdate and @todate   
Group by Items.Product_Code, Items.ProductName    
  
Insert into #temp select Items.Product_Code, items.productname,      
 sum (stockadjustment.quantity)     
from stockadjustmentabstract, stockadjustment, items    
where stockadjustmentabstract.adjustmentid = stockadjustment.serialno   and stockadjustment.product_code = items.product_code  
and  stockadjustmentabstract.adjustmenttype = 0   
and stockadjustmentabstract.adjustmentdate between @fromdate and @todate
Group By Items.Product_Code, Items.ProductName    
    
Select #temp.Product_Code,    
"Item Name" = #temp.ProductName, 
"Total Damages" = Sum(Quantity),
"Reporting UOM" = Sum(Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),
"Conversion Factor" = Sum(Quantity * IsNull(ConversionFactor, 0))
From #temp, Items Where Items.Product_Code = #temp.Product_Code
Group By #temp.Product_Code, #temp.ProductName    
    
Drop Table #temp 


