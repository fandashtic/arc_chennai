CREATE Procedure sp_Get_StkAmendBatch (	@StkTfrID Int,
					@ItemCode nvarchar(20),@Serial int =0)
As
Select Items.Virtual_Track_Batches, Items.TrackPKD, ItemCategories.Price_Option,
Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD,
Batch_Products.QuantityReceived, Batch_Products.PTS, Batch_Products.PTR, 
Batch_Products.ECP, Batch_Products.Company_Price, Batch_Products.PurchasePrice,
Batch_Products.Batch_Code, Items.Purchased_At, Batch_Products.TaxSuffered, 
Case When IsNull(Batch_Products.Vat_Locality,0)=2 
	Then IsNull((Select min(Tax_Code) from Tax Where CST_Percentage=Batch_Products.TaxSuffered and CSTApplicableOn=Batch_Products.ApplicableOn and CSTPartOff=Batch_Products.PartofPercentage), 0) 
	Else IsNull((Select min(Tax_Code) from Tax Where Percentage=Batch_Products.TaxSuffered and LSTApplicableOn=Batch_Products.ApplicableOn and LSTPartOff=Batch_Products.PartofPercentage), 0) 
	End
From Batch_Products, Items, ItemCategories
Where Batch_Products.Product_Code = Items.Product_Code And
Items.CategoryID = ItemCategories.CategoryID And
Batch_Products.StockTransferID = @StkTfrID And 
Batch_Products.serial = @Serial And  
Batch_Products.Free = 0 And
--Batch_Products.QuantityReceived > 0 And
Items.Product_Code = @ItemCode



