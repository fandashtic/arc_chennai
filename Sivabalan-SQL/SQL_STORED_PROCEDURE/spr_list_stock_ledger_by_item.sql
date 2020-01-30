Create PROCEDURE spr_list_stock_ledger_by_item(@FROM_DATE datetime, @ShowItems nvarchar(100),
@StockVal nvarchar(100), @ItemCode nvarchar(2550))
AS
Declare @Delimeter as Char(1)
Set @Delimeter=Char(15)
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

if @ItemCode = '%'
Insert InTo #tmpProd Select Product_code From Items
Else
Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)


--This table is to display the categories in the Order
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)
Exec sp_CatLevelwise_ItemSorting


IF (DATEPART(dy, @FROM_DATE) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FROM_DATE) = DATEPART(yyyy, GETDATE())) OR DATEPART(yyyy, @FROM_DATE) < DATEPART(yyyy, GETDATE())
BEGIN
print ('previous date')
----
create table #tmptotal_Invd_qty(
product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
, Invoiced_qty decimal(18, 6)
)

create table #tmptotal_rcvd_qty(
product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
, rcvdqty decimal(18, 6)
, freeqty decimal(18, 6)
)

create table #tmptotal_Invd_Saleonly_qty(
product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
, Saleableonly_qty decimal(18, 6)
)

--total_Invoiced_qty(Saleable+Free)
Insert Into #tmptotal_Invd_qty
select tmp.product_code, isnull(sum(IDR.quantity), 0)
from #tmpProd tmp left outer join
( select IDR.product_code as product_code, idr.quantity as quantity
from InvoiceDetailReceived IDR join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
where IAR.Status & 64 = 0 and  IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE)
and IAR.Invoicetype = 0
) idr on IDR.product_code = tmp.product_code
group by tmp.product_code

--total_received_qty(Saleable), total_received_qty(Free)
Insert Into #tmptotal_rcvd_qty
select tmp.product_code, isnull(sum(gdt.quantityreceived),0), isnull(sum(gdt.Freeqty),0)
from #tmpProd tmp left outer join
( select IsNull(gdt.quantityreceived, 0) as quantityreceived,
IsNull(gdt.freeqty, 0) as freeqty, gdt.product_code as product_code
from grndetail gdt
join grnabstract gab on gab.grnId = gdt.grnId and gab.grnstatus = 1 and gab.RecdInvoiceId in
(	select InvoiceId from Invoiceabstractreceived IAR
where IAR.Status & 64 = 0 And IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE)
and IAR.Invoicetype = 0
)
where gab.GrnDate < dateadd(d, 1, @FROM_DATE)
) gdt on gdt.product_code = tmp.product_code
group by tmp.product_code

--total_Invoiced_Saleableonly_qty
Insert Into #tmptotal_Invd_Saleonly_qty
select tmp.product_code, isnull(sum(IDR.quantity), 0)
from #tmpProd tmp left outer join
( select IDR.product_code as product_code, idr.quantity as quantity
from InvoiceDetailReceived IDR join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
where IAR.Status & 64 = 0 And IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE)
and IAR.Invoicetype = 0 and IDR.Saleprice > 0
) idr on IDR.product_code = tmp.product_code
group by tmp.product_code


If @ShowItems = 'Items With Stock'
BEGIN
print ('previous date - Items With Stock')
Select
Items.product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,
"Total On Hand Qty" = CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) AS nvarchar)
+ ' ' +  CAST(UOM.Description AS nvarchar),
----Total SIT Qty
"Total SIT Qty" = CAST( tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty AS nvarchar)
+ ' ' +  CAST(UOM.Description AS nvarchar) ,
----Total SIT Qty
"Conversion Unit" = CAST(CAST(Items.ConversionFactor * ISNULL(OpeningDetails.Opening_Quantity, 0) as Decimal(18,6))  AS nvarchar)
+ ' ' +  CAST(ConversionTable.ConversionID AS nvarchar) ,
"Reporting UOM" =   dbo.sp_get_reportingqty(OpeningDetails.Opening_Quantity, Items.ReportingUnit),
"UOM Description" = CAST((Select Description From UOM Where UOM = Items.ReportingUOM)  AS nvarchar) ,
"Total On Hand Value" =
case @StockVal
When 'PTS' Then
((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTS, 0)))
When 'PTR' Then
((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTR, 0)))
When 'ECP' Then
((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))
When 'MRP' Then
((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))
When 'Special Price' Then
((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))
Else
(ISNULL(OpeningDetails.Opening_Value, 0))
End,
----Total SIT Value
"Total SIT Value" =
case @StockVal
When 'PTS' Then
( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.PTS, 0) )
When 'PTR' Then
( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.PTR, 0) )
When 'ECP' Then
( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.ECP, 0) )
When 'MRP' Then
( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.MRP, 0) )
When 'Special Price' Then
( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.Company_Price, 0) )
Else
( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.PTS, 0) )
End,
----Total SIT Value

"Saleable Stock" = openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0),
----Saleable SIT Qty
"Saleable SIT Qty" = (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),
----Saleable SIT Qty
"Saleable Value" =
case @StockVal
When 'PTS' Then
(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTS, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTS, 0))
When 'PTR' Then
(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTR, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTR, 0))
When 'ECP' Then
(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))
When 'MRP' Then
(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))
When 'Special Price' Then
(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))
Else
(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))
End,
----Saleable SIT Value
"Saleable SIT Value" =
case @StockVal
When 'PTS' Then
( (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.PTS, 0) )
When 'PTR' Then
( (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.PTR, 0) )
When 'ECP' Then
( (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.ECP, 0) )
When 'MRP' Then
( (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.MRP, 0) )
When 'Special Price' Then
( (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.Company_Price, 0) )
Else
( (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.PTS, 0) )
End,
----Saleable SIT Value
"Free OnHand Qty" = isnull(openingdetails.Free_Saleable_Quantity, 0),
----Free SIT Qty
"Free SIT Qty" = (tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,
----Free SIT Qty
"Damages Qty" = isnull(openingdetails.Damage_Opening_Quantity,0),
"Damages Value" =
case @StockVal
When 'PTS' Then
isnull((isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTS, 0)), 0)
When 'PTR' Then
isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTR, 0)), 0)
When 'ECP' Then
isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)
When 'MRP' Then
isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)
When 'Special Price' Then
isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)
Else
isnull((openingdetails.Damage_Opening_Value), 0)
End,
"Total On Hand Qty_UOM1" = CAST(Cast(ISNULL(OpeningDetails.Opening_Quantity, 0)  / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6)) AS nvarchar)
+ ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM1) ,
"Total On Hand Qty_UOM2" = CAST(Cast(ISNULL(OpeningDetails.Opening_Quantity, 0)  / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As decimal(18,6))  AS nvarchar)
+ ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Items.UOM2),
"Total SIT Qty_UOM1" = CAST( Cast((tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6)) AS nvarchar)
+ ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM1)  ,

"Total SIT Qty_UOM2" = CAST(Cast((tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6)) AS nvarchar)
+ ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM2),
"Saleable SIT Qty_UOM1" = Cast((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty)  / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6)),
"Saleable SIT Qty_UOM2" = Cast((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty)  / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6)),
"Free SIT Qty_UOM1" = Cast(((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6)),
"Free SIT Qty_UOM2" = Cast(((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
from Items
Inner Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
Left Outer Join UOM On Items.UOM = UOM.UOM
Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID
Inner Join  #tempCategory1 T1 On Items.CategoryID = T1.CategoryID
----link temp tables
Left Outer Join #tmptotal_Invd_qty tmpInvqty On Items.Product_Code = tmpInvqty.Product_Code
Left Outer Join  #tmptotal_rcvd_qty tmprcvdqty On Items.Product_Code = tmprcvdqty.Product_Code
Left Outer Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty On Items.Product_Code = tmpInvdSaleqty.Product_Code
----link temp tables
WHERE
OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)
----join temp tables
----join temp tables
And OpeningDetails.Opening_Quantity > 0
AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
--  AND Items.Active = 1
Order by T1.IDS
END
ELSE
BEGIN
print ('previous date - all Items')
Select
"Item Code1" = Items.product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,
"Total On Hand Qty" = CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) AS nvarchar)
+ ' ' +  CAST(UOM.Description AS nvarchar) ,
"Total SIT Qty" = CAST( tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty AS nvarchar)
+ ' ' +  CAST(UOM.Description AS nvarchar) ,
"Conversion Unit" = CAST(CAST(Items.ConversionFactor * ISNULL(OpeningDetails.Opening_Quantity, 0) as Decimal(18,6))  AS nvarchar)
+ ' ' +  CAST(ConversionTable.ConversionID AS nvarchar) ,
"Reporting UOM" =  dbo.sp_get_reportingqty(OpeningDetails.Opening_Quantity, Items.ReportingUnit),
"UOM Description" = CAST((Select Description From UOM Where UOM = Items.ReportingUOM)  AS nvarchar) ,
"Total On Hand Value" =
case @StockVal
When 'PTS' Then
((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTS, 0)))
When 'PTR' Then
((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTR, 0)))
When 'ECP' Then
((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))
When 'MRP' Then
((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))
When 'Special Price' Then
((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))
Else
(ISNULL(OpeningDetails.Opening_Value, 0))
End,
----Total SIT Value
"Total SIT Value" =
case @StockVal
When 'PTS' Then
( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.PTS, 0) )
When 'PTR' Then
( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.PTR, 0) )
When 'ECP' Then
( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.ECP, 0) )
When 'MRP' Then
( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.MRP, 0) )
When 'Special Price' Then
( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.Company_Price, 0) )
Else
( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.PTS, 0) )
End,
----Total SIT Value
"Saleable Stock" = openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0),

"Saleable SIT Qty" = (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),
"Saleable Value" =
case @StockVal
When 'PTS' Then
(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.PTS, 0))  - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTS, 0))
When 'PTR' Then
(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.PTS, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTR, 0))
When 'ECP' Then
(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.PTS, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))
When 'MRP' Then
(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.MRP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))
When 'Special Price' Then
(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Company_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))
Else
(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))
End,
----Saleable SIT Value
"Saleable SIT Value" =
case @StockVal
When 'PTS' Then
( (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.PTS, 0) )
When 'PTR' Then
( (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.PTR, 0) )
When 'ECP' Then
( (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.ECP, 0) )
When 'MRP' Then
( (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.MRP, 0) )
When 'Special Price' Then
( (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.Company_Price, 0) )
Else
( (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.PTS, 0) )
End,
----Saleable SIT Value
"Free OnHand Qty" = isnull(openingdetails.Free_Saleable_Quantity, 0),
----Free SIT Qty
"Free SIT Qty" = (tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,
----Free SIT Qty
"Damages Qty" = isnull(openingdetails.Damage_Opening_Quantity,0),
"Damages Value" =
case @StockVal
When 'PTS' Then
isnull((isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTS, 0)), 0)
When 'PTR' Then
isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTR, 0)), 0)
When 'ECP' Then
isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)
When 'MRP' Then
isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)
When 'Special Price' Then
isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)
Else
isnull((openingdetails.Damage_Opening_Value), 0)
End,
"Total On Hand Qty_UOM1" = CAST(Cast(ISNULL(OpeningDetails.Opening_Quantity, 0)  / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6)) AS nvarchar)
+ ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM1) ,

"Total On Hand Qty_UOM2" = CAST(Cast(ISNULL(OpeningDetails.Opening_Quantity, 0)  / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As decimal(18,6))  AS nvarchar)
+ ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Items.UOM2) ,
"Total SIT Qty_UOM1" = CAST( Cast((tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6)) AS nvarchar)
+ ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM1)  ,

"Total SIT Qty_UOM2" = CAST(Cast((tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6)) AS nvarchar)
+ ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM2)  ,
"Saleable SIT Qty_UOM1" = Cast((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6)),
"Saleable SIT Qty_UOM2" = Cast((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6)),
"Free SIT Qty_UOM1" = Cast(((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6)),
"Free SIT Qty_UOM2" = Cast(((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
from  Items
Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
Left Outer Join UOM On  Items.UOM = UOM.UOM
Left Outer Join ConversionTable On  Items.ConversionUnit = ConversionTable.ConversionID
Inner Join  ItemCategories IC On  IC.CategoryID = Items.CategoryID
Inner Join #tempCategory1 T1 On Items.CategoryID = T1.CategoryID
----link temp tables
Left Outer Join #tmptotal_Invd_qty tmpInvqty On Items.Product_Code = tmpInvqty.Product_Code
Left Outer Join  #tmptotal_rcvd_qty tmprcvdqty On  Items.Product_Code = tmprcvdqty.Product_Code
Left Outer Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty On Items.Product_Code = tmpInvdSaleqty.Product_Code
----link temp tables
WHERE
OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)
----join temp tables
----join temp tables
AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
--  and Items.Active = 1
Order by T1.IDS
END
END
ELSE
BEGIN
print ('current date')
IF @ShowItems = 'Items with stock'
BEGIN
print ('current date - Items With Stock')
Select  I1.product_Code, "Item Code" = I1.Product_Code, "Item Name" = I1.ProductName,
"Total On Hand Qty" = CAST(ISNULL(SUM(Quantity), 0) AS nvarchar)
+ ' ' +  CAST(UOM.Description AS nvarchar) ,
"Total SIT Qty" =
CAST(	( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
) AS nvarchar
)  + ' ' +  CAST(UOM.Description AS nvarchar) ,
----Total SIT Qty
"Conversion Unit" = CAST(CAST(I1.ConversionFactor * ISNULL(SUM(Quantity), 0) AS Decimal(18,6)) AS nvarchar)
+ ' ' +  CAST(ConversionTable.ConversionUnit AS nvarchar) ,
"Reporting UOM" = dbo.sp_get_reportingqty(Sum(Quantity), I1.ReportingUnit),
"UOM Description" = CAST((Select Description From UOM Where UOM = I1.ReportingUOM)  AS nvarchar) ,
"Total On Hand Value" =
case @StockVal
When 'PTS'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.PTS, 0)) End) End)
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.PTR, 0)) End) End)
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.ECP, 0)) End) End)
When 'MRP' Then
isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(I1.MRP, 0)End)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Company_Price, 0)) End) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End,
----Total SIT Value
"Total SIT Value" = (Select
case @StockVal
When 'PTS' Then
Sum( Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0))
Else (Isnull(IDR.pending, 0) * Isnull(Items.PTS, 0)) End )
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0))
Else (Isnull(IDR.pending, 0) * Isnull(Items.PTR, 0)) End )
When 'ECP' Then
--purchase_at instead of ecp
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ))
Else (Isnull(IDR.pending, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) End )
When 'MRP' Then
isnull(Sum(isnull(IDR.pending, 0) * Isnull(Items.MRP, 0)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.Company_Price, 0))
Else (Isnull(IDR.pending, 0) * Isnull(Items.Company_Price, 0)) End )
Else
--pts instead of PurchasePrice
isnull(Sum(isnull(IDR.pending, 0) * isnull(IDR.PTS, 0)), 0)
End
from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items, ItemCategories IC
where IAR.InvoiceId = IDR.InvoiceId and IAR.Status & 64 = 0
and Items.Product_Code = IDR.Product_Code and Items.CategoryID = IC.CategoryID
and isnull(IDR.saleprice, 0) > 0 And items.product_code = i1.Product_code),
----Total SIT Value
"Saleable Stock" = (select isnull(Sum(Quantity),0) from batch_products, Items  where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And items.product_code = i1.Product_code),
----
"Saleable SIT Qty" =
CAST(	( select IsNull(sum(IDR.pending), 0)
from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) AS nvarchar
)  + ' ' +  CAST(UOM.Description AS nvarchar) ,
----
"Saleable Value" = (Select
case @StockVal
When 'PTS' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End )
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End )
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End )
When 'MRP' Then
isnull(Sum(isnull(Quantity, 0) * Isnull(Items.MRP, 0)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End )
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End
from batch_products, Items, ItemCategories IC  where Items.Product_Code = Batch_Products.Product_Code and Items.CategoryID = IC.CategoryID and isnull(free,0)=0 and isnull(damage,0) = 0 And items.product_code = i1.Product_code),
----Saleable SIT Value
"Saleable SIT Value" = (Select
case @StockVal
When 'PTS' Then
Case IC.Price_Option When 1 Then Isnull(
( select IsNull(sum(IDR.pending * IDR.PTS), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0)
Else (Isnull(
( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
), 0) * Isnull(Itm.PTS, 0))
End
When 'PTR' Then
Case IC.Price_Option When 1 Then Isnull(
( select IsNull(sum(IDR.pending * IDR.PTR), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
), 0)
Else (Isnull(
( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0) * Isnull(Itm.PTR, 0))
End
When 'ECP' Then
Case IC.Price_Option When 1 Then
case when isnull(Itm.purchased_at, 0) = 1 then
Isnull(
( select IsNull(sum(IDR.pending * IDR.PTS), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0)
else
Isnull(
( select IsNull(sum(IDR.pending * IDR.ptr), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0)
end
Else (Isnull(
( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0) * Isnull(Itm.ECP, 0))
End
When 'MRP' Then
isnull(
( select IsNull(sum(IDR.pending * IDR.mrp), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0)
When 'Special Price' Then
Case IC.Price_Option When 1 Then Isnull(
( select IsNull(sum(IDR.pending * IDR.Company_price ), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
), 0)
Else (Isnull(
( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
), 0) * Isnull(Itm.Company_Price, 0))
End
Else
isnull(
( select IsNull(sum(IDR.pending * IDR.pts), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0)
End
from Items Itm, ItemCategories IC
where Itm.CategoryID = IC.CategoryID and
itm.product_code = i1.Product_code),
----Saleable SIT Value
"Free OnHand Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items  where Items.Product_Code = Batch_Products.Product_Code and free <> 0 And IsNull(Damage, 0) <> 1 And items.product_code = i1.Product_code),

----
"Free SIT Qty" =
CAST(	( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code and IAR.Status &  64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) = 0
) AS nvarchar
)  + ' ' +  CAST(UOM.Description AS nvarchar) ,
----
"Damages Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items  where Items.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And items.product_code = i1.Product_code),
"Damages Value" = (select
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
End,
"Total On Hand Qty_UOM1" = CAST((ISNULL(SUM(Quantity), 0) / (Case IsNull(Max(I1.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM1_Conversion),1) End)) AS nvarchar)
+ ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM1)),
"Total On Hand Qty_UOM2" = CAST((ISNULL(SUM(Quantity), 0) / (Case IsNull(Max(I1.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM2_Conversion),1) End)) AS nvarchar)
+ ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM2)) ,
"Total SIT Qty_UOM1" =
CAST(	( select IsNull(sum(IDR.pending), 0) / (Case IsNull(Max(I1.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM1_Conversion),1) End)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
) AS nvarchar
)  + ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM1)) ,
"Total SIT Qty_UOM2" =
CAST(	( select IsNull(sum(IDR.pending), 0) / (Case IsNull(Max(I1.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM2_Conversion),1) End)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
) AS nvarchar
)  + ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM2)) ,

"Saleable SIT Qty_UOM1" =
CAST(	( select IsNull(sum(IDR.pending), 0) / (Case IsNull(Max(I1.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM1_Conversion),1) End)
from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) AS nvarchar
)  + ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM1)) ,
"Saleable SIT Qty_UOM2" =
CAST(	( select IsNull(sum(IDR.pending), 0) / (Case IsNull(Max(I1.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM2_Conversion),1) End)
from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) AS nvarchar
)  + ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM2)) ,
"Free SIT Qty_UOM1" =
CAST(	( select IsNull(sum(IDR.pending), 0) / (Case IsNull(Max(I1.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM1_Conversion),1) End)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code and IAR.Status &  64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) = 0
) AS nvarchar
)  + ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM1)) ,
"Free SIT Qty_UOM2" =
CAST(	( select IsNull(sum(IDR.pending), 0) / (Case IsNull(Max(I1.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM2_Conversion),1) End)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code and IAR.Status &  64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) = 0
) AS nvarchar
)  + ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM2))
from Items, Batch_Products, ItemCategories IC where Items.Product_Code = Batch_Products.Product_Code And Items.CategoryID = IC.CategoryID and isnull(damage,0) <> 0 And items.product_code = i1.Product_code)
from  Items I1
Left Outer Join Batch_Products On I1.Product_Code = Batch_Products.Product_Code
Left Outer Join UOM On  I1.UOM = UOM.UOM
Left Outer Join ConversionTable On I1.ConversionUnit = ConversionTable.ConversionID
Inner Join ItemCategories IC On  I1.CategoryID = IC.CategoryID
Inner Join #tempCategory1 T1 On I1.CategoryID = T1.CategoryID
WHERE  I1.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
--  AND I1.Active = 1
GROUP BY
T1.IDS, I1.Product_Code, I1.ProductName, UOM.Description, I1.ConversionFactor,
ConversionTable.ConversionUnit, I1.ReportingUnit, I1.ReportingUOM
HAVING ISNULL(SUM(Quantity), 0) > 0
Order By T1.IDS
END
ELSE
BEGIN
print ('current date - all Items')
Select  I1.product_Code, "Item Code" = I1.Product_Code, "Item Name" = I1.ProductName,
"Total On Hand Qty" = CAST(ISNULL(SUM(Quantity), 0) AS nvarchar)
+ ' ' +  CAST(UOM.Description AS nvarchar) ,
"Total SIT Qty" =
CAST(	( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
) AS nvarchar
)  + ' ' +  CAST(UOM.Description AS nvarchar) ,
"Conversion Unit" = CAST(CAST(I1.ConversionFactor * ISNULL(SUM(Quantity), 0) AS Decimal(18,6)) AS nvarchar)
+ ' ' +  CAST(ConversionTable.ConversionUnit AS nvarchar) ,
"Reporting UOM" = dbo.sp_get_reportingqty(Sum(QUANTITY), I1.ReportingUnit),
--   SubString(
--    CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE I1.ReportingUnit WHEN 0 THEN 1 ELSE I1.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1,
--    CharIndex('.', CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE I1.ReportingUnit WHEN 0 THEN 1 ELSE I1.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)
--   + '.' +
--   CAST(Sum(Cast(ISNULL(QUANTITY, 0) As Int)) % Avg(Cast((CASE I1.ReportingUnit WHEN 0 THEN 1 ELSE I1.ReportingUnit END) As Int)) AS nvarchar),
--  + ' ' + @ReportingUOM,

--   "Reporting UOM" = dbo.sp_Get_ReportingUOMQty(I1.product_Code, SUM(Quantity)),
"UOM Description" = CAST((Select Description From UOM Where UOM = I1.ReportingUOM)  AS nvarchar) ,
"Total On Hand Value" =
case @StockVal
When 'PTS'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.PTS, 0)) End) End)
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.PTR, 0)) End) End)
When 'ECP' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.ECP, 0)) End) End)
When 'MRP' Then
isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(I1.MRP, 0)End)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Company_Price, 0)) End) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End,
----
"Total SIT Value" = (Select
case @StockVal
When 'PTS' Then
Sum( Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0))
Else (Isnull(IDR.pending, 0) * Isnull(Items.PTS, 0)) End )
When 'PTR' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0))
Else (Isnull(IDR.pending, 0) * Isnull(Items.PTR, 0)) End )
When 'ECP' Then
--purchase_at instead of ecp
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ))
Else (Isnull(IDR.pending, 0) * ( case when isnull(Items.purchased_at, 0) = 1 then Isnull(Items.PTS, 0) else Isnull(Items.PTR, 0) end ) ) End )
When 'MRP' Then
isnull(Sum(isnull(IDR.pending, 0) * Isnull(Items.MRP, 0)),0)
When 'Special Price' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.Company_Price, 0))
Else (Isnull(IDR.pending, 0) * Isnull(Items.Company_Price, 0)) End )
Else
--pts instead of PurchasePrice
isnull(Sum(isnull(IDR.pending, 0) * isnull(IDR.pts, 0)),0)
End
from InvoiceDetailReceived IDR, InvoiceabstractReceived IAR, Items, ItemCategories IC
where IAR.InvoiceId = IDR.InvoiceId  and IAR.Status & 64 = 0
and Items.Product_Code = IDR.Product_Code and Items.CategoryID = IC.CategoryID
and isnull(IDR.saleprice, 0) > 0 And items.product_code = i1.Product_code),
----
"Saleable Stock" = (select isnull(Sum(Quantity),0) from batch_products, Items  where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And items.product_code = i1.Product_code),
----
"Saleable SIT Qty" =
CAST(	( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) AS nvarchar
)  + ' ' +  CAST(UOM.Description AS nvarchar) ,

----
"Saleable Value" = (Select
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
from batch_products, Items, ItemCategories IC  where Items.Product_Code = Batch_Products.Product_Code And Items.CategoryID = IC.CategoryID and  isnull(free,0)=0 and isnull(damage,0) = 0 And items.product_code = i1.Product_code),
----Saleable SIT Value
"Saleable SIT Value" = (Select
case @StockVal
When 'PTS' Then
Case IC.Price_Option When 1 Then Isnull(
( select IsNull(sum(IDR.pending * IDR.PTS), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0)
Else (Isnull(
( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
), 0) * Isnull(Itm.PTS, 0))
End
When 'PTR' Then
Case IC.Price_Option When 1 Then Isnull(
( select IsNull(sum(IDR.pending * IDR.PTR), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
), 0)
Else (Isnull(
( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0) * Isnull(Itm.PTR, 0))
End
When 'ECP' Then
Case IC.Price_Option When 1 Then
case when isnull(Itm.purchased_at, 0) = 1 then
Isnull(
( select IsNull(sum(IDR.pending * IDR.PTS), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0)
else
Isnull(
( select IsNull(sum(IDR.pending * IDR.ptr), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0)
end
Else (Isnull(
( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0) * Isnull(Itm.ECP, 0))
End
When 'MRP' Then
isnull(
( select IsNull(sum(IDR.pending * IDR.mrp), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0)
When 'Special Price' Then
Case IC.Price_Option When 1 Then Isnull(
( select IsNull(sum(IDR.pending * IDR.Company_price ), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code  and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
), 0)
Else (Isnull(
( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and  IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
), 0) * Isnull(Itm.Company_Price, 0))
End
Else
isnull(
( select IsNull(sum(IDR.pending * IDR.pts), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = Itm.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) , 0)
End
from Items Itm, ItemCategories IC
where Itm.CategoryID = IC.CategoryID and
itm.product_code = i1.Product_code),
----Saleable SIT Value
"Free OnHand Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items  where Items.Product_Code = Batch_Products.Product_Code and free <> 0 And IsNull(Damage, 0) <> 1 And items.product_code = i1.Product_code),
----
"Free SIT Qty" =
CAST(	( select IsNull(sum(IDR.pending), 0)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code  and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) = 0
) AS nvarchar
)  + ' ' +  CAST(UOM.Description AS nvarchar) ,

----
"Damages Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items  where Items.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And items.product_code = i1.Product_code),
"Damages Value" = (select
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
from Items, Batch_Products, ItemCategories IC where Items.Product_Code = Batch_Products.Product_Code and IC.CategoryID = Items.CategoryID and isnull(damage,0) <> 0 And items.product_code = i1.Product_code),
"Total On Hand Qty_UOM1" = CAST((ISNULL(SUM(Quantity), 0) / (Case IsNull(Max(I1.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM1_Conversion),1) End)) AS nvarchar)
+ ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM1)),
"Total On Hand Qty_UOM2" = CAST((ISNULL(SUM(Quantity), 0) / (Case IsNull(Max(I1.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM2_Conversion),1) End)) AS nvarchar)
+ ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM2)) ,
"Total SIT Qty_UOM1" =
CAST(	( select IsNull(sum(IDR.pending), 0) / (Case IsNull(Max(I1.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM1_Conversion),1) End)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
) AS nvarchar
)  + ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM1)) ,
"Total SIT Qty_UOM2" =
CAST(	( select IsNull(sum(IDR.pending), 0) / (Case IsNull(Max(I1.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM2_Conversion),1) End)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
) AS nvarchar
)  + ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM2)) ,
"Saleable SIT Qty_UOM1" =
CAST(	( select IsNull(sum(IDR.pending), 0) / (Case IsNull(Max(I1.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM1_Conversion),1) End)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) AS nvarchar
)  + ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM1)) ,
"Saleable SIT Qty_UOM2" =
CAST(	( select IsNull(sum(IDR.pending), 0) / (Case IsNull(Max(I1.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM2_Conversion),1) End)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) > 0
) AS nvarchar
)  + ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM2)) ,
"Free SIT Qty_UOM1" =
CAST(	( select IsNull(sum(IDR.pending), 0) / (Case IsNull(Max(I1.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM1_Conversion),1) End)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code  and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) = 0
) AS nvarchar
)  + ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM1)) ,
"Free SIT Qty_UOM2" =
CAST(	( select IsNull(sum(IDR.pending), 0) / (Case IsNull(Max(I1.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(I1.UOM2_Conversion),1) End)
from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
where IDR.Product_code = I1.Product_code  and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
and isnull(IDR.saleprice, 0) = 0
) AS nvarchar
)  + ' ' +  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM = Max(I1.UOM2))

from  Items I1
Left Outer Join  Batch_Products On I1.Product_Code = Batch_Products.Product_Code
Left Outer Join  UOM On I1.UOM = UOM.UOM
Left Outer Join  ConversionTable On I1.ConversionUnit = ConversionTable.ConversionID
Inner Join ItemCategories IC On  IC.CategoryID = I1.CategoryID
Inner Join  #tempCategory1 T1 On I1.CategoryID = T1.CategoryID
WHERE
I1.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
--  AND I1.Active = 1
GROUP BY
T1.IDS,I1.Product_Code, I1.ProductName, UOM.Description, I1.ConversionFactor,
ConversionTable.ConversionUnit, I1.ReportingUnit, I1.ReportingUOM
Order by T1.IDS
END
--current date end--
END

IF OBJECT_ID('tempdb..#tmpProd') IS NOT NULL
Drop Table #tmpProd

IF OBJECT_ID('tempdb..#tempCategory1') IS NOT NULL
Drop Table #tempCategory1

IF OBJECT_ID('tempdb..#tmptotal_Invd_qty') IS NOT NULL
Drop Table #tmptotal_Invd_qty

IF OBJECT_ID('tempdb..#tmptotal_rcvd_qty') IS NOT NULL
Drop Table #tmptotal_rcvd_qty

IF OBJECT_ID('tempdb..#tmptotal_Invd_Saleonly_qty') IS NOT NULL
Drop Table #tmptotal_Invd_Saleonly_qty

