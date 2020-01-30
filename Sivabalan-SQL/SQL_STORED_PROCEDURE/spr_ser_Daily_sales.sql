CREATE procedure [dbo].[spr_ser_Daily_sales](@FROMDATE DATETIME, @TODATE DATETIME)      
As      
begin    
    
declare @InvoiceDate datetime    
declare @InvoiceType varchar(10)    
declare @Locality varchar(10)    
declare @TaxValue decimal(18,6)    
declare @Prefix varchar(50)    
declare @TaxCompDesc varchar(50)    
declare @Query nvarchar(4000)
declare @Query1 nvarchar(4000)    
declare @SaleID varchar(10)    

Create Table #TempSalesAbstract 
(InvDate datetime,
InvoiceDate datetime,
[Goods Value (Sales)] Decimal(18,6),    
[Goods Value (First Sale)] Decimal(18,6),
[Goods Value (Second Sale)] Decimal(18,6),
[Goods Value (Sales Return Damages)] Decimal(18,6),
[Goods Value (Sales Return Saleable)] Decimal(18,6),
[Total Tax Suffered]  Decimal(18,6),
[Productwise Discount] Decimal(18,6),
[Total Discount] Decimal(18,6),
[Total Tax Applicable] Decimal(18,6)
)

Insert into #TempSalesAbstract 
Select "InvDate" =dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),      
	"InvoiceDate" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),      
	"Goods Value (Sales) (%c)" = Convert(Decimal(18,6),0),      
	"Goods Value (First Sale) (%c)"=Convert(Decimal(18,6),0),    
	"Goods Value (Second Sale) (%c)"=Convert(Decimal(18,6),0),    
	"Goods Value (Sales Return Damages) (%c)" = Sum(Case InvoiceType      
	When 4 Then      
	Case Status & 32       
	When 0 Then      
	0      
	Else      
	IsNull(GoodsValue, 0)      
	End      
	when 6 Then    
	IsNull(GoodsValue, 0)    
	Else      
	0      
	End),      
	"Goods Value (Sales Return Saleable) (%c)" = Sum(Case InvoiceType      
	When 5 Then      
	IsNull(GoodsValue, 0)      
	When 4 Then      
	Case Status & 32       
	When 0 Then      
	IsNull(GoodsValue, 0)      
	Else      
	0      
	End      
	Else      
	0      
	End),      
	"Total Tax Suffered (%c)" = Sum(Case InvoiceType      
	When 4 Then      
	0 - IsNull(TotalTaxSuffered, 0)      
	When 5 Then      
	0 - IsNull(TotalTaxSuffered, 0)      
	When 6 Then      
	0 - IsNull(TotalTaxSuffered, 0)      
	Else      
	IsNull(TotalTaxSuffered, 0)      
	End),      
	"Productwise Discount (%c)" = sum(case InvoiceType     
	when 4 then 0-IsNull(ProductDiscount, 0)     
	when 5 then 0-IsNull(ProductDiscount, 0)     
	when 6 then 0-IsNull(ProductDiscount, 0)     
	else IsNull(ProductDiscount, 0) end),    
	"Total Discount (%c)" = Sum(Case InvoiceType      
	When 4 Then      
	0 - (IsNull(DiscountValue, 0) + IsNull(AddlDiscountValue, 0) )      
	When 5 Then      
	0 - (IsNull(DiscountValue, 0) + IsNull(AddlDiscountValue, 0) )      
	When 6 Then      
	0 - (IsNull(DiscountValue, 0) + IsNull(AddlDiscountValue, 0) )      
	Else      
	(IsNull(DiscountValue, 0) + IsNull(AddlDiscountValue, 0) )      
	End),      
	"Total Tax Applicable (%c)" = Sum(Case InvoiceType      
	When 4 Then      
	0 - IsNull(TotalTaxApplicable, 0)      
	When 5 Then      
	0 - IsNull(TotalTaxApplicable, 0)      
	When 6 Then      
	0 - IsNull(TotalTaxApplicable, 0)      
	Else      
	IsNull(TotalTaxApplicable, 0)      
	End)      
-- 	into #TempSalesAbstract 
	From InvoiceAbstract      
	Where InvoiceAbstract.InvoiceDate Between @Fromdate and @Todate and 
	InvoiceAbstract.Status & 128 = 0 And      
	InvoiceType in (1, 2, 3, 4, 5, 6)      
	Group By dbo.StripDateFromTime(InvoiceDate)    
	order by dbo.StripDateFromTime(InvoiceDate)      

	Insert into #TempSalesAbstract
	Select "InvDate" =dbo.StripDateFromTime(ServiceInvoiceAbstract.ServiceInvoiceDate),      
	"InvoiceDate" = dbo.StripDateFromTime(ServiceInvoiceAbstract.ServiceInvoiceDate),      
	"Goods Value (Sales) (%c)" = Convert(Decimal(18,6),0),      
	"Goods Value (First Sale) (%c)"=Convert(Decimal(18,6),0),    
	"Goods Value (Second Sale) (%c)"=Convert(Decimal(18,6),0),    
	"Goods Value (Sales Return Damages) (%c)" = 0,      
	"Goods Value (Sales Return Saleable) (%c)" = 0,   
	"Total Tax Suffered (%c)" = sum(IsNull(TotalTaxSuffered, 0)),      
	"Productwise Discount (%c)" = sum(IsNull(ItemDiscount, 0)),    
	"Total Discount (%c)" = sum(IsNull(AdditionalDiscountValue_spare, 0) + IsNull(TradeDiscountValue_spare, 0)),      
	"Total Tax Applicable (%c)" = sum(IsNull(TotalTaxApplicable, 0))      
	From ServiceInvoiceAbstract,serviceinvoicedetail      
	Where ServiceInvoiceAbstract.ServiceInvoiceDate Between @Fromdate and @Todate And      
	serviceinvoiceabstract.serviceinvoiceid = serviceinvoicedetail.serviceinvoiceid
	and Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 And      
	Isnull(serviceinvoicedetail.sparecode,'') <> ''
	and ServiceInvoiceType in (1)      
	Group By dbo.StripDateFromTime(ServiceInvoiceDate)    
  	order by dbo.StripDateFromTime(ServiceInvoiceDate)      

Select * into #DailySalesAbstract from #TempSalesAbstract Where 1 = 0 
-- Select * from #DailySalesAbstract 
Insert into #DailySalesAbstract 
	Select "InvDate" = dbo.StripDateFromTime(D.InvoiceDate),     
	"InvoiceDate" = dbo.StripDateFromTime(D.InvoiceDate),     
	"Goods Value (Sales) (%c)" = sum(D.[Goods Value (Sales)]),    
	"Goods Value (First Sale) (%c)" = sum(D.[Goods Value (First Sale)]) ,
	"Goods Value (Second Sale) (%c)" = sum(D.[Goods Value (Second Sale)]),
	"Goods Value (Sales Return Damages) (%c)" = sum(D.[Goods Value (Sales Return Damages)]),
	"Goods Value (Sales Return Saleable) (%c)" =sum(D.[Goods Value (Sales Return Saleable)]),
	"Total Tax Suffered (%c)" = sum(D.[Total Tax Suffered]),
	"Productwise Discount (%c)"  = sum(D.[Productwise Discount]),
	"Total Discount (%c)" = sum(D.[Total Discount]),
	"Total Tax Applicable (%c)" = sum(D.[Total Tax Applicable])
	from #TempSalesAbstract D  
	Group By dbo.StripDateFromTime(D.InvoiceDate)    
	order by dbo.StripDateFromTime(D.InvoiceDate)    

declare DailySalesReport cursor    
for
	select distinct 'Total LT on FS',''    
union all    
	select distinct 'LTFS ',tcd.taxcomponent_desc from     
	invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, customer c    
	where    
	itc.invoiceid=idt.invoiceid and           
	itc.invoiceid=ia.invoiceid and          
	ia.invoicedate between @FromDate and @ToDate and           
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
	itc.taxtype =2
	and ia.serviceinvoicedate between @FromDate and @ToDate 
	and isnull(ia.status,0) & 192 =0 and          
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
	ia.invoicedate between @FromDate and @ToDate and           
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
	idt.serviceinvoiceid=ia.serviceinvoiceid 
	and itc.taxtype =2
	and ia.serviceinvoicedate between @FromDate and @ToDate 
	and isnull(ia.status,0) & 192 =0 
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
	ia.invoicedate between @FromDate and @ToDate and           
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
	idt.serviceinvoiceid=ia.serviceinvoiceid 
	and itc.taxtype =2
	and ia.serviceinvoicedate between @FromDate and @ToDate 
	and isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code=itc.taxcomponent_code and    
	ia.customerid*=c.customerid and     
	isnull(c.locality,1)=1 and    
	idt.saleid=2 
union all    
	select 'Total CT on SS',''    
union all    
	select distinct 'CTSS ',tcd.taxcomponent_desc from     
	invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, customer c    
	where    
	itc.invoiceid=idt.invoiceid and           
	itc.invoiceid=ia.invoiceid and          
	ia.invoicedate between @FromDate and @ToDate and           
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
	idt.serviceinvoiceid=ia.serviceinvoiceid 
	and itc.taxtype =2
	and ia.serviceinvoicedate between @FromDate and @ToDate 
	and           
	isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code=itc.taxcomponent_code and    
	ia.customerid*=c.customerid and     
	isnull(c.locality,1)=2 and    
	idt.saleid=2
union all    
	select 'Net Sales',''

open DailySalesReport    
fetch next from DailySalesReport into @Prefix, @TaxCompDesc     
while @@FETCH_STATUS = 0    
begin
	set @Query = N'alter table #DailySalesAbstract add ['+@Prefix+rtrim(@TaxCompDesc)+' (%c)] decimal(18,6)'
	exec sp_executesql @Query
	fetch next from DailySalesReport into @Prefix, @TaxCompDesc 
end
  
close DailySalesReport    
deallocate DailySalesReport    

declare DailySalesReport cursor     
for    
select dbo.stripdatefromtime(ia.invoicedate), tcd.taxcomponent_desc, isnull(locality,1),
	saleid, sum( case when invoicetype >= 4 and invoicetype <= 6 then 0 - tax_value else tax_value end) from     
	invoiceabstract ia, invoicedetail idt, invoicetaxcomponents itc, taxcomponentdetail tcd, customer c    
	where      
	ia.invoiceid = idt.invoiceid and      
	itc.invoiceid = idt.invoiceid and      
	ia.invoicedate between @Fromdate and @Todate and           
	tcd.taxcomponent_code = itc.tax_component_code and      
	itc.tax_code=idt.taxid and     
	(ia.status & 128)=0 and      
	itc.product_code=idt.product_code and    
	ia.customerid*=c.customerid    
	group by dbo.stripdatefromtime(ia.invoicedate),tcd.Taxcomponent_desc, locality, saleid    
union
	select dbo.stripdatefromtime(ia.serviceinvoicedate),tcd.taxcomponent_desc, isnull(locality,1), 
	saleid, sum(tax_value) from    
	serviceinvoiceabstract ia, serviceinvoicedetail idt, serviceinvoicetaxcomponents itc, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and           
	idt.serviceinvoiceid=ia.serviceinvoiceid         
	and itc.taxtype =2 and
	ia.serviceinvoicedate between @Fromdate and @Todate and           
	isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code=itc.taxcomponent_code and    
	ia.customerid*=c.customerid    
	group by dbo.stripdatefromtime(ia.serviceinvoicedate),tcd.Taxcomponent_desc, locality, saleid    
    
open DailySalesReport    
fetch next from DailySalesReport into @InvoiceDate, @TaxCompDesc, @locality, @SaleID, @TaxValue    
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
	if exists(Select a.name from Tempdb.dbo.Sysobjects A, Tempdb.dbo.SysColumns b Where a.id = b.id  and a.name 
	like '#DailySalesAbstract%' and b.Name like @Prefix+rtrim(@TaxCompDesc)+ ' (%c)' )
	Begin
		set @Query1 = N'update #DailySalesAbstract     
		set ['+@Prefix+rtrim(@TaxCompDesc)+' (%c)]=('+convert(varchar,@TaxValue)+')      
		where InvoiceDate='''+convert(varchar,dbo.stripdatefromtime(@InvoiceDate))+''''    
		exec sp_executesql @Query1    
	end    
  
fetch next from DailySalesReport into @InvoiceDate, @TaxCompDesc, @locality, @SaleID, @TaxValue    
end    
close DailySalesReport    
deallocate DailySalesReport    

set @query = N'update DSA set [Goods Value (Sales)] =    
	(Isnull((select sum(case when invoicetype >= 4 and invoicetype <= 6 then 
	0-(Quantity * SalePrice) else (Quantity * SalePrice) end) 
	from invoicedetail idt, invoiceabstract ia     
	where idt.invoiceid=ia.invoiceid and (status & 128) =0 and     
	dbo.stripdatefromtime(ia.invoicedate)= dsa.invoicedate),0)
	 
	+ ISNULL((select sum(Quantity * Price) from 
	Serviceinvoicedetail idt, Serviceinvoiceabstract ia     
	where idt.serviceinvoiceid=ia.serviceinvoiceid 
	and isnull(status,0) & 192  =0 and
	isnull(idt.sparecode, '''') <> '''' and     
	dbo.stripdatefromtime(ia.serviceinvoicedate)=dsa.invoicedate),0))       
from #DailySalesAbstract DSA'
exec sp_executesql @query

set @query = N'update DSA set [Goods Value (First Sale)]=    
	Isnull((select sum(case when invoicetype >= 4 and invoicetype <= 6 then 0-(Quantity * SalePrice) else 
	(Quantity * SalePrice) end) from invoicedetail idt, invoiceabstract ia     
	where idt.invoiceid=ia.invoiceid and (status & 128) =0 and
	saleid=1 and dbo.stripdatefromtime(ia.invoicedate)=dsa.invoicedate),0)
	+ ISNULL((select sum(Quantity * Price) from Serviceinvoicedetail idt, Serviceinvoiceabstract ia     
	where idt.serviceinvoiceid=ia.serviceinvoiceid 
	and isnull(ia.status,0) & 192  =0 and
	isnull(idt.sparecode, '''') <> '''' and     
	idt.saleid=1 and dbo.stripdatefromtime(ia.serviceinvoicedate)=dsa.invoicedate),0)           
from #DailySalesAbstract DSA'    
exec sp_executesql @query

set @query = N'update DSA set [Goods Value (Second Sale)]=    
	Isnull((select sum(case when invoicetype >= 4 and invoicetype <= 6 then 0-(Quantity * SalePrice) else (Quantity * SalePrice) end) from invoicedetail idt, invoiceabstract ia     
	where idt.invoiceid=ia.invoiceid and (status & 128) =0 and     
	dbo.stripdatefromtime(ia.invoicedate)=dsa.invoicedate and saleid=2),0)  
	+ ISNULL((select sum(Quantity * Price) from Serviceinvoicedetail idt, Serviceinvoiceabstract ia     
	where idt.serviceinvoiceid=ia.serviceinvoiceid 
	and isnull(status,0) & 192  =0 and
	isnull(idt.sparecode, '''') <> '''' and     
	idt.saleid= 2 and
	dbo.stripdatefromtime(ia.serviceinvoicedate)=dsa.invoicedate),0)           
from #DailySalesAbstract DSA'    
exec sp_executesql @query

set @query = N'update DSA set [Total LT on FS (%c)]=    
	Isnull((select sum(case when invoicetype >= 4 and invoicetype <= 6 then 0-stpayable else stpayable end) from invoicedetail idt, invoiceabstract ia     
	where idt.invoiceid=ia.invoiceid and (status & 128) = 0 and     
	dbo.stripdatefromtime(ia.invoicedate)= dsa.invoicedate and saleid=1),0) 
	+ISNULL((select sum(lstpayable) from Serviceinvoicedetail idt, Serviceinvoiceabstract ia     
	where idt.serviceinvoiceid=ia.serviceinvoiceid 
	and isnull(status,0) & 192  =0 and
	isnull(idt.sparecode, '''') <> '''' and     
	idt.saleid= 1 and
	dbo.stripdatefromtime(ia.serviceinvoicedate)=dsa.invoicedate),0)           
from #DailySalesAbstract DSA'
exec sp_executesql @query    

set @query = N'update DSA set DSA.[Total CT on FS (%c)]=    
	Isnull((select sum(case when invoicetype >= 4 and invoicetype <= 6 then 0-cstpayable else cstpayable end) from invoicedetail idt, invoiceabstract ia     
	where idt.invoiceid=ia.invoiceid and (status & 128) =0 and     
	dbo.stripdatefromtime(ia.invoicedate)=dsa.invoicedate and saleid=1),0)
	+ISNULL((select sum(cstpayable) from Serviceinvoicedetail idt, Serviceinvoiceabstract ia     
	where idt.serviceinvoiceid=ia.serviceinvoiceid 
	and isnull(status,0) & 192  =0 and
	isnull(idt.sparecode, '''') <> '''' and     
	dbo.stripdatefromtime(ia.serviceinvoicedate)=dsa.invoicedate and idt.saleid= 1),0)               
from #DailySalesAbstract DSA'    
exec sp_executesql @query

set @query = N'update DSA set [Total LT on SS (%c)]=    
	Isnull((select sum(case when invoicetype >= 4 and invoicetype <= 6 then 0-stpayable else stpayable end) from invoicedetail idt, invoiceabstract ia     
	where idt.invoiceid=ia.invoiceid and (status & 128) =0 and     
	dbo.stripdatefromtime(ia.invoicedate)=dsa.invoicedate  and saleid=2),0)
	+ISNULL((select sum(lstpayable) from Serviceinvoicedetail idt, Serviceinvoiceabstract ia     
	where idt.serviceinvoiceid=ia.serviceinvoiceid 
	and isnull(status,0) & 192  =0 and
	isnull(idt.sparecode, '''') <> '''' and     
	dbo.stripdatefromtime(ia.serviceinvoicedate)=dsa.invoicedate and idt.saleid= 2),0)               
from #DailySalesAbstract DSA'
exec sp_executesql @query    
    
set @query = N'update DSA set [Total CT on SS (%c)]=    
	Isnull((select sum(case when invoicetype >= 4 and invoicetype <= 6 then 0-cstpayable else cstpayable end) from invoicedetail idt, invoiceabstract ia     
	where idt.invoiceid=ia.invoiceid and (status & 128) =0 and     
	dbo.stripdatefromtime(ia.invoicedate)=dsa.invoicedate and saleid=2),0)   
	+ISNULL((select sum(cstpayable) from Serviceinvoicedetail idt, Serviceinvoiceabstract ia     
	where idt.serviceinvoiceid=ia.serviceinvoiceid 
	and isnull(status,0) & 192  =0 and
	isnull(idt.sparecode, '''') <> '''' and     
	dbo.stripdatefromtime(ia.serviceinvoicedate)=dsa.invoicedate and idt.saleid= 2),0)               
from #DailySalesAbstract DSA'
exec sp_executesql @query    
    
set @query = N'update DSA set [Net Sales (%c)] =     
	(select sum(case 
	when invoicetype >= 4 and invoicetype <= 6 then 0-(NetValue - IsNull(Freight, 0))    
	else NetValue - IsNull(Freight, 0)     
	end) from invoiceabstract ia     
	where dsa.invoicedate = dbo.stripdatefromtime(ia.invoicedate) and (ia.status & 128) = 0)
	from #DailySalesAbstract dsa, invoiceabstract ia    
	where dsa.invoicedate = dbo.stripdatefromtime(ia.invoicedate)
	+ isnull((select sum(NetValue - IsNull(Freight, 0))from serviceinvoiceabstract sa,#DailySalesAbstract dsa     
	where dsa.invoicedate = dbo.stripdatefromtime(sa.serviceinvoicedate) 
	and isnull(status,0) & 192  =0),0)' 
exec sp_executesql @query
---from #DailySalesAbstract dsa, serviceinvoiceabstract sa
--where dsa.invoicedate = dbo.stripdatefromtime(sa.serviceinvoicedate)       
    
set @query = N'update #DailySalesAbstract set [Total LT on FS (%c)]=null where [Total LT on FS (%c)]=0'
exec sp_executesql @query    
set @query = N'update #DailySalesAbstract set [Total CT on FS (%c)]=null where [Total CT on FS (%c)]=0'
exec sp_executesql @query
set @query = N'update #DailySalesAbstract set [Total LT on SS (%c)]=null where [Total LT on SS (%c)]=0'    
exec sp_executesql @query
set @query = N'update #DailySalesAbstract set [Total CT on SS (%c)]=null where [Total CT on SS (%c)]=0'    
exec sp_executesql @query
set @query = N'update #DailySalesAbstract set [Net Sales (%c)]=null where [Net Sales (%c)]=0'    
exec sp_executesql @query

set @query = N'Select * from #DailySalesAbstract'
exec sp_executesql @query

drop table #DailySalesAbstract    
drop table #TempSalesAbstract
    
end
