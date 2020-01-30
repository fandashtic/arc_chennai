CREATE procedure [dbo].[spr_ser_Taxwisereport](@Fromdate datetime,@Todate datetime)    
as  

begin  
declare @TaxCompDesc varchar(50)  
declare @Prefix varchar(50)  
declare @TaxCode numeric  
declare @TaxCompCode numeric  
declare @Query nvarchar(4000)  
declare @Locality varchar(10)  
declare @Tax decimal(18,6)  
declare @INVTYPE int
declare @SERVICEINVTYPE int
declare @type int
set @INVTYPE = 1
set @SERVICEINVTYPE =2


CREATE TABLE #TaxPayableByTaxAbstract1 (
[Tax_code] int, 
[Tax Description] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
[Local Sales Tax] decimal(18,6),   
[LT Value (%c)] decimal(18,6), 
[TYPE] int)

Insert into #TaxPayableByTaxAbstract1
Select Tax_Code, "Tax Description" = Tax_Description, 
"Local Sales Tax%" = percentage, 
"LT Value (%c)" = ISNULL(sum(case invoicetype when 4 then 0-STPayable else STPayable end), 0),
@INVTYPE
FROM InvoiceAbstract ia, InvoiceDetail idt, tax  
WHERE ia.InvoiceID = idt.InvoiceID AND    
ia.InvoiceDate between @Fromdate AND @Todate AND    
(ia.Status & 128) = 0 AND idt.taxid=tax.tax_code  
GROUP BY Tax_Code, Tax_Description, Percentage, CST_Percentage    

Insert into #TaxPayableByTaxAbstract1
Select Tax_Code, "Tax Description" = Tax_Description,
"Local Sales Tax%" = percentage,
"LT Value (%c)" = sum(LSTPayable), 
@SERVICEINVTYPE
FROM serviceInvoiceAbstract ia, serviceInvoiceDetail idt, tax, serviceinvoicetaxcomponents itc  
WHERE idt.serialno= itc.serialno and           
idt.serviceinvoiceid=ia.serviceinvoiceid 
and itc.taxtype = 2
and itc.taxcode = tax.tax_code
and ia.serviceinvoicedate between @Fromdate AND @Todate 
and isnull(ia.status,0) & 192 =0 
GROUP BY Tax_Code, Tax_Description, Percentage, CST_Percentage    

-- CREATE TABLE #TaxPayableByTaxAbstract (
-- [Tax_code] int, 
-- [Tax Description] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
-- [Local Sales Tax] decimal(18,6),   
-- [LT Value (%c)] decimal(18,6))

Select * into #TaxPayableByTaxAbstract from #TaxPayableByTaxAbstract1 Where 1 = 0
Insert into #TaxPayableByTaxAbstract 
Select [Tax_code], [Tax Description], [Local Sales Tax], Sum([LT Value (%c)]), 0 
from #TaxPayableByTaxAbstract1 Group by [Tax_code], [Tax Description], [Local Sales Tax]

declare TaxPayable cursor  
for  
	select distinct 'LT ', taxcomponent_desc      
	from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd  
	where       
	itc.invoiceid=idt.invoiceid and       
	itc.invoiceid=ia.invoiceid and      
	ia.invoicedate between @Fromdate and @Todate and       
	idt.product_code=itc.product_code and       
	idt.taxid=itc.tax_code and       
	(ia.status & 128)=0 and      
	tcd.taxcomponent_code=itc.tax_component_code  
union
	select distinct 'LT ', tcd.taxcomponent_desc from     
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia,tax, 
	taxcomponentdetail tcd, customer c    
	where idt.serialno=itc.serialno and           
	idt.serviceinvoiceid=ia.serviceinvoiceid 
	and itc.taxcode = tax.tax_code and
	ia.serviceinvoicedate between @Fromdate and @Todate and       
	itc.taxtype =2
	and isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code = itc.taxcomponent_code 
union all      
	select 'Central Sales Tax','%'  
 
--begin tran  
open TaxPayable  
fetch next from TaxPayable into @Prefix, @TaxCompDesc  
while @@FETCH_STATUS=0  
begin  
	set @Query = N'Alter table #TaxPayableByTaxAbstract add [LT '+rtrim(@TaxCompDesc)+ N' (%c)] decimal(18,6)'    
	exec sp_executesql @Query
	fetch next from TaxPayable into @Prefix, @TaxCompDesc  
end  
close TaxPayable  
  
set @Query = N'alter table #TaxPayableByTaxAbstract add  [Central Sales Tax%] decimal(18,6)'  
exec sp_executesql @Query     
set @Query = N'alter table #TaxPayableByTaxAbstract add  [CT Value (%c)] decimal(18,6)'  
exec sp_executesql @Query     

open TaxPayable  
fetch next from TaxPayable into @Prefix, @TaxCompDesc  
while @@FETCH_STATUS=0  
begin  
	set @Query = 'Alter table #TaxPayableByTaxAbstract add [CT '+rtrim(@TaxCompDesc)+ ' (%c)] decimal(18,6)'    
	exec sp_executesql @Query    
	fetch next from TaxPayable into @Prefix, @TaxCompDesc  
end  
close TaxPayable  
deallocate TaxPayable  
--commit tran  
-- Create table #TaxTemp(Tax_code int, type int, 
-- Taxcomponent_desc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
-- locality varchar(10), tax_value decimal(18,6))
-- Insert into #TaxTemp 
-- Insert into #TaxTemp
-- select * from #TaxTemp   
declare TaxPayable Cursor  
for 
	Select itc.tax_code, tpa.type, tcd.Taxcomponent_desc, isnull(locality,1), 
	sum(case invoicetype when 4 then 0-tax_value else tax_value end) 
	from #TaxPayableByTaxAbstract1 TPA, invoiceabstract ia, invoicedetail idt, 
	invoicetaxcomponents itc, taxcomponentdetail tcd, customer c
	where  
	tpa.tax_code = idt.taxid and  
	ia.invoiceid = idt.invoiceid and  
	itc.invoiceid = idt.invoiceid and  
	ia.invoicedate between @Fromdate and @Todate and 
	tcd.taxcomponent_code = itc.tax_component_code and  
	itc.tax_code=idt.taxid and 
	tpa.tax_code=itc.tax_code and 
	(ia.status & 128)=0 and  
	tpa.type = 1 and
	itc.product_code=idt.product_code and
	ia.customerid*=c.customerid
	group by itc.tax_code,tpa.type,tcd.Taxcomponent_Code,tcd.Taxcomponent_desc, locality
Union 
	Select itc.taxcode, tpa.type,tcd.Taxcomponent_desc, isnull(locality,1), 
	sum(tax_value) from #TaxPayableByTaxAbstract1 TPA,
	serviceinvoiceabstract ia, serviceinvoicedetail idt, serviceinvoicetaxcomponents itc,tax,
	taxcomponentdetail tcd, customer c
	where itc.serialno=idt.serialno 
	and itc.taxcode = tax.tax_code
	and idt.serviceinvoiceid=ia.serviceinvoiceid and          
	itc.taxtype =2 and
	ia.serviceinvoicedate between @Fromdate and @Todate
	and tcd.taxcomponent_code = itc.taxcomponent_code and  
	tpa.tax_code=itc.taxcode and 
	isnull(ia.status,0) & 192 =0 and  
	tpa.type =2 and
	idt.sparecode=idt.product_code and
	ia.customerid*=c.customerid
	group by itc.taxcode,tpa.type, tcd.Taxcomponent_Code,tcd.Taxcomponent_desc, locality

open TaxPayable  
fetch next from TaxPayable into @TaxCode, @TYPE,@TaxCompDesc, @Locality, @Tax  
while @@FETCH_STATUS=0   
begin  
	if isnull(@Locality,1) = '1'  
	begin  
		set @Query = 'update TPA set [LT '+rtrim(@TaxCompDesc)+' (%c)] = '+convert(varchar,@Tax)+' from   
		#TaxPayableByTaxAbstract TPA where TPA.Tax_Code='+convert(varchar,@TaxCode)+'' 
		exec sp_executesql @Query  
	end  
	else if isnull(@Locality,1) = '2' 
	begin
		set @Query = 'update TPA set [CT '+rtrim(@TaxCompDesc)+' (%c)] = '+convert(varchar,@Tax)+' from   
		#TaxPayableByTaxAbstract TPA where TPA.Tax_Code='+convert(varchar,@TaxCode) +''   
		exec sp_executesql @Query  
	end  
	fetch next from TaxPayable into @TaxCode,@TYPE, @TaxCompDesc, @Locality, @Tax  
end  
close TaxPayable  
deallocate TaxPayable  

set @Query = 'update TPA set [Central Sales Tax%] = cst_percentage   
from #TaxPayableByTaxAbstract TPA, Tax where tpa.tax_code=tax.tax_code'  
exec sp_executesql @Query  
  
set @Query = 'update TPA set [CT Value (%c)] =   
(select sum(case invoicetype when 4 then 0-cstpayable else cstpayable end) 
	from invoicedetail idt, invoiceabstract ia   
	where ia.invoiceid=idt.invoiceid and  
	ia.invoicedate between '''+convert(varchar,@Fromdate)+''' and '''+convert(varchar,@Todate)+''' and  
idt.taxid=tpa.tax_code and status & 128 = 0)
from #TaxPayableByTaxAbstract TPA, invoicedetail idt, invoiceabstract ia  
where tpa.tax_code=idt.taxid and   
idt.invoiceid=ia.invoiceid'
exec sp_executesql @Query  

set @Query = 'update TPA set [CT Value (%c)] =  [CT Value (%c)] + 
(select sum(cstpayable) 
from serviceinvoicedetail idt, serviceinvoiceabstract ia ,serviceinvoicetaxcomponents itc, tax  
where idt.serialno = itc.serialno and ia.serviceinvoiceid=idt.serviceinvoiceid and  
ia.serviceinvoicedate between '''+convert(varchar,@Fromdate)+''' and '''+convert(varchar,@Todate)+''' and  
itc.taxcode = tax.tax_code and isnull(ia.status,0) & 192 =0)
from #TaxPayableByTaxAbstract TPA, serviceinvoicedetail idt, serviceinvoiceabstract ia ,serviceinvoicetaxcomponents itc,tax  
where idt.serialno = itc.serialno
and itc.taxcode = tax.tax_code and   
idt.serviceinvoiceid=ia.serviceinvoiceid'
exec sp_executesql @Query  

set @Query = 'Alter Table #TaxPayableByTaxAbstract Drop Column Type select * from #TaxPayableByTaxAbstract'  
exec sp_executesql @Query  

drop table #TaxPayableByTaxAbstract  
End
