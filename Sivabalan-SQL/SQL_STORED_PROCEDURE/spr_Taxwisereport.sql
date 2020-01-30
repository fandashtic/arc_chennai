CREATE procedure [dbo].[spr_Taxwisereport] (@FROMDATE datetime,@TODATE datetime)    
as  

begin  

declare @TaxCompDesc nvarchar(50)  
declare @Prefix nvarchar(50)  
declare @TaxCode numeric  
declare @TaxCompCode numeric  
declare @Query nvarchar(4000)  
declare @Locality nvarchar(10)  
declare @Tax decimal(18,6)  
  
select Tax_Code, "Tax Description" = Tax_Description,  
"Local Sales Tax%" = percentage, "LT Value (%c.)" = ISNULL(sum(case when invoicetype In (4,5,6) then 0-STPayable else STPayable end), 0)  
into #TaxPayableByTaxAbstract  
FROM InvoiceAbstract ia, InvoiceDetail idt, tax  
WHERE    
ia.InvoiceID = idt.InvoiceID AND    
ia.InvoiceDate between @FromDate AND @ToDate AND    
(ia.Status & 128) = 0 AND   
idt.taxid=tax.tax_code  
GROUP BY Tax_Code, Tax_Description, Percentage, CST_Percentage    
    
declare TaxPayable cursor  
for  
select distinct N'LT ', taxcomponent_desc      
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd  
where       
itc.invoiceid=idt.invoiceid and       
itc.invoiceid=ia.invoiceid and      
ia.invoicedate between @FromDate and @ToDate and       
idt.product_code=itc.product_code and       
idt.taxid=itc.tax_code and       
(ia.status & 128 )=0 and      
tcd.taxcomponent_code=itc.tax_component_code  
union all      
select N'Central Sales Tax',N'%'  
  
  
begin tran  
open TaxPayable  
fetch next from TaxPayable into @Prefix, @TaxCompDesc  
while @@FETCH_STATUS=0  
begin  
 set @Query = N'alter table #TaxPayableByTaxAbstract add [LT '+rtrim(@TaxCompDesc)+ N' (%c.)] decimal(18,6)'    
 exec sp_executesql @Query    
 fetch next from TaxPayable into @Prefix, @TaxCompDesc  
end  
close TaxPayable  
  
alter table #TaxPayableByTaxAbstract add  [Central Sales Tax%] decimal(18,6)  
alter table #TaxPayableByTaxAbstract add  [CT Value (%c.)] decimal(18,6)  
  
open TaxPayable  
fetch next from TaxPayable into @Prefix, @TaxCompDesc  
while @@FETCH_STATUS=0  
begin  
 set @Query = N'alter table #TaxPayableByTaxAbstract add [CT '+rtrim(@TaxCompDesc)+ N' (%c.)] decimal(18,6)'    
 exec sp_executesql @Query    
 fetch next from TaxPayable into @Prefix, @TaxCompDesc  
end  
close TaxPayable  
deallocate TaxPayable  
commit tran  
  
declare TaxPayable Cursor  
for   
select itc.tax_code, tcd.Taxcomponent_desc, isnull(locality,1), sum(case when invoicetype In (4,5,6) then 0-tax_value else tax_value end) from   
#TaxPayableByTaxAbstract TPA, invoiceabstract ia, invoicedetail idt, invoicetaxcomponents itc, taxcomponentdetail tcd, customer c
where  
tpa.tax_code = idt.taxid and  
ia.invoiceid = idt.invoiceid and  
itc.invoiceid = idt.invoiceid and  
ia.invoicedate between @FromDate and @ToDate and  
tcd.taxcomponent_code = itc.tax_component_code and  
itc.tax_code=idt.taxid and 
tpa.tax_code=itc.tax_code and 
(ia.status & 128)=0 and  
itc.product_code=idt.product_code and
ia.customerid*=c.customerid
group by itc.tax_code,tcd.Taxcomponent_Code,tcd.Taxcomponent_desc, locality  
  
  
open TaxPayable  
fetch next from TaxPayable into @TaxCode, @TaxCompDesc, @Locality, @Tax  
while @@FETCH_STATUS=0   
begin  
 if isnull(@Locality,1) = N'1'  
 begin  
  set @Query = N'update TPA set [LT '+rtrim(@TaxCompDesc)+N' (%c.)] = '+convert(nvarchar,@Tax)+N' from   
  #TaxPayableByTaxAbstract TPA where TPA.Tax_Code='+convert(nvarchar,@TaxCode)  
 end  
 else if isnull(@Locality,1) = N'2' 
 begin  
  set @Query = N'update TPA set [CT '+rtrim(@TaxCompDesc)+N' (%c.)] = '+convert(nvarchar,@Tax)+N' from   
  #TaxPayableByTaxAbstract TPA where TPA.Tax_Code='+convert(nvarchar,@TaxCode)  
 end  
 exec sp_executesql @Query  
  
 fetch next from TaxPayable into @TaxCode, @TaxCompDesc, @Locality, @Tax  
end  
  
set @Query = N'update TPA set [Central Sales Tax%] = cst_percentage   
from #TaxPayableByTaxAbstract TPA, Tax where tpa.tax_code=tax.tax_code'  
exec sp_executesql @Query  
  
set @Query = N'update TPA set [CT Value (%c.)] =   
 (select sum(case when invoicetype In (4,5,6) then 0-cstpayable else cstpayable end) from invoicedetail idt, invoiceabstract ia   
 where ia.invoiceid=idt.invoiceid and  
ia.invoicedate between '''+convert(nvarchar,@FromDate)+''' and '''+convert(nvarchar,@ToDate)+''' and  
idt.taxid=tpa.tax_code and status & 128 = 0)  
from #TaxPayableByTaxAbstract TPA, invoicedetail idt, invoiceabstract ia  
where   
tpa.tax_code=idt.taxid and   
idt.invoiceid=ia.invoiceid  
'  

exec sp_executesql @Query  
  
  
  
select * from #TaxPayableByTaxAbstract  
close TaxPayable  
deallocate TaxPayable  
  
drop table #TaxPayableByTaxAbstract  
end
