CREATE procedure [dbo].[sp_get_GRNItems_UOM_Pidilite](@GRN_ID varchar(255))       
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
Batch_Products.Batch_Code   ,batch_products.grntaxid,     
--------------------------------------------------------------------------------------------  
"Octroi Percentage"  = (Select OctroiPercentage From InvoiceDetailReceived IDR
						Where InvoiceID = GRNAbstract.RecdInvoiceID and IDR.Product_Code = Batch_Products.Product_Code),
"Octroi Amount"  = (Select OctroiAmount From InvoiceDetailReceived IDR
						Where InvoiceID = GRNAbstract.RecdInvoiceID and IDR.Product_Code = Batch_Products.Product_Code),
"Freight"  = (Select Freight From InvoiceDetailReceived IDR
						Where InvoiceID = GRNAbstract.RecdInvoiceID and IDR.Product_Code = Batch_Products.Product_Code)  
--------------------------------------------------------------------------------------------  
from Items,ItemCategories, Batch_Products, Vendors, GRNAbstract, UOM      
where   GRNAbstract.GRNID  IN (select grnid from #temp) and       
 GRNAbstract.VendorID = Vendors.VendorID and      
 Items.CategoryID = ItemCategories.CategoryID and      
 ItemCategories.Price_Option = 0 and      
 Batch_Products.Product_Code = Items.Product_Code and      
 Batch_Products.GRN_ID = GRNAbstract.GRNID and      
 Batch_Products.UOMQty > 0 and      
 Batch_Products.UOM *= UOM.UOM      
      
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
Batch_Products.Batch_Code,batch_products.grntaxid,    
--------------------------------------------------------------------------------------------  
"Octroi Percentage"  = (Select OctroiPercentage From InvoiceDetailReceived IDR
						Where InvoiceID = GRNAbstract.RecdInvoiceID and IDR.Product_Code = Batch_Products.Product_Code),
"Octroi Amount"  = (Select OctroiAmount From InvoiceDetailReceived IDR
						Where InvoiceID = GRNAbstract.RecdInvoiceID and IDR.Product_Code = Batch_Products.Product_Code),
"Freight"  = (Select Freight From InvoiceDetailReceived IDR
						Where InvoiceID = GRNAbstract.RecdInvoiceID and IDR.Product_Code = Batch_Products.Product_Code)  
--------------------------------------------------------------------------------------------  
from Batch_Products, Items, ItemCategories, GRNAbstract, Vendors, UOM      
where  Batch_Products.GRN_ID = GRNAbstract.GRNID and      
 GRNAbstract.GRNID  IN (select grnid from #temp) and       
 GRNAbstract.VendorID = Vendors.VendorID and      
 Batch_Products.Product_Code = Items.Product_Code and      
 Items.CategoryID = ItemCategories.CategoryID and      
 ItemCategories.Price_Option = 1 and      
 Batch_Products.UOMQty > 0 and      
 Batch_Products.quantityreceived >0  and
 Batch_Products.UOM *= UOM.UOM      
Order by Batch_Products.Batch_Code    
    
drop table #temp                    
end
