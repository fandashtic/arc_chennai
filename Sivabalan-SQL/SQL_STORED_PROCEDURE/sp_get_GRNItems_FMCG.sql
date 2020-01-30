CREATE procedure sp_get_GRNItems_FMCG(@GRN_ID nvarchar(255))   
as  
begin  
create table #Temp (grnid int)            
Exec ('Insert Into #Temp Select GRNID FROm GrnAbstract Where GRNID in (' + @GRN_ID + ')')  
  
select Batch_Products.Product_Code as "Code", Items.ProductName as "Name",  
Batch_Products.QuantityReceived as "Qty",   
Case Batch_Products.Free When 1 then 0 Else Batch_Products.PurchasePrice End as "Price",  
Batch_Products.Batch_Code as "BatchCode", Batch_Products.Batch_Number as "Batch",   
Batch_Products.Expiry as "Expiry",   
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
Case Batch_Products.Free When 1 then 0 Else Case ItemCategories.Price_Option When 1 Then Batch_Products.SalePrice Else Items.Sale_Price End End as "Sale Price",   
Batch_Products.PKD as "Packaging Date",  
Batch_Products.Free as "Free"  , batch_products.grntaxid
from Batch_Products, Items, GRNAbstract, Vendors, ItemCategories  
where  Batch_Products.GRN_ID = GRNAbstract.GRNID and  
GRNAbstract.GRNID IN (select grnid from #temp)  and  
GRNAbstract.VendorID = Vendors.VendorID and  
Batch_Products.Product_Code = Items.Product_Code and  
Batch_Products.QuantityReceived > 0 And  
Items.CategoryID = ItemCategories.CategoryID  
order by Batch_Products.Batch_Code 
drop table #temp                
end            
  
  




