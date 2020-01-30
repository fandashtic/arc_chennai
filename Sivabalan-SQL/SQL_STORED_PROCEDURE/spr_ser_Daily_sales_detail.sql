CREATE procedure [dbo].[spr_ser_Daily_sales_detail](@DateSale datetime)      
As    
begin    
     
declare @InvoiceID int    
declare @ServiceInvoiceID int    
declare @InvoiceType varchar(10)    
declare @Locality varchar(10)    
declare @TaxValue decimal(18,6)    
declare @Prefix varchar(50)    
declare @TaxCompDesc varchar(50)    
declare @Query nvarchar(4000)    
declare @SaleID varchar(10)    
    

	Select "InvoiceID" = invoiceid,     
	"Invoice ID" = VoucherPrefix.Prefix + CAST(DocumentID AS varchar),      
	"Doc Reference"=DocReference,      
	"Type" = case InvoiceType      
	WHEN 5 THEN       
	'Retail Sales Return Saleable'      
	WHEN 6 THEN       
	'Retail Sales Return Damages'      
	WHEN 4 THEN       
	Case Status & 32      
	When 0 Then      
	'Sales Return Saleable'      
	Else      
	'Sales Return Damages'      
	End      
	WHEN 2 THEN 'Retail Invoice'      
	ELSE 'Invoice'      
	END,      
	"Goods Value (%c)" = Case       
	When InvoiceType>=4 and InvoiceType<=6 Then      
	0 - IsNull(InvoiceAbstract.GoodsValue, 0)      
	Else      
	IsNull(InvoiceAbstract.GoodsValue, 0)      
	End,      
	"Goods Value (First Sale) (%c)"= convert(decimal(18,6),'0'),    
	"Goods Value (Second Sale) (%c)"= convert(decimal(18,6),'0'),    
	"Tax Suffered (%c)" = Case   
	When InvoiceType>=4 and InvoiceType<=6  Then      
	0 - IsNull(InvoiceAbstract.TotalTaxSuffered, 0)      
	Else      
	IsNull(InvoiceAbstract.TotalTaxSuffered, 0)      
	End,      
	"Productwise Discount (%c)" = case when InvoiceType>=4 and InvoiceType<=6      
	then 0-IsNull(ProductDiscount, 0)     
	else IsNull(ProductDiscount, 0) end,    
	"Discount (%c)" = Case   
	When InvoiceType>=4 and InvoiceType<=6  Then      
	0 - (IsNull(DiscountValue, 0) + IsNull(AddlDiscountValue, 0) )      
	Else      
	(IsNull(DiscountValue, 0) + IsNull(AddlDiscountValue, 0) )      
	End,      
	"Tax Applicable (%c)" = Case       
	When InvoiceType>=4 and InvoiceType<=6  Then      
	0 - IsNull(InvoiceAbstract.TotalTaxApplicable, 0)      
	Else      
	IsNull(InvoiceAbstract.TotalTaxApplicable, 0)      
	End      
	into #DailySalesDetails    
	FROM  InvoiceAbstract, VoucherPrefix      
	WHERE  (InvoiceAbstract.Status & 128) = 0 AND      
	dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) = @DateSale AND       
	VoucherPrefix.TranID = 'INVOICE' AND      
	InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6)      
  
declare DailySalesReport cursor    
for    
	select distinct 'Total LT on FS',''    
union all    
	select distinct 'LTFS ',tcd.taxcomponent_desc from     
	invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, customer c    
	where    
	itc.invoiceid=idt.invoiceid and           
	itc.invoiceid=ia.invoiceid and          
	dbo.stripdatefromtime(ia.invoicedate) = @DateSale and     
	idt.product_code=itc.product_code and           
	idt.taxid=itc.tax_code and    
	(ia.status & 128 )=0 and          
	tcd.taxcomponent_code=itc.tax_component_code and    
	ia.customerid*=c.customerid and     
	isnull(c.locality,1)=1 and    
	idt.saleid=1    
union 
	select distinct 'LTFS ',tcd.taxcomponent_desc from     
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and           
	idt.serviceinvoiceid=ia.serviceinvoiceid and          
	itc.taxtype =2 and 
	dbo.stripdatefromtime(ia.serviceinvoicedate) = @DateSale and           
	isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code=itc.taxcomponent_code and    
	ia.customerid*=c.customerid and     
	isnull(c.locality,1)=1 and    
	idt.saleid=1 
union all    
	select 'Total CT on FS',''    
union all    
	select distinct 'CTFS ',tcd.taxcomponent_desc from     
	invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, customer c    
	where    
	itc.invoiceid=idt.invoiceid and           
	itc.invoiceid=ia.invoiceid and          
	dbo.stripdatefromtime(ia.invoicedate)=@DateSale and          
	idt.product_code=itc.product_code and           
	idt.taxid=itc.tax_code and    
	(ia.status & 128 )=0 and          
	tcd.taxcomponent_code=itc.tax_component_code and    
	ia.customerid*=c.customerid and     
	isnull(c.locality,1)=2 and    
	idt.saleid=1    
union 
	select distinct 'CTFS ',tcd.taxcomponent_desc from     
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and           
	idt.serviceinvoiceid=ia.serviceinvoiceid and
	itc.taxtype =2 and 
	dbo.stripdatefromtime(ia.serviceinvoicedate) = @DateSale and           
	isnull(ia.status,0) & 192 =0 
	and tcd.taxcomponent_code=itc.taxcomponent_code and    
	ia.customerid*=c.customerid and     
	isnull(c.locality,1)=2 and    
	idt.saleid=1 
	
union all    
	select 'Total LT on SS',''    
union all  
	select distinct 'LTSS ',tcd.taxcomponent_desc from     
	invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, customer c    
	where   
	itc.invoiceid=idt.invoiceid and           
	itc.invoiceid=ia.invoiceid and          
	dbo.stripdatefromtime(ia.invoicedate) =@DateSale and           
	idt.product_code=itc.product_code and           
	idt.taxid=itc.tax_code and    
	(ia.status & 128 )=0 and          
	tcd.taxcomponent_code=itc.tax_component_code and    
	ia.customerid*=c.customerid and     
	isnull(c.locality,1)=1 and    
	idt.saleid=2    
union   
	select distinct 'LTSS ',tcd.taxcomponent_desc from     
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and           
	idt.serviceinvoiceid=ia.serviceinvoiceid and 
	itc.taxtype =2 and 
	dbo.stripdatefromtime(ia.serviceinvoicedate) = @DateSale and           
	isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code=itc.taxcomponent_code and    
	ia.customerid*=c.customerid and     
	isnull(c.locality,1)=1 and    
	idt.saleid=2 
union all    
	select 'Total CT on SS',''    
union all    
	select distinct 'CTSS ',tcd.taxcomponent_desc from     
	invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, customer c    
	where itc.invoiceid=idt.invoiceid and           
	itc.invoiceid=ia.invoiceid and          
	dbo.stripdatefromtime(ia.invoicedate)=@DateSale and           
	idt.product_code=itc.product_code and           
	idt.taxid=itc.tax_code and    
	(ia.status & 128 )=0 and          
	tcd.taxcomponent_code=itc.tax_component_code and    
	ia.customerid*=c.customerid and     
	isnull(c.locality,1)=2 and    
	idt.saleid=2    
union 
	select distinct 'CTSS ',tcd.taxcomponent_desc from     
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and           
	idt.serviceinvoiceid=ia.serviceinvoiceid and 
	itc.taxtype =2 and 
	dbo.stripdatefromtime(ia.serviceinvoicedate) = @DateSale and           
	isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code=itc.taxcomponent_code and    
	ia.customerid*=c.customerid and     
	isnull(c.locality,1)=2 and    
	idt.saleid=2
union all    
	select 'Net Sales',''    
open DailySalesReport    
fetch next from DailySalesReport into @Prefix, @TaxCompDesc     
while @@FETCH_STATUS=0    
begin    
	set @Query = N'Alter table #DailySalesDetails add ['+@Prefix+rtrim(@TaxCompDesc)+' (%c)] decimal(18,6)'    
	exec sp_executesql @Query    
	fetch next from DailySalesReport into @Prefix, @TaxCompDesc     
end    
    
close DailySalesReport    
deallocate DailySalesReport    
    
    
declare DailySalesReport cursor     
for    
	select ia.invoiceid, tcd.taxcomponent_desc, isnull(locality,1), saleid, 
	sum( case when  InvoiceType>=4 and InvoiceType<=6  then 0 - tax_value else tax_value end) 
	from invoiceabstract ia, invoicedetail idt, invoicetaxcomponents itc, 
	taxcomponentdetail tcd, customer c    
	where ia.invoiceid = idt.invoiceid and      
	itc.invoiceid = idt.invoiceid and      
	tcd.taxcomponent_code = itc.tax_component_code and      
	itc.tax_code=idt.taxid and     
	(ia.status & 128)=0 and      
	itc.product_code=idt.product_code and    
	ia.customerid*=c.customerid and     
	dbo.stripdatefromtime(ia.invoicedate) = @DateSale    
	group by ia.invoiceid,tcd.Taxcomponent_desc, locality, saleid    
    
open DailySalesReport    
fetch next from DailySalesReport into @InvoiceID, @TaxCompDesc, @locality, @SaleID, @TaxValue    
while @@FETCH_STATUS = 0    
begin    
    
	if isnull(@Locality,1) = 1    
		set @Prefix = 'LT'    
	else    
		set @Prefix = 'CT'    
	
	if @SaleID = 1    
		set @Prefix = @Prefix + 'FS '    
	else    
		set @Prefix = @Prefix + 'SS '    

	if @TaxValue = 0 set @TaxValue = null    

	if exists(Select a.name from Tempdb.dbo.Sysobjects A, Tempdb.dbo.SysColumns b 
	Where a.id = b.id  and a.name like '#DailySalesAbstract%' and 
	b.Name like @Prefix+rtrim(@TaxCompDesc)+ '(%c)' )
	Begin
		set @Query = N'Update #DailySalesDetails     
		set ['+@Prefix+rtrim(@TaxCompDesc)+' (%c)]=('+convert(varchar,@TaxValue)+')      
		where InvoiceID='''+convert(varchar,@InvoiceID)+''''    
		exec sp_executesql @Query    
	end    
	fetch next from DailySalesReport into @InvoiceID, @TaxCompDesc, @locality, @SaleID, @TaxValue    
end    
close DailySalesReport    
deallocate DailySalesReport    

set @Query = N'update DSD set [Goods Value (First Sale) (%c)]=    
	(select sum(case when InvoiceType>=4 and InvoiceType<=6 then 0-(Quantity * SalePrice) 
	else (Quantity * SalePrice) end) 
	from invoicedetail idt, invoiceabstract ia     
	where ia.invoiceid=dsd.invoiceid and 
	idt.invoiceid=ia.invoiceid and     
	(status & 128) =0 and     
	saleid=1)    
from #DailySalesDetails DSD'    
exec sp_executesql @Query 

set @Query = N'update DSD set [Goods Value (Second Sale) (%c)]=    
	(select sum(case when InvoiceType>=4 and InvoiceType<=6 then 0-(Quantity * SalePrice) 
	else (Quantity * SalePrice) end) from invoicedetail idt, invoiceabstract ia     
	where ia.invoiceid=dsd.invoiceid and    
	idt.invoiceid=ia.invoiceid and     
	(status & 128) =0 and saleid=2)    
from #DailySalesDetails DSD'
exec sp_executesql @Query 

set @Query = N'update DSD set [Total LT on FS (%c)]=    
	(select sum(case when InvoiceType>=4 and InvoiceType<=6 then 0-stpayable else stpayable end) 
	from invoicedetail idt, invoiceabstract ia     
	where ia.invoiceid=dsd.invoiceid and     
	idt.invoiceid=ia.invoiceid and (status & 128) =0 and saleid=1)    
from #DailySalesDetails DSD'    
exec sp_executesql @Query 

set @Query = N'update DSD set [Total CT on FS (%c)]=    
	(select sum(case when InvoiceType>=4 and InvoiceType<=6 then 0-cstpayable else cstpayable end) 
	from invoicedetail idt, invoiceabstract ia     
	where ia.invoiceid=dsd.invoiceid and idt.invoiceid=ia.invoiceid and     
	(status & 128) =0 and saleid=1)    
from #DailySalesDetails DSD'
exec sp_executesql @Query 
    
set @Query = N'Update DSD set [Total LT on SS (%c)]=    
	(select sum(case when InvoiceType>=4 and InvoiceType<=6 then 0-stpayable else stpayable end) 
	from invoicedetail idt, invoiceabstract ia     
	where ia.invoiceid=dsd.invoiceid and idt.invoiceid=ia.invoiceid and     
	(status & 128) =0 and saleid=2)    
from #DailySalesDetails DSD'
exec sp_executesql @Query     
    
set @Query = N'update DSD set [Total CT on SS (%c)]=    
	(select sum(case when InvoiceType>=4 and InvoiceType<=6 then 0-cstpayable else cstpayable end) 
	from invoicedetail idt, invoiceabstract ia     
	where ia.invoiceid=dsd.invoiceid and idt.invoiceid=ia.invoiceid and     
	(status & 128) =0 and saleid=2)    
from #DailySalesDetails DSD'
exec sp_executesql @Query     
    
set @Query = N'update DSD set [Net Sales (%c)] = (    
	case when InvoiceType>=4 and InvoiceType<=6 then 0-(NetValue - IsNull(Freight, 0))    
	else NetValue - IsNull(Freight, 0)     
	end)    
from #DailySalesDetails DSD, invoiceabstract ia    
where dsd.invoiceid = ia.invoiceid and (ia.status & 128) = 0'
exec sp_executesql @Query 
 
set @Query = 'update #DailySalesDetails set [Total LT on FS (%c)]=null where [Total LT on FS (%c)]=0'    
exec sp_executesql @Query 
set @Query = 'update #DailySalesDetails set [Total CT on FS (%c)]=null where [Total CT on FS (%c)]=0'    
exec sp_executesql @Query 
set @Query = 'update #DailySalesDetails set [Total LT on SS (%c)]=null where [Total LT on SS (%c)]=0'    
exec sp_executesql @Query 
set @Query = 'update #DailySalesDetails set [Total CT on SS (%c)]=null where [Total CT on SS (%c)]=0'    
exec sp_executesql @Query 
set @Query = 'update #DailySalesDetails set [Net Sales (%c)]=null where [Net Sales (%c)]=0'    
exec sp_executesql @Query 
set @Query = 'update #DailySalesDetails set [Tax Suffered (%c)]=null where [Tax Suffered (%c)]=0'    
exec sp_executesql @Query 
    
--select * from #DailySalesDetails    
Select * into #InvoiceDetailTemp from #DailySalesDetails
-- set @Query = N'Select * into #InvoiceDetailTemp from #DailySalesDetails' 
-- exec sp_executesql @Query 
Delete from #DailySalesDetails    

/* Service */
Insert into #DailySalesDetails
(InvoiceID, [Invoice ID], [Doc Reference], Type, [Goods Value (%c)], 
[Goods Value (First Sale) (%c)], [Goods Value (Second Sale) (%c)], [Tax Suffered (%c)], 
[Productwise Discount (%c)], [Discount (%c)], [Tax Applicable (%c)])
Select "InvoiceID" = Serviceinvoiceid,     
"Invoice ID" = VoucherPrefix.Prefix + CAST(DocumentID AS varchar),      
"Doc Reference"=DocReference,      
"Type" = 'Service Invoice',      
"Goods Value (%c)" = (select (Quantity * Price) from 
	Serviceinvoicedetail idt, Serviceinvoiceabstract ia     
	where idt.serviceinvoiceid=ia.serviceinvoiceid 
	and isnull(status,0) & 192  =0 and
	isnull(idt.sparecode,'') <> ''), 
"Goods Value (First Sale) (%c)"= convert(decimal(18,6),'0'),    
"Goods Value (Second Sale) (%c)"= convert(decimal(18,6),'0'),    
"Tax Suffered (%c)" = IsNull(serviceInvoiceAbstract.TotalTaxSuffered, 0),      
"Productwise Discount (%c)" = IsNull(ItemDiscount, 0),    
"Discount (%c)" = (IsNull(AdditionalDiscountValue_spare, 0) + IsNull(TradeDiscountValue_spare, 0)),      
"Tax Applicable (%c)" = IsNull(TotalTaxApplicable, 0)      
FROM  serviceInvoiceAbstract, VoucherPrefix      
WHERE isnull(serviceInvoiceAbstract.status,0) & 192 =0   
AND dbo.StripDateFromTime(serviceInvoiceAbstract.serviceInvoiceDate) = @DateSale AND       
VoucherPrefix.TranID = 'SERVICE INVOICE' AND      
serviceInvoiceAbstract.serviceInvoiceType in (1)      
        
declare ServiceDailySalesReport cursor     
for
	select ia.serviceinvoiceid,tcd.taxcomponent_desc, isnull(locality,1), saleid, 
	sum(tax_value) from
	serviceinvoiceabstract ia, serviceinvoicedetail idt, serviceinvoicetaxcomponents itc, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and idt.serviceinvoiceid=ia.serviceinvoiceid         
	and itc.taxtype =2 and ia.serviceinvoicedate = @Datesale
	and isnull(ia.status,0) & 192 =0 and tcd.taxcomponent_code=itc.taxcomponent_code and    
	ia.customerid*=c.customerid    
	group by ia.serviceinvoiceid,tcd.Taxcomponent_desc, locality, saleid    
   
open ServiceDailySalesReport    

fetch next from ServiceDailySalesReport into @ServiceInvoiceID, @TaxCompDesc, @locality, @SaleID, @TaxValue    
while @@FETCH_STATUS = 0    
begin    
    
	if isnull(@Locality,1) = 1    
		set @Prefix = 'LT'    
	else    
		set @Prefix = 'CT'    
    
	if @SaleID = 1    
		set @Prefix = @Prefix + 'FS '    
	else    
		set @Prefix = @Prefix + 'SS '    

	if @TaxValue = 0 set @TaxValue = null    

	if exists(Select a.name from Tempdb.dbo.Sysobjects A, Tempdb.dbo.SysColumns b 
	Where a.id = b.id  and a.name like '#DailySalesDetails%' and b.Name like @Prefix+rtrim(@TaxCompDesc)+ '(%c)' )
	Begin
		set @Query = 'update #DailySalesDetails     
		set ['+@Prefix+rtrim(@TaxCompDesc)+' (%c)]=('+convert(varchar,@TaxValue)+')      
		where InvoiceID='''+convert(varchar,@ServiceInvoiceID)+''''    
		exec sp_executesql @Query    
	end    
	fetch next from ServiceDailySalesReport into @ServiceInvoiceID, @TaxCompDesc, @locality, @SaleID, @TaxValue    
end    
close ServiceDailySalesReport    
deallocate ServiceDailySalesReport    
    
    
set @Query = N'update SDSD set [Goods Value (First Sale) (%c)]=    
	(select sum(Quantity * Price) from Serviceinvoicedetail idt,Serviceinvoiceabstract ia     
	where ia.serviceinvoiceid=sdsd.invoiceid
	and idt.serviceinvoiceid=ia.serviceinvoiceid  
	and isnull(ia.status,0) & 192  =0 and
	isnull(idt.sparecode, '''') <> '''' and idt.saleid=1)
from #DailySalesDetails SDSD'
exec sp_executesql @Query     
    
set @Query = N'update SDSD set [Goods Value (Second Sale) (%c)]=    
	(select sum(Quantity * Price) from Serviceinvoicedetail idt, Serviceinvoiceabstract ia     
	where ia.serviceinvoiceid=sdsd.invoiceid
	and idt.serviceinvoiceid=ia.serviceinvoiceid  
	and isnull(status,0) & 192  =0 and
	isnull(idt.sparecode, '''') <> '''' and     
	idt.saleid= 2) 
from #DailySalesDetails SDSD'
exec sp_executesql @Query 

set @Query = N'update SDSD set [Total LT on FS (%c)]=    
	(select sum(lstpayable) from serviceinvoicedetail idt, serviceinvoiceabstract ia     
	where ia.serviceinvoiceid=sdsd.invoiceid
	and idt.serviceinvoiceid=ia.serviceinvoiceid  
	and isnull(status,0) & 192  =0 and
	isnull(idt.sparecode,'''') <> '''' and saleid=1)    
from #DailySalesDetails SDSD'    
exec sp_executesql @Query 
    
set @Query = N'update SDSD set [Total CT on FS (%c)]=    
	(select sum(cstpayable) from serviceinvoicedetail idt, serviceinvoiceabstract ia     
	where ia.serviceinvoiceid=sdsd.invoiceid
	and idt.serviceinvoiceid=ia.serviceinvoiceid  and isnull(status,0) & 192  =0 and
	isnull(idt.sparecode,'''') <> '''' and saleid=1)    
from #DailySalesDetails SDSD'    
exec sp_executesql @Query 

set @Query = N'update SDSD set [Total LT on SS (%c)]=    
(select sum(lstpayable) from serviceinvoicedetail idt, serviceinvoiceabstract ia     
where ia.serviceinvoiceid=sdsd.invoiceid
and idt.serviceinvoiceid=ia.serviceinvoiceid  and isnull(status,0) & 192  =0 and
isnull(idt.sparecode, '''') <> '''' and saleid=2)    
from #DailySalesDetails SDSD'    
    
set @Query = N'update SDSD set [Total CT on SS (%c)]=    
(select sum(cstpayable) from serviceinvoicedetail idt, serviceinvoiceabstract ia     
where ia.serviceinvoiceid=sdsd.invoiceid
and idt.serviceinvoiceid=ia.serviceinvoiceid and isnull(status,0) & 192  =0 and
isnull(idt.sparecode, '''') <> '''' and saleid=2)    
from #DailySalesDetails SDSD'    
exec sp_executesql @Query 
 
set @Query = N'update SDSD set [Net Sales (%c)] = NetValue - IsNull(Freight, 0)     
from #DailySalesDetails SDSD, serviceinvoiceabstract ia    
where ia.serviceinvoiceid=sdsd.invoiceid
and isnull(status,0) & 192 = 0' 
exec sp_executesql @Query 
--isnull(idt.sparecode,'') <> ''     
    
set @Query = 'update #DailySalesDetails set [Total LT on FS (%c)]=null where [Total LT on FS (%c)]=0    
update #DailySalesDetails set [Total CT on FS (%c)]=null where [Total CT on FS (%c)]=0    
update #DailySalesDetails set [Total LT on SS (%c)]=null where [Total LT on SS (%c)]=0    
update #DailySalesDetails set [Total CT on SS (%c)]=null where [Total CT on SS (%c)]=0    
update #DailySalesDetails set [Net Sales (%c)]=null where [Net Sales (%c)]=0    
update #DailySalesDetails set [Tax Suffered (%c)]=null where [Tax Suffered (%c)]=0'
exec sp_executesql @Query 
-- select * into #ServiceInvoiceDetailTemp from #ServiceDailySalesDetails 
-- drop table #ServiceDailySalesDetails    
-- select * from #InvoiceDetailTemp
-- select * from #ServiceInvoiceDetailTemp
-- insert into #InvoiceDetailTemp  Select * from #ServiceInvoiceDetailTemp
-- drop table #ServiceInvoiceDetailTemp
Insert into #InvoiceDetailTemp  Select * from #DailySalesDetails
set @Query = N'Select * from #InvoiceDetailTemp drop table #InvoiceDetailTemp' 
exec sp_executesql @Query 
-- drop table #ServiceDailySalesDetails    
end
