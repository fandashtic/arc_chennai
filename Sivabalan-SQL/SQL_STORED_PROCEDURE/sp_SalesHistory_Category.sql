CREATE PROCEDURE sp_SalesHistory_Category
		@FromDate Datetime,
		@ToDate  Datetime,
		@FromSalesManID int,
		@ToSalesManID int
AS
SELECT  a.Category_Name as Company,b.Category_Name as Division,c.Category_Name as Sub_Category,
	d.Category_Name as MarketSKU,Items.Product_Code,Items.Productname,sum(InvoiceDetail.Quantity)  as QuantityinBaseUOM,
	sum(Quantity*isnull(Items.UOM1_Conversion,0)) as QuantityinUOM1,sum(Quantity*isnull(Items.UOM2_Conversion,0)) AS QuantityinUOM2,
   	sum(SalePrice) as PriceinBaseUOM,sum(SalePrice*isnull(Items.UOM1_Conversion,0)) AS PriceinUOM1,sum(SalePrice*isnull(Items.UOM2_Conversion,0)) AS PriceinUOM2,
   	sum(Quantity*SalePrice) as Value	

from 	ItemCategories a,ItemCategories b,ItemCategories c, ItemCategories d,Items,InvoiceDetail,InvoiceAbstract
where 
	a.Categoryid=B.ParentID and
	B.Categoryid=C.ParentID and
	C.Categoryid=D.ParentID and
	Items.CategoryID=D.CategoryID and
	InvoiceAbstract.InvoiceId=InvoiceDetail.InvoiceId and
	InvoiceDetail.Product_Code=Items.Product_Code and  
	(isnull(InvoiceAbstract.Status,0) & 128 ) = 0  and 
	(isnull(InvoiceAbstract.Status,0) & 64 ) = 0 and
	InvoiceAbstract.InvoiceType in (1,3) and 
	Invoicedate Between @FromDate And @Todate  and 
	SalesManID Between @FromSalesManID and @ToSalesManID 

Group by  	Items.Product_Code, Items.Productname,SalePrice,a.Category_Name,b.Category_Name,c.Category_Name,d.Category_Name  
order by 	a.Category_Name, b.Category_Name,
		c.Category_Name,d.Category_Name,Items.Product_Code

