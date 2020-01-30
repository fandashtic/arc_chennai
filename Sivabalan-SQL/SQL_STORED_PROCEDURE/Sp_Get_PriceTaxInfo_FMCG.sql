CREATE Procedure Sp_Get_PriceTaxInfo_FMCG(@ProductCode as nvarchar(15))
as
select BP.salePrice,IsNull(BP.taxsuffered,0),BP.PurchasePrice,
Case When IsNull(BP.Vat_Locality,0)=2   
Then IsNull((Select min(Tax_Code) from Tax 
	Where CST_Percentage=bp.TaxSuffered 
	and CSTApplicableOn=bp.ApplicableOn 
	and CSTPartOff=bp.PartofPercentage), 0)   
Else IsNull((Select min(Tax_Code) from Tax 
	Where Percentage=bp.TaxSuffered 
	and LSTApplicableOn=bp.ApplicableOn 
	and LSTPartOff=bp.PartofPercentage), 0)   
End as TaxCode 
from batch_products BP
where batch_code=(select max(batch_code) 
from batch_products where product_code = @ProductCode and IsNull(free,0)<>1)


