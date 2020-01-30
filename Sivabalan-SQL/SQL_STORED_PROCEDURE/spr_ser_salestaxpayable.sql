CREATE procedure [dbo].[spr_ser_salestaxpayable](@Fromdate datetime, @Todate datetime)    
as    
begin
   
declare @sComponentName varchar(500)    
declare @Prefix varchar(10)    
declare @s nvarchar(4000)    
declare @InvoiceID varchar(50)    
declare @TaxComp varchar(50)    
declare @TaxValue decimal(18,6)    
declare @Locality varchar(10)    
declare @SaleID int    
declare @TYPE int
declare @INVTYPE int
declare @SERVICEINVTYPE int
set @INVTYPE = 1
set @SERVICEINVTYPE =2

CREATE TABLE #SalesTaxPayableTemp1(InvoiceID INT, InvoiceNo nvarchar(50)collate SQL_Latin1_General_Cp1_CI_AS,
[Doc Reference] nvarchar(255)collate SQL_Latin1_General_Cp1_CI_AS,TYPE int,[FS Total (%c)] decimal(18,6),[FSLT Total (%c)] decimal(18,6))

insert into #SalesTaxPayableTemp1
select  "invoiceid" =IA.invoiceid,               
	"InvoiceNo" = VoucherPrefix.Prefix + CAST(IA.documentid AS NVARCHAR),              
	"Doc Reference"=DocReference ,
        "TYPE" =@INVTYPE,
	"FS Total (%c)" = Sum(case WHEN saleid = 1 AND IA.InvoiceType = 4 then 0 - (amount) WHEN saleid = 1 AND IA.InvoiceType <> 4 then amount else 0 end),     
	"FSLT Total (%c)"= sum(case when saleid = 1 and IA.InvoiceType = 4 then 0 - (stpayable) when saleid = 1 AND IA.InvoiceType <> 4 then stpayable else 0 end)
	from invoiceabstract IA, VoucherPrefix , invoicedetail idt    
	where invoicedate between @Fromdate and @Todate and (status & 128)=0    
	and ia.invoiceid=idt.invoiceid  and tranid='INVOICE'    
	group by ia.invoiceid, documentid, ia.docreference, prefix    

Insert into #SalesTaxPayableTemp1
select  "invoiceid"=IA.Serviceinvoiceid , 
	"InvoiceNo" = VoucherPrefix.Prefix + CAST(IA.documentid AS NVARCHAR),              
	"Doc Reference"=DocReference,
         "TYPE" =@SERVICEINVTYPE,
	"FS Total (%c)" = Sum(case WHEN isnull(saleid,0) = 1 AND IA.ServiceInvoiceType = 1 then isnull(idt.netvalue,0) else 0 end),     
	"FSLT Total (%c)"= sum(case when isnull(saleid,0) = 1 AND IA.ServiceInvoiceType = 1 then isnull(lstpayable,0) else 0 end)
	from serviceinvoiceabstract IA, VoucherPrefix , serviceinvoicedetail idt    
	where serviceinvoicedate between @Fromdate and @Todate
	and isnull(status,0) & 192 = 0    
	and isnull(idt.sparecode,'') <> ''
	and ia.serviceinvoiceid=idt.serviceinvoiceid  and tranid='SERVICEINVOICE'    
	group by ia.serviceinvoiceid, documentid, ia.docreference, prefix    

select * into #SalesTaxPayableTemp from #SalesTaxPayableTemp1 
   
declare SalesTaxComponents cursor for    
select distinct 'FSLT ', taxcomponent_desc 
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd    
where itc.invoiceid=idt.invoiceid and     
itc.invoiceid=ia.invoiceid and    
ia.customerid*=c.customerid and    
ia.invoicedate between @Fromdate and @Todate and     
idt.product_code=itc.product_code and     
idt.taxid=itc.tax_code and     
(ia.status & 128 )=0 and    
tcd.taxcomponent_code=itc.tax_component_code and    
isnull(c.locality,1) = 1 and saleid = 1    
union
select distinct 'FSLT ', taxcomponent_desc from   
serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
taxcomponentdetail tcd, customer c    
where itc.serialno=idt.serialno and           
idt.serviceinvoiceid=ia.serviceinvoiceid and          
itc.taxtype =2 and ia.serviceinvoicedate between @Fromdate and @Todate and 
isnull(ia.status,0) & 192 =0 and          
tcd.taxcomponent_code=itc.taxcomponent_code and    
ia.customerid*=c.customerid and     
isnull(c.locality,1)=1 and idt.saleid=1 
union all    
select 'FSCT ','Total'    

union all    
select distinct 'FSCT ', taxcomponent_desc    
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd    
where itc.invoiceid=idt.invoiceid and     
itc.invoiceid=ia.invoiceid and    
ia.customerid*=c.customerid and    
ia.invoicedate between @Fromdate and @Todate and     
idt.product_code=itc.product_code and     
idt.taxid=itc.tax_code and     
(ia.status & 128 )=0 and    
tcd.taxcomponent_code=itc.tax_component_code and    
isnull(c.locality,1)=2 and saleid=1    
union 
select distinct 'FSCT ', taxcomponent_desc from     
serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
taxcomponentdetail tcd, customer c    
where itc.serialno=idt.serialno and           
idt.serviceinvoiceid=ia.serviceinvoiceid and          
itc.taxtype =2
and ia.serviceinvoicedate between @Fromdate and @Todate
and isnull(ia.status,0) & 192 =0 and          
tcd.taxcomponent_code=itc.taxcomponent_code and    
ia.customerid*=c.customerid and     
isnull(c.locality,1)=2 and idt.saleid=1 
union all    
select 'SS ','Total'    

union all    
select 'SSLT ','Total'    
union all    
select distinct 'SSLT ', taxcomponent_desc    
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd    
where itc.invoiceid=idt.invoiceid and     
itc.invoiceid=ia.invoiceid and    
ia.customerid*=c.customerid and    
ia.invoicedate between @Fromdate and @Todate and     
idt.product_code=itc.product_code and     
idt.taxid=itc.tax_code and     
(ia.status & 128 )=0 and    
tcd.taxcomponent_code=itc.tax_component_code and    
isnull(c.locality,1)=1 and saleid=2  
union 
select distinct 'SSLT ', taxcomponent_desc from  
serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
taxcomponentdetail tcd, customer c    
where itc.serialno=idt.serialno and           
idt.serviceinvoiceid=ia.serviceinvoiceid and          
itc.taxtype =2
and ia.serviceinvoicedate between @Fromdate and @Todate
and isnull(ia.status,0) & 192 =0 and          
tcd.taxcomponent_code=itc.taxcomponent_code and    
ia.customerid*=c.customerid and     
isnull(c.locality,1)=1 and idt.saleid=2 
  
union all    
select 'SSCT ','Total'    
union all    
select distinct 'SSCT ', taxcomponent_desc    
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd    
where itc.invoiceid=idt.invoiceid and     
itc.invoiceid=ia.invoiceid and    
ia.customerid*=c.customerid and    
ia.invoicedate between @Fromdate and @Todate and     
idt.product_code=itc.product_code and     
idt.taxid=itc.tax_code and     
(ia.status & 128 )=0 and    
tcd.taxcomponent_code=itc.tax_component_code and    
isnull(c.locality,1)=2 and saleid = 2    
union 
select distinct 'SSCT ', taxcomponent_desc from    
serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
taxcomponentdetail tcd, customer c    
where itc.serialno=idt.serialno and           
idt.serviceinvoiceid=ia.serviceinvoiceid and          
itc.taxtype =2 and ia.serviceinvoicedate between @Fromdate and @Todate and 
isnull(ia.status,0) & 192 =0 and          
tcd.taxcomponent_code=itc.taxcomponent_code and    
ia.customerid*=c.customerid and     
isnull(c.locality,1)=2 and idt.saleid=2 
open SalesTaxComponents    
fetch next from SalesTaxComponents into @Prefix,@sComponentName    
while @@FETCH_STATUS=0    
 begin    
   set @s = 'alter table #SalesTaxPayableTemp add ['+@Prefix+rtrim(@sComponentName)+ ' (%c)] decimal(18,6)'    
   exec sp_executesql @s    
   fetch next from SalesTaxComponents into @Prefix,@sComponentName    
 end    
   
close SalesTaxComponents    
deallocate SalesTaxComponents    

create table #temp1(invoiceid int,type int,taxcomponent_desc nvarchar(255) collate SQL_Latin1_General_Cp1_CI_AS,tax_value decimal(18,6), locality int,saleid int)

insert into #temp1
select STP.invoiceid,STP.Type,tcd.taxcomponent_desc,
case when sum(case when ia.InvoiceType = 4 then 0-tax_value else tax_value end)=0 then null else sum(case when ia.InvoiceType = 4 then 0-tax_value else tax_value end) end, 
isnull(locality,1),idt.saleid
from #SalesTaxPayableTemp STP,invoicetaxcomponents itc, customer c, invoiceabstract ia, invoicedetail idt, taxcomponentdetail tcd    
where stp.invoiceid=itc.invoiceid and     
ia.customerid*=c.customerid and    
ia.invoiceid=itc.invoiceid and     
idt.invoiceid=itc.invoiceid and    
idt.taxid=itc.tax_code and  
stp.type=1 and
tcd.taxcomponent_code=itc.tax_component_code and    
idt.product_code=itc.product_code and (ia.status & 128) = 0
and invoicedate between @Fromdate and @Todate 
group by STP.invoiceid,tcd.taxcomponent_desc, Locality, SaleID,STP.TYPE    
-- Select * from #SalesTaxPayableTemp
-- select * from serviceinvoicetaxcomponents where SerialNo in (
-- select SerialNo from serviceinvoicedetail where ServiceInvoiceId in (579, 580, 581, 583, 584, 586))

insert into #temp1
 select STP.invoiceid,STP.Type,tcd.taxcomponent_desc, sum(tax_value), 
 isnull(locality,1), idt.saleid
 from #SalesTaxPayableTemp STP, serviceinvoicetaxcomponents itc, customer c,
 serviceinvoiceabstract ia,
 serviceinvoicedetail idt,taxcomponentdetail tcd    
 where stp.invoiceid=ia.ServiceInvoiceID and ia.customerid*=c.customerid and    
 idt.serviceInvoiceId = ia.serviceInvoiceId and 
 itc.serialno=idt.serialno and 
 itc.taxtype =2 and stp.type=2 and 
 tcd.taxcomponent_code=itc.taxcomponent_code and    
 isnull(ia.status,0) & 192 =0         
 group by STP.invoiceid, tcd.taxcomponent_desc, Locality, SaleID,STP.TYPE    

-- select * from #Temp1 order by #temp1.invoiceid

declare SalesTaxComponentsUpdate cursor for     
select * from #Temp1 order by #temp1.invoiceid
open SalesTaxComponentsUpdate    
fetch from SalesTaxComponentsUpdate into @InvoiceID,@type, @TaxComp, @TaxValue, @Locality, @SaleID

while @@FETCH_STATUS=0    
begin    
 if isnull(@Locality,1) = 1 and @SaleID = 1    
 begin    
	if @TYPE = 1
		Begin
		set @s = 'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+@invoiceid+' and type = 1'
		exec sp_executesql @s
		End
	Else if @TYPE = 2
		Begin
		set @s = 'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+@invoiceid +' and type = 2'   
		exec sp_executesql @s
		End
 end    
 else if isnull(@Locality,1) = 2 and @SaleID = 1    
 begin    
	if @TYPE = 1
		Begin
		set @s = 'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+@invoiceid +' and type = 1'   
		exec sp_executesql @s
		End
	Else if @TYPE =2
		Begin
		set @s = 'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+@invoiceid +' and type = 2'   
		exec sp_executesql @s
		End
 end    
 else if isnull(@Locality,1) = 1 and @SaleID = 2    
 begin    
	IF @TYPE = 1
		Begin
		set @s = 'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+@invoiceid +' and type = 1'   
		exec sp_executesql @s
		End
	ELse if @Type = 2
		Begin
		set @s = 'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+@invoiceid +' and type = 2'    
		exec sp_executesql @s
		End
 end    
 else if isnull(@Locality,1) = 2 and @SaleID = 2    
 begin    
  If @Type = 1 
	  Begin
	  set @s = 'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+@invoiceid  +' and type = 1'   
	  exec sp_executesql @s
	  End
  Else If @Type = 2
	  Begin
	  set @s = 'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+@invoiceid +' and type = 2'    
	  exec sp_executesql @s
	  End
 end    
--  print @s    
 fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TYPE,@TaxComp, @TaxValue, @Locality, @SaleID
end    

--if @type = 1 
--Begin 
set @s = 'update STP set STP.[FSCT Total (%c)]= ( 
select sum(case ia.InvoiceType when 4 then 0-cstpayable else cstpayable end)
from invoicedetail idt, invoiceabstract ia
where 
stp.invoiceid=idt.invoiceid  and saleid=1 and stp.invoiceid=ia.invoiceid and stp.type =1)
from #SalesTaxPayableTemp STP'
exec sp_executesql @s 
--End    

--else if @type =  2
--Begin

set @s = 'update STP set STP.[FSCT Total (%c)] = isnull((select sum(isnull(cstpayable,0)) 
from serviceinvoiceabstract,serviceinvoicedetail
where stp.invoiceid = serviceinvoicedetail.serviceinvoiceid and saleid = 1 and stp.type =2 and
stp.invoiceid = serviceinvoiceabstract.serviceinvoiceid),0) 
from #SalesTaxPayableTemp STP'
exec sp_executesql @s
--End 

--if @type = 1
--Begin

set @s = 'update STP set STP.[SSLT Total (%c)]=(
select sum(case ia.InvoiceType when 4 then 0-stpayable else stpayable end)
from invoicedetail idt, invoiceabstract ia
where    
stp.invoiceid=idt.invoiceid and saleid=2 and stp.invoiceid=ia.invoiceid and stp.type =1)
from #SalesTaxPayableTemp STP'
exec sp_executesql @s
--End
--Else if @type = 2
--begin

set @s = 'update STP set STP.[SSLT Total (%c)] = isnull((select sum(isnull(lstpayable,0)) 
from serviceinvoiceabstract,serviceinvoicedetail
where stp.invoiceid = serviceinvoicedetail.serviceinvoiceid and saleid = 2 and stp.type =2 and
stp.invoiceid = serviceinvoiceabstract.serviceinvoiceid),0)
from #SalesTaxPayableTemp STP'
exec sp_executesql @s
--End

--if @type = 1
--Begin
    
set @s = 'update STP set STP.[SSCT Total (%c)]=(
select sum(case ia.InvoiceType when 4 then 0-cstpayable else cstpayable end)
from invoicedetail idt, invoiceabstract ia
where    
stp.invoiceid=idt.invoiceid  and saleid=2 and stp.invoiceid=ia.invoiceid and stp.type =1)
from #SalesTaxPayableTemp STP'
exec sp_executesql @s
--End
--Else if @type =2
--Begin

set @s = 'update STP set STP.[SSCT Total (%c)] = isnull((select sum(isnull(cstpayable,0)) 
from serviceinvoiceabstract,serviceinvoicedetail
where stp.invoiceid = serviceinvoicedetail.serviceinvoiceid and 
saleid = 2 
and stp.type =2 and
stp.invoiceid = serviceinvoiceabstract.serviceinvoiceid),0) 
from #SalesTaxPayableTemp STP' 
exec sp_executesql @s
--End


-- IF @type = 1
--begin

set @s = 'update STP set [SS Total (%c)]= (
select sum(case ia.InvoiceType when 4 then 0-amount else amount end) 
from invoicedetail idt, invoiceabstract ia
where 
stp.invoiceid=idt.invoiceid  and saleid=2 and stp.invoiceid=ia.invoiceid and stp.type =1)
from #SalesTaxPayableTemp STP' 
exec sp_executesql @s
--end

--else if @type =2 
--begin
set @s = 'update STP set [SS Total (%c)]=  isnull((select sum(isnull(serviceinvoicedetail.netvalue,0)) 
from serviceinvoiceabstract,serviceinvoicedetail
where stp.invoiceid = serviceinvoicedetail.serviceinvoiceid and saleid = 2 and
stp.invoiceid = serviceinvoiceabstract.serviceinvoiceid and stp.type = 2 and
isnull(sparecode,'''') <> ''''), 0) 
from #SalesTaxPayableTemp STP' 
exec sp_executesql @s
--End
close SalesTaxComponentsUpdate    
deallocate SalesTaxComponentsUpdate    

set @s = 'update #SalesTaxPayableTemp set [FS Total (%c)]=null where [FS Total (%c)]=0' 
exec sp_executesql @s
set @s = 'update #SalesTaxPayableTemp set [FS Total (%c)]=null where [FS Total (%c)]=0' 
exec sp_executesql @s
set @s = 'update #SalesTaxPayableTemp set [FSLT Total (%c)]=null where [FSLT Total (%c)]=0' 
exec sp_executesql @s
set @s = 'update #SalesTaxPayableTemp set [FSCT Total (%c)]=null where [FSCT Total (%c)]=0' 
exec sp_executesql @s
set @s = 'update #SalesTaxPayableTemp set [SS Total (%c)]=null where [SS Total (%c)]=0' 
exec sp_executesql @s
set @s = 'update #SalesTaxPayableTemp set [SSLT Total (%c)]=null where [SSLT Total (%c)]=0' 
exec sp_executesql @s
set @s = 'update #SalesTaxPayableTemp set [SSCT Total (%c)]=null where [SSCT Total (%c)]=0' 
exec sp_executesql @s

alter table #SalesTaxPayableTemp alter column InvoiceID nvarchar(30) null 
alter table #SalesTaxPayableTemp alter column Type nvarchar(30) null 

update #SalesTaxPayableTemp
set InvoiceID = cast(InvoiceID as nvarchar(20)) + Char(2) + cast(Type as nvarchar(3))

Update #SalesTaxPayableTemp
Set Type = 'Service Invoice'
Where Type ='2'

Update #SalesTaxPayableTemp
Set Type = 'Invoice'
Where Type ='1'

select * from #SalesTaxPayableTemp    
drop table #SalesTaxPayableTemp    
drop table #SalesTaxPayableTemp1
drop table #temp1 
--drop table #temp2
end
