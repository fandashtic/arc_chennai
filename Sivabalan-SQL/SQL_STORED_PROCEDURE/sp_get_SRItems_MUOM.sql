CREATE Procedure sp_get_SRItems_MUOM(@STK_REQ_Number int)              
As              
Declare @ProductCode nvarchar(30)          
Declare @ProductName nvarchar(510)          
Declare @BatchNumber nvarchar(128)          
Declare @Expiry nvarchar(128)          
Declare @PKD nvarchar(128)          
Declare @PurchasePrice decimal(18,6)          
Declare @PendingQty nvarchar(62)          
Declare @TaxSuff Decimal(18,6)          
Declare @TrackBatch Int        
Declare @TrackPKD Int        
Declare @PriceOption Int        
Declare @TrackInventory Int        
Declare @UOMDesc nvarchar(510)          
Declare @UOMID Int        
Declare @UOMPrice Decimal(18,6)          
Declare @Serial Int        
Declare @UOM Int        
Declare @UOMConversion Decimal(18,6)          
Declare @Qty Decimal(18,6)          
Declare @Count int          
        
Create Table #TempUOMWiseSRDetail(          
Product_Code nvarchar(30),           
ProductName nvarchar(510),           
Batch_Number nvarchar(128),        
Expiry nvarchar(128),          
PKD nvarchar(128),        
PurchasePrice Decimal(18,6),           
Quantity Decimal(18,6),        
TaxSuff Decimal(18,6),           
TrackBatch Int,         
TrackPKD Int,        
PriceOption Int,         
TrackInventory Int,        
UOM nvarchar(255),        
UOMID Int,           
UOMPrice Decimal(18,6),          
Serial Int        
)          
        
        
Select SRDR.Product_Code, Items.ProductName,               
"BatchNo"= Null, "Expiry"= Null, "PKD"= Null,           
SRDR.PurchasePrice,      
"Quantity" = dbo.GetQtyAsMultiple(SRDR.Product_Code,SRDR.Pending) ,"TaxSuff"= Null,          
Items.Virtual_Track_Batches, Items.TrackPKD,ItemCategories.Price_Option,          
ItemCategories.Track_Inventory,          
"UOM" = dbo.fn_GetUOMDesc(SRDR.UOM,0),          
SRDR.Serial        
Into #TempSRDetail          
From Stock_Request_Detail_Received SRDR, Items, ItemCategories              
Where SRDR.ForumCode = Items.Alias And              
Items.CategoryID = ItemCategories.CategoryID And                      
SRDR.STK_REQ_Number = @STK_REQ_Number          
Order by Serial              
        
Declare CurSRDetails Cursor for Select * from #TempSRDetail          
        
Open CurSRDetails           
        
Fetch From CurSRDetails into @ProductCode,@ProductName,@BatchNumber,@Expiry,@PKD,        
@PurchasePrice,@PendingQty,@TaxSuff,@TrackBatch,@TrackPKD,@PriceOption,@TrackInventory,@UOMDesc,@Serial        
        
While @@Fetch_Status = 0          
Begin          
 Set @count = 0           
 Select * into #TempQty From Dbo.Sp_SplitIn2Rows(@PendingQty,'*')          
 Declare CurQty Cursor for Select * from #TempQty          
 Open CurQty          
 Fetch From CurQty into @Qty          
 While @@Fetch_Status = 0          
 Begin           
  Set @count = @count + 1          
  If @Qty > 0          
  Begin          
   if @count = 1           
   begin          
   Select @UOM = UOM2, @UOMConversion = UOM2_Conversion           
   From Items Where Product_Code = @ProductCode          
   end          
   else if @count = 2          
   begin          
   Select @UOM = UOM1, @UOMConversion = UOM1_Conversion           
   From Items Where Product_Code = @ProductCode          
   end          
  else          
  begin          
  Select @UOM = UOM, @UOMConversion = 1           
  From Items Where Product_Code = @ProductCode          
  end           
  select @UomDesc = Description from UOM where UOM = @UOM          
  Set @UOMPrice = @PurchasePrice * @UOMConversion          
  --set @Qty = @Qty * @UOMConversion          
         
  Insert into #TempUOMWiseSRDetail        
  (Product_Code,ProductName,Batch_Number,Expiry,PKD,PurchasePrice,Quantity,TaxSuff,        
  TrackBatch,TrackPKD,PriceOption,TrackInventory,UOM,UOMID,UOMPrice,Serial)             
  Values         
  (@ProductCode,@ProductName,@BatchNumber,@Expiry,@PKD,@UOMPrice,@Qty,@TaxSuff,        
  @TrackBatch,@TrackPKD,@PriceOption,@TrackInventory,@UOMDesc,@UOM,@UOMPrice,@Serial)        
  End          
  Fetch From CurQty into @Qty          
 End    
 Fetch From CurSRDetails into @ProductCode,@ProductName,@BatchNumber,@Expiry,@PKD,        
 @PurchasePrice,@PendingQty,@TaxSuff,@TrackBatch,@TrackPKD,@PriceOption,@TrackInventory,@UOMDesc,@Serial        
 Drop table #TempQty           
        
 Close CurQty          
 Deallocate CurQty          
End          
Close CurSRDetails          
        
Select Product_Code,Max(ProductName),        
Max(Batch_Number),Max(Expiry),Max(PKD),Max(PurchasePrice),Sum(Quantity),Max(TaxSuff),        
Max(TrackBatch),Max(TrackPKD),Max(PriceOption),Max(TrackInventory),        
Max(UOM) "UOM",UOMID,Max(UOMPrice),Max(Serial) "Serial"        
From #TempUOMWiseSRDetail         
Group By Product_Code,UOMID        
Order by Min(Serial)        
        
Deallocate CurSRDetails          
Drop table #TempSRDetail          
Drop Table #TempUOMWiseSRDetail           
    
  


