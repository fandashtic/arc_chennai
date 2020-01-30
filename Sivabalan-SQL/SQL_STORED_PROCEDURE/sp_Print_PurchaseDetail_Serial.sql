CREATE procedure [dbo].[sp_Print_PurchaseDetail_Serial](@AdjustmentID int)  
as  
Select   
"Item Code" = AdjustmentReturnDetail.Product_Code,   
"Item Name" = Items.ProductName,   
"Batch" = AdjustmentReturnDetail.BatchNumber,   
"Expiry" = cast(month(Batch_Products.Expiry) as nvarchar) + N'/' + cast(year(Batch_Products.Expiry) as nvarchar),   
"Quantity" = AdjustmentReturnDetail.Quantity,  
"Rate" = AdjustmentReturnDetail.Rate,   
"Reason" = StockAdjustmentReason.Message,   
"Bill Reference" = (Select (case isnull(BillReference, N'')   
when N'' then Bill.Prefix else BillAmend.Prefix end) +  
cast(DocumentID as nvarchar) From BillAbstract, VoucherPrefix Bill, VoucherPrefix BillAmend  
Where BillID = AdjustmentReturnDetail.BillID AND Bill.TranID = N'BILL' AND  
BillAmend.TranID = N'BILL AMENDMENT'),  
"Bill Date" = (Select BillDate From BillAbstract   
Where BillID = AdjustmentReturnDetail.BillID),  
"Bill Qty" = (Select Sum(Quantity) From BillDetail, BillAbstract  
Where Product_Code = AdjustmentReturnDetail.Product_Code And  
BillAbstract.BillID = BillDetail.BillID  
Group By BillDetail.Product_Code),  
"Bill Value" = (Select Value From BillAbstract Where   
BillID = AdjustmentReturnDetail.BillID),  
"Tax" = AdjustmentReturnDetail.Tax,  
"Total Value" = AdjustmentReturnDetail.Total_Value  
From AdjustmentReturnAbstract, AdjustmentReturnDetail, Items, Batch_Products, StockAdjustmentReason, ItemCategories  
Where AdjustmentReturnDetail.AdjustmentID = @AdjustmentID AND  
AdjustmentReturnDetail.Product_Code = Items.Product_Code AND  
AdjustmentReturnDetail.BatchCode = Batch_Products.Batch_Code AND  
ItemCategories.CategoryID = Items.CategoryID And   
AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID And   
AdjustmentReturnDetail.ReasonID *= StockAdjustmentReason.MessageID  
order by AdjustmentReturnDetail.serialno
