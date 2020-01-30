
CREATE Procedure sp_get_SRItems(@DocSerial int)    
As    
Declare @ItemCode nvarchar(20)    
Declare @Reqd_Qty Decimal(18,6)    
Declare @Qty Decimal(18,6)    
Declare @ProductCode nvarchar(20)    
Declare @Batch nvarchar(100)    
Declare @PKD datetime    
Declare @Expiry datetime    
Declare @Rate Decimal(18,6)    
Declare @Quantity Decimal(18,6)    
Declare @TaxSuffered Decimal(18,6)    
    
Create Table #temp    
(Product_Code nvarchar(20) null,    
Batch_Number nvarchar(100) null,    
PKD datetime null,    
Expiry datetime null,    
Rate Decimal(18,6) null,    
Quantity Decimal(18,6) null,    
TaxSuffered Decimal(18,6) null)    
    
Declare SRItems Cursor Keyset For    
Select Product_Code, Pending From Stock_Request_Detail_Received     
Where Stk_Req_Number = @DocSerial And     
IsNull(Product_Code, N'') <> N'' And    
Pending <> 0    
    
Open SRItems    
    
Fetch From SRItems into @ItemCode, @Qty    
While @@Fetch_Status = 0    
Begin    
 Set @Reqd_Qty = @Qty    
    
 Declare ReleaseStocks Cursor KeySet For    
 Select Batch_Products.Product_Code, Batch_Products.Batch_Number, Batch_Products.PKD,     
 Batch_Products.Expiry,     
 Batch_Products.PTS,  
 Batch_Products.Quantity,     
 Batch_Products.TaxSuffered     
 From Batch_Products    
 Where Batch_Products.Product_Code = @ItemCode And    
 IsNull(Batch_Products.Free, 0) = 0 And Batch_Products.Quantity > 0    
    
 Open ReleaseStocks    
     
 Fetch From ReleaseStocks into @ProductCode, @Batch, @PKD, @Expiry, @Rate, @Quantity,    
 @TaxSuffered     
 While @@Fetch_Status = 0    
 Begin    
  If @Quantity >= @Reqd_Qty    
  Begin    
   Insert into #temp Values (@ProductCode, @Batch, @PKD, @Expiry,     
   @Rate, @Reqd_Qty, @TaxSuffered)    
   GoTo OvernOut    
  End    
  Else    
  Begin    
   Set @Reqd_Qty = @Reqd_Qty - @Quantity    
   Insert into #temp Values (@ProductCode, @Batch, @PKD, @Expiry,     
   @Rate, @Quantity, @TaxSuffered)       
  End     
  Fetch Next From ReleaseStocks into @ProductCode, @Batch, @PKD, @Expiry,    
  @Rate, @Quantity, @TaxSuffered    
 End    
OvernOut:    
 Close ReleaseStocks    
 DeAllocate ReleaseStocks    
 Fetch Next From SRItems into @ItemCode, @Qty    
End    
Close SRItems    
DeAllocate SRItems    
Select #temp.Product_Code, Items.ProductName, #temp.Batch_Number, #temp.PKD, #temp.Expiry,    
#temp.Rate, Sum(#temp.Quantity), #temp.TaxSuffered, Items.Virtual_Track_Batches,    
Items.TrackPKD, ItemCategories.Price_Option, ItemCategories.Track_Inventory    
From #temp, Items, ItemCategories    
Where #temp.Product_Code collate SQL_Latin1_General_Cp1_CI_AS = Items.Product_Code And    
Items.CategoryID = ItemCategories.CategoryID    
Group By #temp.Product_Code, Items.ProductName, #temp.Batch_Number, #temp.PKD, #temp.Expiry,    
#temp.Rate, #temp.TaxSuffered, Items.Virtual_Track_Batches,    
Items.TrackPKD, ItemCategories.Price_Option, ItemCategories.Track_Inventory    
Drop Table #temp    
  
