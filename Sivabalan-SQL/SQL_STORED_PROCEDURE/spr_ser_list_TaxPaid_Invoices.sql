CREATE procedure [dbo].[spr_ser_list_TaxPaid_Invoices](@TAXID int, @FROMDATE datetime, @TODATE datetime)    
as  
begin  

declare @TaxCompDesc varchar(50)  
declare @Prefix varchar(50)  
declare @TaxCode numeric  
declare @TaxCompCode numeric  
declare @Query nvarchar(4000)  
declare @Locality varchar(10)  
declare @TaxValue decimal(18,6)  
declare @ProductCode varchar(100)
declare @QueryaleID int    
declare @TYPE int  

create table #TaxPayableByTaxDetails1([product_Code] nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Item Code] nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Product Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Type int)  

Insert into #TaxPayableByTaxDetails1
select  idt.Product_Code, "Item Code" = idt.Product_Code, "Product Name" = i.productname,"TYPE" = 1
--into #TaxPayableByTaxDetails  
FROM InvoiceAbstract ia, InvoiceDetail idt, tax, invoicetaxcomponents itc, items i
WHERE 
ia.InvoiceID = idt.InvoiceID and 
idt.invoiceid = itc.invoiceid and 
idt.product_code = i.product_code and
ia.InvoiceDate between @Fromdate and @Todate and
(ia.Status & 128) = 0 and 
idt.taxid=tax.tax_code and 
idt.taxid=@TaxID
GROUP BY idt.product_code, i.productname

Insert into #TaxPayableByTaxDetails1
select  idt.spareCode, "Item Code" = idt.spareCode, "Product Name" = i.productname,"TYPE" = 2
FROM serviceInvoiceAbstract ia, serviceInvoiceDetail idt, 
tax, serviceinvoicetaxcomponents itc, items i
WHERE 
idt.serialno= itc.serialno and           
idt.serviceinvoiceid=ia.serviceinvoiceid and 
itc.taxtype =2 and 
itc.taxcode = tax.tax_code and
idt.sparecode = i.product_code and
ia.serviceinvoicedate between @Fromdate and @Todate and 
isnull(ia.Status,0) & 192 = 0 and itc.taxcode = @TaxID
GROUP BY idt.sparecode, i.productname

select * into  #TaxPayableByTaxDetails from #TaxPayableByTaxDetails1   
declare TaxPayable cursor  
for  
	select 'First Sale Total',''
union all
	select 'FSLT Total',''
union all
	select distinct 'FSLT ', taxcomponent_desc 
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
union	
	select distinct 'FSLT ' ,tcd.taxcomponent_desc from     
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and           
	idt.serviceinvoiceid=ia.serviceinvoiceid 
	and itc.taxcode = @TaxID and
	ia.serviceinvoicedate between @FromDate and @ToDate 
	and itc.taxtype =2
	and isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code=itc.taxcomponent_code 
	and ia.customerid*=c.customerid and 
	isnull(c.locality,1)=1 and
	idt.saleid=1
union all      
	select 'FSCT ','Total'
union all
	select distinct 'FSCT ', taxcomponent_desc 
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
union
	select distinct 'FSCT ' ,tcd.taxcomponent_desc from     
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and           
	idt.serviceinvoiceid=ia.serviceinvoiceid and
	ia.serviceinvoicedate between @FromDate and @ToDate and                 
	itc.taxtype =2
	and itc.taxcode = @TaxID
	and isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code=itc.taxcomponent_code 
	and ia.customerid*=c.customerid and 
	isnull(c.locality,1)=2 and
	idt.saleid=1
union all
	select 'Second Sale Total',''
union all
	select 'SSLT ','Total'
union all
	select distinct 'SSLT ', taxcomponent_desc 
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
	(idt.saleid=2 or idt.saleid=0)
union
	select distinct 'SSLT ' ,tcd.taxcomponent_desc from     
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and           
	idt.serviceinvoiceid=ia.serviceinvoiceid and          
	ia.serviceinvoicedate between @FromDate and @ToDate 
	and itc.taxcode = @TaxID and
	itc.taxtype =2
	and isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code=itc.taxcomponent_code 
	and ia.customerid*=c.customerid and 
	isnull(c.locality,1)=1 and
	(idt.saleid=2 or idt.saleid=0)
union all      
	select 'SSCT ','Total'
union all
	select distinct 'SSCT ', taxcomponent_desc 
	from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, 
	taxcomponentdetail tcd, customer c
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
	(idt.saleid=2 or idt.saleid=0)
union
	select distinct 'SSCT ' ,tcd.taxcomponent_desc from     
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and           
	idt.serviceinvoiceid=ia.serviceinvoiceid and          
	itc.taxtype =2 and
	itc.taxcode = @TaxID and 
	ia.serviceinvoicedate between @FromDate and @ToDate 
	and isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code=itc.taxcomponent_code 
	and ia.customerid*=c.customerid and 
	isnull(c.locality,1)=2 and
	(idt.saleid=2 or idt.saleid=0)
  
open TaxPayable  
fetch next from TaxPayable into @Prefix, @TaxCompDesc  
while @@FETCH_STATUS=0  
begin  
	set @Query = 'alter table #TaxPayableByTaxDetails add ['+@Prefix+rtrim(@TaxCompDesc)+ ' (%c)] decimal(18,6)'    	
	exec sp_executesql @Query    
	fetch next from TaxPayable into @Prefix, @TaxCompDesc  
end  
close TaxPayable  
deallocate TaxPayable  
set @Query = ''
	
create table #temp1([product_code] nvarchar(15),type int,taxcomponent_desc nvarchar(255),locality int,saleid int,tax_value decimal(18,6))
insert into #temp1
	select TPD.product_Code,tpd.type, tcd.taxcomponent_desc, isnull(locality,1), 
	idt.saleid, sum(case invoicetype when 4 then 0-tax_value else tax_value end)
	from #TaxPayableByTaxDetails TPD , invoicetaxcomponents itc, customer c, 
	invoiceabstract ia, invoicedetail idt, taxcomponentdetail tcd    
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
	(status & 128)=0 and tpd.Type = 1
	group by TPD.product_Code, tpd.type, tcd.taxcomponent_desc, Locality, SaleID    

Insert into #temp1
	select TPD.product_Code, tpd.type, tcd.taxcomponent_desc, isnull(locality,1), 
	idt.saleid, sum(tax_value)
	from #TaxPayableByTaxDetails TPD , serviceinvoicetaxcomponents itc, customer c, 
	serviceinvoiceabstract ia, serviceinvoicedetail idt, taxcomponentdetail tcd    	
	where itc.serialno= idt.serialno and           
	tpd.product_code = idt.sparecode and 
	idt.serviceinvoiceid = ia.serviceinvoiceid and          
	itc.taxtype =2 and itc.taxcode = @Taxid
	and isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code = itc.taxcomponent_code 
	and ia.customerid *= c.customerid and 
	ia.serviceinvoicedate between @FromDate and @ToDate 
	and tpd.Type = 2
	group by TPD.product_Code, tpd.type, tcd.taxcomponent_desc, Locality, SaleID    

declare TaxPayable Cursor  
for   
select *from #temp1
  
open TaxPayable  
fetch next from TaxPayable into @ProductCode, @TYPE,@TaxCompDesc, @Locality, @QueryaleID, @TaxValue  
while @@FETCH_STATUS=0   
begin  
	if isnull(@Locality,1) = 1 and @QueryaleID = 1    
	begin    
		if @type = 1
		begin 
			set @Query = 'update #TaxPayableByTaxDetails set [FSLT '+rtrim(@TaxCompDesc)+' (%c)]='+convert(varchar,@TaxValue)+' from #TaxPayableByTaxDetails where product_code='''+@ProductCode+'''' + ' and type = 1'   
			exec sp_executesql @Query    
		end
		else if @type  = 2
		begin
			set @Query = 'update #TaxPayableByTaxDetails set [FSLT '+rtrim(@TaxCompDesc)+' (%c)]='+convert(varchar,@TaxValue)+' from #TaxPayableByTaxDetails where product_code='''+@ProductCode+'''' +' and type = 2'   
			exec sp_executesql @Query    
		end   
	end    
	else if isnull(@Locality,1) = 2 and @QueryaleID = 1    
	begin  
		if @type =1 
		begin   
			set @Query = 'update #TaxPayableByTaxDetails set [FSCT '+rtrim(@TaxCompDesc)+' (%c)]='+convert(varchar,@TaxValue)+' from #TaxPayableByTaxDetails where product_code='''+@ProductCode+'''' +' and type = 1'   
			exec sp_executesql @Query    
		end
		else if @type =2 
		begin
			set @Query = 'update #TaxPayableByTaxDetails set [FSCT '+rtrim(@TaxCompDesc)+' (%c)]='+convert(varchar,@TaxValue)+' from #TaxPayableByTaxDetails where product_code='''+@ProductCode+'''' +' and type = 2'   
			exec sp_executesql @Query    
		end
	end    
	else if isnull(@Locality,1) = 1   
	begin    
		if @type = 1
		begin
			set @Query = 'update #TaxPayableByTaxDetails set [SSLT '+rtrim(@TaxCompDesc)+' (%c)]=  Isnull([SSLT '+rtrim(@TaxCompDesc)+' (%c)], 0) + '+convert(varchar,@TaxValue)+' from #TaxPayableByTaxDetails where product_code='''+@ProductCode+'''' +' and type = 1'   
			
			exec sp_executesql @Query    
		end
		else if @type =2
		begin
			set @Query = 'update #TaxPayableByTaxDetails set [SSLT '+rtrim(@TaxCompDesc)+' (%c)]= Isnull([SSLT '+rtrim(@TaxCompDesc)+' (%c)], 0) + '+convert(varchar,@TaxValue)+' from #TaxPayableByTaxDetails where product_code='''+@ProductCode+'''' +' and type = 2'   
			exec sp_executesql @Query    
		end
	end    
	else if isnull(@Locality,1) = 2 
	begin    
		if @type = 1
		begin
			set @Query = 'update #TaxPayableByTaxDetails set [SSCT '+rtrim(@TaxCompDesc)+' (%c)]= Isnull([SSCT '+rtrim(@TaxCompDesc)+' (%c)], 0) + '+convert(varchar,@TaxValue)+' from #TaxPayableByTaxDetails where product_code='''+@ProductCode+'''' +' and type = 1'   
			exec sp_executesql @Query    
		end
		else if @type =2
		begin
			set @Query = 'update #TaxPayableByTaxDetails set [SSCT '+rtrim(@TaxCompDesc)+' (%c)]= Isnull([SSCT '+rtrim(@TaxCompDesc)+' (%c)], 0) + '+convert(varchar,@TaxValue)+' from #TaxPayableByTaxDetails where product_code='''+@ProductCode+'''' +' and type = 2'   
			exec sp_executesql @Query    
		end
	end    
	fetch next from TaxPayable into @ProductCode, @TYPE,@TaxCompDesc, @Locality, @QueryaleID, @TaxValue  
end  
  
close TaxPayable  
deallocate TaxPayable  

update TPD set TPD.[First Sale Total (%c)]=(
select sum(case invoicetype when 4 then 0-(Isnull(stpayable, 0)+ Isnull(cstpayable, 0)) else (Isnull(stpayable, 0)+ Isnull(cstpayable, 0)) end) 
from invoicedetail idt, invoiceabstract ia
where 
idt.product_code=TPD.product_code and ia.invoiceid=idt.invoiceid and 
ia.invoicedate between @FromDate and @ToDate and
idt.taxid=@TaxID and (ia.status & 128)=0 and Isnull(saleid, 2) = 1 group by idt.product_code)
from #TaxPayableByTaxDetails TPD where tpd.type =1

update TPD set TPD.[First Sale Total (%c)]=(
select sum(Isnull(lstpayable, 0) + Isnull(cstpayable, 0))  
from serviceinvoicedetail idt, serviceinvoiceabstract ia,serviceinvoicetaxcomponents itc
where itc.serialno=idt.serialno and tpd.product_code =idt.sparecode and 
ia.serviceinvoiceid=idt.serviceinvoiceid and 
ia.serviceinvoicedate between @FromDate and @ToDate and
itc.taxcode = @TaxID and 
isnull(ia.status,0)& 192=0 and Isnull(saleid, 2) = 1 group by idt.sparecode)
from #TaxPayableByTaxDetails TPD Where tpd.type = 2

update TPD set TPD.[FSLT Total (%c)]=(
select sum(case invoicetype when 4 then 0- Isnull(stpayable, 0) else Isnull(stpayable, 0) end) 
from invoicedetail idt, invoiceabstract ia
where 
idt.product_code=TPD.product_code and ia.invoiceid=idt.invoiceid and 
ia.invoicedate between @FromDate and @ToDate and
(ia.status & 128)=0 and idt.taxid=@TaxID and Isnull(Saleid, 2) = 1 group by idt.product_code)
from #TaxPayableByTaxDetails TPD Where tpd.type =1

update TPD set TPD.[FSLT Total (%c)]=(
select sum(Isnull(lstpayable, 0)) 
from serviceinvoicedetail idt, serviceinvoiceabstract ia,serviceinvoicetaxcomponents itc
where  itc.serialno=idt.serialno and
tpd.product_code =idt.sparecode and 
ia.serviceinvoiceid=idt.serviceinvoiceid and 
ia.serviceinvoicedate between @FromDate and @ToDate and
isnull(ia.status,0) & 192=0 and
itc.taxcode = @TaxID and Isnull(saleid, 0) = 1 group by idt.sparecode)
from #TaxPayableByTaxDetails TPD Where tpd.type = 2

update TPD set TPD.[FSCT Total (%c)]=(
select sum(case invoicetype when 4 then 0- Isnull(cstpayable,0) else Isnull(cstpayable, 0) end) from invoicedetail idt, invoiceabstract ia
where 
idt.product_code=TPD.product_code and 
ia.invoiceid=idt.invoiceid and 
ia.invoicedate between @FromDate and @ToDate and
(ia.status & 128)=0 and
idt.taxid=@TaxID and Isnull(saleid, 0) = 1 group by idt.product_code)
from #TaxPayableByTaxDetails TPD Where tpd.type =1

update TPD set TPD.[FSCT Total (%c)]=(
select sum(IsNull(cstpayable, 0)) from serviceinvoicedetail idt, serviceinvoiceabstract ia, 
serviceinvoicetaxcomponents itc
where idt.serialno = itc.serialno and
tpd.product_code =idt.sparecode and 
ia.serviceinvoiceid=idt.serviceinvoiceid and 
ia.serviceinvoicedate between @FromDate and @ToDate and
isnull(ia.status,0) & 192=0 and
itc.taxcode =@TaxID and Isnull(saleid, 2) = 1 group by idt.sparecode)
from #TaxPayableByTaxDetails TPD where tpd.type =2
  
update TPD set TPD.[Second Sale Total (%c)]=(
select sum(case invoicetype when 4 then 0-(Isnull(stpayable, 0) + Isnull(cstpayable, 0)) else 
Isnull(stpayable, 0) + Isnull(cstpayable, 0) end) 
from invoicedetail idt, invoiceabstract ia
where idt.product_code=TPD.product_code and 
ia.invoiceid=idt.invoiceid and 
ia.invoicedate between @FromDate and @ToDate and
(ia.status & 128)=0 and
idt.taxid=@TaxID and (Isnull(saleid, 2) = 2 or Isnull(saleid, 2) = 0) group by idt.product_code)
from #TaxPayableByTaxDetails TPD where tpd.type = 1

update TPD set TPD.[Second Sale Total (%c)]=(select sum(Isnull(lstpayable, 0) + Isnull(cstpayable, 0)) 
from serviceinvoicedetail idt, serviceinvoiceabstract ia, serviceinvoicetaxcomponents itc
where idt.serialno = itc.serialno and
tpd.product_code =idt.sparecode and 
ia.serviceinvoiceid=idt.serviceinvoiceid and 
ia.serviceinvoicedate between @FromDate and @ToDate and
isnull(ia.status,0) & 192 =0 and
itc.taxcode = @TaxID and
(Isnull(saleid, 2) = 2 or Isnull(saleid, 2)=0) group by idt.sparecode)
from #TaxPayableByTaxDetails TPD Where tpd.type = 2

update TPD set TPD.[SSLT Total (%c)]=(
select sum(case invoicetype when 4 then 0- Isnull(stpayable, 0) else Isnull(stpayable, 0) end) 
from invoicedetail idt, invoiceabstract ia
where idt.product_code=TPD.product_code and 
ia.invoiceid=idt.invoiceid and 
ia.invoicedate between @FromDate and @ToDate and
(Isnull(ia.status,0) & 128)=0 and
idt.taxid=@TaxID and
(Isnull(saleid, 2) = 2 or Isnull(saleid, 2) = 0) group by idt.product_code)
from #TaxPayableByTaxDetails TPD where tpd.type =1

update TPD set TPD.[SSLT Total (%c)]=(
select sum(Isnull(lstpayable, 0)) 
from serviceinvoicedetail idt, serviceinvoiceabstract ia,serviceinvoicetaxcomponents itc
where idt.serialno = itc.serialno and
tpd.product_code = idt.sparecode and 
ia.serviceinvoiceid=idt.serviceinvoiceid and 
ia.serviceinvoicedate between @FromDate and @ToDate and
isnull(ia.status,0)& 192 = 0 and
itc.taxcode = @TaxID and
(Isnull(saleid, 2) = 2 or Isnull(saleid, 2) = 0) group by idt.sparecode)--and itc.type =2)
from #TaxPayableByTaxDetails TPD Where tpd.type = 2 

update TPD set TPD.[SSCT Total (%c)]=(select sum(case invoicetype when 4 then 
0 - IsnUll(cstpayable, 0) else Isnull(cstpayable, 0) end) 
from invoicedetail idt, invoiceabstract ia
where 
idt.product_code=TPD.product_code and 
ia.invoiceid=idt.invoiceid and 
ia.invoicedate between @FromDate and @ToDate and
(Isnull(ia.status, 0) & 128) = 0 and
idt.taxid=@TaxID and
(Isnull(saleid, 2) = 2 or Isnull(saleid, 2) = 0) group by idt.product_code)
from #TaxPayableByTaxDetails TPD Where tpd.type = 1

update TPD set TPD.[SSCT Total (%c)]=(
select sum(Isnull(cstpayable, 0)) from serviceinvoicedetail idt, 
serviceinvoiceabstract ia, serviceinvoicetaxcomponents itc
where idt.serialno = itc.serialno and
tpd.product_code =idt.sparecode and 
ia.serviceinvoiceid=idt.serviceinvoiceid and 
ia.serviceinvoicedate between @FromDate and @ToDate and
isnull(ia.status,0) & 192=0 and
itc.taxcode =@TaxID and
(Isnull(saleid, 2) = 2 or Isnull(saleid, 2) = 0) group by idt.sparecode)--and itc.type =2)
from #TaxPayableByTaxDetails TPD Where tpd.type = 2 

update #TaxPayableByTaxDetails set [First Sale Total (%c)]=null where [First Sale Total (%c)]=0
update #TaxPayableByTaxDetails set [FSLT Total (%c)]=null where [FSLT Total (%c)]=0
update #TaxPayableByTaxDetails set [FSCT Total (%c)]=null where [FSCT Total (%c)]=0
update #TaxPayableByTaxDetails set [Second Sale Total (%c)]=null where [Second Sale Total (%c)]=0
update #TaxPayableByTaxDetails set [SSLT Total (%c)]=null where [SSLT Total (%c)]=0
update #TaxPayableByTaxDetails set [SSCT Total (%c)]=null where [SSCT Total (%c)]=0

select * from #TaxPayableByTaxDetails  
drop table #TaxPayableByTaxDetails  
drop table #temp1
drop table #TaxPayableByTaxDetails1  
end
