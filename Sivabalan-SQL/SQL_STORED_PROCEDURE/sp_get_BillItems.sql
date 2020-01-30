CREATE procedure sp_get_BillItems(@Bill_ID int) as    
    
select BillDetail.Product_Code as "Code", Items.ProductName as "Name",     
Quantity, PurchasePrice, Amount, BillDetail.TaxSuffered, TaxAmount, Discount,    
BillDetail.Batch, BillDetail.Expiry, BillDetail.PKD, BillDetail.PTS, BillDetail.PTR,     
CASE IsNull(BillDetail.Promotion,0)    
WHEN 1 THEN     
0    
ELSE    
BillDetail.ECP    
END, BillDetail.SpecialPrice, BillDetail.Promotion, BillDetail.ECP  , BillDetail.TaxCode "TaxCode",  
"ExciseDuty" = IsNull(BillDetail.ExciseDuty,0), "PPBED" = IsNull(BillDetail.PurchasePriceBeforeExciseAmount,0)  ,"VAT" = ISNULL(BillDetail.VAT,0)
from BillDetail, Items     
where BillDetail.Product_Code = Items.Product_Code and BillID = @Bill_ID    
Order by BillDetail.Serial    
    
    
  
  



