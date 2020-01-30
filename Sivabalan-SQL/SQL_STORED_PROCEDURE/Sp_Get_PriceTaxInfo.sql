CREATE Procedure Sp_Get_PriceTaxInfo(@ProductCode as nvarchar(15))
as
SELECT BP.PTS, BP.PTR, BP.ECP, BP.company_Price, TT.TaxType, IsNull(BP.TaxSuffered,0) as Tax, 
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
from Batch_products BP, tbl_merp_TaxType TT 
Where IsNull(BP.TaxType, 1) = TT.TaxID And BP.batch_code = (Select Max(batch_code) from batch_products 
	Where product_code = @ProductCode and IsNull(free,0)<> 1)


