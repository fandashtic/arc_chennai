CREATE procedure sp_list_batchinfo(@ItemCode nvarchar(15))                        
as  
BEGIN                               
If Exists (select Top 1 * from Items Where Product_code = @ItemCode and Active = 1)
	Begin                            
		SELECT Batch_Number, Expiry, SUM(Quantity),                         
			PurchasePrice,PKD, IsNull(Free, 0), PTS, PTR, ECP, Company_Price,           
			IsNull(TaxSuffered, 0), IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0),
			isnull(PFM,0), isnull(TaxType,0) TaxType,
			Isnull(MRPforTax,0), MRPPerPack,IsNull(TOQ,0) TOQ,TaxID = isnull(GRNTaxID,0)
			,isnull(GSTTaxType,0) GSTTaxType
		FROM Batch_Products                        
		WHERE  Batch_Products.Product_Code = @ITEMCODE And           
		Quantity > 0 And ISNULL(Damage, 0) = 0                        
		GROUP BY Batch_Number, Expiry, PurchasePrice, PKD, IsNull(Free, 0),           
		PTS, PTR, ECP, Company_Price, IsNull(TaxSuffered, 0),                    
		IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0),
		isnull(PFM,0),Isnull(TaxType,0),Isnull(MRPforTax,0),MRPPerPack,IsNull(TOQ,0),isnull(GSTTaxType,0),isnull(GRNTaxID,0)
		HAVING SUM(Quantity) > 0                        
		Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code) 
	End
End
