CREATE Procedure sp_Get_AmendBatch     (@GRNID Int,  
     @ItemCode nvarchar(20),@Serial int=0)  
As  

Declare @maxCnt integer
Select @maxCnt=Max(Isnull(Serial,0)) from batch_products where GRN_ID=@GRNID
--This Checking is done becos in  Upgrade the batch_products serial number will not be present
--And hence the batch will return nothing on opening GRN amendment screen.
if(@maxCnt >0)
	Begin
		Select Items.Virtual_Track_Batches, Items.TrackPKD, ItemCategories.Price_Option,  
		Replace(Batch_Products.Batch_Number, ',', Char( 9)), Batch_Products.Expiry, Batch_Products.PKD,  
		Batch_Products.QuantityReceived, Batch_Products.PTS, Batch_Products.PTR,   
		Batch_Products.ECP, Batch_Products.Company_Price, Batch_Products.PurchasePrice,  
		Batch_Products.Batch_Code, Items.Purchased_At  ,  Batch_Products.TaxSuffered,  Batch_Products.GRNTaxID,  Batch_Products.GRNTaxSuffered
		From Batch_Products, Items, ItemCategories  
		Where Batch_Products.Product_Code = Items.Product_Code And  
		Items.CategoryID = ItemCategories.CategoryID And  
		Batch_Products.GRN_ID = @GRNID And   
		batch_products.Serial = @serial and
		Batch_Products.Free = 0 And  
		Items.Product_Code = @ItemCode  
	End
Else
	Begin
		Select Items.Virtual_Track_Batches, Items.TrackPKD, ItemCategories.Price_Option,  
		Replace(Batch_Products.Batch_Number, ',', Char( 9)), Batch_Products.Expiry, Batch_Products.PKD,  
		Batch_Products.QuantityReceived, Batch_Products.PTS, Batch_Products.PTR,   
		Batch_Products.ECP, Batch_Products.Company_Price, Batch_Products.PurchasePrice,  
		Batch_Products.Batch_Code, Items.Purchased_At  ,  Batch_Products.TaxSuffered,  Batch_Products.GRNTaxID,  Batch_Products.GRNTaxSuffered
		From Batch_Products, Items, ItemCategories  
		Where Batch_Products.Product_Code = Items.Product_Code And  
		Items.CategoryID = ItemCategories.CategoryID And  
		Batch_Products.GRN_ID = @GRNID And   
		Batch_Products.Free = 0 And  
		Items.Product_Code = @ItemCode  
	End


