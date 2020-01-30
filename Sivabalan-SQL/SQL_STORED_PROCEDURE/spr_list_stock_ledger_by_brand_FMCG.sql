CREATE PROCEDURE [dbo].[spr_list_stock_ledger_by_brand_FMCG](@BRAND nvarchar(2550),
@FROM_DATE datetime,
@ShowItems nvarchar(50),
@StockVal nvarchar(100),
@ItemCode nvarchar(2550))
AS

Declare @Delimeter as Char(1)
Set @Delimeter=Char(15)
Create table #tmpDiv(Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

if @BRAND='%'
Insert into #tmpDiv select BrandName from Brand
Else
Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@BRAND,@Delimeter)

if @ItemCode = '%'
Insert InTo #tmpProd Select Product_code From Items
Else
Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)

IF (DATEPART(dy, @FROM_DATE) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FROM_DATE) = DATEPART(yyyy, GETDATE())) OR DATEPART(yyyy, @FROM_DATE) < DATEPART(yyyy, GETDATE())
BEGIN
IF @ShowItems = 'Items with stock'
BEGIN
Select  Items.BrandID,
"Division" = Brand.BrandName,
"Total On Hand Qty" = ISNULL(SUM(OpeningDetails.Opening_Quantity), 0),
"Total On Hand Value" =
case @StockVal
When 'SalePrice' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))
When 'PurchasePrice' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))
--   When 'ECP' Then
--   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))
When 'MRP' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))
--   When 'Special Price' Then
--   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))
Else
SUM(ISNULL(OpeningDetails.Opening_Value, 0))
End,
"Saleable Stock" = sum(isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),
"Saleable Value" =
case @StockVal
When 'SalePrice' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))
When 'PurchasePrice' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))
--   When 'ECP' Then
--   sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))
When 'MRP' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))
--   When 'Special Price' Then
--   sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))
Else
sum(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))
End,
"Free OnHand Qty" = isnull(sum(openingdetails.Free_Saleable_Quantity ), 0),
"Damages Qty" = isnull(sum(openingdetails.Damage_Opening_Quantity),0),
"Damages Value" =
case @StockVal
When 'SalePrice' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.Sale_Price), 0)
When 'PurchasePrice' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.Purchase_Price), 0)
--   When 'ECP' Then
--   isnull(sum(openingdetails.Damage_Opening_Quantity * Items.ECP), 0)
When 'MRP' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.MRP), 0)
--   When 'Special Price' Then
--   isnull(sum(openingdetails.Damage_Opening_Quantity * Items.Company_Price), 0)
Else
isnull(sum(openingdetails.Damage_Opening_Value), 0)
End
from    Items --, OpeningDetails, Brand
Inner Join Brand On Items.BrandID = Brand.BrandID
Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
--WHERE   Items.Product_Code *= OpeningDetails.Product_Code
WHERE OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)
--AND Items.BrandID = Brand.BrandID
AND Brand.BrandName In (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv)
AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and Brand.active  = 1
GROUP BY Items.BrandID, Brand.BrandName
HAVING ISNULL(SUM(OpeningDetails.Opening_Quantity), 0) > 0
END
ELSE
BEGIN
Select  Items.BrandID,
"Division" = Brand.BrandName,
"Total On Hand Qty" = ISNULL(SUM(OpeningDetails.Opening_Quantity), 0),
"Total On Hand Value" =
case @StockVal
When 'SalePrice' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))
When 'PurchasePrice' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))
--   When 'ECP' Then
--   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))
When 'MRP' Then
(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))
--   When 'Special Price' Then
--   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))
Else
SUM(ISNULL(OpeningDetails.Opening_Value, 0))
End,
"Saleable Stock" = sum(isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),
"Saleable Value" =
case @StockVal
When 'SalePrice' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))
When 'PurchasePrice' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))
--   When 'ECP' Then
--   sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))
When 'MRP' Then
sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))
--   When 'Special Price' Then
--   sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))
Else
sum(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))
End,
"Free OnHand Qty" = isnull(sum(openingdetails.Free_Saleable_Quantity ), 0),
"Damages Qty" = isnull(sum(openingdetails.Damage_Opening_Quantity),0),
"Damages Value" =
case @StockVal
When 'SalePrice' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.Sale_Price), 0)
When 'PurchasePrice' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.Purchase_Price), 0)
--   When 'ECP' Then
--   isnull(sum(openingdetails.Damage_Opening_Quantity * Items.ECP), 0)
When 'MRP' Then
isnull(sum(openingdetails.Damage_Opening_Quantity * Items.MRP), 0)
--   When 'Special Price' Then
--   isnull(sum(openingdetails.Damage_Opening_Quantity * Items.Company_Price), 0)
Else
isnull(sum(openingdetails.Damage_Opening_Value), 0)
End
from    Items --, OpeningDetails, Brand
Inner Join Brand On Items.BrandID = Brand.BrandID
Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
--WHERE   Items.Product_Code *= OpeningDetails.Product_Code
WHERE OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)
--AND Items.BrandID = Brand.BrandID
AND Brand.BrandName In (Select Division  COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv)
AND Items.Product_Code in (Select product_code  COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and Brand.active  = 1
GROUP BY Items.BrandID, Brand.BrandName
END
END
ELSE
BEGIN
IF @ShowItems = 'Items with stock'
BEGIN
Select  Items.BrandID,
"Division" = b1.BrandName,
"Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0),
"Total On Hand Value" =
case @StockVal
When 'SalePrice'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End) End)
When 'PurchasePrice' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End) End)
--   When 'ECP' Then
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End) End)
When 'MRP' Then
isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0)End)),0)
--   When 'Special Price' Then
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End,

"Saleable Stock" = isnull((select isnull(Sum(Quantity),0) from batch_products, Items where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And Items.BrandID = b1.BrandID),0),
"Saleable Value" = Isnull((Select
case @StockVal
When 'SalePrice'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)
When 'PurchasePrice' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)
--   When 'ECP' Then
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)
When 'MRP' Then
isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)
--   When 'Special Price' Then
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End
from batch_products, Items, ItemCategories IC where Items.Product_Code = Batch_Products.Product_Code and Items.CategoryID = IC.CategoryID and isnull(free,0)=0 and isnull(damage,0) = 0 And Items.BrandID = b1.BrandID),0),
"Free OnHand Qty" = isnull((select isnull(sum(Quantity),0) from Batch_Products, Items where Items.Product_Code = Batch_Products.Product_Code and free <> 0 And Items.BrandID = b1.BrandID),0),
"Damages Qty" = isnull((select isnull(sum(Quantity),0) from Batch_Products, items where Items.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And Items.BrandID = b1.BrandID),0),
"Damages Value" = isnull((select
case @StockVal
When 'SalePrice'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)
When 'PurchasePrice' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)
--   When 'ECP' Then
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)
When 'MRP' Then
isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)
--   When 'Special Price' Then
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End
from items, Batch_Products, ItemCategories IC where Items.Product_Code = Batch_Products.Product_Code and Items.CategoryID = IC.CategoryID and isnull(damage,0) <> 0 And Items.BrandID = b1.BrandID),0)
from  Items --, Batch_Products, Brand b1, ItemCategories IC
Inner Join Brand b1 On Items.BrandID = b1.BrandID
Inner Join  ItemCategories IC On Items.CategoryID = IC.CategoryID
Left Outer Join  Batch_Products On Items.Product_Code = Batch_Products.Product_Code
--WHERE  Items.BrandID = b1.BrandID
--AND Items.Product_Code *= Batch_Products.Product_Code
--AND Items.CategoryID = IC.CategoryID
WHERE b1.BrandName In (Select Division  COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv)
And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and b1.active  = 1
GROUP BY Items.BrandID, b1.BrandID, b1.BrandName
HAVING ISNULL(SUM(QUANTITY), 0) > 0
END
ELSE
BEGIN
Select  Items.BrandID,
"Division" = b1.BrandName,
"Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0),
"Total On Hand Value" =
case @StockVal
When 'SalePrice'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End) End)
When 'PurchasePrice' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End) End)
--   When 'ECP' Then
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End) End)
When 'MRP' Then
isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0)End)),0)
--   When 'Special Price' Then
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End,

"Saleable Stock" = isnull((select isnull(Sum(Quantity),0) from batch_products, Items where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And Items.BrandID = b1.BrandID),0),
"Saleable Value" = Isnull((Select
case @StockVal
When 'SalePrice'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)
When 'PurchasePrice' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)
--   When 'ECP' Then
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)
When 'MRP' Then
isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)
--   When 'Special Price' Then
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End
from batch_products, Items, ItemCategories IC where Items.CategoryID = IC.CategoryID And Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And Items.BrandID = b1.BrandID),0),
"Free OnHand Qty" = isnull((select isnull(sum(Quantity),0) from Batch_Products, Items where Items.Product_Code = Batch_Products.Product_Code and free <> 0 And Items.BrandID = b1.BrandID),0),
"Damages Qty" = isnull((select isnull(sum(Quantity),0) from Batch_Products, items where Items.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And Items.BrandID = b1.BrandID),0),
"Damages Value" = isnull((select
case @StockVal
When 'SalePrice'  Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)
When 'PurchasePrice' Then
Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)
--   When 'ECP' Then
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)
When 'MRP' Then
isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)
--   When 'Special Price' Then
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)
Else
isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)
End
from items, Batch_Products, ItemCategories IC where Items.CategoryID = IC.CategoryID And Items.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And Items.BrandID = b1.BrandID),0)
from  Items --, Batch_Products, Brand b1, ItemCategories IC
Inner Join Brand b1 On Items.BrandID = b1.BrandID
Inner Join  ItemCategories IC On Items.CategoryID = IC.CategoryID
Left Outer Join  Batch_Products On Items.Product_Code = Batch_Products.Product_Code
--WHERE  Items.BrandID = b1.BrandID
--AND Items.Product_Code *= Batch_Products.Product_Code
--AND Items.CategoryID = IC.CategoryID
WHERE b1.BrandName In (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv)
And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and b1.active  = 1
GROUP BY Items.BrandID, b1.BrandID, b1.BrandName
END
END


Drop table #tmpDiv
Drop table #tmpProd
