CREATE Procedure sp_Get_AmendBatch_MUOM (@GRNID Int,    
     @ItemCode nvarchar(20),@Serial int, @UomID int)    
As    
Create Table #temp (    
Product_Code nvarchar(20) Collate SQL_Latin1_General_CP1_CI_AS,    
BatchNo nvarchar(128),    
Expiry DateTime,    
PKD DateTime,    
Quantity Decimal(18,6),    
FreeQuantity Decimal(18,6),    
PFM Decimal(18,6),    
PTS Decimal(18,6),    
PTR Decimal(18,6),    
ECP Decimal(18,6),    
Company_Price Decimal(18,6),    
PurchasePrice Decimal(18,6),    
ComboID Integer,    
TaxSuffered Decimal(18,6),    
GRNTaxID Integer Null,    
GRNTaxSuffered Decimal(18,6),  
UOMID int,  
UOMPrice decimal(18,6),
ItemOrder Int,
OrgPTS Decimal(18,6),
MRPForTax Decimal(18,6),
MRPPerPack Decimal(18, 6))    

Declare @Locality int        
Select @Locality = Locality from Vendors,GrnAbstract where Vendors.VendorID = GrnAbstract.VendorID and GrnAbstract.GrnID=@GRNID 
    
Insert Into #temp     
Select Batch_Products.Product_Code, Replace(Batch_Products.Batch_Number, ',', Char(9)), Batch_Products.Expiry, Batch_Products.PKD, 
Sum(case IsNull(Free,0) When 0 Then Batch_Products.uomqty Else 0 End),     
Sum(case IsNull(Free,0) When 1 Then Batch_Products.uomqty Else 0 End),  
Case IsNull(Free, 0)     
When 1 Then (Select a.PFM From Batch_Products a Where a.Batch_Code = max(Batch_Products.BatchReference))    
Else Batch_Products.PFM End,        
Case IsNull(Free, 0)     
When 1 Then (Select a.PTS From Batch_Products a Where a.Batch_Code = max(Batch_Products.BatchReference))    
Else Batch_Products.PTS End,     
Case IsNull(Free, 0)     
When 1 Then (Select a.PTR From Batch_Products a Where a.Batch_Code = max(Batch_Products.BatchReference))    
Else Batch_Products.PTR End,     
Case IsNull(Free, 0)     
When 1 Then (Select a.ECP From Batch_Products a Where a.Batch_Code = max(Batch_Products.BatchReference))    
Else Batch_Products.ECP End,     
Case IsNull(Free, 0)     
When 1 Then (Select a.OrgPTS From Batch_Products a Where a.Batch_Code = max(Batch_Products.BatchReference))    
Else Batch_Products.OrgPTS End,     
Case IsNull(Free, 0)     
When 1 Then (Select a.PurchasePrice From Batch_Products a Where a.Batch_Code = max(Batch_Products.BatchReference))    
Else Batch_Products.PurchasePrice End,    
Min(Batch_Products.ComboID),batch_products.TaxSuffered,batch_products.GRNTaxID,batch_products.GRNTaxSuffered,    
min(batch_products.uom) as uomid,   
(Case IsNull(Free, 0)     
When 1 Then (Select a.UOMPrice From Batch_Products a Where a.Batch_Code = max(Batch_Products.BatchReference))    
Else Batch_Products.UOMPrice End) as uomprice , Max(ReceInvItemOrder), Max(OrgPTS), MRPForTAX, MRPPerPack
From Batch_Products    
Where Batch_Products.Product_Code = @ItemCode   
And Batch_Products.serial = @serial   
and Batch_Products.GRN_ID = @GRNID     
And Batch_Products.uom = @uomid  
Group By Batch_Products.Product_Code, Batch_Products.Batch_Number,     
   Batch_Products.Expiry, Batch_Products.PKD, Batch_Products.PFM, Batch_Products.PTS, Batch_Products.PTR,     
   Batch_Products.ECP, Batch_Products.Company_Price, Batch_Products.PurchasePrice, Batch_Products.OrgPTS,
   Batch_Products.Free, batch_products.TaxSuffered, batch_products.GRNTaxID, batch_products.GRNTaxSuffered, batch_products.UOMPrice,MRPForTAX, MRPPerPack     
    

Select Items.Virtual_Track_Batches, Items.TrackPKD, ItemCategories.Price_Option,    
#temp.BatchNo, #temp.Expiry, #temp.PKD,     
Sum(#temp.Quantity),#temp.PTS, #temp.PTR, #temp.ECP, #temp.Company_Price,   
#temp.PurchasePrice, Sum(#temp.FreeQuantity),    
Items.Purchased_At, #Temp.ComboID ,#Temp.TaxSuffered,#Temp.GRNTaxID,#Temp.GRNTaxSuffered,  
#Temp.uomid,#Temp.uomprice, 
-- --BEGIN
-- Case ItemCategories.Price_Option              
-- When 1 Then              
--  Case Purchased_At              
--  When 1 Then              
--  Sum((Batch_Products.QuantityReceived * Batch_Products.PTS) + dbo.fn_calculateTax(Batch_Products.Product_code,(Batch_Products.QuantityReceived * Batch_Products.PTS),Batch_Products.QuantityReceived,@Locality,Batch_Products.GRNTaxID,Batch_Products.Batch_Code))              
--  When 2 Then              
--  Sum((Batch_Products.QuantityReceived * Batch_Products.PTR) + dbo.fn_calculateTax(Batch_Products.Product_code,(Batch_Products.QuantityReceived * Batch_Products.PTR),Batch_Products.QuantityReceived,@Locality,Batch_Products.GRNTaxID,Batch_Products.Batch_Code))              
--  Else              
--  Sum((Batch_Products.QuantityReceived * Batch_Products.PurchasePrice) + dbo.fn_calculateTax(Batch_Products.Product_code,(Batch_Products.QuantityReceived * Batch_Products.PurchasePrice),Batch_Products.QuantityReceived,@Locality,Batch_Products.GRNTaxID,Batch_Products.Batch_Code))              
--  End              
-- Else              
--  Sum((Batch_Products.QuantityReceived * Batch_Products.PurchasePrice) + dbo.fn_calculateTax(Batch_Products.Product_code,(Batch_Products.QuantityReceived * Batch_Products.PurchasePrice),Batch_Products.QuantityReceived,@Locality,Batch_Products.GRNTaxID,Batch_Products.Batch_Code))              
-- End As GoodsValue
-- -- END 
 "ItemOrder" = Max(#temp.ItemOrder), "OrgPTS" = Max(#temp.OrgPTS), "PFM" = Max(#temp.PFM), "MRPForTax" = Max(#temp.MRPForTax), "MRPPerPack" = #temp.MRPPerPack
From #temp, Items, ItemCategories
-- ,Batch_Products
Where #temp.Product_Code = Items.Product_Code And    
-- --Begin
-- Batch_Products.Product_Code = Items.Product_Code  and 
-- Batch_Products.GRN_ID = @GRNID  
-- And Batch_Products.Serial = @Serial
-- And Batch_Products.Free = 0    
-- And Batch_Products.UOM = @UOMID
-- And Batch_products.Product_Code = @ItemCode and    
-- --End
Items.CategoryID = ItemCategories.CategoryID    
Group By Items.Virtual_Track_Batches, Items.TrackPKD, ItemCategories.Price_Option,    
#temp.BatchNo, #temp.Expiry, #temp.PKD, #temp.PTS, #temp.PTR, #temp.ECP,     
#temp.Company_Price, #temp.PurchasePrice, Items.Purchased_At, #temp.Product_Code,  
 #Temp.ComboID , #Temp.TaxSuffered, #Temp.GRNTaxID, #Temp.GRNTaxSuffered,  
#Temp.uomid,#Temp.uomprice,#Temp.PFM,#temp.MRPForTax,#temp.MRPPerPack  
-- , Batch_Products.serial, Batch_Products.UOM,Batch_Products.Product_Code, Batch_Products.free    
