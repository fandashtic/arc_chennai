CREATE procedure sp_ser_loaduomconversion(@ProductCode nvarchar(15))
as
Select 'UOM1_Conversion' = IsNull(UOM1_Conversion,0),
'UOM2_Conversion' = IsNull(UOM2_Conversion,0),
'UOM'=IsNull(UOM,0),'UOM1'=IsNull(UOM1,0),'UOM2'=IsNull(UOM2,0)
from Items Where Product_Code = @ProductCode
