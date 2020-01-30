CREATE PROCEDURE sp_get_bookstock_RetailReturn(@PRODUCT_CODE nvarchar(15),  
 @TRACK_BATCH int,  
 @CAPTURE_PRICE int,  
 @CUSTOMER_TYPE int,  
 @UNUSED int = 0)  
AS
 
IF @TRACK_BATCH = 1  
BEGIN  
	IF @CUSTOMER_TYPE = 1   
	BEGIN  
		Select Batch_Number, Expiry, SUM(Quantity), PTS, PKD,   
			isnull(Free, 0), IsNull(TaxSuffered, 0) , isnull(Max(ECP), 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
			Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), Tax.Tax_Description    
		From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code  
		where Product_Code= @PRODUCT_CODE And ISNULL(Damage, 0) = 0   
		Group By Batch_Number, Expiry, PTS, PKD, isnull(Free, 0)  ,  
			IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),isnull(GRNTaxID,0),Tax.Tax_Description  
		Having sum(Quantity) > 0  
		Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code)   
	END  
	ELSE IF @CUSTOMER_TYPE = 2   
	BEGIN  
		Select Batch_Number, Expiry, SUM(Quantity), PTR, PKD,   
			isnull(Free, 0), IsNull(TaxSuffered, 0), isnull(Max(ECP), 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
			Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), Tax.Tax_Description    
		From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code  
		where Product_Code= @PRODUCT_CODE And ISNULL(Damage, 0) = 0   
		Group By Batch_Number, Expiry, PTR, PKD, isnull(Free, 0)   ,  
			IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),isnull(GRNTaxID,0),Tax.Tax_Description  
		Having sum(Quantity) > 0  
		Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code)   
	END  
	ELSE IF @CUSTOMER_TYPE = 3   
	BEGIN  
		Select Batch_Number, Expiry, SUM(Quantity), Company_Price, PKD,   
			isnull(Free, 0), IsNull(TaxSuffered, 0), isnull(Max(ECP), 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
			Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), Tax.Tax_Description    
		From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code  
		where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0   
		Group By Batch_Number, Expiry, Company_Price, PKD, isnull(Free, 0)  ,  
			IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),isnull(GRNTaxID,0),Tax.Tax_Description  
		Having sum(Quantity) > 0  
		Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code)   
	END  
	ELSE IF @CUSTOMER_TYPE = 4   
	BEGIN  
		Select Batch_Number, Expiry, SUM(Quantity), ECP, PKD,   
			isnull(Free, 0), IsNull(TaxSuffered, 0), isnull(Max(ECP), 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0) ,  
			Isnull(ApplicableOn,0), Isnull(Partofpercentage,0) ,  
	  --To display the batch in the last row if that batch has Zero Quantity  
			case SUM(batch_products.Quantity) when 0 then 1 else 0 end as QtyOrder, Tax.Tax_Description 
		From Batch_Products  Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code 
		where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0   
		Group By Batch_Number, Expiry, ECP, PKD, isnull(Free, 0)   ,  
			IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),isnull(GRNTaxID,0),Tax.Tax_Description  
		Having sum(Quantity) > 0  
		Order By QtyOrder,Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code)   
	END  
END  
ELSE  
BEGIN  
	IF @CUSTOMER_TYPE = 1   
	BEGIN  
		Select N'', '', SUM(Quantity), PTS, PKD, isnull(Free, 0),   
			IsNull(TaxSuffered, 0), isnull(Max(ECP), 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0) ,  
			Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), Tax.Tax_Description   
		From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code  
		where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0   
		Group By PTS, PKD, isnull(Free, 0)  ,  
			IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),isnull(GRNTaxID,0),Tax.Tax_Description   
		Having sum(Quantity) > 0  
		Order By Isnull(Free, 0), PKD, MIN(Batch_Code)   
	END  
	ELSE IF @CUSTOMER_TYPE = 2   
	BEGIN  
		Select N'', '', SUM(Quantity), PTR, PKD, isnull(Free, 0),   
			IsNull(TaxSuffered, 0), isnull(Max(ECP), 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
			Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), Tax.Tax_Description    
		From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code  
		where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0   
		Group By PTR, PKD, isnull(Free, 0)   ,  
			IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),isnull(GRNTaxID,0),Tax.Tax_Description  
		Having sum(Quantity) > 0  
		Order By Isnull(Free, 0), PKD, MIN(Batch_Code)   
	END  
	ELSE IF @CUSTOMER_TYPE = 3   
	BEGIN  
		Select N'', '', SUM(Quantity), Company_Price, PKD, isnull(Free, 0),   
			IsNull(TaxSuffered, 0), isnull(Max(ECP), 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
			Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), Tax.Tax_Description  
		From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code  
		where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0   
		Group By Company_Price, PKD, isnull(Free, 0)   ,  
			IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),isnull(GRNTaxID,0),Tax.Tax_Description  
		Having sum(Quantity) > 0  
		Order By Isnull(Free, 0), PKD, MIN(Batch_Code)   
	END  
	ELSE IF @CUSTOMER_TYPE = 4   
	BEGIN  
		Select N'', '', SUM(Quantity), ECP, PKD, isnull(Free, 0),   
			IsNull(TaxSuffered, 0), isnull(Max(ECP), 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
			Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),  
	  --To display the batch in the last row if that batch has Zero Quantity  
			case SUM(batch_products.Quantity) when 0 then 1 else 0 end as QtyOrder, Tax.Tax_Description  
		From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code  
		where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0   
		Group By ECP, PKD, isnull(Free, 0)   ,  
			IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),isnull(GRNTaxID,0),Tax.Tax_Description  
		Having sum(Quantity) > 0  
		Order By QtyOrder,Isnull(Free, 0), PKD, MIN(Batch_Code)   
	END  
END

