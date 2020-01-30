CREATE procedure [dbo].[sp_print_vanStockTransferAbstract] (@DocSerial int)
as
declare @ItemCount int
Declare @GODOWNTOVAN As NVarchar(50)
Declare @VANTOVAN As NVarchar(50)
Declare @VANTOGODOWN As NVarchar(50)

Set @GODOWNTOVAN = dbo.LookupDictionaryItem(N'Godown to Van', Default)
Set @VANTOVAN = dbo.LookupDictionaryItem(N'Van to Van', Default)
Set @VANTOGODOWN = dbo.LookupDictionaryItem(N'Van to Godown', Default)

select @ItemCount=count(*) from vantransferDetail,
Items,batch_products where vantransferDetail.Product_Code = items.product_code and 
VantransferDetail.BatchCode *= Batch_products.Batch_Code
and docserial = @DocSerial

select "DocumentNo" = docprefix + cast(documentid as nvarchar),
"Date" = DocumentDate,  "DocumentReference" = DocumentReference,
"Transfer Type" = case TransferType when 0 then @GODOWNTOVAN when 1 then 
@VANTOVAN when 2 then @VANTOGODOWN end, "DocSerialType" = DocSerialType,
"FromVan" = FromVanid, "ToVan" = TovanId, "Transfer Value" = Value, "Item Count" = @ItemCount
from vantransferabstract where DocSerial=@DocSerial
