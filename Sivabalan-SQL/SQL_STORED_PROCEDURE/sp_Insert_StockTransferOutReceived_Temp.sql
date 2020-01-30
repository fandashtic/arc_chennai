CREATE Procedure sp_Insert_StockTransferOutReceived_Temp (@DocSerial int)
As
Declare @DocID int
Declare @Doc int
Declare @ItemCode nvarchar(15)
Declare @Batch nvarchar(255)
Declare @PTS Decimal(18,6)
Declare @PTR Decimal(18,6)
Declare @ECP Decimal(18,6)
Declare @SpecialPrice Decimal(18,6)
Declare @Rate Decimal(18,6)
Declare @Quantity Decimal(18,6)
Declare @Amount Decimal(18,6)
Declare @ForumCode nvarchar(20)
Declare @Expiry datetime
Declare @PKD datetime

Begin Tran
Update DocumentNumbers Set DocumentID = DocumentID + 1 Where DocType = 17
Select @DocID = DocumentID - 1 From DocumentNumbers Where DocType = 17
Insert Into StockTransferOutAbstractReceived (	DocumentID,
						DocumentDate,
						WareHouseID,
						NetValue,
						Status,
						ForumCode,
						OriginalID)
Select @DocID, DocumentDate, WareHouse.WareHouseID, NetValue, 0, WareHouse.ForumID,
DocPrefix + Cast(DocumentID as nvarchar) From StockTransferOutAbstract, WareHouse 
Where StockTransferOutAbstract.WareHouseID = WareHouse.WareHouseID
And StockTransferOutAbstract.DocSerial = @DocSerial

Select @Doc = @@Identity
Declare ReleaseStockTransfer Cursor Keyset For
Select Items.Product_Code, StockTransferOutDetail.Batch_Number, StockTransferOutDetail.PTS, 
StockTransferOutDetail.PTR, StockTransferOutDetail.ECP, StockTransferOutDetail.SpecialPrice, 
StockTransferOutDetail.Rate, StockTransferOutDetail.Quantity, StockTransferOutDetail.Amount, 
Items.Alias, Batch_Products.Expiry, Batch_Products.PKD 
From StockTransferOutDetail, Items, Batch_Products
Where DocSerial = @DocSerial And StockTransferOutDetail.Product_Code = Items.Product_Code
And StockTransferOutDetail.Batch_Code = Batch_Products.Batch_Code

Open ReleaseStockTransfer
Fetch From ReleaseStockTransfer into @ItemCode, @Batch, @PTS, @PTR, @ECP, @SpecialPrice,
@Rate, @Quantity, @Amount, @ForumCode, @Expiry, @PKD
While @@Fetch_Status  = 0
Begin
	Insert Into StockTransferOutDetailReceived (	DocSerial,
							Product_Code,
							Batch_Number,
							PTS,
							PTR,
							ECP,
							SpecialPrice,
							Rate,
							Quantity,
							Amount,
							ForumCode,
							Expiry,
							PKD)
	Values (					@Doc,
							@ItemCode,
							@Batch,
							@PTS,
							@PTR,
							@ECP,
							@SpecialPrice,
							@Rate,
							@Quantity,
							@Amount,
							@ForumCode,
							@Expiry,
							@PKD)
	Fetch Next From	ReleaseStockTransfer into @ItemCode, @Batch, @PTS, @PTR, @ECP,
@SpecialPrice, @Rate, @Quantity, @Amount, @ForumCode, @Expiry, @PKD
End
Close ReleaseStockTransfer
Deallocate ReleaseStockTransfer
Commit Tran
SET QUOTED_IDENTIFIER OFF 
