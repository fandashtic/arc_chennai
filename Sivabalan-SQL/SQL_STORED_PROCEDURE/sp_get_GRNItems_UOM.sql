CREATE procedure sp_get_GRNItems_UOM(@GRN_ID nvarchar(255))     
as    
begin    
create table #Temp (grnid int)              
Exec ('Insert Into #Temp Select GRNID FROm GrnAbstract Where GRNID in (' + @GRN_ID + ')')    
    
select Batch_Products.Product_Code as "Code", Items.ProductName as "Name",     
Batch_Products.UOMQty as "Qty",     
Batch_Products.UOMPrice as "Price",    
Batch_Products.Batch_Code as "BatchCode", Batch_Products.Batch_Number as "Batch",     
Batch_Products.Expiry as "Expiry",     
Case Batch_Products.Free When 1 Then 0 Else Items.PTS End as "PTS",     
Case Batch_Products.Free When 1 Then 0 Else Items.PTR End as "PTR",    
Case Batch_Products.Free When 1 Then 0 Else Items.ECP End as "ECP",     
Case   
When (Batch_Products.TaxSuffered is Null) then   
 Case Vendors.Locality When 1 then   
  isnull((Select Percentage From Tax Where Tax_Code = Items.TaxSuffered),0)  
 Else  
  isnull((Select CST_Percentage From Tax Where Tax_Code = Items.TaxSuffered),0)  
 End  
Else  
 Batch_Products.TaxSuffered   
End  
as "Tax Suffered",    
Batch_Products.PKD as "Packaging Date", Batch_Products.Free as "Free",    
Case Batch_Products.Free When 1 Then 0 Else Items.Company_Price End as "Special Price",    
UOM.Description as "UOM", Batch_Products.UOM as "UOMID",    
------ THIS FIELD IS USED FOR SORTING GRNITEMS IN THE BILL DO NOT USE FOR ANY OTHER PURPOSE-    
Batch_Products.Batch_Code   ,batch_products.grntaxid   
--------------------------------------------------------------------------------------------    
from Items
inner join ItemCategories on Items.CategoryID = ItemCategories.CategoryID    
inner join Batch_Products on Batch_Products.Product_Code = Items.Product_Code    
inner join  GRNAbstract on  Batch_Products.GRN_ID = GRNAbstract.GRNID       
inner join Vendors on  GRNAbstract.VendorID = Vendors.VendorID      
left outer join UOM     on  Batch_Products.UOM = UOM.UOM 
where   GRNAbstract.GRNID  IN (select grnid from #temp) and     
 ItemCategories.Price_Option = 0 and    
 Batch_Products.UOMQty > 0 and    
Batch_Products.quantityreceived >0      
UNION ALL    
    
select Batch_Products.Product_Code as "Code", Items.ProductName as "Name",    
Batch_Products.UOMQty as "Qty", Batch_Products.UOMPrice as "Price",    
Batch_Products.Batch_Code as "BatchCode", Batch_Products.Batch_Number as "Batch",     
Batch_Products.Expiry as "Expiry",     
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.PTS End as "PTS",     
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.PTR End as "PTR",    
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.ECP End as "ECP",     
Case   
When (Batch_Products.TaxSuffered is Null) then   
 Case Vendors.Locality When 1 then   
  isnull((Select Percentage From Tax Where Tax_Code = Items.TaxSuffered),0)  
 Else  
  isnull((Select CST_Percentage From Tax Where Tax_Code = Items.TaxSuffered),0)  
 End  
Else  
 Batch_Products.TaxSuffered   
End  
as "Tax Suffered",    
Batch_Products.PKD as "Packaging Date", Batch_Products.Free as "Free",    
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.Company_Price End as "Special Price",    
UOM.Description as "UOM", Batch_Products.UOM as "UOMID",    
------ THIS FIELD IS USED FOR SORTING GRNITEMS IN THE BILL DO NOT USE FOR ANY OTHER PURPOSE-    
Batch_Products.Batch_Code,batch_products.grntaxid  
--------------------------------------------------------------------------------------------    
from Batch_Products
inner join  Items on  Batch_Products.Product_Code = Items.Product_Code      
inner join  ItemCategories on   Items.CategoryID = ItemCategories.CategoryID     
inner join  GRNAbstract on  Batch_Products.GRN_ID = GRNAbstract.GRNID      
inner join  Vendors on  GRNAbstract.VendorID = Vendors.VendorID      
left outer join UOM     on  Batch_Products.UOM = UOM.UOM 
where 
 GRNAbstract.GRNID  IN (select grnid from #temp) and     
 ItemCategories.Price_Option = 1 and    
 Batch_Products.UOMQty > 0 and    
Batch_Products.quantityreceived >0   
 
Order by Batch_Products.Batch_Code  
  
drop table #temp                  
end     

