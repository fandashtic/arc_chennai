CREATE PROCEDURE [dbo].[sp_acc_rpt_StkAdjRetdetailuom1](@ADJUSTMENTID INT)
AS
DECLARE @BillID int
DECLARE @SPECIALCASE2 INT
SET @SPECIALCASE2 = 5

SELECT Top 1 @BillID = BillAbstract.BillID FROM AdjustmentReturnDetail, BillAbstract WHERE AdjustmentReturnDetail.BillID = BillAbstract.DocumentID AND AdjustmentID = @ADJUSTMENTID
SELECT  
"Item Code" = AdjustmentReturnDetail.Product_Code,
"Item Name" = Items.ProductName, 
"Description" = UOM.[Description], 
'','','','','','','',
"UOM Quantity" = Max(AdjustmentReturnDetail.UOMQty), 
"UOM Price" = Max(AdjustmentReturnDetail.UOMPrice),
"Purchase Price" = ISNULL(Rate, 0),
"Value" = isnull(Sum(AdjustmentReturnDetail.Quantity*Rate), 0), 
"Tax" = Max(Tax),
"Tax Amount" = ((Max(Quantity)* Max(Rate))* Max(Tax)/100),
"Total Amount" = isnull(Sum(AdjustmentReturnDetail.Quantity*Rate), 0) + ((Max(Quantity)* Max(Rate))* Max(Tax)/100),
"Reason" = ISNULL(StockAdjustmentReason.Message, N''),
"Bill No" = (Select case ISNULL(BillAbstract.BillReference , N'')
	When N'' then 
	Bill.Prefix
	else
	BillAmend.Prefix
	end
	+ cast(DocumentID as nvarchar) From BillAbstract, VoucherPrefix Bill, 
	VoucherPrefix BillAmend
	Where BillID = AdjustmentReturnDetail.BillID AND
	Bill.TranID = dbo.LookupDictionaryItem('BILL',Default) AND
	BillAmend.TranID = dbo.LookupDictionaryItem('BILL AMENDMENT',Default)),
"Bill Date" = (Select BillDate From BillAbstract Where BillID = @BillID),
"Orig Qty" = (Select SUM(Quantity) From BillDetail
	 Where BillID = @BillID AND
	Product_Code = AdjustmentReturnDetail.Product_Code),
"Orig Value" = (Select SUM(Value) From BillAbstract Where BillID = @BillID),@SPECIALCASE2
FROM AdjustmentReturnDetail
Left Outer Join Items on AdjustmentReturnDetail.Product_Code = Items.Product_Code
Left Outer Join StockAdjustmentReason on AdjustmentReturnDetail.ReasonID = StockAdjustmentReason.MessageID
Left Outer Join UOM on AdjustmentReturnDetail.UOM = UOM.UOM
WHERE 	AdjustmentID = @ADJUSTMENTID 
	--AND 
	--AdjustmentReturnDetail.Product_Code *= Items.Product_Code AND 
	--AdjustmentReturnDetail.ReasonID *= StockAdjustmentReason.MessageID
	--And AdjustmentReturnDetail.UOM *= UOM.UOM
GROUP BY AdjustmentReturnDetail.Product_Code, Items.ProductName, 
Rate, ISNULL(StockAdjustmentReason.Message, N''), AdjustmentReturnDetail.BillID,
UOM.UOM,UOM.[Description]
