
CREATE PROCEDURE spr_list_StkAdjRetItems(@ADJUSTMENTID INT)
AS
DECLARE @BillID int

SELECT @BillID = Max(BillAbstract.BillID) 
FROM AdjustmentReturnDetail, BillAbstract WHERE AdjustmentReturnDetail.BillID = BillAbstract.DocumentID AND AdjustmentID = @ADJUSTMENTID

SELECT 
"Product_Code"=Max(AdjustmentReturnDetail.Product_Code), 
"Item Code" = Max(AdjustmentReturnDetail.Product_Code),
"Item Name" = Max(Items.ProductName), 
"Quantity" = Sum(AdjustmentReturnDetail.Quantity), 
"Purchase Price" = Max(ISNULL(Rate, 0)),
"Value" = isnull(Sum(AdjustmentReturnDetail.Quantity*Rate), 0), 
"Reason" = Max(ISNULL(StockAdjustmentReason.Message, N'')),

"Bill No" = (Select case Max(ISNULL(BillAbstract.BillReference , N''))
	When N'' then 
		Max(Bill.Prefix)
	else
		Max(BillAmend.Prefix)
	end
	+ cast(Max(DocumentID) as nvarchar) From BillAbstract, VoucherPrefix Bill, 
	VoucherPrefix BillAmend
	Where BillID = Max(AdjustmentReturnDetail.BillID) AND
	Bill.TranID = N'BILL' AND
	BillAmend.TranID = N'BILL AMENDMENT'),

"Bill Date" = (Select Max(BillDate) From BillAbstract Where BillID = @BillID),

"Orig Qty" = (Select SUM(Quantity) From BillDetail
	 Where BillID = @BillID AND
	Product_Code = Max(AdjustmentReturnDetail.Product_Code)),

"Orig Value" = (Select SUM(Value) From BillAbstract Where BillID = @BillID)

FROM AdjustmentReturnDetail, Items, StockAdjustmentReason

WHERE 	AdjustmentID = @ADJUSTMENTID AND 
	AdjustmentReturnDetail.Product_Code = Items.Product_Code AND 
	AdjustmentReturnDetail.ReasonID = StockAdjustmentReason.MessageID
GROUP BY 
	AdjustmentReturnDetail.SerialNo
Order By
	AdjustmentReturnDetail.SerialNo

