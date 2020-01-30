CREATE procedure [dbo].[sp_Print_PurchaseDetail] (@AdjustmentID int)  
as  


DECLARE @BillID int  

SELECT @BillID = Max(BillAbstract.BillID)   
FROM AdjustmentReturnDetail, BillAbstract WHERE AdjustmentReturnDetail.BillID = BillAbstract.DocumentID AND AdjustmentID = @AdjustmentID  


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
Where BillID = @BillID),  
"Bill Qty" = (Select Sum(Quantity) From BillDetail  
Where Product_Code = AdjustmentReturnDetail.Product_Code And  
BillDetail.BillID = @BillID Group By BillDetail.Product_Code),  
"Bill Value" = (Select Value From BillAbstract Where   
BillID = @BillID),  
"Tax" = AdjustmentReturnDetail.Tax,  
"Total Value" = AdjustmentReturnDetail.Total_Value  
From AdjustmentReturnAbstract, AdjustmentReturnDetail, Items, Batch_Products, StockAdjustmentReason, ItemCategories  
Where AdjustmentReturnDetail.AdjustmentID = @AdjustmentID AND  
AdjustmentReturnDetail.Product_Code = Items.Product_Code AND  
AdjustmentReturnDetail.BatchCode = Batch_Products.Batch_Code AND  
ItemCategories.CategoryID = Items.CategoryID And   
AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID And   
AdjustmentReturnDetail.ReasonID *= StockAdjustmentReason.MessageID  
order by AdjustmentReturnDetail.Product_Code
