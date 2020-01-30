create procedure spr_ser_list_itemwise_damageditems(@fromdate datetime, @todate datetime)      
AS      
    
Create Table #temp      
  
(Product_Code nvarchar(20), ProductName nvarchar(255), Quantity Decimal(18,6))        
Insert into #temp select items.product_code,items.productname,  
Sum(Quantity) From InvoiceAbstract, InvoiceDetail,Items    
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
(InvoiceAbstract.Status & 32) <> 0 And    
invoiceabstract.status & 128 = 0  and  
InvoiceDetail.Product_Code = items.product_code And    
InvoiceAbstract.InvoiceType = 4 And   
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate
Group by Items.Product_Code, Items.ProductName      

Insert into #temp select items.product_code,items.productname,
 ISnull(Sum(Qty),0) From sparesReturnInfo, IssueDetail,Items    
Where SparesReturnInfo.SerialNo = IssueDetail.SerialNo And    
Isnull(SparesReturnInfo.ReturnType,0) = 2 And    
Issuedetail.sparecode = items.product_code And    
SparesReturnInfo.Creationtime Between @FromDate And @ToDate
Group by Items.Product_Code, Items.ProductName      
    
Insert into #temp select Items.Product_Code, items.productname,        
 sum (stockadjustment.quantity)       
from stockadjustmentabstract, stockadjustment, items      
where stockadjustmentabstract.adjustmentid = stockadjustment.serialno   and stockadjustment.product_code = items.product_code    
and  stockadjustmentabstract.adjustmenttype = 0     
and stockadjustmentabstract.adjustmentdate between @fromdate and @todate  
Group By Items.Product_Code, Items.ProductName      
      
Select Product_Code,      
"Item Name" = ProductName, "Total Damages" = Sum(Quantity)  
From #temp Group By Product_Code, ProductName      
      
Drop Table #temp   
  
  
  


