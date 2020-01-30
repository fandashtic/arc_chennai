CREATE procedure spr_salestaxpayable_ITC (@FromDate datetime,@ToDate datetime, @Breakup nVarchar(3))        
as        
Begin        
declare @sComponentName nvarchar(500)        
declare @Prefix nvarchar(10)        
declare @s nvarchar(4000)        
declare @InvoiceID nvarchar(50)        
declare @TaxComp nvarchar(255)        
declare @TaxValue decimal(18,6)        
declare @Locality nvarchar(10)        
declare @SaleID int        
declare @TaxDesc nvarchar(255) 
declare @PrevTaxDesc nvarchar(255)  
declare @BreakupFlag int
declare @TmpTaxCompCode int
declare @temp datetime 
Set DATEFormat DMY
set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)

If(@FROMDATE > @temp)
Begin
	Select 0,'This report cannot be generated for GST period' as Reason
	GoTo GSTOut
End               
                 
If(@TODATE > @temp )
Begin
	Set @TODATE  = @temp 
	--goto GSTOut
End                 

If Upper(@Breakup) = N'YES'
	Set @BreakupFlag = 1
Else
	Set @BreakupFlag = 0

Declare @TaxPayable Table(ColHead1 nVarchar(50), ColHead2 nVarchar(400), ColHead3 nVarchar(255), ColHead4 int)

Create Table #SalesTaxPayableTemp (InvoiceID int, InvoiceNo nVarchar(50), [Doc Reference] nVarchar(255))
-- 
-- If @BreakupFlag = 1
-- Begin
	Set @s = 'Alter Table #SalesTaxPayableTemp Add [Exempt] Decimal(18,6), [FS Total (%c)] Decimal(18,6), [FSLT Total (%c)] Decimal(18,6)'
	Exec sp_executesql @s	

	Set @s = 'Insert Into #SalesTaxPayableTemp 
	select IA.invoiceid, VoucherPrefix.Prefix + CAST(IA.documentid AS NVARCHAR), DocReference, 
		Sum(case WHEN (idt.TaxCode = 0) AND (idt.TaxCode2 = 0) AND (IA.InvoiceType in (4,5,6)) then 0 - (amount) WHEN (idt.TaxCode = 0) AND (idt.TaxCode2 = 0) AND   
		(IA.InvoiceType In (1,2,3)) then amount else null end), 
		Sum(case WHEN (idt.TaxCode <> 0 or idt.TaxCode2 <> 0) AND (saleid = 1) AND (IA.InvoiceType in (4,5,6)) then 0 - (amount) WHEN (idt.TaxCode <> 0 or idt.TaxCode2 <> 0)  AND (saleid = 1) AND   
		(IA.InvoiceType In (1,2,3)) then amount else null end),         
		Sum(case when saleid = 1 and IA.InvoiceType in (4,5,6) then 0 - (stpayable)when saleid = 1 AND IA.InvoiceType In (1,2,3) then stpayable else null end)         
	from invoiceabstract IA, VoucherPrefix , invoicedetail idt        
	where (status & 128)=0 and invoicedate between ''' + Cast(@FromDate as nVarchar) + ''' and ''' + Cast(@ToDate as nVarchar) + ''' and        
	ia.invoiceid=idt.invoiceid and tranid = ''INVOICE''        
	group by ia.invoiceid, documentid, ia.docreference, prefix'
	Exec sp_executesql @s	
-- End
-- Else
-- Begin
-- 	Set @s = 'Alter Table #SalesTaxPayableTemp Add [FS Total (%c)] Decimal(18,6), [FSLT Total (%c)] Decimal(18,6)'
-- 	Exec sp_executesql @s	
-- 
-- 	Set @s = 'Insert Into #SalesTaxPayableTemp 
-- 	select IA.invoiceid, VoucherPrefix.Prefix + CAST(IA.documentid AS NVARCHAR), DocReference, 
-- 		Sum(case WHEN (saleid = 1) AND (IA.InvoiceType in (4,5,6)) then 0 - (amount) WHEN (saleid = 1) AND   
-- 		(IA.InvoiceType In (1,2,3)) then amount else null end),         
-- 		Sum(case when saleid = 1 and IA.InvoiceType in (4,5,6) then 0 - (stpayable)when saleid = 1 AND IA.InvoiceType In (1,2,3) then stpayable else null end)         
-- 	from invoiceabstract IA, VoucherPrefix , invoicedetail idt        
-- 	where (status & 128)=0 and invoicedate between ''' + Cast(@FromDate as nVarchar) + ''' and ''' + Cast(@ToDate as nVarchar) + ''' and        
-- 	ia.invoiceid=idt.invoiceid and tranid = ''INVOICE''        
-- 	group by ia.invoiceid, documentid, ia.docreference, prefix'
-- 	Exec sp_executesql @s	
-- End
        
Insert into @TaxPayable
select distinct 'FSLT ', taxcomponent_desc, tax_description, tcd.taxcomponent_code         
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, Tax 
where         
(ia.status & 128 )=0 and        
ia.invoicedate between @FromDate and @ToDate and         
ia.invoiceid = idt.invoiceid and 
idt.taxcode <> 0 and 
itc.invoiceid=idt.invoiceid and         
itc.invoiceid=ia.invoiceid and        
idt.product_code=itc.product_code and         
idt.taxid=itc.tax_code and 
itc.tax_code = tax.tax_code and         
tcd.taxcomponent_code=itc.tax_component_code and   
saleid=1 
order by tax_description, tcd.taxcomponent_code       

-- Imported tax handled
Insert into @TaxPayable
Select Distinct 'FSLT ','',Tax_Description , 0
From InvoiceAbstract InvA, InvoiceDetail InvD, Tax T
Where InvA.Status & 128 = 0 And 
InvA.InvoiceDate BetWeen @FromDate and @ToDate And
InvA.InvoiceID = InvD.InvoiceID And 
InvD.TaxCode <> 0 And
InvD.TaxID = T.Tax_Code And 
InvD.SaleID = 1 and
T.Tax_Description Not In (
Select Distinct Tax_Description
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, Tax 
where         
(ia.status & 128 )=0 and        
ia.invoicedate between @FromDate and @ToDate and         
ia.invoiceid = idt.invoiceid and 
idt.taxcode <> 0 and 
itc.invoiceid=idt.invoiceid and         
itc.invoiceid=ia.invoiceid and        
idt.product_code=itc.product_code and         
idt.taxid=itc.tax_code and 
itc.tax_code = tax.tax_code and         
tcd.taxcomponent_code=itc.tax_component_code and   
saleid=1)

Insert into @TaxPayable
select 'FSCT ', 'Total', '', ''        

Insert into @TaxPayable
select distinct 'FSCT ', taxcomponent_desc, tax_description, tcd.taxcomponent_code         
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, Tax 
where         
(ia.status & 128 )=0 and        
ia.invoicedate between @FromDate and @ToDate and  
ia.invoiceid = idt.invoiceid and 
idt.taxcode2 <> 0 and        
itc.invoiceid=idt.invoiceid and         
itc.invoiceid=ia.invoiceid and        
idt.product_code=itc.product_code and         
idt.taxid=itc.tax_code and         
itc.tax_code = tax.tax_code and         
tcd.taxcomponent_code=itc.tax_component_code and  
saleid=1      
order by tax_description, tcd.taxcomponent_code  

-- Imported tax handled
Insert into @TaxPayable
select distinct 'FSCT ', '', tax_description, 0
from invoicedetail invd, invoiceabstract inva, Tax T
where         
(inva.status & 128 )=0 and        
inva.invoicedate between @FromDate and @ToDate and  
inva.invoiceid = invd.invoiceid and 
invd.taxcode2 <> 0 and        
invd.taxid=t.tax_code and
saleid=1 And 
tax_description Not In
(select distinct tax_description
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, Tax 
where         
(ia.status & 128 )=0 and        
ia.invoicedate between @FromDate and @ToDate and  
ia.invoiceid = idt.invoiceid and 
idt.taxcode2 <> 0 and        
itc.invoiceid=idt.invoiceid and         
itc.invoiceid=ia.invoiceid and        
idt.product_code=itc.product_code and         
idt.taxid=itc.tax_code and         
itc.tax_code = tax.tax_code and         
tcd.taxcomponent_code=itc.tax_component_code and  
saleid=1)

Insert into @TaxPayable
select 'SS ', 'Total', '', ''        

Insert into @TaxPayable
select 'SSLT ', 'Total', '', ''        

Insert into @TaxPayable
select distinct 'SSLT ', taxcomponent_desc, tax_description, tcd.taxcomponent_code         
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, Tax 
where         
(ia.status & 128 )=0 and        
ia.invoicedate between @FromDate and @ToDate and         
ia.invoiceid = idt.invoiceid and 
idt.taxcode <> 0 and 
itc.invoiceid=idt.invoiceid and         
itc.invoiceid=ia.invoiceid and        
idt.product_code=itc.product_code and         
idt.taxid=itc.tax_code and         
itc.tax_code = tax.tax_code and         
tcd.taxcomponent_code=itc.tax_component_code and  
saleid=2        
order by tax_description, tcd.taxcomponent_code

-- Imported tax handled
Insert into @TaxPayable
select distinct 'SSLT ', '', tax_description,0
from invoicedetail invd, invoiceabstract inva, Tax T
where         
(inva.status & 128 )=0 and        
inva.invoicedate between @FromDate and @ToDate and         
inva.invoiceid = invd.invoiceid and 
invd.taxcode <> 0 and 
invd.taxid=t.tax_code and         
saleid=2 And
tax_description Not In 
(select distinct tax_description 
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, Tax 
where         
(ia.status & 128 )=0 and        
ia.invoicedate between @FromDate and @ToDate and         
ia.invoiceid = idt.invoiceid and 
idt.taxcode <> 0 and 
itc.invoiceid=idt.invoiceid and         
itc.invoiceid=ia.invoiceid and        
idt.product_code=itc.product_code and         
idt.taxid=itc.tax_code and         
itc.tax_code = tax.tax_code and         
tcd.taxcomponent_code=itc.tax_component_code and  
saleid=2)

Insert into @TaxPayable
select 'SSCT ', 'Total', '', ''        

Insert into @TaxPayable
select distinct 'SSCT ', taxcomponent_desc, tax_description, tcd.taxcomponent_code         
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, Tax 
where         
(ia.status & 128 )=0 and        
ia.invoicedate between @FromDate and @ToDate and 
ia.invoiceid = idt.invoiceid and 
idt.taxcode2 <> 0 and         
itc.invoiceid=idt.invoiceid and         
itc.invoiceid=ia.invoiceid and        
idt.product_code=itc.product_code and         
idt.taxid=itc.tax_code and         
itc.tax_code = tax.tax_code and         
tcd.taxcomponent_code = itc.tax_component_code and 
saleid=2        
order by tax_description, tcd.taxcomponent_code


-- Imported tax handled
Insert into @TaxPayable
select distinct 'SSCT ', '', tax_description, 0
from invoicedetail invd, invoiceabstract inva,Tax  T
where         
(inva.status & 128 )=0 and        
inva.invoicedate between @FromDate and @ToDate and 
inva.invoiceid = invd.invoiceid and 
invd.taxcode2 <> 0 and         
invd.taxid=t.tax_code and 
saleid=2 And
tax_description Not In
(select distinct tax_description
from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, Tax 
where         
(ia.status & 128 )=0 and        
ia.invoicedate between @FromDate and @ToDate and 
ia.invoiceid = idt.invoiceid and 
idt.taxcode2 <> 0 and         
itc.invoiceid=idt.invoiceid and         
itc.invoiceid=ia.invoiceid and        
idt.product_code=itc.product_code and         
idt.taxid=itc.tax_code and         
itc.tax_code = tax.tax_code and         
tcd.taxcomponent_code = itc.tax_component_code and 
saleid=2)

Declare SalesTaxComponents cursor        
for  
Select * From @TaxPayable

Set @PrevTaxDesc = N''
open SalesTaxComponents        
fetch next from SalesTaxComponents into @Prefix, @sComponentName, @TaxDesc, @TmpTaxCompCode        
while @@FETCH_STATUS=0        
begin        
	-- Cummulative column
	If (@TaxDesc <> @PrevTaxDesc) And (@TaxDesc <> N'') --And (@BreakupFlag = 1)
	Begin
		Set @s = 'alter table #SalesTaxPayableTemp add ['+@Prefix + rtrim(@TaxDesc) + N' (%c)] decimal(18,6)'        
		exec sp_executesql @s        
	End
	
	-- Tax split up column
	If (@TaxDesc <> N'') And (@sComponentName <> N'') And (@BreakupFlag = 1)
	Begin
		Set @s = 'alter table #SalesTaxPayableTemp add ['+@Prefix + rtrim(@sComponentName)+ '_of_'+ @TaxDesc +' (%c)] decimal(18,6)'
		exec sp_executesql @s        
	End
	
	-- Other total values
	If @TaxDesc = N''
	Begin
		Set @s = 'alter table #SalesTaxPayableTemp add ['+@Prefix + rtrim(@sComponentName)+ ' (%c)] decimal(18,6)'
		exec sp_executesql @s        
	End
	Set @PrevTaxDesc = @TaxDesc     
	fetch next from SalesTaxComponents into @Prefix, @sComponentName, @TaxDesc, @TmpTaxCompCode        
end        
       
close SalesTaxComponents        
deallocate SalesTaxComponents        
    
Select Distinct InvoiceID, Product_Code, SaleID, TaxID, TaxCode, TaxCode2 Into #InvDet From InvoiceDetail 
Where InvoiceID in (Select InvoiceID From InvoiceAbstract Where IsNull(Status,0) & 128 = 0 And 
InvoiceDate Between @FromDate and @ToDate)

declare SalesTaxComponentsUpdate cursor        
for         
select STP.invoiceid, tcd.taxcomponent_desc, case when sum(case when ia.InvoiceType in (4,5,6) then 0-tax_value else tax_value end)=0 then null else sum(case when ia.InvoiceType In (4,5,6) then 0-tax_value else tax_value end) end,  
(Case When (idt.taxcode <> 0) Then 1 When (idt.taxcode2 <> 0) Then 2 End), idt.saleid, tax_description  
from #SalesTaxPayableTemp STP , invoicetaxcomponents itc, invoiceabstract ia, #InvDet idt, taxcomponentdetail tcd, tax 
where        
(ia.status & 128) = 0 and    
ia.InvoiceDate Between @FromDate and @ToDate and 
ia.InvoiceID = idt.InvoiceID and 
stp.invoiceid=itc.invoiceid and         
ia.invoiceid=itc.invoiceid and         
idt.invoiceid=itc.invoiceid and     
idt.Product_Code = itc.Product_Code and    
(idt.TaxCode <> 0 or idt.TaxCode2 <> 0) And 
idt.taxid=itc.tax_code and        
itc.tax_code = tax.tax_code and 
tcd.taxcomponent_code=itc.tax_component_code and        
idt.product_code=itc.product_code 
group by STP.invoiceid, tcd.taxcomponent_desc, SaleID, tax_description, idt.taxcode, idt.taxcode2 --, Locality        

open SalesTaxComponentsUpdate        
fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @TaxDesc        
        
while @@FETCH_STATUS=0        
begin        
	if isnull(@Locality,1) = 1 and @SaleID = 1        
	begin        
		If @BreakupFlag = 1
			set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [FSLT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #Sales
TaxPayableTemp where invoiceid=' + @invoiceid
		Else
			set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+  N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
--			set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid='+@invoiceid        
	end        
	else if isnull(@Locality,1) = 2 and @SaleID = 1        
	begin   
		If @BreakupFlag = 1
			set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [FSCT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #Sales
TaxPayableTemp where invoiceid=' + @invoiceid
		Else     
			set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+  N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
--			set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
	end        
	else if isnull(@Locality,1) = 1 and @SaleID = 2        
	begin   
		If @BreakupFlag = 1
			set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [SSLT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #Sales
TaxPayableTemp where invoiceid=' + @invoiceid
		Else     
			set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
--			set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
	end        
	else if isnull(@Locality,1) = 2 and @SaleID = 2        
	begin        
		If @BreakupFlag = 1
			set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [SSCT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #Sales
TaxPayableTemp where invoiceid=' + @invoiceid
		Else     
			set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
--			set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
	end        
	exec sp_executesql @s        
	fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @TaxDesc        
end        
close SalesTaxComponentsUpdate        
deallocate SalesTaxComponentsUpdate        

-- Imported tax handled
Declare SalesTaxComponentsUpdate cursor        
for         
select STP.invoiceid, '', case when sum(case when ia.InvoiceType in (4,5,6) then 0-(STPayable+CSTPayable) else (STPayable+CSTPayable) end)=0 then null else sum(case when ia.InvoiceType In (4,5,6) then 0-(STPayable+CSTPayable) else (STPayable+CSTPayable) end) end,  
(Case When (idt.taxcode <> 0) Then 1 When (idt.taxcode2 <> 0) Then 2 End), idt.saleid, tax_description  
from #SalesTaxPayableTemp STP , invoiceabstract ia, InvoiceDetail idt, tax 
where        
(ia.status & 128) = 0 and    
ia.InvoiceDate Between @FromDate and @ToDate and 
ia.InvoiceID = idt.InvoiceID and 
stp.invoiceid=ia.invoiceid and         
idt.taxid=tax.tax_code and 
(idt.TaxCode <> 0 or idt.TaxCode2 <> 0) And 
tax_description  Not In
(select Distinct tax_description  
from #SalesTaxPayableTemp STPX, invoicetaxcomponents itc, invoiceabstract inva, #InvDet invdt, taxcomponentdetail tcd, tax 
where        
(inva.status & 128) = 0 and    
inva.InvoiceDate Between @FromDate and @ToDate and 
inva.InvoiceID = invdt.InvoiceID and 
stpX.invoiceid=itc.invoiceid and         
inva.invoiceid=itc.invoiceid and         
invdt.invoiceid=itc.invoiceid and     
invdt.Product_Code = itc.Product_Code and    
invdt.taxid=itc.tax_code and  
(invdt.TaxCode <> 0 or invdt.TaxCode2 <> 0) And       
itc.tax_code = tax.tax_code and 
tcd.taxcomponent_code=itc.tax_component_code and        
invdt.product_code=itc.product_code 
)
group by STP.invoiceid, SaleID, tax_description, idt.taxcode, idt.taxcode2 --, Locality        

open SalesTaxComponentsUpdate        
fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @TaxDesc        
        
while @@FETCH_STATUS=0        
begin        
	if isnull(@Locality,1) = 1 and @SaleID = 1        
	begin        
-- 		If @BreakupFlag = 1
-- 			set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [FSLT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
-- 		Else
			set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+  N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
--			set @s = N'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid='+@invoiceid        
	end        
	else if isnull(@Locality,1) = 2 and @SaleID = 1        
	begin   
-- 		If @BreakupFlag = 1
-- 			set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [FSCT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
-- 		Else     
			set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+  N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
--			set @s = N'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
	end        
	else if isnull(@Locality,1) = 1 and @SaleID = 2        
	begin   
-- 		If @BreakupFlag = 1
-- 			set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [SSLT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
-- 		Else     
			set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
--			set @s = N'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
	end        
	else if isnull(@Locality,1) = 2 and @SaleID = 2        
	begin        
-- 		If @BreakupFlag = 1
-- 			set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [SSCT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
-- 		Else     
			set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
--			set @s = N'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxComp)+N'_of_'+ @TaxDesc +' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #SalesTaxPayableTemp where invoiceid=' + @invoiceid
	end        
	exec sp_executesql @s        
	fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @TaxDesc        
end        
close SalesTaxComponentsUpdate        
deallocate SalesTaxComponentsUpdate        
----****************

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

-- If @BreakupFlag = 1
-- Begin    
update STP set [SS Total (%c)]= (    
 select sum(case when ia.InvoiceType in (4,5,6) THEN 0-amount else amount end)     
 from invoicedetail idt, invoiceabstract ia    
 where stp.invoiceid=idt.invoiceid  and (idt.TaxCode <> 0 or idt.TaxCode2 <> 0) AND saleid=2 and stp.invoiceid=ia.invoiceid)    
 from #SalesTaxPayableTemp STP     
-- End
-- Else
-- Begin
-- update STP set [SS Total (%c)]= (    
--  select sum(case when ia.InvoiceType in (4,5,6) THEN 0-amount else amount end)     
--  from invoicedetail idt, invoiceabstract ia    
--  where stp.invoiceid=idt.invoiceid and saleid=2 and stp.invoiceid=ia.invoiceid)    
--  from #SalesTaxPayableTemp STP     
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
 GSTOut:    
end   
