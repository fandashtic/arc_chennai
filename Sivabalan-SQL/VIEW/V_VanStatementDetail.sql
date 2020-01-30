Create VIEW   [V_VanStatementDetail] 
([DocumentID],[Product_Code],[BaseUOM],[QtyinBaseUOM],[UOM1],[QtyinUOM1],[UOM2],[QtyinUOM2])
AS
SELECT 	ID,VanStatementDetail.Product_Code, Items.UOM as BaseUOM,Quantity as QtyinBaseUOM ,
	UOM1 as UOM1, isnull(UOM1_Conversion,1)*Quantity as QtyinUOM1,
	UOM2 as UOM2, isnull(UOM2_Conversion,1)*Quantity as QtyinUOM2
from 	VanStatementDetail 
Inner Join Items On VanStatementDetail.Product_Code = Items.Product_Code
