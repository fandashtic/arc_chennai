CREATE procedure [dbo].[spr_list_TaxPaid_Invoices] (@TAXID int, @FROMDATE datetime, @TODATE datetime)    
as  

begin  

declare @TaxCompDesc nvarchar(50)  
declare @Prefix nvarchar(50)  
declare @TaxCode numeric  
declare @TaxCompCode numeric  
declare @Query nvarchar(4000)  
declare @Locality nvarchar(10)  
declare @TaxValue decimal(18,6)  
declare @ProductCode nvarchar(100)
declare @QueryaleID int    

select  idt.Product_Code, "Item Code" = idt.Product_Code, "Product Name" = i.productname
into #TaxPayableByTaxDetails  
FROM InvoiceAbstract ia, InvoiceDetail idt, tax, invoicetaxcomponents itc, items i
WHERE 
ia.InvoiceID = idt.InvoiceID AND 
idt.invoiceid = itc.invoiceid and 
idt.product_code = i.product_code and
ia.InvoiceDate between @FromDate AND @ToDate AND    
(ia.Status & 128) = 0 AND   
idt.taxid=tax.tax_code 
and idt.taxid=@TaxID
GROUP BY idt.product_code, i.productname
    

declare TaxPayable cursor  
for  
select N'First Sale Total',N''
union all
select N'FSLT Total',N''
union all
select distinct N'FSLT ', taxcomponent_desc 
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd , customer c
where       
itc.invoiceid=idt.invoiceid and       
itc.invoiceid=ia.invoiceid and      
ia.invoicedate between @FromDate and @ToDate and       
idt.product_code=itc.product_code and       
idt.taxid=itc.tax_code  and
idt.taxid=@TaxID and       
(ia.status & 128 )=0 and 
tcd.taxcomponent_code=itc.tax_component_code and
ia.customerid*=c.customerid and 
isnull(c.locality,1)=1 and
idt.saleid=1
union all      
select N'FSCT ',N'Total'
union all
select distinct N'FSCT ', taxcomponent_desc 
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, customer c
where       
itc.invoiceid=idt.invoiceid and       
itc.invoiceid=ia.invoiceid and      
ia.invoicedate between @FromDate and @ToDate and       
idt.product_code=itc.product_code and       
idt.taxid=itc.tax_code and
idt.taxid=@TaxID and 
(ia.status & 128 )=0 and      
tcd.taxcomponent_code=itc.tax_component_code and
ia.customerid*=c.customerid and 
isnull(c.locality,1)=2 and
idt.saleid=1
union all
select N'Second Sale Total',N''
union all
select N'SSLT ',N'Total'
union all
select distinct N'SSLT ', taxcomponent_desc 
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd , customer c
where       
itc.invoiceid=idt.invoiceid and       
itc.invoiceid=ia.invoiceid and      
ia.invoicedate between @FromDate and @ToDate and       
idt.product_code=itc.product_code and
idt.taxid=@TaxID and       
idt.taxid=itc.tax_code and       
(ia.status & 128 )=0 and 
tcd.taxcomponent_code=itc.tax_component_code and
ia.customerid*=c.customerid and 
isnull(c.locality,1)=1 and
idt.saleid=2
union all      
select N'SSCT ',N'Total'
union all
select distinct N'SSCT ', taxcomponent_desc 
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, customer c
where       
itc.invoiceid=idt.invoiceid and       
itc.invoiceid=ia.invoiceid and      
ia.invoicedate between @FromDate and @ToDate and       
idt.product_code=itc.product_code and       
idt.taxid=itc.tax_code and
idt.taxid=@TaxID and 
(ia.status & 128 )=0 and      
tcd.taxcomponent_code=itc.tax_component_code and
ia.customerid*=c.customerid and 
isnull(c.locality,1)=2 and
idt.saleid=2

  
open TaxPayable  
fetch next from TaxPayable into @Prefix, @TaxCompDesc  
while @@FETCH_STATUS=0  
begin  
 set @Query = N'alter table #TaxPayableByTaxDetails add ['+@Prefix+rtrim(@TaxCompDesc)+ N' (%c)] decimal(18,6)'    

 exec sp_executesql @Query    
 fetch next from TaxPayable into @Prefix, @TaxCompDesc  
end  
close TaxPayable  
deallocate TaxPayable  

  
declare TaxPayable Cursor  
for   
select TPD.product_Code, tcd.taxcomponent_desc, isnull(locality,1),idt.saleid, 
sum(case When invoicetype In (4,5,6) then 0-tax_value else tax_value end)
from #TaxPayableByTaxDetails TPD , invoicetaxcomponents itc, customer c, invoiceabstract ia, invoicedetail idt, taxcomponentdetail tcd    
where    
tpd.product_code=itc.product_code and 
ia.customerid*=c.customerid and 
ia.invoiceid=itc.invoiceid and 
idt.invoiceid=itc.invoiceid and
idt.taxid=@TaxID and 
idt.taxid=itc.tax_code and
tcd.taxcomponent_code=itc.tax_component_code and    
ia.invoicedate between @FromDate and @ToDate and       
idt.product_code=itc.product_code and 
(status & 128)=0
group by TPD.product_Code, tcd.taxcomponent_desc, Locality, SaleID    
  
  
open TaxPayable  
fetch next from TaxPayable into @ProductCode, @TaxCompDesc, @Locality, @QueryaleID, @TaxValue  
while @@FETCH_STATUS=0   
begin  
 
 if isnull(@Locality,1) = 1 and @QueryaleID = 1    
 begin    
  set @Query = N'update #TaxPayableByTaxDetails set [FSLT '+rtrim(@TaxCompDesc)+N' (%c)]='+convert(nvarchar,@TaxValue)+N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
 end    
 else if isnull(@Locality,1) = 2 and @QueryaleID = 1    
 begin    
  set @Query = N'update #TaxPayableByTaxDetails set [FSCT '+rtrim(@TaxCompDesc)+N' (%c)]='+convert(nvarchar,@TaxValue)+N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
 end    
 else if isnull(@Locality,1) = 1 and @QueryaleID = 2    
 begin    
  set @Query = N'update #TaxPayableByTaxDetails set [SSLT '+rtrim(@TaxCompDesc)+N' (%c)]='+convert(nvarchar,@TaxValue)+N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
 end    
 else if isnull(@Locality,1) = 2 and @QueryaleID = 2    
 begin    
  set @Query = N'update #TaxPayableByTaxDetails set [SSCT '+rtrim(@TaxCompDesc)+N' (%c)]='+convert(nvarchar,@TaxValue)+N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
 end    
 
 exec sp_executesql @Query    
fetch next from TaxPayable into @ProductCode, @TaxCompDesc, @Locality, @QueryaleID, @TaxValue  
end  

  
  
close TaxPayable  
deallocate TaxPayable  

update TPD set TPD.[First Sale Total (%c)]=(
select sum(case When invoicetype In (4,5,6) then 0-(stpayable+cstpayable) else (stpayable+cstpayable) end) 
from invoicedetail idt, invoiceabstract ia
where 
idt.product_code=TPD.product_code and 
ia.invoiceid=idt.invoiceid and 
ia.invoicedate between @FromDate and @ToDate and
idt.taxid=@TaxID and
(ia.status & 128)=0 and
saleid=1 )
from #TaxPayableByTaxDetails TPD

update TPD set TPD.[FSLT Total (%c)]=(
select sum(case When invoicetype In (4,5,6) then 0-stpayable else stpayable end) 
from invoicedetail idt, invoiceabstract ia
where 
idt.product_code=TPD.product_code and 
ia.invoiceid=idt.invoiceid and 
ia.invoicedate between @FromDate and @ToDate and
(ia.status & 128)=0 and
idt.taxid=@TaxID and
saleid=1)
from #TaxPayableByTaxDetails TPD

update TPD set TPD.[FSCT Total (%c)]=(
select sum(case When invoicetype In (4,5,6) then 0-cstpayable else cstpayable end) from invoicedetail idt, invoiceabstract ia
where 
idt.product_code=TPD.product_code and 
ia.invoiceid=idt.invoiceid and 
ia.invoicedate between @FromDate and @ToDate and
(ia.status & 128)=0 and
idt.taxid=@TaxID and
saleid=1)
from #TaxPayableByTaxDetails TPD
  

update TPD set TPD.[Second Sale Total (%c)]=(
select sum(case When invoicetype In (4,5,6) then 0-(stpayable+cstpayable) else stpayable+cstpayable end) from invoicedetail idt, invoiceabstract ia
where 
idt.product_code=TPD.product_code and 
ia.invoiceid=idt.invoiceid and 
ia.invoicedate between @FromDate and @ToDate and
(ia.status & 128)=0 and
idt.taxid=@TaxID and
saleid=2)
from #TaxPayableByTaxDetails TPD

update TPD set TPD.[SSLT Total (%c)]=(
select sum(case When invoicetype In (4,5,6) then 0-stpayable else stpayable end) 
from invoicedetail idt, invoiceabstract ia
where 
idt.product_code=TPD.product_code and 
ia.invoiceid=idt.invoiceid and 
ia.invoicedate between @FromDate and @ToDate and
(ia.status & 128)=0 and
idt.taxid=@TaxID and
saleid=2)
from #TaxPayableByTaxDetails TPD

update TPD set TPD.[SSCT Total (%c)]=(
select sum(case When invoicetype In (4,5,6) then 0-cstpayable else cstpayable end) from invoicedetail idt, invoiceabstract ia
where 
idt.product_code=TPD.product_code and 
ia.invoiceid=idt.invoiceid and 
ia.invoicedate between @FromDate and @ToDate and
(ia.status & 128)=0 and
idt.taxid=@TaxID and
saleid=2)
from #TaxPayableByTaxDetails TPD


update #TaxPayableByTaxDetails set [First Sale Total (%c)]=null where [First Sale Total (%c)]=0
update #TaxPayableByTaxDetails set [FSLT Total (%c)]=null where [FSLT Total (%c)]=0
update #TaxPayableByTaxDetails set [FSCT Total (%c)]=null where [FSCT Total (%c)]=0
update #TaxPayableByTaxDetails set [Second Sale Total (%c)]=null where [Second Sale Total (%c)]=0
update #TaxPayableByTaxDetails set [SSLT Total (%c)]=null where [SSLT Total (%c)]=0
update #TaxPayableByTaxDetails set [SSCT Total (%c)]=null where [SSCT Total (%c)]=0

select * from #TaxPayableByTaxDetails  
  
drop table #TaxPayableByTaxDetails  
end
