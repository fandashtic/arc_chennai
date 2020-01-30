CREATE Procedure spr_ser_list_Manufacturerwise_StockSales(@Manufacturer Varchar(2550),    
       @FromDate Datetime,    
       @ToDate Datetime, 
       @ItemCode VarChar(255))    
As    
Declare @NEXT_DATE Datetime    
DECLARE @CORRECTED_DATE datetime      
Declare @Delimeter as Char(1)      
Declare @SalesValue Decimal(18, 6), @TaxSuffered Decimal(18, 6)
Set @Delimeter=Char(15)      
Create table #tmpMfr(Manufacturer varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
create table #tmpProd(product_code varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
create table #tmpone(SalesValue Decimal(18, 6), TaxSuffered Decimal(18, 6))
if @Manufacturer = '%'       
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer      
Else      
   Insert into #tmpMfr select * from dbo.sp_Ser_SplitIn2Rows(@Manufacturer,@Delimeter)      

if @ItemCode = '%'
	Insert InTo #tmpProd Select Product_code From Items
Else
	Insert into #tmpProd select * from dbo.sp_ser_SplitIn2Rows(@ItemCode, @Delimeter)
    
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS varchar) + '/'       
+ CAST(DATEPART(mm, @TODATE) as varchar) + '/'       
+ cast(DATEPART(yyyy, @TODATE) AS varchar)      
SET  @NEXT_DATE = CAST(DATEPART(dd, dbo.fn_GetOperartingDate(GETDATE())) AS varchar) + '/'       
+ CAST(DATEPART(mm, dbo.fn_GetOperartingDate(GETDATE())) as varchar) + '/'       
+ cast(DATEPART(yyyy, dbo.fn_GetOperartingDate(GETDATE())) AS varchar)      

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

Insert InTo #tmpone(SalesValue) 

Select Sum(Isnull(serviceinvoicedetail.netvalue,0)) - (Sum(Isnull(Price,0) * Isnull(Quantity,0)) * Max(ServiceInvoiceDetail.Tax_SufferedPercentage) / 100) - SUM((Isnull(LSTPayable,0) + Isnull(CSTPayable,0)))  
From Manufacturer, ServiceInvoiceAbstract, ServiceInvoiceDetail,items
Where serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID And  
serviceInvoiceAbstract.serviceInvoiceDate Between @Fromdate and @Todate And  
IsNull(serviceInvoiceAbstract.Status, 0) & 192 = 0 And  
Isnull(serviceInvoicedetail.Sparecode,'')<> '' And
Items.ManufacturerID = Manufacturer.ManufacturerID And
serviceInvoiceDetail.spareCode = Items.Product_Code And  
Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) 
Group By serviceInvoicedetail.serviceInvoiceID, serviceInvoiceType, serviceInvoiceDetail.sparecode


Insert InTo #tmpone(TaxSuffered)
select Case InvoiceType
	When 4 then
	0 - (sum(SalePrice * Quantity) * max(InvoiceDetail.TaxSuffered) / 100)
	Else
	sum(SalePrice * Quantity) * max(InvoiceDetail.TaxSuffered) / 100
	End From Manufacturer, InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @Fromdate and @Todate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
	Items.ManufacturerID = Manufacturer.ManufacturerID And
        items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
	Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) 
        Group by invoicetype, invoicedetail.invoiceid, invoicedetail.product_code

Insert InTo #tmpone(TaxSuffered)

select sum(Isnull(Price,0) * Isnull(Quantity,0)) * max(Isnull(serviceInvoiceDetail.Tax_SufferedPercentage,0)) / 100
	From Manufacturer, ServiceInvoiceAbstract, ServiceInvoiceDetail,items
	Where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID And
	ServiceInvoiceAbstract.ServiceInvoiceDate Between @Fromdate and @Todate And
	IsNull(ServiceInvoiceAbstract.Status, 0) & 192 = 0 And
	Isnull(Serviceinvoicedetail.sparecode,'') <> '' And
	Items.ManufacturerID = Manufacturer.ManufacturerID And
        serviceInvoiceDetail.spareCode = Items.Product_Code And  
	Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
	Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) 
	Group by serviceinvoicetype, serviceinvoicedetail.serviceinvoiceid, serviceinvoicedetail.sparecode


select  @salesvalue = Sum(SalesValue), @Taxsuffered = Sum(TaxSuffered) from #tmpone


Select Manufacturer.Manufacturer_Name,    
"Manufacturer" = Manufacturer.Manufacturer_Name,    
"Sales Value (%c)" = @SalesValue,
--IsNull(dbo.sp_compute_gv_mfr(Manufacturer.ManufacturerID, @FromDate, @ToDate), 0),    
"Tax Suffered" = @TaxSuffered,
--IsNull(dbo.sp_compute_ts_mfr(Manufacturer.ManufacturerID, @FromDate, @ToDate), 0),    
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
 Items.ManufacturerID = Manufacturer.ManufacturerID), 0)
+ IsNull((Select Sum(Isnull(LSTPayable,0) + Isnull(CSTPayable,0))    
	From ServiceInvoiceAbstract, ServiceInvoiceDetail,items
	Where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID And    
	ServiceInvoiceAbstract.ServiceInvoiceDate Between  @FromDate and @ToDate
	and IsNull(ServiceInvoiceAbstract.Status, 0) & 192 = 0 And 
        serviceInvoiceAbstract.ServiceinvoiceType in(1) And
	isnull(serviceinvoicedetail.sparecode, '') <> '' And
         serviceInvoiceDetail.spareCode = Items.Product_Code And    
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
 Items.ManufacturerID = Manufacturer.ManufacturerID), 0)

 + IsNull((Select Sum(Isnull(ServiceInvoiceDetail.Netvalue,0))
	From ServiceInvoiceAbstract, ServiceInvoiceDetail,items
	Where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID And    
	ServiceInvoiceAbstract.ServiceInvoiceDate Between @FromDate and @ToDate
	And IsNull(ServiceInvoiceAbstract.Status, 0) & 192 = 0 And    
        serviceInvoiceDetail.spareCode = Items.Product_Code And  
	isnull(serviceinvoicedetail.sparecode, '') <> '' And
	serviceInvoiceAbstract.ServiceinvoiceType in(1) And
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
 (Quantity * Items.ECP * dbo.fn_Get_TaxOnMRP(Batch_Products.TaxSuffered )/100) Else    
 (Quantity * Batch_Products.ECP * dbo.fn_Get_TaxOnMRP(Batch_Products.TaxSuffered )/100) End    
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
     (Quantity * PurchasePrice) +IsNull((Quantity * Items.ECP * dbo.sp_ser_Get_TaxOnMRP(Batch_Products.TaxSuffered) / 100), 0)    
    Else    
     (Quantity * PurchasePrice) +IsNull((Quantity * Batch_Products.ECP * dbo.fn_Get_TaxOnMRP(Batch_Products.TaxSuffered) / 100), 0)    
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
From  Manufacturer
Where Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) 
    
    
Drop Table #tmpMfr    
Drop Table #tmpProd    
Drop Table #tmpone











