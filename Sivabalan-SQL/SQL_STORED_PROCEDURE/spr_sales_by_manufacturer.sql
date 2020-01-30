CREATE procedure spr_sales_by_manufacturer
                (@MANUFACTURER NVARCHAR (4000),
                 @FROMDATE DATETIME,
                 @TODATE DATETIME,
                 @ItemCode nVarChar(2550))
As

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

Create Table #TmpMfr (Mfr nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

If @MANUFACTURER = '%' 
	Insert Into #TmpMfr Select Manufacturer_Name From Manufacturer
Else
	Insert Into #TmpMfr Select * From DBO.sp_SplitIn2Rows(@MANUFACTURER,@Delimeter)

if @ItemCode = '%'
	Insert InTo #tmpProd Select Product_code From Items
Else
	Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)

Select Items.ManufacturerID,"Manufacturer Name" = Manufacturer.Manufacturer_Name, 
"Net Value (%c)" = sum(Amount) 
from invoicedetail,InvoiceAbstract,Manufacturer,Items 
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)
And Manufacturer.Manufacturer_Name in (Select Mfr COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpMfr)
and items.ManufacturerID=Manufacturer.ManufacturerID 
and items.product_Code=invoiceDetail.product_Code
And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)

Group by Items.ManufacturerID,Manufacturer.Manufacturer_Name

Drop Table #TmpMfr
Drop Table #tmpProd



