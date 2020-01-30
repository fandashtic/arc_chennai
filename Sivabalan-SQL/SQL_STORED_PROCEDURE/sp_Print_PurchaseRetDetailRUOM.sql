Create procedure sp_Print_PurchaseRetDetailRUOM (@AdjustmentID int)
as
Select 
"Item Code" = AdjustmentReturnDetail.Product_Code, 
"Item Name" = Items.ProductName, 
"Batch" = AdjustmentReturnDetail.BatchNumber, 
"Expiry" = Max(Batch_Products.Expiry), 
"Quantity" = Sum(AdjustmentReturnDetail.uomQty),
"Rate" = AdjustmentReturnDetail.uomprice, 
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
"Bill Value" = (
	Select Value From BillAbstract Where BillID = AdjustmentReturnDetail.BillID),
"Tax" = AdjustmentReturnDetail.Tax,
"Total Value" = Sum((AdjustmentReturnDetail.Quantity * AdjustmentReturnDetail.Rate) +
				   (
						(AdjustmentReturnDetail.Quantity * AdjustmentReturnDetail.Rate) *
						 AdjustmentReturnDetail.Tax/100
					)),
"UOMDescription" = uom.description

/*	(Select UOM.Description from UOM Where UOM.UOM in
		(Select UOM from Items 
		Where Items.Product_Code =  AdjustmentReturnDetail.Product_Code ))*/

From 
AdjustmentReturnDetail 
Inner Join Items On AdjustmentReturnDetail.Product_Code = Items.Product_Code
Inner Join Batch_Products On AdjustmentReturnDetail.BatchCode = Batch_Products.Batch_Code
Left Outer Join StockAdjustmentReason On AdjustmentReturnDetail.ReasonID = StockAdjustmentReason.MessageID 
Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID
Inner Join uom On AdjustmentReturnDetail.UOM = UOM.UOM
Where AdjustmentReturnDetail.AdjustmentID = @AdjustmentID 
Group By
AdjustmentReturnDetail.Product_Code, Items.ProductName,
AdjustmentReturnDetail.BatchNumber, 
AdjustmentReturnDetail.uomprice, StockAdjustmentReason.Message, AdjustmentReturnDetail.BillID,
AdjustmentReturnDetail.Tax, uom.Description
order by AdjustmentReturnDetail.Product_Code

