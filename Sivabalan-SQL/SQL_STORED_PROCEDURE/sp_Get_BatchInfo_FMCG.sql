CREATE Procedure [dbo].[sp_Get_BatchInfo_FMCG] (@PriceOption  int,           
     @ItemCode nvarchar(20))          
As          
If @PriceOption = 1           
Begin          
	If exists(Select Batch_Code From Batch_Products Where Product_Code = @ItemCode And IsNull(Free, 0) = 0)          
	Begin          
		Select Top 1 Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD, ITEMS.Sale_Price, ITEMS.Purchase_Price "PurchasePrice", Batch_Products.TaxSuffered, 
		 Case When IsNull(Batch_Products.Vat_Locality,0)=2 
				Then IsNull((Select min(Tax_Code) from Tax Where CST_Percentage=Batch_Products.TaxSuffered and CSTApplicableOn=Batch_Products.ApplicableOn and CSTPartOff=Batch_Products.PartofPercentage), 0) 
				Else IsNull((Select min(Tax_Code) from Tax Where Percentage=Batch_Products.TaxSuffered and LSTApplicableOn=Batch_Products.ApplicableOn and LSTPartOff=Batch_Products.PartofPercentage), 0) 
		 		End
		From Batch_Products, ITEMS 
		Where ITEMS.PRODUCT_CODE = BATCH_PRODUCTS.PRODUCT_CODE 
		AND Batch_Products.Batch_Code in (Select Batch_Code From Batch_Products           
		Where Product_Code = @ItemCode And IsNull(Free, 0) = 0) Order By Batch_Products.Batch_Code Desc          
	End          
	Else          
	Begin          
		Select Null, Null, Null, Sale_Price, Purchase_Price "PurchasePrice", Tax.Percentage,Tax.Tax_Code          
		From Items
		Left Outer Join Tax on Items.TaxSuffered = Tax.Tax_Code 
		Where Product_Code = @ItemCode 
		--And Items.TaxSuffered *= Tax.Tax_Code          
	End          
End           
Else          
Begin          
	If exists(Select Batch_Code From Batch_Products Where Product_Code = @ItemCode And IsNull(Free, 0) = 0)          
	Begin          
		Select Top 1 Batch_Number, Expiry, PKD, Items.Sale_Price, Items.Purchase_Price "PurchasePrice",           
		Batch_Products.TaxSuffered, 
		 Case When IsNull(Batch_Products.Vat_Locality,0)=2 
				Then IsNull((Select min(Tax_Code) from Tax Where CST_Percentage=Batch_Products.TaxSuffered and CSTApplicableOn=Batch_Products.ApplicableOn and CSTPartOff=Batch_Products.PartofPercentage), 0) 
				Else IsNull((Select min(Tax_Code) from Tax Where Percentage=Batch_Products.TaxSuffered and LSTApplicableOn=Batch_Products.ApplicableOn and LSTPartOff=Batch_Products.PartofPercentage), 0) 
		 		End
		From Batch_Products, Items          
		Where Batch_Products.Product_Code = Items.Product_Code And          
		Batch_Code in (Select Batch_Code From Batch_Products           
		Where Product_Code = @ItemCode And IsNull(Free, 0) = 0) Order By Batch_Products.Batch_Code Desc          
	End          
	Else          
	Begin          
		Select Null, Null, Null, Sale_Price, Purchase_Price "PurchasePrice", Tax.Percentage,Tax.Tax_Code          
		From Items
		Left Outer Join Tax on Items.TaxSuffered = Tax.Tax_Code
		Where Product_Code = @ItemCode 
		--And Items.TaxSuffered *= Tax.Tax_Code          
	End          
End          
