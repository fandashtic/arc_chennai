Create PROCEDURE sp_SalesHistory_Item
		@FromDate Datetime,
		@ToDate  Datetime,
		@FromSalesManID int,
		@ToSalesManID int
AS
Select 	InvoiceAbstract.InvoiceDate  as InvoiceDate, InvoiceAbstract.DocReference as InvoiceReferenceNumber ,
	sum(InvoiceAbstract.NetValue+InvoiceAbstract.RoundOffAmount) as  InvoiceAmount,InvoiceAbstract.CustomerID AS OutletCode,
	Customer.Company_Name as OutletName ,Beat.Description as Beat,Salesman.Salesman_Name as SalesmanName,
	InvoiceDetail.Product_Code as ItemCode,Items.Description as ItemName,sum(InvoiceDetail.Quantity)  as QuantityinBaseUOM,
	sum((case  when Isnull(Items.UOM1_Conversion, 0) = 0 then 0 else Quantity / Items.UOM1_Conversion end)) as QuantityinUOM1,
	sum((case  when isnull(Items.UOM2_Conversion, 0) = 0 then 0 else Quantity / Items.UOM2_Conversion end)) as QuantityinUOM2,
	sum(SalePrice) as PriceinBaseUOM,	
	sum(SalePrice * isnull(Items.UOM1_Conversion,0)) AS PriceinUOM1,
	sum(SalePrice * isnull(Items.UOM2_Conversion,0)) AS PriceinUOM2,
	sum(Quantity*SalePrice) as Value	
From    InvoiceAbstract
Inner Join Customer On InvoiceAbstract.CustomerId = Customer.CustomerId 
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceId = InvoiceDetail.InvoiceId 
Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code 
Left Outer Join Beat on InvoiceAbstract.BeatID = Beat.BeatID 
Left Outer Join SalesMan On InvoiceAbstract.SalesManId = SalesMan.SalesManId 
where   
	Invoicedate Between @FromDate And @Todate  and 
	InvoiceAbstract.SalesManID Between @FromSalesManID and @ToSalesManID and
	(isnull(InvoiceAbstract.Status,0) & 128 ) = 0  and 
	(isnull(InvoiceAbstract.Status,0) & 64 ) = 0 and
	InvoiceAbstract.InvoiceType in (1,3) 
Group By  InvoiceDetail.Product_Code, SalePrice, InvoiceAbstract.DocReference, 
	InvoiceAbstract.InvoiceDate, InvoiceAbstract.ReferenceNumber, 
	InvoiceAbstract.CustomerID, Customer.Company_Name, Beat.Description, 
	SalesMan.Salesman_Name, Items.Description
order by InvoiceDetail.Product_Code
