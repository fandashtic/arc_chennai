CREATE procedure spr_ser_sales_by_manufacturer
                (@MANUFACTURER NVARCHAR (4000),
                 @FROMDATE DATETIME,
                 @TODATE DATETIME)
As

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

CREATE TABLE #ManufactuereTemp( ManufacturerID int,ManufacturerName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
NetValue Decimal(18,6))

Create Table #TmpMfr (Mfr varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

If @MANUFACTURER = '%' 
	Insert Into #TmpMfr Select Manufacturer_Name From Manufacturer
Else
	Insert Into #TmpMfr Select * From DBO.sp_SplitIn2Rows(@MANUFACTURER,@Delimeter)

Insert into #ManufactuereTemp

Select Items.ManufacturerID,"Manufacturer Name" = Manufacturer.Manufacturer_Name, 
"Net Value (%c)" = sum(Amount) 
from invoicedetail,InvoiceAbstract,Manufacturer,Items 
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)
And Manufacturer.Manufacturer_Name in (Select Mfr From #TmpMfr)
and items.ManufacturerID=Manufacturer.ManufacturerID 
and items.product_Code=invoiceDetail.product_Code
Group by Items.ManufacturerID,Manufacturer.Manufacturer_Name

Insert into #ManufactuereTemp

Select Items.ManufacturerID,"Manufacturer Name" = Manufacturer.Manufacturer_Name, 
"Net Value (%c)" = Isnull(sum(ServiceInvoiceDetail.NetValue),0) 
from serviceinvoicedetail,serviceInvoiceAbstract,Manufacturer,Items 
where serviceinvoiceAbstract.serviceInvoiceID=serviceInvoiceDetail.serviceInvoiceID 
and serviceinvoicedate between @FROMDATE and @TODATE
And Isnull(serviceInvoiceAbstract.Status,0)&192=0 
And Isnull(serviceinvoicedetail.sparecode,'') <> ''
And ServiceInvoiceAbstract.ServiceInvoiceType in (1)
And Manufacturer.Manufacturer_Name in (Select Mfr From #TmpMfr)
and items.ManufacturerID=Manufacturer.ManufacturerID 
and items.product_Code=serviceinvoiceDetail.SpareCode
Group by Items.ManufacturerID,Manufacturer.Manufacturer_Name

Drop Table #TmpMfr

SELECT "ManufacturerID" = ManufacturerID, "Manufacturer Name" = ManufacturerName,
"Net Value (%c)" = sum(Netvalue) from #ManufactuereTemp
Group by ManufacturerID,ManufacturerName
Drop Table #ManufactuereTemp



