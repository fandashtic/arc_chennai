CREATE procedure sp_ser_loadtaskspares(@TaskID nvarchar(50),@ProductCode nvarchar(15),
@CustomerID nvarchar(50))
as
Declare @Locality Int,@CustomerType Int
Select @Locality = IsNull(Locality,1),@CustomerType = CustomerCategory
from Customer Where CustomerID = @CustomerID 

Select SpareCode,'SpareName' = dbo.sp_ser_getitemname(SpareCode),
'UOMDescription' = UOM.[Description],'UOMCode'= IsNull(task_items_spares.UOM,0),
'Qty'=IsNull(Qty,0),'UOMQty' =IsNull(UOMQty,0),'TaxSufferedCode' = IsNull(Items.TaxSuffered,''),
'SalePrice'= IsNull(dbo.sp_ser_getspareprice(@CustomerType,SpareCode),0),
'TaxSufferedPercentage' = IsNull(dbo.sp_ser_gettaxpercenatge(1,IsNull(Items.TaxSuffered,0),0),0),
'SaleTaxCode' = IsNull(Sale_Tax,0),
'SalesTaxPercentage'=IsNull(dbo.sp_ser_gettaxpercenatge(@Locality,IsNull(Items.Sale_Tax,0),0),0),
'UOMPrice' = IsNull(dbo.sp_ser_getuomprice(SpareCode,task_items_spares.UOM,@CustomerType),0), 
'VatExists' = Isnull(Vat, 0), 'CollectTaxSuffered' = Isnull(CollectTaxSuffered, 0)
from Task_Items_Spares,Items,UOM
where TaskID = @TaskID
and Task_Items_Spares.Product_Code = @ProductCode
and Task_Items_Spares.SpareCode = Items.Product_Code
and Task_Items_Spares.UOM = UOM.UOM



