CREATE Procedure sp_get_openingdetails(@PRODUCTCODE nvarchar(15))
as
SELECT  Batch_Number,  Expiry , Quantity , "value"=purchaseprice * quantity ,saleprice, 
	GRN_ID, PTR, PTS, ECP, Company_Price, PKD, Batch_Code, TaxSuffered, ApplicableOn, PartOfPercentage, 
	isnull(TaxType,0) as Vat_Locality,isNull(PFM,0) as PFM,Isnull(MRPFORTAX,0) as MRPForTax,MRPPerPack
FROM batch_products
WHERE (Batch_Products.Product_Code = @PRODUCTCODE)
AND (quantity <> 0)
order by batch_number


