CREATE Procedure sp_Get_StkAmendBatch_FMCG_MUOM(@StkTfrID Int,@ItemCode nvarchar(20),
	@Serial int , @UOMID int)
As
Create Table #template1
(
TrackBatch integer,
TrackPKD Integer,
Priceoption integer,
BatchNumber nvarchar(20),
BatchExpiry datetime,
BatchPKD datetime,
Qty Decimal(18,6),
BSalePrice Decimal(18,6),
BpurchasePrice Decimal(18,6),
FreeQty Decimal(18,6),
TaxSuff Decimal(18,6),
TaxID Int
)

Insert into #template1 
	Select Items.Virtual_Track_Batches, Items.TrackPKD, ItemCategories.Price_Option,
	Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD,
	"Qty"=Batch_Products.QuantityReceived, 
	Batch_Products.SalePrice, Batch_Products.PurchasePrice,
	"Free"=(Select Isnull(BTab.QuantityReceived,0) From Batch_Products BTAb Where BTab.BatchReference =Batch_products.Batch_code) ,
	Batch_Products.TaxSuffered, 
	Case When IsNull(Batch_Products.Vat_Locality,0)=2 
		Then IsNull((Select min(Tax_Code) from Tax Where CST_Percentage=Batch_Products.TaxSuffered and CSTApplicableOn=Batch_Products.ApplicableOn and CSTPartOff=Batch_Products.PartofPercentage), 0) 
		Else IsNull((Select min(Tax_Code) from Tax Where Percentage=Batch_Products.TaxSuffered and LSTApplicableOn=Batch_Products.ApplicableOn and LSTPartOff=Batch_Products.PartofPercentage), 0) 
		End
	From Batch_Products, Items, ItemCategories 
	Where Batch_Products.Product_Code = Items.Product_Code And
	Items.CategoryID = ItemCategories.CategoryID And
	Batch_Products.StockTransferID =@StkTfrID  And 
	batch_products.Serial = @Serial and
	batch_products.UOm = @uomID and
	Batch_Products.Free = 0 And
	Items.Product_Code =@ItemCode 


Select TrackBatch,TrackPKD,Priceoption,BatchNumber,BatchExpiry,BatchPKD,
Sum(Qty),BSalePrice,BpurchasePrice,
Sum(FreeQty),TaxSuff,TaxID From #template1
Group by TrackBatch,TrackPKD,Priceoption,BatchNumber,BatchExpiry,BatchPKD,
BSalePrice,BpurchasePrice,TaxSuff,TaxID

Drop table #template1




