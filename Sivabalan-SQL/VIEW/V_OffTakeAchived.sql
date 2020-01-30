
CREATE VIEW [V_OffTakeAchived]
( [SchemeID], [CustomerID], [ItemCode], [Quantity_in_Base_UOM], [Quantity_in_UOM1], [Quantity_in_UOM2], [Value] )
AS	
select SchemeID as SchemeID 
, CusCode as CustomerID
, Product_Code as ItemCode
, Qty_in_Base_UOM as Quantity_in_Base_UOM
, Qty_in_Base_UOM1 Quantity_in_UOM1
, Qty_in_Base_UOM2 Quantity_in_UOM2
, SalesValue as value
from dbo.Fn_Get_OffTake_AchievedScheme() 

