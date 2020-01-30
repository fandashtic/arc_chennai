CREATE procedure sp_ser_loadspareinfo(@SpareCode nvarchar(15),
@CustomerID nvarchar(15))
as
Declare @Locality Int,@CustomerType Int
Select @Locality = IsNull(Locality,1),@CustomerType = CustomerCategory
from Customer Where CustomerID = @CustomerID 

Select 'SpareCode' = Product_Code,'SpareName' = dbo.sp_ser_getitemname(@SpareCode),
'UOMDescription' = UOM.[Description],'UOMCode' = Items.UOM,
'TaxSufferedCode' = IsNull(Items.TaxSuffered,''),'SalePrice'= dbo.sp_ser_getspareprice(@CustomerType,@SpareCode),
'TaxSufferedPercentage' = dbo.sp_ser_gettaxpercenatge(1,IsNull(Items.TaxSuffered,0),0),
'SaleTaxCode' = Sale_Tax, 'SalesTaxPercentage' = dbo.sp_ser_gettaxpercenatge(@Locality,Items.Sale_Tax,0),
'UOMPrice' = dbo.sp_ser_getuomprice(@SpareCode,Items.UOM,@CustomerType), 
'VatExists' = Isnull(Vat, 0), 'CollectTaxSuffered' = Isnull(CollectTaxSuffered, 0)
from Items,UOM
where Product_Code = @SpareCode
and Items.UOM = UOM.UOM


