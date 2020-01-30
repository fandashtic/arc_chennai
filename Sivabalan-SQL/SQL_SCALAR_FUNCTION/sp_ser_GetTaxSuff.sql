CREATE function sp_ser_GetTaxSuff( @Batch_Code int)
returns decimal(18,6)
as
begin
	declare @Tax decimal(18,6)
	select @Tax = TaxSuffered from batch_products where batch_Code = @Batch_Code
	return isnull(@Tax ,0)
end




