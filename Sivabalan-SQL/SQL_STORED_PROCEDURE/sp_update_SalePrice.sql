Create PROCEDURE sp_update_SalePrice    
(    
 @ItemCode as nVarchar(15),     
 @PriceAtUOMLevel as Int,
 @Version nVarChar(15) = N''
)          
AS     
BEGIN
	DECLARE @nconvFactor Decimal(18,6) 
	Declare @PriceOption int
	Declare @ScreenCode nVarchar(100)

	If @Version = 'CUG' 
	Begin
		Select @ScreenCode = ScreenCode from tbl_mERP_ConfigAbstract 
		Where ScreenName = 'Import Item Modify'

		If IsNull((Select Flag from tbl_mERP_ConfigDetail 
		Where ScreenCode = @ScreenCode And ControlName = 'PriceAtUOMLevel'),1) <> 0
		Begin
			SET @nconvFactor = 1
			IF @PriceAtUOMLevel=1
				SET @nconvFactor = (SELECT UOM1_Conversion FROM Items WHERE Product_Code=@ItemCode)
			ELSE IF @PriceAtUOMLevel=2
				SET @nconvFactor = (SELECT UOM2_Conversion FROM Items WHERE Product_Code=@ItemCode)
			IF @nconvFactor>0     
			BEGIN 
				
				If IsNull((Select Flag from tbl_mERP_ConfigDetail 
				Where ScreenCode = @ScreenCode And ControlName = 'SpecialPrice'),1) <> 0
				UPDATE Items SET Company_Price = Company_Price/@nconvFactor WHERE Product_Code=@ItemCode

				If IsNull((Select Flag from tbl_mERP_ConfigDetail 
				Where ScreenCode = @ScreenCode And ControlName = 'ECP'),1) <> 0
				UPDATE Items SET Sale_Price = Sale_Price/@nconvFactor  WHERE Product_Code=@ItemCode


				If IsNull((Select Flag from tbl_mERP_ConfigDetail 
				Where ScreenCode = @ScreenCode And ControlName = 'PTS'),1) <> 0
				UPDATE Items SET PTS = PTS/@nconvFactor WHERE Product_Code=@ItemCode  

				If IsNull((Select Flag from tbl_mERP_ConfigDetail 
				Where ScreenCode = @ScreenCode And ControlName = 'PTR'),1) <> 0
				UPDATE Items SET PTR = PTR/@nconvFactor  WHERE Product_Code=@ItemCode 

				If IsNull((Select Flag from tbl_mERP_ConfigDetail 
				Where ScreenCode = @ScreenCode And ControlName = 'ECP'),1) <> 0
				UPDATE Items SET ECP = ECP/@nconvFactor WHERE Product_Code=@ItemCode  

				If IsNull((Select Flag from tbl_mERP_ConfigDetail 
				Where ScreenCode = @ScreenCode And ControlName = 'PurchasedAT'),1) <> 0
				UPDATE Items SET Purchase_Price = Purchase_Price/@nconvFactor WHERE Product_Code=@ItemCode 

				If IsNull((Select Flag from tbl_mERP_ConfigDetail 
				Where ScreenCode = @ScreenCode And ControlName = 'MRP'),1) <> 0
				UPDATE Items SET MRP = MRP/@nconvFactor WHERE Product_Code=@ItemCode

   
				select @priceOption=price_option from ItemCategories where CategoryId in( select categoryId from items where Product_code=@ITEMCODE)
				If @PriceOption = 0
				Begin
					--Locking of fields need not be checked here as it will be restricted in the item master
					--table iself whatever is there in the item master will be updated in the batch_products
					Update Batch_Products set Company_Price=Items.Company_Price , 
					SalePrice = Items.Sale_Price,PTS = Items.PTS, PTR = Items.PTR , 
					ECP = Items.ECP from Batch_Products Batch , Items
					where Batch.Product_code = Items.Product_code and IsNull([free],0) <> 1
				End
			END    
		End
	End 
	Else
	Begin
		SET @nconvFactor = 1
			IF @PriceAtUOMLevel=1
				SET @nconvFactor = (SELECT UOM1_Conversion FROM Items WHERE Product_Code=@ItemCode)
			ELSE IF @PriceAtUOMLevel=2
				SET @nconvFactor = (SELECT UOM2_Conversion FROM Items WHERE Product_Code=@ItemCode)
			IF @nconvFactor>0     
			BEGIN    
				 UPDATE Items SET Company_Price = Company_Price/@nconvFactor, Sale_Price = Sale_Price/@nconvFactor,     
				 PTS = PTS/@nconvFactor, PTR = PTR/@nconvFactor, ECP = ECP/@nconvFactor,  
				 Purchase_Price = Purchase_Price/@nconvFactor, MRP = MRP/@nconvFactor    
				 WHERE Product_Code=@ItemCode    

				select @priceOption=price_option from ItemCategories where CategoryId in( select categoryId from items where Product_code=@ITEMCODE)
				If @PriceOption = 0
				Begin
					Update Batch_Products set Company_Price=Items.Company_Price , 
					SalePrice = Items.Sale_Price,PTS = Items.PTS, PTR = Items.PTR , 
					ECP = Items.ECP from Batch_Products Batch , Items
					where Batch.Product_code = Items.Product_code and IsNull([free],0) <> 1
				End
			END    
	End
END


