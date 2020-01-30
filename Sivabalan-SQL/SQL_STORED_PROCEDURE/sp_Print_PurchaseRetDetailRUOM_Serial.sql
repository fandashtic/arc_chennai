CREATE procedure [dbo].[sp_Print_PurchaseRetDetailRUOM_Serial] (@AdjustmentID int)
as
Select 
"Item Code" = AdjustmentReturnDetail.Product_Code, 
"Item Name" = Items.ProductName, 
"Batch" = AdjustmentReturnDetail.BatchNumber, 
"Expiry" = Batch_Products.Expiry, 
"Quantity" = AdjustmentReturnDetail.uomQty,
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
"Total Value" = (AdjustmentReturnDetail.Quantity * AdjustmentReturnDetail.Rate) +
				((AdjustmentReturnDetail.Quantity * AdjustmentReturnDetail.Rate) *
					+ AdjustmentReturnDetail.Tax/100),
"UOMDescription" = uom.description

/*	(Select UOM.Description from UOM Where UOM.UOM in
		(Select UOM from Items 
		Where Items.Product_Code =  AdjustmentReturnDetail.Product_Code ))*/

From 
AdjustmentReturnDetail, 
Items, 
Batch_Products, 
StockAdjustmentReason, 
ItemCategories, 
uom
Where AdjustmentReturnDetail.AdjustmentID = @AdjustmentID AND
AdjustmentReturnDetail.UOM = UOM.UOM and 
Items.CategoryID = ItemCategories.CategoryID and 
AdjustmentReturnDetail.Product_Code = Items.Product_Code AND
AdjustmentReturnDetail.BatchCode = Batch_Products.Batch_Code AND
AdjustmentReturnDetail.ReasonID *= StockAdjustmentReason.MessageID
order by AdjustmentReturnDetail.Serialno
/*
group by AdjustmentReturnDetail.Product_Code, Items.ProductName, 
AdjustmentReturnDetail.BatchNumber, Batch_Products.Expiry, AdjustmentReturnDetail.Quantity,
AdjustmentReturnDetail.Rate, StockAdjustmentReason.Message, AdjustmentReturnDetail.BillID--,
--AdjustmentReturnDetail.Tax, uom.uom
*/
