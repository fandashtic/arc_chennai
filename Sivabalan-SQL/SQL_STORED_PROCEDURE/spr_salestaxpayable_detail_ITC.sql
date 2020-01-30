CREATE procedure spr_salestaxpayable_detail_ITC (@InvoiceID int, @Breakup nVarchar(3))  
as  
begin  
declare @sComponentName nvarchar(500)  
declare @Prefix nvarchar(10)  
declare @s nvarchar(4000)  
declare @TaxComp nvarchar(255)  
declare @TaxValue decimal(18,6)  
declare @Locality nvarchar(10)  
declare @SaleID int  
declare @ProductCode nvarchar(50)  
declare @TaxDesc nVarchar(255) 
declare @PrevTaxDesc nVarchar(255) 
declare @BreakupFlag int
declare @TmpTaxCompCode int

If Upper(@Breakup) = N'YES'
	Set @BreakupFlag = 1
Else
	Set @BreakupFlag = 0

Declare @TaxPayable Table(ColHead1 nVarchar(50), ColHead2 nVarchar(400), ColHead3 nVarchar(255), ColHead4 int)

Create Table #SalesTaxPayableTemp (InvoiceID int, [Item Code] nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, [Item Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

-- If @BreakupFlag = 1
-- Begin
	Set @s = 'Alter Table #SalesTaxPayableTemp Add [Exempt] Decimal(18,6), [FS Total (%c)] Decimal(18,6), [FSLT Total (%c)] Decimal(18,6)'
	Exec sp_executesql @s	

	Set @s = 'Insert Into #SalesTaxPayableTemp 
	select "invoiceid"=ia.invoiceid, "Item Code"=idt.product_code, "Item Name"=items.productname,  
	"Exempt" = Sum(case WHEN (idt.taxcode = 0) AND (idt.taxcode2 = 0) AND (IA.InvoiceType in (4,5,6)) then 0 - (amount) WHEN (idt.taxcode = 0) AND (idt.taxcode2 = 0) AND IA.InvoiceType not in (4,5,6) then amount else null end),   
	"FS Total (%c)" = Sum(case WHEN (idt.taxcode <> 0 or idt.taxcode2 <> 0) AND (idt.saleid = 1) AND (IA.InvoiceType in (4,5,6)) then 0 - (amount) WHEN (idt.taxcode <> 0 or idt.taxcode2 <> 0) AND (idt.saleid = 1) AND (IA.InvoiceType not in (4,5,6)) then amount else null end),   
	"FSLT Total (%c)"= sum(case when idt.saleid = 1 and IA.InvoiceType in (4,5,6) then 0 - (stpayable) when idt.saleid = 1 AND IA.InvoiceType not in (4,5,6) then stpayable else null end)
	from invoiceabstract IA, VoucherPrefix, invoicedetail idt, items  
	where (ia.status & 128) = 0 and ia.invoiceid=idt.invoiceid and tranid = N''INVOICE''  
	and idt.invoiceid = ' + Cast(@InvoiceID as nVarchar) + ' and items.product_code=idt.product_code 
	group by ia.invoiceid, documentid, ia.docreference, prefix, idt.product_code, items.productname'
	Exec sp_executesql @s	
-- End
-- Else
-- Begin
-- 	Set @s = 'Alter Table #SalesTaxPayableTemp Add [FS Total (%c)] Decimal(18,6), [FSLT Total (%c)] Decimal(18,6)'
-- 	Exec sp_executesql @s	
-- 
-- 	Set @s = 'Insert Into #SalesTaxPayableTemp 
-- 	select  "invoiceid"=ia.invoiceid, "Item Code"=idt.product_code, "Item Name"=items.productname,  
-- 	"FS Total (%c)" = Sum(case WHEN (idt.saleid = 1) AND (IA.InvoiceType in (4,5,6)) then 0 - (amount) WHEN (idt.saleid = 1) AND (IA.InvoiceType not in (4,5,6)) then amount else null end),   
-- 	"FSLT Total (%c)"= sum(case when idt.saleid = 1 and IA.InvoiceType in (4,5,6) then 0 - (stpayable)when idt.saleid = 1 AND IA.InvoiceType not in (4,5,6) then stpayable else null end)
-- 	from invoiceabstract IA, VoucherPrefix, invoicedetail idt, items  
-- 	where (ia.status & 128) = 0 and ia.invoiceid=idt.invoiceid and tranid = N''INVOICE''  
-- 	and idt.invoiceid = ' + Cast(@InvoiceID as nVarchar) + ' and items.product_code=idt.product_code 
-- 	group by ia.invoiceid, documentid, ia.docreference, prefix, idt.product_code, items.productname'
-- 	Exec sp_executesql @s	
-- End
  
Insert Into @TaxPayable 
select distinct N'FSLT ', taxcomponent_desc, tax_description, tcd.taxcomponent_code   
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, tax 
where   
(ia.status & 128) = 0 and 
itc.invoiceid=idt.invoiceid and   
itc.invoiceid=ia.invoiceid and  
idt.invoiceid=@Invoiceid and 
idt.taxcode <> 0 and 
idt.product_code=itc.product_code and   
idt.taxid=itc.tax_code and 
itc.tax_code = tax.tax_code and  
tcd.taxcomponent_code=itc.tax_component_code and  
saleid=1  
order by tax_description, tcd.taxcomponent_code 

-- Imported tax handled
Insert Into @TaxPayable 
select distinct N'FSLT ', '', tax_description,0
from invoicedetail invdt, invoiceabstract inva, tax 
where   
(inva.status & 128) = 0 and 
invdt.invoiceid=inva.invoiceid and  
invdt.invoiceid=@Invoiceid and 
invdt.taxcode <> 0 and 
invdt.taxid=tax.tax_code and 
saleid=1 And
tax_description Not In
(select distinct tax_description
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, tax 
where   
(ia.status & 128) = 0 and 
itc.invoiceid=idt.invoiceid and   
itc.invoiceid=ia.invoiceid and  
idt.invoiceid=@Invoiceid and 
idt.taxcode <> 0 and 
idt.product_code=itc.product_code and   
idt.taxid=itc.tax_code and 
itc.tax_code = tax.tax_code and  
tcd.taxcomponent_code=itc.tax_component_code and  
saleid=1)

Insert Into @TaxPayable 
select N'FSCT ', N'Total', N'', N''  

Insert Into @TaxPayable 
select distinct N'FSCT ', taxcomponent_desc, tax_description, tcd.taxcomponent_code   
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, tax 
where   
(ia.status & 128) = 0 and 
itc.invoiceid=idt.invoiceid and   
itc.invoiceid=ia.invoiceid and  
idt.invoiceid=@Invoiceid and 
idt.taxcode2 <> 0 and 
idt.product_code=itc.product_code and   
idt.taxid=itc.tax_code and   
itc.tax_code = tax.tax_code and 
tcd.taxcomponent_code=itc.tax_component_code and  
saleid=1  
order by tax_description, tcd.taxcomponent_code 

-- Imported tax handled
Insert Into @TaxPayable 
select distinct N'FSCT ', '', tax_description, 0
from invoicedetail invdt, invoiceabstract inva , tax 
where   
(inva.status & 128) = 0 and 
inva.invoiceid=invdt.invoiceid and   
invdt.invoiceid=@Invoiceid and 
invdt.taxcode2 <> 0 and 
invdt.taxid = tax.tax_code and 
saleid=1 And 
tax_description  Not In 
(select distinct tax_description 
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, tax 
where   
(ia.status & 128) = 0 and 
itc.invoiceid=idt.invoiceid and   
itc.invoiceid=ia.invoiceid and  
idt.invoiceid=@Invoiceid and 
idt.taxcode2 <> 0 and 
idt.product_code=itc.product_code and   
idt.taxid=itc.tax_code and   
itc.tax_code = tax.tax_code and 
tcd.taxcomponent_code=itc.tax_component_code and  
saleid=1 )

Insert Into @TaxPayable 
select N'SS ', N'Total', N'', N'' 

Insert Into @TaxPayable 
select N'SSLT ', N'Total', N'', N''  

Insert Into @TaxPayable 
select distinct N'SSLT ', taxcomponent_desc, tax_description, tcd.taxcomponent_code   
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, tax 
where   
(ia.status & 128) = 0 and 
itc.invoiceid=idt.invoiceid and   
itc.invoiceid=ia.invoiceid and  
idt.invoiceid=@Invoiceid and 
idt.taxcode <> 0 and 
idt.product_code=itc.product_code and   
idt.taxid=itc.tax_code and   
itc.tax_code = tax.tax_code and 
tcd.taxcomponent_code=itc.tax_component_code and  
saleid=2  
order by tax_description, tcd.taxcomponent_code 

-- Imported tax handled
Insert Into @TaxPayable 
select distinct N'SSLT ', '', tax_description, 0
from Invoicedetail invdt, invoiceabstract inva , tax 
where   
(inva.status & 128) = 0 and 
inva.invoiceid=invdt.invoiceid and   
invdt.invoiceid=@Invoiceid and 
invdt.taxcode <> 0 and 
invdt.taxid = tax.tax_code and 
saleid=2  And tax_description Not IN
(
select distinct tax_description
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, tax 
where   
(ia.status & 128) = 0 and 
itc.invoiceid=idt.invoiceid and   
itc.invoiceid=ia.invoiceid and  
idt.invoiceid=@Invoiceid and 
idt.taxcode <> 0 and 
idt.product_code=itc.product_code and   
idt.taxid=itc.tax_code and   
itc.tax_code = tax.tax_code and 
tcd.taxcomponent_code=itc.tax_component_code and  
saleid=2
)

Insert Into @TaxPayable 
select N'SSCT ', N'Total', N'', N''  

Insert Into @TaxPayable 
select distinct N'SSCT ', taxcomponent_desc, tax_description, tcd.taxcomponent_code   
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, tax 
where   
(ia.status & 128) = 0 and 
itc.invoiceid=idt.invoiceid and   
itc.invoiceid=ia.invoiceid and  
idt.invoiceid=@Invoiceid and 
idt.taxcode2 <> 0 and 
idt.product_code=itc.product_code and   
idt.taxid=itc.tax_code and   
itc.tax_code = tax.tax_code and 
tcd.taxcomponent_code=itc.tax_component_code and  
saleid=2  
order by tax_description, tcd.taxcomponent_code 

-- Imported tax handled
Insert Into @TaxPayable 
select distinct N'SSCT ', '', tax_description, 0
from invoicedetail invdt, invoiceabstract inva, tax 
where   
(inva.status & 128) = 0 and 
inva.invoiceid=invdt.invoiceid and   
invdt.invoiceid=@Invoiceid and 
invdt.taxcode2 <> 0 and 
invdt.taxid = tax.tax_code and 
saleid=2 And tax_description Not In
(
select distinct tax_description 
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, tax 
where   
(ia.status & 128) = 0 and 
itc.invoiceid=idt.invoiceid and   
itc.invoiceid=ia.invoiceid and  
idt.invoiceid=@Invoiceid and 
idt.taxcode2 <> 0 and 
idt.product_code=itc.product_code and   
idt.taxid=itc.tax_code and   
itc.tax_code = tax.tax_code and 
tcd.taxcomponent_code=itc.tax_component_code and  
saleid=2  
)

declare SalesTaxComponents cursor  
for 
Select * From @TaxPayable

Set @PrevTaxDesc = N''
open SalesTaxComponents  
fetch next from SalesTaxComponents into @Prefix, @sComponentName, @TaxDesc, @TmpTaxCompCode  
while @@FETCH_STATUS=0  
begin 
	-- Cummulative column
	If (@TaxDesc <> @PrevTaxDesc) And (@TaxDesc <> N'') -- And (@BreakupFlag = 1) 
	Begin
		Set @s = 'alter table #SalesTaxPayableTemp add ['+@Prefix + rtrim(@TaxDesc) + N' (%c)] decimal(18,6)'        
		exec sp_executesql @s        
	End

	-- Tax split up column
	If (@TaxDesc <> N'') And (@BreakupFlag = 1) And (@sComponentName <> N'')
	Begin
		set @s = N'alter table #SalesTaxPayableTemp add ['+@Prefix+rtrim(@sComponentName)+ '_of_'+ @TaxDesc +' (%c)] decimal(18,6)'  
		exec sp_executesql @s  
	End
	
	-- Other total values
	If @TaxDesc = N''
	Begin
		set @s = N'alter table #SalesTaxPayableTemp add ['+@Prefix+rtrim(@sComponentName)+ ' (%c)] decimal(18,6)'  
		exec sp_executesql @s  
	End
	Set @PrevTaxDesc = @TaxDesc 
	fetch next from SalesTaxComponents into @Prefix, @sComponentName, @TaxDesc, @TmpTaxCompCode  
end  
close SalesTaxComponents  
deallocate SalesTaxComponents  

Select Distinct InvoiceID, Product_Code, SaleID, TaxID, TaxCode, TaxCode2 Into #InvDet 
From InvoiceDetail Where InvoiceID = @InvoiceID and (TaxCode <> 0 or TaxCode2 <> 0)
  
declare SalesTaxComponentsUpdate cursor  
for   
select STP.invoiceid, tcd.taxcomponent_desc, sum(case invoicetype when 4 then 0-tax_value else tax_value end), 
(Case When (idt.taxcode <> 0) Then 1 When (idt.taxcode2 <> 0) Then 2 End), idt.saleid, idt.product_code, tax.tax_description   
from #SalesTaxPayableTemp STP , invoicetaxcomponents itc, invoiceabstract ia, #InvDet idt, taxcomponentdetail tcd, tax 
where  
(ia.status & 128) = 0 and 
stp.invoiceid=itc.invoiceid and   
itc.invoiceid=ia.invoiceid and   
ia.invoiceid=idt.invoiceid and  
idt.invoiceid=@InvoiceID and 
idt.Product_Code = itc.Product_Code and 
idt.taxid=itc.tax_code and  
(idt.TaxCode <> 0 or idt.TaxCode2 <> 0) And 
itc.tax_code = tax.tax_code and 
tcd.taxcomponent_code=itc.tax_component_code and  
idt.product_code=itc.product_code and   
idt.product_code=stp.[Item Code] 
group by STP.invoiceid, tcd.taxcomponent_desc, SaleID, idt.product_code, tax.tax_description, idt.taxcode, idt.taxcode2 --Locality   
  
open SalesTaxComponentsUpdate  
fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @ProductCode, @TaxDesc    
while @@FETCH_STATUS=0  
begin  
 if isnull(@Locality,1) = 1 and @SaleID = 1  
 begin  
	If @BreakupFlag = 1
		set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [FSLT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
	Else
		set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
--		set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
 end  
 else if isnull(@Locality,1) = 2 and @SaleID = 1  
 begin  
	If @BreakupFlag = 1
		set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [FSCT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
	Else
		set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
--		set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
 end  
 else if isnull(@Locality,1) = 1 and @SaleID = 2  
 begin  
	If @BreakupFlag = 1
		set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [SSLT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
	Else
		set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
--		set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
 end  
 else if isnull(@Locality,1) = 2 and @SaleID = 2  
 begin  
	If @BreakupFlag = 1
		set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [SSCT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
	Else
		set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
--		set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
 end  
 exec sp_executesql @s  
 fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @ProductCode, @TaxDesc  
end  
close SalesTaxComponentsUpdate  
deallocate SalesTaxComponentsUpdate   

------***
-- Imported tax handled
declare SalesTaxComponentsUpdate cursor  
for   
select STPx.invoiceid,'', sum(case invoicetype when 4 then 0-(STPayable+CSTPayable) else (STPayable+CSTPayable) end), 
(Case When (invdt.taxcode <> 0) Then 1 When (invdt.taxcode2 <> 0) Then 2 End), invdt.saleid, invdt.product_code, tax.tax_description   
from #SalesTaxPayableTemp STPX , invoiceabstract inva,InvoiceDetail invdt, tax 
where  
(inva.status & 128) = 0 and 
stpx.invoiceid=inva.invoiceid and   
inva.invoiceid=invdt.invoiceid and  
invdt.invoiceid=@InvoiceID and 
invdt.taxid = tax.tax_code and 
(invdt.TaxCode <> 0 or invdt.TaxCode2 <> 0) And 
invdt.product_code=stpx.[Item Code] 
And tax.tax_description   Not In
(
select Distinct tax.tax_description   
from #SalesTaxPayableTemp STP , invoicetaxcomponents itc, invoiceabstract ia, #InvDet idt, taxcomponentdetail tcd, tax 
where  
(ia.status & 128) = 0 and 
stp.invoiceid=itc.invoiceid and   
itc.invoiceid=ia.invoiceid and   
ia.invoiceid=idt.invoiceid and  
idt.invoiceid=@InvoiceID and 
idt.Product_Code = itc.Product_Code and 
idt.taxid=itc.tax_code and  
(idt.TaxCode <> 0 or idt.TaxCode2 <> 0) And 
itc.tax_code = tax.tax_code and 
tcd.taxcomponent_code=itc.tax_component_code and  
idt.product_code=itc.product_code and   
idt.product_code=stp.[Item Code] 
)
group by STPx.invoiceid, SaleID, invdt.product_code, tax.tax_description, invdt.taxcode, invdt.taxcode2 --Locality   
  
open SalesTaxComponentsUpdate  
fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @ProductCode, @TaxDesc    
while @@FETCH_STATUS=0  
begin  
 if isnull(@Locality,1) = 1 and @SaleID = 1  
 begin  
-- 	If @BreakupFlag = 1
-- 		set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [FSLT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
-- 	Else
		set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
--		set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
 end  
 else if isnull(@Locality,1) = 2 and @SaleID = 1  
 begin  
-- 	If @BreakupFlag = 1
-- 		set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [FSCT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
-- 	Else
		set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
--		set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
 end  
 else if isnull(@Locality,1) = 1 and @SaleID = 2  
 begin  
-- 	If @BreakupFlag = 1
-- 		set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [SSLT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
-- 	Else
		set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
--		set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
 end  
 else if isnull(@Locality,1) = 2 and @SaleID = 2  
 begin  
-- 	If @BreakupFlag = 1
-- 		set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [SSCT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
-- 	Else
		set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
--		set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxComp)+'_of_' + rtrim(@TaxDesc) + ' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where [Item Code]=N'''+@ProductCode+''''  
 end  
 exec sp_executesql @s  
 fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @ProductCode, @TaxDesc  
end  
close SalesTaxComponentsUpdate  
deallocate SalesTaxComponentsUpdate  
------***
update STP set STP.[FSCT Total (%c)]= (     
 select sum(case when ia.InvoiceType In (4,5,6) then 0-cstpayable else cstpayable end)    
 from invoicedetail idt, invoiceabstract ia    
 where   stp.invoiceid=idt.invoiceid  and saleid=1 and idt.product_code=stp.[Item Code] and stp.invoiceid=ia.invoiceid)    
 from #SalesTaxPayableTemp STP 

update STP set STP.[SSLT Total (%c)]=(    
 select sum(case when ia.InvoiceType In (4,5,6) then 0-stpayable else stpayable end)    
 from invoicedetail idt, invoiceabstract ia    
 where stp.invoiceid=idt.invoiceid and saleid=2 and idt.product_code=stp.[Item Code] and stp.invoiceid=ia.invoiceid)    
 from #SalesTaxPayableTemp STP

update STP set STP.[SSCT Total (%c)]=(    
 select sum(case when ia.InvoiceType In (4,5,6) then 0-cstpayable else cstpayable end)    
 from invoicedetail idt, invoiceabstract ia    
 where stp.invoiceid=idt.invoiceid  and saleid=2 and idt.product_code=stp.[Item Code] and stp.invoiceid=ia.invoiceid)    
 from #SalesTaxPayableTemp STP 

-- If @BreakupFlag = 1
-- Begin
	update STP set [SS Total (%c)]= (    
	 select sum(case when ia.InvoiceType in (4,5,6) THEN 0-amount else amount end)     
	 from invoicedetail idt, invoiceabstract ia    
	 where stp.invoiceid=idt.invoiceid and (idt.taxcode <> 0 or idt.taxcode2 <> 0) and saleid=2 and idt.product_code=stp.[Item Code] and stp.invoiceid=ia.invoiceid)    
	 from #SalesTaxPayableTemp STP
-- End
-- Else
-- Begin
-- 	update STP set [SS Total (%c)]= (    
-- 	 select sum(case when ia.InvoiceType in (4,5,6) THEN 0-amount else amount end)     
-- 	 from invoicedetail idt, invoiceabstract ia    
-- 	 where stp.invoiceid=idt.invoiceid and saleid=2 and idt.product_code=stp.[Item Code] and stp.invoiceid=ia.invoiceid)    
-- 	 from #SalesTaxPayableTemp STP
-- End

update #SalesTaxPayableTemp set [FS Total (%c)]=null where [FS Total (%c)]=0
update #SalesTaxPayableTemp set [FSLT Total (%c)]=null where [FSLT Total (%c)]=0
update #SalesTaxPayableTemp set [FSCT Total (%c)]=null where [FSCT Total (%c)]=0
update #SalesTaxPayableTemp set [SS Total (%c)]=null where [SS Total (%c)]=0
update #SalesTaxPayableTemp set [SSLT Total (%c)]=null where [SSLT Total (%c)]=0
update #SalesTaxPayableTemp set [SSCT Total (%c)]=null where [SSCT Total (%c)]=0
  
select * from #SalesTaxPayableTemp  
drop table #SalesTaxPayableTemp 
drop table #InvDet 
end 

