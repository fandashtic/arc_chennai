Create PROCEDURE spr_list_stock_ledger_by_brand(@BRAND nvarchar(2550), @FROM_DATE datetime,
@ShowItems nvarchar(50), @StockVal nvarchar(100))
AS

Declare @Delimeter as Char(1)
Set @Delimeter=Char(15)
Declare @tmpDiv table(Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Declare @tmpProd table(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @BRAND='%'
Insert into @tmpDiv select BrandName from Brand
Else
Insert into @tmpDiv select * from dbo.sp_SplitIn2Rows(@BRAND,@Delimeter)

--if @ItemCode = '%'
Insert InTo @tmpProd Select Product_code From Items
--Else
-- Insert into @tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)


IF (DATEPART(dy, @FROM_DATE) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FROM_DATE) = DATEPART(yyyy, GETDATE())) OR DATEPART(yyyy, @FROM_DATE) < DATEPART(yyyy, GETDATE())
BEGIN


----temp tables for SIT
create table #tmptotal_Invd_Saleonly_qty(
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
, Saleableqty decimal(18, 6)
, salablevalue decimal(18, 6)
)

create table #tmptotal_Invd_Freeonly_qty(
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
, freeqty decimal(18, 6)
, freevalue decimal(18, 6)
)

create table #tmptotal_rcvd_qty(
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
, saleableqty decimal(18, 6)
, freeqty decimal(18, 6)
, salablevalue decimal(18, 6)
, freevalue decimal(18, 6)
)


create table #tmpPreviousDate(
BrandID int
, Division  nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
, [Total On Hand Qty] decimal(18, 6)
, [Total On Hand Value] decimal(18, 6)
, [Saleable Stock] decimal(18, 6)
, [Saleable Value] decimal(18, 6)
, [Free OnHand Qty] decimal(18, 6)
, [Damages Qty] decimal(18, 6)
, [Damages Value] decimal(18, 6)
)

-- total_Invoiced_qty(Saleable Item only)
Insert Into #tmptotal_Invd_Saleonly_qty
select tmpDiv.Division, isnull(sum(IDR.quantity), 0)
,isnull(sum(IDR.quantity * (case @StockVal
When 'PTS' Then Items.PTS
When 'PTR' Then Items.PTR
When 'ECP' Then Items.ECP
When 'MRP' Then Items.MRP
When 'Special Price' Then Items.Company_Price
Else Items.MRP End)), 0)
from @tmpDiv tmpDiv
join Brand  on Brand.BrandName = tmpDiv.Division
join Items  on Brand.BrandID= Items.BrandID
join @tmpProd tmpprod on Items.product_code  = tmpprod.product_code
left outer join ( select IDR.product_code as product_code, IDR.quantity as quantity
from InvoiceDetailReceived IDR join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
where IAR.Status & 64 = 0  and IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE)
and IAR.Invoicetype = 0 and IDR.Saleprice > 0
) IDR on IDR.product_code = Items.product_code
group by tmpDiv.Division

-- total_Invoiced_Freeonly_qty
Insert Into #tmptotal_Invd_Freeonly_qty
select  tmpDiv.Division, isnull(sum(IDR.quantity), 0)
,isnull(sum(IDR.quantity * (case @StockVal
When 'PTS' Then Items.PTS
When 'PTR' Then Items.PTR
When 'ECP' Then Items.ECP
When 'MRP' Then Items.MRP
When 'Special Price' Then Items.Company_Price
Else Items.MRP End)), 0)
from @tmpDiv  tmpDiv
join Brand  on tmpDiv.Division =Brand.BrandName
join Items on  Brand.BrandID = Items.BrandID
join @tmpProd tmpprod on Items.product_code  = tmpprod.product_code
left outer join ( select IDR.product_code as product_code, IDR.quantity as quantity
from InvoiceDetailReceived IDR join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
where IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE)
and IAR.Invoicetype = 0 and IDR.Saleprice = 0
) IDR on IDR.product_code = Items.product_code
group by tmpDiv.Division


-- total_received_qty(Saleable), total_received_qty(Free)
Insert Into #tmptotal_rcvd_qty
select tmpDiv.Division, IsNull(sum(gdt.quantityreceived), 0), IsNull(sum(gdt.Freeqty), 0)
,isnull(sum(gdt.quantityreceived * (case @StockVal
When 'PTS' Then Items.PTS
When 'PTR' Then Items.PTR
When 'ECP' Then Items.ECP
When 'MRP' Then Items.MRP
When 'Special Price' Then Items.Company_Price
Else Items.MRP End)), 0)
,isnull(sum(gdt.freeqty * (case @StockVal
When 'PTS' Then Items.PTS
When 'PTR' Then Items.PTR
When 'ECP' Then Items.ECP
When 'MRP' Then Items.MRP
When 'Special Price' Then Items.Company_Price
Else Items.MRP End)), 0)
from @tmpDiv  tmpDiv
join Brand  on tmpDiv.Division = Brand.BrandName
join Items on Brand.BrandID = Items.BrandID
join @tmpProd tmpprod on Items.product_code  = tmpprod.product_code
left outer join
( select gdt.quantityreceived as quantityreceived,
gdt.freeqty as freeqty, gdt.product_code as product_code
from grndetail gdt
join grnabstract gab on gab.grnId = gdt.grnId and gab.grnstatus = 1 and gab.RecdInvoiceId in
( select InvoiceId from Invoiceabstractreceived IAR
where IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE)
and IAR.Invoicetype = 0
)
where gab.GrnDate < dateadd(d, 1, @FROM_DATE)
) gdt on gdt.product_code = items.product_code
group by  tmpDiv.Division

--select * from #tmptotal_Invd_Saleonly_qty
--select * from #tmptotal_Invd_Freeonly_qty
--select * from #tmptotal_rcvd_qty


----
IF @ShowItems = 'Items with stock'
BEGIN
Insert into #tmpPreviousDate
Select  Items.BrandID,
"Division" = Brand.BrandName,
"Total On Hand Qty" = ISNULL(SUM(OpeningDetails.Opening_Quantity), 0),
"Total On Hand Value" =
case @StockVal
When 'PTS' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTS, 0)))
When 'PTR' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTR, 0)))
When 'ECP' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))
When 'MRP' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))
When 'Special Price' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))
Else
SUM(ISNULL(OpeningDetails.Opening_Value, 0))
End,
"Saleable Stock" = sum(isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),
"Saleable Value" =
case @StockVal
When 'PTS' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTS, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTS, 0))
When 'PTR' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTR, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTR, 0))
When 'ECP' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))
When 'MRP' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))
When 'Special Price' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))
Else
sum(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))
End,
"Free OnHand Qty" = isnull(sum(openingdetails.Free_Saleable_Quantity ), 0),
"Damages Qty" = isnull(sum(openingdetails.Damage_Opening_Quantity),0),
"Damages Value" =
case @StockVal
When 'PTS' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.PTS), 0)
When 'PTR' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.PTR), 0)
When 'ECP' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.ECP), 0)
When 'MRP' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.MRP), 0)
When 'Special Price' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.Company_Price), 0)
Else
isnull(sum(openingdetails.Damage_Opening_Value), 0)
End
from    Items
Inner Join Brand On Items.BrandID = Brand.BrandID
Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
WHERE
Brand.active  = 1
AND Brand.BrandName In (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpDiv)
AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)
--And Items.Product_Code *= OpeningDetails.Product_Code
--AND Items.BrandID = Brand.BrandID
GROUP BY Items.BrandID, Brand.BrandName
HAVING ISNULL(SUM(OpeningDetails.Opening_Quantity), 0) > 0

select tempPre.BrandID, tempPre.Division
, tempPre.[Total On Hand Qty]
, "Total SIT Qty" = ( ( tmpInvdSale.Saleableqty + tmpInvdfree.freeqty ) - tmprcvdqty.saleableqty - tmprcvdqty.freeqty )
, tempPre.[Total On Hand Value]
, "Total SIT Value" = ( tmpInvdSale.salablevalue - tmprcvdqty.salablevalue )
, tempPre.[Saleable Stock]
, "Saleable SIT Qty" = ( tmpInvdSale.Saleableqty - tmprcvdqty.saleableqty  )
, tempPre.[Saleable Value]
, "Saleable SIT Value" = ( tmpInvdSale.salablevalue - tmprcvdqty.salablevalue )
, tempPre.[Free OnHand Qty]
, "Free SIT Qty" =  ( tmpInvdfree.freeqty - tmprcvdqty.freeqty )
, tempPre.[Damages Qty]
, tempPre.[Damages Value]
from #tmpPreviousDate tempPre --tempMfr
join #tmptotal_Invd_Saleonly_qty tmpInvdSale on tempPre.[Division] = tmpInvdSale.Division
Join #tmptotal_Invd_Freeonly_qty tmpInvdfree on tempPre.[Division] = tmpInvdfree.Division
Join #tmptotal_rcvd_qty tmprcvdqty on tempPre.[Division] = tmprcvdqty.Division

END
ELSE
BEGIN
Insert into #tmpPreviousDate
Select  Items.BrandID,
"Division" = Brand.BrandName,
"Total On Hand Qty" = ISNULL(SUM(OpeningDetails.Opening_Quantity), 0),
"Total On Hand Value" =
case @StockVal
When 'PTS' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTS, 0)))
When 'PTR' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTR, 0)))
When 'ECP' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))
When 'MRP' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))
When 'Special Price' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))
Else
SUM(ISNULL(OpeningDetails.Opening_Value, 0))
End,
"Saleable Stock" = sum(isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),

"Saleable Value" =
case @StockVal
When 'PTS' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTS, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTS, 0))
When 'PTR' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTR, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTR, 0))
When 'ECP' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))
When 'MRP' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTR, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))
When 'Special Price' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))
Else
sum(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))
End,
"Free OnHand Qty" = isnull(sum(openingdetails.Free_Saleable_Quantity ), 0),
"Damages Qty" = isnull(sum(openingdetails.Damage_Opening_Quantity),0),
"Damages Value" =
case @StockVal
When 'PTS' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.PTS), 0)
When 'PTR' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.PTR), 0)
When 'ECP' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.ECP), 0)
When 'MRP' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.MRP), 0)
When 'Special Price' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.Company_Price), 0)
Else
isnull(sum(openingdetails.Damage_Opening_Value), 0)
End
from    Items
Inner Join Brand On Items.BrandID = Brand.BrandID
Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
WHERE
Brand.active  = 1
AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)
AND Brand.BrandName In (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpDiv)
--AND Items.Product_Code *= OpeningDetails.Product_Code
--AND Items.BrandID = Brand.BrandID
GROUP BY Items.BrandID, Brand.BrandName

select tempPre.BrandID, tempPre.Division
, tempPre.[Total On Hand Qty]
, "Total SIT Qty" = ( ( tmpInvdSale.Saleableqty + tmpInvdfree.freeqty ) - tmprcvdqty.saleableqty - tmprcvdqty.freeqty )
, tempPre.[Total On Hand Value]
, "Total SIT Value" = ( tmpInvdSale.salablevalue - tmprcvdqty.salablevalue )
, tempPre.[Saleable Stock]
, "Saleable SIT Qty" = ( tmpInvdSale.Saleableqty - tmprcvdqty.saleableqty  )
, tempPre.[Saleable Value]
, "Saleable SIT Value" = ( tmpInvdSale.salablevalue - tmprcvdqty.salablevalue )
, tempPre.[Free OnHand Qty]
, "Free SIT Qty" =  ( tmpInvdfree.freeqty - tmprcvdqty.freeqty )
, tempPre.[Damages Qty]
, tempPre.[Damages Value]
from #tmpPreviousDate tempPre --tempMfr
join #tmptotal_Invd_Saleonly_qty tmpInvdSale on tempPre.[Division] = tmpInvdSale.Division
Join #tmptotal_Invd_Freeonly_qty tmpInvdfree on tempPre.[Division] = tmpInvdfree.Division
Join #tmptotal_rcvd_qty tmprcvdqty on tempPre.[Division] = tmprcvdqty.Division

END
END
ELSE
BEGIN
IF @ShowItems = 'Items with stock'
BEGIN
Select  Items.BrandID,
"Division" = b1.BrandName,
"Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0),
"Total SIT Qty"		= isnull((select isnull(Sum(IDR.Pending),0) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items
where
Items.Product_Code = IDR.Product_Code
And IDR.InvoiceID = IAR.InvoiceID
And IAR.Status & 64 = 0
And Items.BrandID = b1.BrandID),0),

"Total On Hand Value" =
case @StockVal
When 'PTS'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End) End)
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End) End)
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End) End)
When 'MRP' Then
isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0)End)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End,

"Total SIT Value" = Isnull((Select
case @StockVal
When 'PTS'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTS, 0)) Else (Case (IDR.SalePrice) When 0 Then 0  Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0))End) End)
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTR, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0))End) End)
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0))End) End)
When 'MRP' Then
isnull(Sum((Case(IDR.SalePrice) When 0 Then 0 Else isnull(IDR.Pending,0) * Isnull(Items.MRP,0)End)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.Company_Price, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0))End) End)
Else
isnull(Sum(isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)),0)
End
from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items, ItemCategories IC
where  Items.CategoryID = IC.CategoryID
And Items.Product_Code = IDR.Product_Code
And IDR.InvoiceID = IAR.InvoiceID
And IAR.Status & 64 = 0
And Items.BrandID = b1.BrandID),0),

"Saleable Stock" = isnull((select isnull(Sum(Quantity),0) from batch_products, Items
where  isnull(free,0)=0 and isnull(damage,0) = 0
and Items.Product_Code = Batch_Products.Product_Code
And Items.BrandID = b1.BrandID),0),

"Saleable SIT" = isnull((select isnull(Sum(IDR.Pending),0) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items
where
Items.Product_Code = IDR.Product_Code
And IDR.InvoiceID = IAR.InvoiceID
And IAR.Status & 64 = 0
And Items.BrandID = b1.BrandID
And isnull (IDR.Pending,0) > 0),0),

"Saleable Value" = Isnull((Select
case @StockVal
When 'PTS'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End)
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End)
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)
When 'MRP' Then
isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End
from batch_products, Items, ItemCategories IC
where
isnull(free,0)=0 and isnull(damage,0) = 0
and Items.Product_Code = Batch_Products.Product_Code
and Items.CategoryID = IC.CategoryID
And Items.BrandID = b1.BrandID
),0),

"Saleable SIT Value" = Isnull((Select
case @StockVal
When 'PTS'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTS, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0)) End)
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTR, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0)) End)
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0)) End)
When 'MRP' Then
isnull(Sum(isnull(IDR.Pending, 0) * isnull(Items.MRP, 0)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.Company_Price, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0)) End)
Else
isnull(Sum(isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)),0)
End
from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items, ItemCategories IC
where
Items.CategoryID = IC.CategoryID
And Items.Product_Code = IDR.Product_Code
And IDR.InvoiceID = IAR.InvoiceID
And IAR.Status & 64 = 0
And Items.BrandID = b1.BrandID
And IDR.SalePrice > 0
),0),

"Free OnHand Qty" = isnull((select isnull(sum(Quantity),0) from Batch_Products, Items
where
free <> 0 And IsNull(Damage, 0) <> 1
and Items.Product_Code = Batch_Products.Product_Code
And Items.BrandID = b1.BrandID
),0),

"Free SIT Qty" = isnull((select isnull(sum(IDR.Pending),0) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items
where Items.Product_Code = IDR.Product_Code
And IDR.InvoiceID = IAR.InvoiceID
And IAR.Status & 64 = 0
And Items.BrandID = b1.BrandID
And IDR.SalePrice = 0
),0),

"Damages Qty" = isnull((select isnull(sum(Quantity),0) from Batch_Products, items
where
isnull(damage,0) <> 0
and Items.Product_Code = Batch_Products.Product_Code
And Items.BrandID = b1.BrandID
),0),
"Damages Value" = isnull((select
case @StockVal
When 'PTS'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End)
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End)
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)
When 'MRP' Then
IsNull(Sum(Case IsNull(Free, 0) When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0) End ), 0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End
from items, Batch_Products, ItemCategories IC where Items.Product_Code = Batch_Products.Product_Code and Items.CategoryID = IC.CategoryID and isnull(damage,0) <> 0 And Items.BrandID = b1.BrandID),0)
from  Items
Inner Join Brand b1 On Items.BrandID = b1.BrandID
Inner Join  ItemCategories IC On Items.CategoryID = IC.CategoryID
Left Outer Join  Batch_Products On Items.Product_Code = Batch_Products.Product_Code
WHERE
b1.active  = 1
AND b1.BrandName In (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpDiv)
--AND Items.BrandID = b1.BrandID
--AND Items.Product_Code *= Batch_Products.Product_Code
--AND Items.CategoryID = IC.CategoryID
GROUP BY Items.BrandID, b1.BrandID, b1.BrandName
HAVING ISNULL(SUM(QUANTITY), 0) > 0
END
ELSE
BEGIN
Select  Items.BrandID,
"Division" = b1.BrandName,
"Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0),
"Total SIT Qty"		= isnull((select isnull(Sum(IDR.Pending),0) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items
where
Items.Product_Code = IDR.Product_Code
And IDR.InvoiceID = IAR.InvoiceID
And IAR.Status & 64 = 0
And Items.BrandID = b1.BrandID),0),
"Total On Hand Value" =
case @StockVal
When 'PTS'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End) End)
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End) End)
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End) End)
When 'MRP' Then
isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0)End)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End,

"Total SIT Value" =isnull ((select
case @StockVal
When 'PTS'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTS, 0)) Else (Case (IDR.SalePrice) When 0 Then  0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0))End) End)
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTR, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0)) End) End)
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0)) End) End)
When 'MRP' Then
isnull(Sum((Case (IDR.SalePrice) When 0 Then 0 Else isnull(IDR.Pending, 0) * Isnull(Items.MRP, 0)End)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.Company_Price, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0)) End) End)
Else
isnull(Sum(isnull(IDR.Pending, 0) * isnull(IDR.SalePrice , 0)),0)
End
from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items, ItemCategories IC
where Items.CategoryID = IC.CategoryID
And IDR.InvoiceID = IAR.InvoiceID
And IAR.Status & 64 = 0
And Items.Product_Code = IDR.Product_Code
And Items.BrandID = b1.BrandID
),0),

"Saleable Stock" = isnull((select isnull(Sum(Quantity),0) from batch_products, Items
where
isnull(free,0)=0 and isnull(damage,0) = 0
and Items.Product_Code = Batch_Products.Product_Code
And Items.BrandID = b1.BrandID
),0),

"Saleable SIT" = isnull((select isnull(Sum(IDR.Pending),0) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items
where Items.Product_Code = IDR.Product_Code
And IDR.InvoiceID = IAR.InvoiceID
And IAR.Status & 64 = 0
And Items.BrandID = b1.BrandID
And isnull (IDR.SalePrice,0) > 0) ,0),

"Saleable Value" = Isnull((Select
case @StockVal
When 'PTS'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End)
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End)
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)
When 'MRP' Then
isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End
from batch_products, Items, ItemCategories IC
where
isnull(free,0)=0 and isnull(damage,0) = 0
and Items.CategoryID = IC.CategoryID
And Items.Product_Code = Batch_Products.Product_Code
And Items.BrandID = b1.BrandID
),0),

"Saleable SIT Value" = Isnull((Select
case @StockVal
When 'PTS'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTS, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0)) End)
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTR, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0)) End)
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0)) End)
When 'MRP' Then
isnull(Sum(isnull(IDR.Pending, 0) * isnull(Items.MRP, 0)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.Company_Price, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0)) End)
Else
isnull(Sum(isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)),0)
End
from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items, ItemCategories IC
where  Items.CategoryID = IC.CategoryID
And Items.Product_Code = IDR.Product_Code
And IDR.InvoiceID = IAR.InvoiceID
And IAR.Status & 64 = 0
And Items.BrandID = b1.BrandID
And IDR.SalePrice > 0
),0),

"Free OnHand Qty" = isnull((select isnull(sum(Quantity),0) from Batch_Products, Items
where
free <> 0 And IsNull(Damage, 0) <> 1
and Items.Product_Code = Batch_Products.Product_Code
And Items.BrandID = b1.BrandID
),0),

"Free SIT Qty" = isnull((select isnull(sum(IDR.Pending),0) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items
where Items.Product_Code = IDR.Product_Code
And Items.BrandID = b1.BrandID
And IDR.InvoiceID = IAR.InvoiceID
And IAR.Status & 64 = 0
And IDR.SalePrice = 0
),0),

"Damages Qty" = isnull((select isnull(sum(Quantity),0) from Batch_Products, items
where
isnull(damage,0) <> 0
and Items.Product_Code = Batch_Products.Product_Code
And Items.BrandID = b1.BrandID),0),

"Damages Value" = isnull((select
case @StockVal
When 'PTS'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End)
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End)
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)
When 'MRP' Then
IsNull(Sum(Case IsNull(Free, 0) When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0) End ), 0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End
from items, Batch_Products, ItemCategories IC
where
isnull(damage,0) <> 0
and Items.CategoryID = IC.CategoryID
And Items.Product_Code = Batch_Products.Product_Code
And Items.BrandID = b1.BrandID),0)
from  Items
Inner Join  Brand b1 On Items.BrandID = b1.BrandID
Inner Join ItemCategories IC  On Items.CategoryID = IC.CategoryID
Left Outer Join Batch_Products On  Items.Product_Code = Batch_Products.Product_Code
WHERE
b1.active  = 1
AND b1.BrandName In (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpDiv)
--AND Items.BrandID = b1.BrandID
--AND Items.CategoryID = IC.CategoryID
--AND Items.Product_Code *= Batch_Products.Product_Code
GROUP BY Items.BrandID, b1.BrandID, b1.BrandName
END
END

