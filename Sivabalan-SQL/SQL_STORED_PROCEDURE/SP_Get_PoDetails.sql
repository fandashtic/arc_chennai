create Procedure SP_Get_PoDetails(@PONumber nvarchar(255))
AS
Select * into #tempPo from dbo.sp_splitin2rows(@PONumber,',')

Select Items.Product_Code, 
	"Quantity" = isnull(SUM(PODetailReceived.Quantity),0)
    From PODetailReceived, Items,#tempPo
	WHERE PODetailReceived.PONumber = #tempPo.itemvalue and
    PODetailReceived.Product_Code = Items.Alias 
    GROUP BY  ISNULL(PODetailReceived.SERIAL,0),Items.Product_Code 
	Order by ISNULL(PODetailReceived.SERIAL,0)

drop table #tempPo



