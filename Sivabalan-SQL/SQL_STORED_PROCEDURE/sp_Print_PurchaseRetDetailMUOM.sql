CREATE procedure sp_Print_PurchaseRetDetailMUOM (@AdjustmentID int)  
As  
Select   
"Item Code" = AdjustmentReturnDetail.Product_Code,   
"Item Name" = Items.ProductName,   
"Batch" = AdjustmentReturnDetail.BatchNumber,   
"Expiry" = Batch_Products.Expiry,   
"Rate" = AdjustmentReturnDetail.Rate,   
"Reason" = StockAdjustmentReason.Message,   
"Bill Reference" = (  
 Select (case isnull(BillReference, N'')   
  when N'' then Bill.Prefix else BillAmend.Prefix end) +  
  cast(DocumentID as nvarchar)   
 From BillAbstract, VoucherPrefix Bill, VoucherPrefix BillAmend  
 Where   
  BillID = AdjustmentReturnDetail.BillID AND   
  Bill.TranID = N'BILL' AND  
  BillAmend.TranID = N'BILL AMENDMENT'),  
"Bill Date" = (  
 Select BillDate From BillAbstract   
 Where BillID = AdjustmentReturnDetail.BillID),  
"Bill Qty" = (  
 Select Sum(Quantity) From BillDetail, BillAbstract  
 Where Product_Code = AdjustmentReturnDetail.Product_Code And  
  BillAbstract.BillID = BillDetail.BillID  
 Group By BillDetail.Product_Code),  
"Bill Value" = (Select Value From BillAbstract Where   
BillID = AdjustmentReturnDetail.BillID),  
"Tax" = AdjustmentReturnDetail.Tax,  
"Total Value" =   
  sum((AdjustmentReturnDetail.quantity * AdjustmentReturnDetail.Rate) +   
  (  
   (AdjustmentReturnDetail.quantity * AdjustmentReturnDetail.Rate) *   
   AdjustmentReturnDetail.Tax/100  
  )),  
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(AdjustmentReturnDetail.Product_Code, Sum(AdjustmentReturnDetail.Quantity)),    
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  AdjustmentReturnDetail.Product_Code )),    
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(AdjustmentReturnDetail.Product_Code, Sum(AdjustmentReturnDetail.Quantity)),    
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  AdjustmentReturnDetail.Product_Code )),    
"UOMQuantity" = dbo.GetLastLevelUOMQty(AdjustmentReturnDetail.Product_Code, Sum(AdjustmentReturnDetail.Quantity)),    
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  AdjustmentReturnDetail.Product_Code ))  
  
From AdjustmentReturnDetail
Inner Join Items ON AdjustmentReturnDetail.Product_Code = Items.Product_Code
Inner Join Batch_Products ON AdjustmentReturnDetail.BatchCode = Batch_Products.Batch_Code
Left Outer Join StockAdjustmentReason ON AdjustmentReturnDetail.ReasonID = StockAdjustmentReason.MessageID
Inner Join ItemCategories ON Items.CategoryID = ItemCategories.CategoryID
Left Outer Join UOM  ON AdjustmentReturnDetail.UOM = UOM.UOM
Where AdjustmentReturnDetail.AdjustmentID = @AdjustmentID 
Group By AdjustmentReturnDetail.Product_Code, Items.ProductName,   
ItemCategories.Category_Name, AdjustmentReturnDetail.BatchNumber,   
Batch_Products.Expiry, AdjustmentReturnDetail.rate, StockAdjustmentReason.Message,  
AdjustmentReturnDetail.BillID, AdjustmentReturnDetail.Tax  

