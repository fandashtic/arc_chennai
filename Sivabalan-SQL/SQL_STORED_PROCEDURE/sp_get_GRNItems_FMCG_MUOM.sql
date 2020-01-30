CREATE procedure [dbo].[sp_get_GRNItems_FMCG_MUOM](@GRN_ID nvarchar(255))       
as      
begin  
create table #Temp (grnid int)            
Exec ('Insert Into #Temp Select GRNID FROm GrnAbstract Where GRNID in (' + @GRN_ID + ')')  
  
select Batch_Products.Product_Code as "Code", Items.ProductName as "Name",      
Batch_Products.UOMQty as "Qty",       
Case Batch_Products.Free When 1 then 0 Else Batch_Products.UOMPrice End as "Price",      
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
Batch_Products.Free as "Free" ,UOM.Description as "UOM", Batch_Products.UOM as "UOMID" ,
Batch_Products.grntaxid
from Batch_Products, Items, GRNAbstract, Vendors, UOM, ItemCategories  
where  Batch_Products.GRN_ID = GRNAbstract.GRNID And      
GRNAbstract.GRNID IN (select grnid from #temp) And      
GRNAbstract.VendorID = Vendors.VendorID And      
Batch_Products.Product_Code = Items.Product_Code And      
Batch_Products.QuantityReceived > 0 And      
Batch_Products.UOM *= UOM.UOM  And  
Items.CategoryID = ItemCategories.CategoryID  
order by Batch_Products.Batch_Code 
drop table #temp                
end
