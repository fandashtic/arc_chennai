--Adjustment Amount is excluded for calculating Purchase Value

CREATE Procedure spr_Itemwise_purchase (@FromDate datetime, @ToDate Datetime)  
as  
select  BillDetail.Product_Code ,   
 "Item Name" = Items.ProductName ,   
 "Purchase Value" = sum(BillDetail.amount + BillDetail.TaxAmount),  
 "Total Qty" = sum (Quantity)   
From  BillAbstract, BillDetail, Items  
Where Items.Product_Code = BillDetail.Product_Code   
 AND BillDetail.BillId = BillAbstract.BillId  
 AND Billabstract.BillDate between @FromDate and @ToDate   
 AND (BillAbstract.Status & 128) = 0   
Group by BillDetail.Product_Code, Items.ProductName



