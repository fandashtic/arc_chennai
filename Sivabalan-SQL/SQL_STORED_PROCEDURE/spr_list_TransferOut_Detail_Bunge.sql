CREATE Procedure spr_list_TransferOut_Detail_Bunge (@DocSerial int)    
As    
Select (StockTransferOutDetail.Product_Code),    
"Item Code" =  (StockTransferOutDetail.Product_Code),    
"Item Name" = (Items.ProductName), "Batch" = (StockTransferOutDetail.Batch_Number),    
"PKD" = (Batch_Products.PKD), "Expiry" = (Batch_Products.Expiry),    
"Quantity" =  Sum(StockTransferOutDetail.Quantity),     
"Rate" = (StockTransferOutDetail.Rate),    
"Amount" =  Sum(StockTransferOutDetail.Amount),    
"PTS" = (StockTransferOutDetail.PTS),    
"PTR" = (StockTransferOutDetail.PTR),    
"ECP" = (StockTransferOutDetail.ECP),    
"Remarks" = Case     
When (IsNull(StockTransferOutDetail.Free, 0)) = 0 Then    
''    
Else    
'Free'    
End    
From StockTransferOutDetail, Batch_Products, Items    
Where StockTransferOutDetail.DocSerial = @DocSerial And    
StockTransferOutDetail.Batch_Code = Batch_Products.Batch_Code And    
StockTransferOutDetail.Product_Code = Items.Product_Code    
Group By StockTransferOutDetail.Serial, StockTransferOutDetail.Product_Code,
Items.ProductName, StockTransferOutDetail.Batch_Number,
Batch_Products.PKD, StockTransferOutDetail.Batch_Number, StockTransferOutDetail.Rate,
Batch_Products.Expiry, StockTransferOutDetail.PTS, StockTransferOutDetail.PTR,
StockTransferOutDetail.ECP,StockTransferOutDetail.Free
Order By StockTransferOutDetail.Serial    


