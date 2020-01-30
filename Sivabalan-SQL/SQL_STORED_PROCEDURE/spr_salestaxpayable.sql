CREATE procedure [dbo].[spr_salestaxpayable] (@FromDate datetime,@ToDate datetime)        
as        
begin        
select  "invoiceid"=IA.invoiceid ,                   
  "Invoiceno" = VoucherPrefix.Prefix + CAST(IA.documentid AS NVARCHAR),                  
  "Doc Reference"=DocReference ,"FS Total (%c)" = Sum(case WHEN saleid = 1 AND IA.InvoiceType in (4,5,6) then 0 - (amount) WHEN saleid = 1 AND   
  IA.InvoiceType In (1,2,3) then amount else null end),         
  "FSLT Total (%c)"= sum(case when saleid = 1 and IA.InvoiceType in (4,5,6) then 0 - (stpayable)when saleid = 1 AND IA.InvoiceType In (1,2,3) then stpayable else null end)         
into #SalesTaxPayableTemp        
from invoiceabstract IA, VoucherPrefix , invoicedetail idt        
where invoicedate between @FromDate and @ToDate and (status & 128)=0        
and ia.invoiceid=idt.invoiceid  and tranid='INVOICE'        
group by ia.invoiceid, documentid, ia.docreference, prefix        
        
declare @sComponentName nvarchar(500)        
declare @Prefix nvarchar(10)        
declare @s nvarchar(600)        
declare @InvoiceID nvarchar(50)        
declare @TaxComp nvarchar(50)        
declare @TaxValue decimal(18,6)        
declare @Locality nvarchar(10)        
declare @SaleID int        
        
declare SalesTaxComponents cursor        
for        
select distinct 'FSLT ', taxcomponent_desc        
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd        
where         
itc.invoiceid=idt.invoiceid and         
itc.invoiceid=ia.invoiceid and        
ia.customerid*=c.customerid and        
ia.invoicedate between @FromDate and @ToDate and         
idt.product_code=itc.product_code and         
idt.taxid=itc.tax_code and         
(ia.status & 128 )=0 and        
tcd.taxcomponent_code=itc.tax_component_code and        
isnull(c.locality,1)=1 and         
saleid=1        
union all        
select 'FSCT ','Total'        
union all        
select distinct 'FSCT ', taxcomponent_desc        
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd        
where         
itc.invoiceid=idt.invoiceid and         
itc.invoiceid=ia.invoiceid and        
ia.customerid*=c.customerid and        
ia.invoicedate between @FromDate and @ToDate and         
idt.product_code=itc.product_code and         
idt.taxid=itc.tax_code and         
(ia.status & 128 )=0 and        
tcd.taxcomponent_code=itc.tax_component_code and        
isnull(c.locality,1)=2 and         
saleid=1        
union all        
select 'SS ','Total'        
union all        
select 'SSLT ','Total'        
union all        
select distinct 'SSLT ', taxcomponent_desc        
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd        
where         
itc.invoiceid=idt.invoiceid and         
itc.invoiceid=ia.invoiceid and        
ia.customerid*=c.customerid and        
ia.invoicedate between @FromDate and @ToDate and         
idt.product_code=itc.product_code and         
idt.taxid=itc.tax_code and         
(ia.status & 128 )=0 and        
tcd.taxcomponent_code=itc.tax_component_code and        
isnull(c.locality,1)=1 and         
saleid=2        
union all        
select 'SSCT ','Total'        
union all        
select distinct 'SSCT ', taxcomponent_desc        
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd        
where         
itc.invoiceid=idt.invoiceid and         
itc.invoiceid=ia.invoiceid and        
ia.customerid*=c.customerid and        
ia.invoicedate between @FromDate and @ToDate and         
idt.product_code=itc.product_code and         
idt.taxid=itc.tax_code and         
(ia.status & 128 )=0 and        
tcd.taxcomponent_code=itc.tax_component_code and        
isnull(c.locality,1)=2 and         
saleid=2        
        
    
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
    
       
declare SalesTaxComponentsUpdate cursor        
for         
select STP.invoiceid, tcd.taxcomponent_desc, case when sum(case when ia.InvoiceType in (4,5,6) then 0-tax_value else tax_value end)=0 then null else sum(case when ia.InvoiceType In (4,5,6) then 0-tax_value else tax_value end) end,  isnull(locality,1),idt.saleid 
       
from #SalesTaxPayableTemp STP , invoicetaxcomponents itc, customer c, invoiceabstract ia, invoicedetail idt, taxcomponentdetail tcd        
where        
stp.invoiceid=itc.invoiceid and         
ia.customerid*=c.customerid and        
ia.invoiceid=itc.invoiceid and         
idt.invoiceid=itc.invoiceid and        
idt.taxid=itc.tax_code and        
tcd.taxcomponent_code=itc.tax_component_code and        
idt.product_code=itc.product_code and     
(ia.status & 128) = 0    
group by STP.invoiceid, tcd.taxcomponent_desc, Locality, SaleID        
    
    
open SalesTaxComponentsUpdate        
fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID        
        
while @@FETCH_STATUS=0        
begin        
 if isnull(@Locality,1) = 1 and @SaleID = 1        
 begin        
  set @s = 'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxComp)+' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+@invoiceid        
 end        
 else if isnull(@Locality,1) = 2 and @SaleID = 1        
 begin        
  set @s = 'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxComp)+' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+@invoiceid        
 end        
 else if isnull(@Locality,1) = 1 and @SaleID = 2        
 begin        
  set @s = 'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxComp)+' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+@invoiceid        
 end        
 else if isnull(@Locality,1) = 2 and @SaleID = 2        
 begin        
  set @s = 'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxComp)+' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+@invoiceid        
 end        
 print @s        
 exec sp_executesql @s        
         
 fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID        
        
end        
close SalesTaxComponentsUpdate        
deallocate SalesTaxComponentsUpdate        
    
        
update STP set STP.[FSCT Total (%c)]= (     
 select sum(case when ia.InvoiceType In (4,5,6) then 0-cstpayable else cstpayable end)    
 from invoicedetail idt, invoiceabstract ia    
 where   stp.invoiceid=idt.invoiceid  and saleid=1 and stp.invoiceid=ia.invoiceid)    
 from #SalesTaxPayableTemp STP    
        
update STP set STP.[SSLT Total (%c)]=(    
 select sum(case when ia.InvoiceType In (4,5,6) then 0-stpayable else stpayable end)    
 from invoicedetail idt, invoiceabstract ia    
 where stp.invoiceid=idt.invoiceid and saleid=2 and stp.invoiceid=ia.invoiceid)    
 from #SalesTaxPayableTemp STP    
        
update STP set STP.[SSCT Total (%c)]=(    
 select sum(case when ia.InvoiceType In (4,5,6) then 0-cstpayable else cstpayable end)    
 from invoicedetail idt, invoiceabstract ia    
 where stp.invoiceid=idt.invoiceid  and saleid=2 and stp.invoiceid=ia.invoiceid)    
 from #SalesTaxPayableTemp STP    
    
update STP set [SS Total (%c)]= (    
 select sum(case when ia.InvoiceType in (4,5,6) THEN 0-amount else amount end)     
 from invoicedetail idt, invoiceabstract ia    
 where stp.invoiceid=idt.invoiceid  and saleid=2 and stp.invoiceid=ia.invoiceid)    
 from #SalesTaxPayableTemp STP     
    
    
    
update #SalesTaxPayableTemp set [FS Total (%c)]=null where [FS Total (%c)]=0    
update #SalesTaxPayableTemp set [FSLT Total (%c)]=null where [FSLT Total (%c)]=0    
update #SalesTaxPayableTemp set [FSCT Total (%c)]=null where [FSCT Total (%c)]=0    
update #SalesTaxPayableTemp set [SS Total (%c)]=null where [SS Total (%c)]=0    
update #SalesTaxPayableTemp set [SSLT Total (%c)]=null where [SSLT Total (%c)]=0    
update #SalesTaxPayableTemp set [SSCT Total (%c)]=null where [SSCT Total (%c)]=0    
     
        
select * from #SalesTaxPayableTemp        
drop table #SalesTaxPayableTemp        
end
