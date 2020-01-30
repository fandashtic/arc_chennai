CREATE Procedure sp_ser_loadspareinfo_fmcg(@SpareCode nvarchar(15),
@CustomerID nvarchar(15))
as
Declare @Locality Int
Select @Locality = IsNull(Locality,1) from Customer Where CustomerID = @CustomerID 

Select 'SpareCode' = Product_Code,'SpareName' = dbo.sp_ser_getitemname(@SpareCode),
'UOMDescription' = UOM.[Description],'UOMCode' = Items.UOM,
'TaxSufferedCode' = IsNull(Items.TaxSuffered,''),'SalePrice'= sale_price, 
'TaxSufferedPercentage' = dbo.sp_ser_gettaxpercenatge(1,IsNull(Items.TaxSuffered,0),0),
'SaleTaxCode' = Sale_Tax,'SalesTaxPercentage'=dbo.sp_ser_gettaxpercenatge(@Locality,Items.Sale_Tax,0),
'UOMPrice' = dbo.sp_ser_getuomprice_fmcg(@SpareCode,Items.UOM),
'VatExists' = Isnull(Vat, 0), 'CollectTaxSuffered' = Isnull(CollectTaxSuffered, 0)
from Items,UOM
where Product_Code = @SpareCode
and Items.UOM = UOM.UOM


