CREATE Procedure spr_list_Manufacturerwise_StockSales_FMCG(@Manufacturer nvarchar(20),
							@FromDate Datetime,
							@ToDate Datetime, 
                            @ItemCode nvarchar(2550))
As
Declare @NEXT_DATE Datetime
DECLARE @CORRECTED_DATE datetime  
Declare @Delimeter as Char(1)      
Declare @SalesValue Decimal(18, 6), @TaxSuffered Decimal(18, 6)
Set @Delimeter=Char(15)      
Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )
create table #tmpone(SalesValue Decimal(18, 6), TaxSuffered Decimal(18, 6))
if @Manufacturer = '%'       
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer      
Else      
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Manufacturer,@Delimeter)      

if @ItemCode = '%'
	Insert InTo #tmpProd Select Product_code From Items
Else
	Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)

SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS nvarchar) + '/'   
+ CAST(DATEPART(mm, @TODATE) as nvarchar) + '/'   
+ cast(DATEPART(yyyy, @TODATE) AS nvarchar)  
SET  @NEXT_DATE = CAST(DATEPART(dd, GETDATE()) AS nvarchar) + '/'   
+ CAST(DATEPART(mm, GETDATE()) as nvarchar) + '/'   
+ cast(DATEPART(yyyy, GETDATE()) AS nvarchar)  

Insert InTo #tmpone(SalesValue) 
Select Case InvoiceType  
 When 4 then  
 0 - 0 --(Sum(Amount) - (Sum(SalePrice * Quantity) * Max(InvoiceDetail.TaxSuffered) / 100) - SUM(ABS((STPayable + CSTPayable))))  
 Else  
 Sum(Amount) - (Sum(SalePrice * Quantity) * Max(InvoiceDetail.TaxSuffered) / 100) - SUM((STPayable + CSTPayable))  
 End From Manufacturer, InvoiceAbstract, InvoiceDetail, Items  
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
 InvoiceDetail.Product_Code = Items.Product_Code And  
 Items.ManufacturerID = Manufacturer.ManufacturerID And
 Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
 Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) 
 Group By Invoicedetail.InvoiceID, InvoiceType, InvoiceDetail.Product_Code  

Insert InTo #tmpone(TaxSuffered)
select Case InvoiceType
	When 4 then
	0 - (sum(SalePrice * Quantity) * max(InvoiceDetail.TaxSuffered) / 100)
	Else
	sum(SalePrice * Quantity) * max(InvoiceDetail.TaxSuffered) / 100
	End From Manufacturer, InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @Fromdate And @ToDate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
	Items.ManufacturerID = Manufacturer.ManufacturerID And
    Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
    Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) 
    Group by invoicetype, invoicedetail.invoiceid, invoicedetail.product_code

Select @SalesValue = Sum(SalesValue), @TaxSuffered = Sum(TaxSuffered) From #tmpone
	
Select Manufacturer.Manufacturer_Name,
"Manufacturer" = Manufacturer.Manufacturer_Name,
"Sales Value (%c)" = @SalesValue,
"Tax Suffered" = @TaxSuffered,
"Tax Applicable" = IsNull((Select Sum(Case InvoiceType
	When 4 then
	0 - (STPayable + CSTPayable)
	Else
	(STPayable + CSTPayable)
	End) From InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
    Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
	Items.ManufacturerID = Manufacturer.ManufacturerID), 0),
"Total (%c)" = IsNull((Select Sum(Case InvoiceType
	When 4 then
	0 - Amount
	Else
	Amount
	End) From InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
    Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
	Items.ManufacturerID = Manufacturer.ManufacturerID), 0),
"Stock Value (%c)" = CASE when (@TODATE < @NEXT_DATE) THEN   
	ISNULL((Select sum(Opening_Value)
	FROM OpeningDetails,Items   
	WHERE OpeningDetails.Product_Code = Items.Product_Code And
    Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
	Items.ManufacturerID = Manufacturer.ManufacturerID  
	AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)  
	ELSE   
	IsNull((Select Sum(Quantity * PurchasePrice) From Batch_Products, Items
	Where Batch_Products.Product_Code = Items.Product_Code And
    Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
	Items.ManufacturerID = Manufacturer.ManufacturerID And
	Batch_Products.Quantity > 0), 0)
	END,
"Tax Suffered" = CASE when (@TODATE < @NEXT_DATE) THEN   
	ISNULL((Select sum(Opening_Quantity * Purchase_Price * IsNull(TaxSuffered_Value,0)/100 )
	FROM OpeningDetails,Items   
	WHERE OpeningDetails.Product_Code = Items.Product_Code And
    Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
	Items.ManufacturerID = Manufacturer.ManufacturerID 
	AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)  
	ELSE   
	IsNull((Select Sum(case isnull(batch_products.TaxOnMRP,0) when 1 then case(itemcategories.price_option) when 0 then
	(Quantity * Items.Sale_Price * dbo.fn_Get_TaxOnMRP(Batch_Products.TaxSuffered )/100) Else
	(Quantity * Batch_Products.SalePrice * dbo.fn_Get_TaxOnMRP(Batch_Products.TaxSuffered )/100) End
	Else (Quantity * PurchasePrice * Batch_Products.TaxSuffered /100) End) 
	From Batch_Products, Items, ItemCategories
	Where Batch_Products.Product_Code = Items.Product_Code And
    Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
	Items.Categoryid=ItemCategories.Categoryid and	
	Items.ManufacturerID = Manufacturer.ManufacturerID And
	Batch_Products.Quantity > 0), 0)
	END,
"Total Value (%c)" = CASE when (@TODATE < @NEXT_DATE) THEN   
	ISNULL((Select sum(Opening_Value + (Opening_Quantity * Purchase_Price * IsNull(TaxSuffered_Value,0)/100 ))   
	FROM OpeningDetails,Items   
	WHERE OpeningDetails.Product_Code = Items.Product_Code And
    Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
	Items.ManufacturerID = Manufacturer.ManufacturerID  
	AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)  
	ELSE   
	IsNull((Select Sum(
		case isnull(batch_products.TaxOnMRP,0) 
		when 1 then 
			case(itemcategories.price_option) 
				when 0 then
					(Quantity * PurchasePrice) +IsNull((Quantity * Items.Sale_Price * dbo.fn_Get_TaxOnMRP(Batch_Products.TaxSuffered) / 100), 0)
				Else
					(Quantity * PurchasePrice) +IsNull((Quantity * Batch_Products.SalePrice * dbo.fn_Get_TaxOnMRP(Batch_Products.TaxSuffered) / 100), 0)
				End
		Else
		(Quantity * PurchasePrice) +IsNull((Quantity * PurchasePrice * Batch_Products.TaxSuffered / 100), 0)
	           End

			)
	From Batch_Products, Items, ItemCategories
	Where Batch_Products.Product_Code = Items.Product_Code And
    Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
	Items.Categoryid=ItemCategories.Categoryid and	
	Items.ManufacturerID = Manufacturer.ManufacturerID And
	Batch_Products.Quantity > 0), 0)
	END
From 	Manufacturer
Where	Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) 


Drop Table #tmpMfr    
Drop Table #tmpProd    
Drop Table #tmpone




