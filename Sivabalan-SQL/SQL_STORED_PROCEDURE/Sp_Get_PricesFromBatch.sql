CREATE procedure Sp_Get_PricesFromBatch(@Product_code NVarchar(15),
		@Batch_number Nvarchar(128))
as
Select bp.PTS, bp.PTR, bp.ECP, bp.Company_Price, IsNull(items.AdhocAmount,0) 
from batch_products as Bp,Items 
Where items.product_Code = bp.product_code and
bp.Product_Code = @Product_code and
bp.batch_number = @batch_number




