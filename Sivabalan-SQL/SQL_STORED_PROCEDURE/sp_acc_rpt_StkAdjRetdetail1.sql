CREATE pROCEDURE [dbo].[sp_acc_rpt_StkAdjRetdetail1](@ADJUSTMENTID INT)
AS
DECLARE @BillID int
DECLARE @SPECIALCASE2 INT
Declare @Version Int
SET @SPECIALCASE2 = 5

Set @Version = dbo.sp_acc_getversion()

If @Version = 5 or @Version = 8 or @Version= 18 or @Version=19 or @Version=11
Begin
	Execute sp_acc_rpt_StkAdjRetdetailuom1 @ADJUSTMENTID 
End
Else
Begin
	SELECT Top 1 @BillID = BillAbstract.BillID FROM AdjustmentReturnDetail, BillAbstract WHERE AdjustmentReturnDetail.BillID = BillAbstract.DocumentID AND AdjustmentID = @ADJUSTMENTID
	SELECT  
	"Item Code" = AdjustmentReturnDetail.Product_Code,
	"Item Name" = Items.ProductName, 
	"Quantity" = Sum(AdjustmentReturnDetail.Quantity), 
	'','','','','','','',
	"Purchase Price" = ISNULL(Rate, 0),
	"Value" = isnull(Sum(AdjustmentReturnDetail.Quantity*Rate), 0), 
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
	WHERE 	AdjustmentID = @ADJUSTMENTID 
		--AND 
		--AdjustmentReturnDetail.Product_Code *= Items.Product_Code AND 
		--AdjustmentReturnDetail.ReasonID *= StockAdjustmentReason.MessageID
	GROUP BY AdjustmentReturnDetail.Product_Code, Items.ProductName, 
	Rate, ISNULL(StockAdjustmentReason.Message, N''), AdjustmentReturnDetail.BillID
End
