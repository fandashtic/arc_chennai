Create procedure sp_Get_StkAmendBatch_MUOM(  
@StkTfrID Int,  
@ItemCode nvarchar(20),  
@Serial Int,@UOM int)  
As      
---Stock transferid and itemcode no longer required    
--Batch code is used to fetch exact batch from the batch_products      
Create Table #template1        
(        
 TrackBatch integer,        
 TrackPKD Integer,        
 Priceoption integer,        
 BatchNumber nvarchar(20),        
 BatchExpiry datetime,        
 BatchPKD datetime,        
 Qty Decimal(18,6),        
 BPTS Decimal(18,6),       
 BPTR Decimal(18,6),        
 BECP Decimal(18,6),        
 ComPrice Decimal(18,6),        
 BpurchasePrice Decimal(18,6),        
 FreeQty Decimal(18,6),        
 PurchaseAt integer,        
 TaxSuff Decimal(18,6),        
 TaxID Int,     
 UOMID int,    
 UOMPrice decimal(18,6),
 BPFM Decimal(18,6),
 MRPFORTAX Decimal(18,6)
,  MRPPerPack Decimal(18,6)
)        
        
Insert into #template1        
 Select Items.Virtual_Track_Batches, Items.TrackPKD, ItemCategories.Price_Option,        
  Batch_Products.Batch_Number,         
  Batch_Products.Expiry,         
  Batch_Products.PKD,        
  "Qty"=Batch_Products.QuantityReceived,         
  Batch_Products.PTS, Batch_Products.PTR,         
  Batch_Products.ECP, Batch_Products.Company_Price, Batch_Products.PurchasePrice,        
  "Free"=(Select Isnull(Btab.QuantityReceived,0) From Batch_Products BTAb    
  Where BTab.BatchReference=Batch_products.Batch_code),         
  Items.Purchased_At, Batch_Products.TaxSuffered,     
  StockTransferInDetail.TaxCode,  
--Cm  
   --Case When IsNull(Batch_Products.Vat_Locality,0)=2     
   --Then IsNull((Select min(Tax_Code) from Tax Where CST_Percentage=Batch_Products.TaxSuffered and CSTApplicableOn=Batch_Products.ApplicableOn and CSTPartOff=Batch_Products.PartofPercentage), 0)     
   --Else IsNull((Select min(Tax_Code) from Tax Where Percentage=Batch_Products.TaxSuffered and LSTApplicableOn=Batch_Products.ApplicableOn and LSTPartOff=Batch_Products.PartofPercentage), 0)     
   --End,    
--CM  
  "UOMID" = Batch_Products.uom,    
  "UOMPrice" = Batch_Products.uomprice,Batch_Products.PFM    ,Batch_Products.MRPFORTAX    
,Batch_Products.MRPPerPack
 From Batch_Products
Inner Join Items On Batch_Products.Product_Code = Items.Product_Code
Inner Join ItemCategories On  Items.CategoryID = ItemCategories.CategoryID
Inner Join StockTransferInDetail On Batch_products.Batch_code = StockTransferInDetail.Batch_code
Left Outer Join Tax On  StockTransferInDetail.TaxCode=Tax.Tax_Code  --CM        
 Where  Batch_Products.serial = @Serial And         
 Batch_Products.uom = @uom And         
 IsNull(Batch_Products.Free,0) = 0 and    
 Batch_Products.StockTransferID = @StkTfrID And  
 StockTransferInDetail.Docserial= @StkTfrID And        
 Items.Product_Code = @ItemCode        
           
 Select TrackBatch,TrackPKD,Priceoption,BatchNumber,BatchExpiry,BatchPKD,        
 Isnull(Qty,0),BPTS,BPTR,BECP,ComPrice,BpurchasePrice,Isnull(FreeQty,0),    
 PurchaseAt,TaxSuff,TaxID,uomid,uomprice,BPFM,MRPFORTAX,MRPPerPack From #template1        
 order by batchnumber     
 drop table #template1        
