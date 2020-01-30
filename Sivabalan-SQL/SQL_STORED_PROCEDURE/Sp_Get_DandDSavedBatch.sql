Create procedure Sp_Get_DandDSavedBatch @ID int, @Product_Code nVarchar(30)
AS
BEGIN

Select BP.Batch_Number, Sum(IsNull(DD.TotalQuantity,0)) as TotalQuantity, Rate = BP.PTS, Tax = BP.TaxSuffered
	,Sum(IsNull(DD.RFAQuantity, 0)) as RFAQuantity
	,Sum(IsNull(DD.TaxAmount, 0)) as TaxAmount, Sum(IsNull(DD.TotalAmount,0)) as  TotalAmount,Sum(IsNull(DD.UOMTotalQty,0)) as UOMTotalQty,
	Sum(IsNull(DD.UOMRFAQty, 0)) as UOMRFAQty,Sum(IsNull(DD.UOMTaxAmount, 0)) as UOMTaxAmount,max(isnull(UOMBatchTaxAmount,0)) as UOMBatchTaxAmount,
	max(isnull(UOMBatchTotalAmount,0)) as UOMBatchTotalAmount,Max(Isnull(BP.TOQ,0)) as TOQ,BP.GRNTaxID as TaxID, 
	TaxType = Case When isnull(BP.TaxType,0) = 5 Then isnull(BP.GSTTaxType,0) Else isnull(BP.TaxType,0) End

From DandDDetail DD, Batch_Products BP
Where
	DD.Batch_Code = BP.Batch_Code	
	And DD.ID = @ID
	And DD.Product_Code = @Product_Code
Group By BP.Batch_Number, BP.PTS, BP.TaxSuffered,BP.GRNTaxID, BP.TaxType,BP.GSTTaxType
Order BY Min(BP.Batch_Code)

END
