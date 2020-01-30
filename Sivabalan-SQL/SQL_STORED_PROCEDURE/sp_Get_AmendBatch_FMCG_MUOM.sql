CREATE Procedure sp_Get_AmendBatch_FMCG_MUOM(@GRNID Int,        
     @ItemCode nvarchar(20),@Serial int, @UomID int)  
As       
create table #temp(    
Product_code nvarchar(20),    
BatchNo nvarchar(128),    
Expiry Datetime,    
PKD Datetime,    
Quantity Decimal(18,6),    
FreeQuantity Decimal(18,6),    
SalePrice Decimal(18,6),    
PurchasePrice Decimal(18,6),
TaxSuffered Decimal(18,6),
GRNTaxID Integer Null,
GRNTaxSuffered Decimal(18,6),
UOMID int,
UOMPrice decimal(18,6))  
    
insert into #temp    
Select Batch_products.Product_code,Replace(Batch_Products.Batch_Number, ',', Char(9)),Batch_Products.Expiry, Batch_Products.PKD,    
sum(case IsNull(free,0) when 0 Then Batch_Products.uomqty Else 0 End),    
Sum(case IsNull(Free,0) When 1 Then Batch_Products.uomqty Else 0 End),    
case IsNull(Free,0)    
When 1 Then (select a.SalePrice from batch_products a where a.batch_code=max(Batch_Products.BatchReference))    
Else Batch_products.SalePrice    
End ,    
case IsNull(Free,0)    
When 1 Then (Select a.PurchasePrice From Batch_Products a Where a.Batch_Code = max(Batch_Products.BatchReference))      
Else Batch_Products.PurchasePrice End    , batch_products.TaxSuffered, batch_products.GRNTaxID, batch_products.GRNTaxSuffered ,
min(batch_products.uom) as uomid, 
(Case IsNull(Free, 0)   
When 1 Then (Select a.UOMPrice From Batch_Products a Where a.Batch_Code = max(Batch_Products.BatchReference))  
Else Batch_Products.UOMPrice End) as uomprice
From Batch_Products    
Where Batch_Products.Product_code=@ItemCode and    
Batch_Products.GRN_ID=@GRNID    
And Batch_Products.serial = @serial 
And Batch_Products.uom = @uomid
Group by Batch_Products.Product_Code,Batch_Products.Batch_Number,    
Batch_Products.Expiry,Batch_Products.PKD,Batch_Products.SalePrice,    
Batch_Products.PurchasePrice,Batch_Products.Free  , 
batch_products.TaxSuffered, batch_products.GRNTaxID, batch_products.GRNTaxSuffered ,
batch_products.UOMPrice 
    
Select Items.Virtual_Track_Batches, Items.TrackPKD, ItemCategories.Price_Option,        
#temp.BatchNo, #temp.Expiry, #temp.PKD,        
sum(#temp.Quantity), #temp.SalePrice,#temp.PurchasePrice,        
sum(#temp.FreeQuantity),#Temp.TaxSuffered,#Temp.GRNTaxID,#Temp.GRNTaxSuffered,
#Temp.uomid,#Temp.uomprice
From #temp,Items,ItemCategories        
Where #temp.Product_Code = Items.Product_Code And        
Items.CategoryID = ItemCategories.CategoryID        
group by Items.Virtual_Track_Batches, Items.TrackPKD, ItemCategories.Price_Option,     
#temp.BatchNo,#temp.Expiry,#temp.PKD,#temp.SalePrice,#temp.PurchasePrice,#temp.Product_code  ,#Temp.TaxSuffered,#Temp.GRNTaxID,#Temp.GRNTaxSuffered,
#Temp.uomid,#Temp.uomprice
drop table #temp    
    
     
    
      
    
  
  
  
  
  


