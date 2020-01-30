CREATE procedure [dbo].[spr_salestaxpayable_detail] (@InvoiceID int)  
as  
begin  

select  "invoiceid"=ia.invoiceid, "Item Code"=idt.product_code, "Item Name"=items.productname,  
 "FS Total (%c)" = Sum(case WHEN idt.saleid = 1 AND IA.InvoiceType = 4 then 0 - (amount) WHEN idt.saleid = 1 AND IA.InvoiceType <> 4 then amount else null end),   
"FSLT Total (%c)"= sum(case when idt.saleid = 1 and IA.InvoiceType = 4 then 0 - (stpayable)when idt.saleid = 1 AND IA.InvoiceType <> 4 then stpayable else null end)
into #SalesTaxPayableTemp  
from invoiceabstract IA, VoucherPrefix , invoicedetail idt, items  
where ia.invoiceid=idt.invoiceid  and tranid=N'INVOICE'  
and items.product_code=idt.product_code and (ia.status & 128) = 0 and idt.invoiceid=@InvoiceID
group by ia.invoiceid, documentid, ia.docreference, prefix, idt.product_code, items.productname
  
declare @sComponentName nvarchar(500)  
declare @Prefix nvarchar(10)  
declare @s nvarchar(600)  
declare @TaxComp nvarchar(50)  
declare @TaxValue decimal(18,6)  
declare @Locality nvarchar(10)  
declare @SaleID int  
declare @ProductCode nvarchar(50)  
  
declare SalesTaxComponents cursor  
for  
select distinct N'FSLT ', taxcomponent_desc  
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd  
where   
itc.invoiceid=idt.invoiceid and   
itc.invoiceid=ia.invoiceid and  
ia.customerid*=c.customerid and  
idt.product_code=itc.product_code and   
idt.taxid=itc.tax_code and   
tcd.taxcomponent_code=itc.tax_component_code and  
idt.invoiceid=@Invoiceid and 
(ia.status & 128) = 0 and 
isnull(c.locality,1)=1 and   
saleid=1  
union all  
select N'FSCT ',N'Total'  
union all  

select distinct N'FSCT ', taxcomponent_desc  
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd  
where   
itc.invoiceid=idt.invoiceid and   
itc.invoiceid=ia.invoiceid and  
idt.invoiceid=@Invoiceid and 
ia.customerid*=c.customerid and  
idt.product_code=itc.product_code and   
idt.taxid=itc.tax_code and   
tcd.taxcomponent_code=itc.tax_component_code and  
isnull(c.locality,1)=2 and   
(ia.status & 128) = 0 and 
saleid=1  
union all  

select N'SS ',N'Total' 
union all

select N'SSLT ',N'Total'  
union all  

select distinct N'SSLT ', taxcomponent_desc  
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd  
where   
itc.invoiceid=idt.invoiceid and   
itc.invoiceid=ia.invoiceid and  
idt.invoiceid=@Invoiceid and 
ia.customerid*=c.customerid and  
idt.product_code=itc.product_code and   
idt.taxid=itc.tax_code and   
tcd.taxcomponent_code=itc.tax_component_code and  
isnull(c.locality,1)=1 and   
(ia.status & 128) = 0 and 
saleid=2  
union all  
select N'SSCT ',N'Total'  
union all  
select distinct N'SSCT ', taxcomponent_desc  
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd  
where   
itc.invoiceid=idt.invoiceid and   
itc.invoiceid=ia.invoiceid and  
idt.invoiceid=@Invoiceid and 
ia.customerid*=c.customerid and  
idt.product_code=itc.product_code and   
idt.taxid=itc.tax_code and   
tcd.taxcomponent_code=itc.tax_component_code and  
isnull(c.locality,1)=2 and   
(ia.status & 128) = 0 and 
saleid=2  
  
  
open SalesTaxComponents  
fetch next from SalesTaxComponents into @Prefix,@sComponentName  
while @@FETCH_STATUS=0  
begin  
 set @s = N'alter table #SalesTaxPayableTemp add ['+@Prefix+rtrim(@sComponentName)+ ' (%c)] decimal(18,6)'  
 exec sp_executesql @s  
   
 fetch next from SalesTaxComponents into @Prefix,@sComponentName  
end  
--alter table #SalesTaxPayableTemp add [FSCT Total] Decimal(18,6)  
close SalesTaxComponents  
deallocate SalesTaxComponents  
  
declare SalesTaxComponentsUpdate cursor  
for   
select STP.invoiceid, tcd.taxcomponent_desc, sum(case invoicetype when 4 then 0-tax_value else tax_value end), isnull(locality,1),idt.saleid, idt.product_code  
from #SalesTaxPayableTemp STP , invoicetaxcomponents itc, customer c, invoiceabstract ia, invoicedetail idt, taxcomponentdetail tcd  
where  
stp.invoiceid=itc.invoiceid and   
itc.invoiceid=ia.invoiceid and   
ia.invoiceid=idt.invoiceid and  
idt.invoiceid=@InvoiceID and
idt.taxid=itc.tax_code and  
ia.customerid*=c.customerid and  
tcd.taxcomponent_code=itc.tax_component_code and  
idt.product_code=itc.product_code and   
idt.product_code=stp.[Item Code] and 
(ia.status & 128) = 0
group by STP.invoiceid, tcd.taxcomponent_desc, Locality, SaleID, idt.product_code  
  
open SalesTaxComponentsUpdate  
fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @ProductCode    
while @@FETCH_STATUS=0  
begin  
 if isnull(@Locality,1) = 1 and @SaleID = 1  
 begin  
  set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxComp)+' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
 end  
 else if isnull(@Locality,1) = 2 and @SaleID = 1  
 begin  
  set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxComp)+' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
 end  
 else if isnull(@Locality,1) = 1 and @SaleID = 2  
 begin  
  set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxComp)+' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
 end  
 else if isnull(@Locality,1) = 2 and @SaleID = 2  
 begin  
  set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxComp)+' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
 end  
 print @s  
 exec sp_executesql @s  
   
 fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @ProductCode  
  
end  
close SalesTaxComponentsUpdate  
deallocate SalesTaxComponentsUpdate  
  
update STP set STP.[FSCT Total (%c)]= case cstpayable when 0 then null else (case invoicetype when 4 then 0-cstpayable else cstpayable end) end
from #SalesTaxPayableTemp STP, invoicedetail idt, invoiceabstract ia
where  
stp.invoiceid=idt.invoiceid and saleid=1  and idt.product_code=stp.[Item Code]
and stp.invoiceid=ia.invoiceid
  
update STP set STP.[SSLT Total (%c)]= case stpayable when 0 then null else (case invoicetype when 4 then 0-stpayable else stpayable end) end
from #SalesTaxPayableTemp STP, invoicedetail idt, invoiceabstract ia
where  
stp.invoiceid=idt.invoiceid and saleid=2    and idt.product_code=stp.[Item Code]
and stp.invoiceid=ia.invoiceid
  
update STP set STP.[SSCT Total (%c)]=case cstpayable when 0 then null else (case invoicetype when 4 then 0-cstpayable else cstpayable end) end
from #SalesTaxPayableTemp STP, invoicedetail idt, invoiceabstract ia
where  
stp.invoiceid=idt.invoiceid  and saleid=2    and idt.product_code=stp.[Item Code]
and stp.invoiceid=ia.invoiceid

update STP set [SS Total (%c)]=case (amount) when 0 then null else (case invoicetype when 4 then 0-amount else amount end) end
from #SalesTaxPayableTemp STP, invoicedetail idt, invoiceabstract ia
where  
stp.invoiceid=idt.invoiceid  and saleid=2    and idt.product_code=stp.[Item Code]
and stp.invoiceid=ia.invoiceid

update #SalesTaxPayableTemp set [FS Total (%c)]=null where [FS Total (%c)]=0
update #SalesTaxPayableTemp set [FSLT Total (%c)]=null where [FSLT Total (%c)]=0
update #SalesTaxPayableTemp set [FSCT Total (%c)]=null where [FSCT Total (%c)]=0
update #SalesTaxPayableTemp set [SS Total (%c)]=null where [SS Total (%c)]=0
update #SalesTaxPayableTemp set [SSLT Total (%c)]=null where [SSLT Total (%c)]=0
update #SalesTaxPayableTemp set [SSCT Total (%c)]=null where [SSCT Total (%c)]=0
  
select * from #SalesTaxPayableTemp  
drop table #SalesTaxPayableTemp  
end
