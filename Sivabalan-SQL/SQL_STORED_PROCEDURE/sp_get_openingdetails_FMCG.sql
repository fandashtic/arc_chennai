CREATE Procedure sp_get_openingdetails_FMCG(@PRODUCTCODE nvarchar(15))
as
SELECT  Batch_Number,  Expiry , Quantity , "value"=purchaseprice * quantity ,saleprice, 
GRN_ID,PKD, Batch_Code, TaxSuffered, PurchasePrice, ApplicableOn, PartOfPercentage, Vat_Locality
FROM batch_products
WHERE (Batch_Products.Product_Code = @PRODUCTCODE)
AND (quantity <> 0)
order by batch_number



