CREATE procedure [dbo].[SP_Get_PoDetails_MUOM](@PONumber nvarchar(255))
AS
Select * into #tempPo from dbo.sp_splitin2rows(@PONumber,',')

select Items.Product_Code,
	"Quantity" = ISNULL(dbo.GetQtyAsMultiple(PODetailReceived.Product_Code, SUM(PODetailReceived.Quantity)), 0),  
	"UOMDescription" = case when isnull(Items.uom1, 0) = 0 and isnull(Items.uom2, 0) = 0
           then isnull(uom.description,'') else 'Multiple' end
    From PODetailReceived, items , UOM ,#tempPo
	WHERE PODetailReceived.PONumber = #tempPo.itemvalue and
    items.uom *= uom.uom and 
	PODetailReceived.Product_Code = Items.Alias
    GROUP BY PODetailReceived.Serial,Items.Product_Code, PODetailReceived.Product_Code, 
	Items.UOM1, Items.UOM2, uom.description 
	Order By PODetailReceived.Serial

drop table #tempPo
