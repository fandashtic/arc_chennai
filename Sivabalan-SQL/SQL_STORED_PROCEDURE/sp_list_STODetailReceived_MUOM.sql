Create Procedure sp_list_STODetailReceived_MUOM(@DocID NVarchar(50))    
As    
Begin    
 Select     
 Items.Product_Code,    
 Items.ProductName,    
 StockTransferOutDetailReceived.Batch_Number,    
 StockTransferOutDetailReceived.Expiry,    
 StockTransferOutDetailReceived.PKD,    
 StockTransferOutDetailReceived.PTS,    
 StockTransferOutDetailReceived.PTR,    
 StockTransferOutDetailReceived.ECP,    
 StockTransferOutDetailReceived.SpecialPrice,    
 StockTransferOutDetailReceived.RATE,    
 Sum(QUANTITY),    
 Sum(AMOUNT),    
 Items.Virtual_Track_Batches,    
 ItemCategories.Track_Inventory,    
 ItemCategories.Price_Option,    
 Items.TrackPKD,    
 Items.Purchased_At,    
 StockTransferOutDetailReceived.Free,    
 StockTransferOutDetailReceived.TaxSuffered,    
 Sum(StockTransferOutDetailReceived.TaxAmount),    
 Sum(StockTransferOutDetailReceived.TotalAmount),    
 max(StockTransferOutDetailReceived.Applicableon),    
 max(StockTransferOutDetailReceived.partoff),    
 StockTransferOutDetailReceived.UOM    
 From StockTransferOutDetailReceived, Items, ItemCategories    
 Where DocSerial in (@DocID)    
 And StockTransferOutDetailReceived.Product_Code = Items.Product_Code And    
 Items.CategoryID = ItemCategories.CategoryID And Items.Active = 1    
 Group By Items.Product_Code, Items.ProductName,    
 StockTransferOutDetailReceived.Batch_Number, StockTransferOutDetailReceived.PTS,    
 StockTransferOutDetailReceived.PTR, StockTransferOutDetailReceived.ECP,    
 StockTransferOutDetailReceived.SpecialPrice, StockTransferOutDetailReceived.Rate,    
 Items.Virtual_Track_Batches, StockTransferOutDetailReceived.Expiry,    
 StockTransferOutDetailReceived.PKD, ItemCategories.Track_Inventory,    
 ItemCategories.Price_Option, Items.TrackPKD, Items.Purchased_At,    
 StockTransferOutDetailReceived.Free, StockTransferOutDetailReceived.TaxSuffered,    
 StockTransferOutDetailReceived.UOM
 Order By Items.Product_Code,StockTransferOutDetailReceived.UOM  
End    
