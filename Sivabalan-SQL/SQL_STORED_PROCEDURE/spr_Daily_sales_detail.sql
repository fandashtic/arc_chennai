create procedure spr_Daily_sales_detail (@DateSale datetime)      
As    
begin    
     
declare @InvoiceID int    
declare @InvoiceType nvarchar(10)    
declare @Locality nvarchar(10)    
declare @TaxValue decimal(18,6)    
declare @Prefix nvarchar(50)    
declare @TaxCompDesc nvarchar(50)    
declare @Query nvarchar(4000)    
declare @SaleID nvarchar(10)    
Declare @RETAILSALESRETURNSALEABLE As NVarchar(50)
Declare @RETAILSALESRETURNDAMAGES As NVarchar(50)
Declare @SALESRETURNSALEABLE As NVarchar(50)
Declare @SALESRETURNDAMAGES As NVarchar(50)
Declare @RETAILINVOICE As NVarchar(50)
Declare @INVOICE As NVarchar(50)

Set @RETAILSALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'Retail Sales Return Saleable', Default)
Set @RETAILSALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'Retail Sales Return Damages', Default)
Set @SALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'Sales Return Saleable', Default)
Set @SALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'Sales Return Damages', Default)
Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice' , Default)
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)
    
Select "InvoiceID" = invoiceid,     
"Invoice ID" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),      
 "Doc Reference"=DocReference,      
 "Type" = case InvoiceType      
WHEN 5 THEN       
@RETAILSALESRETURNSALEABLE     
WHEN 6 THEN       
@RETAILSALESRETURNDAMAGES     
WHEN 4 THEN       
 Case Status & 32      
 When 0 Then      
@SALESRETURNSALEABLE      
 Else      
@SALESRETURNDAMAGES     
 End      
WHEN 2 THEN @RETAILINVOICE      
ELSE @INVOICE      
END,      
 "Goods Value (%c)" = Case       
 When InvoiceType>=4 and InvoiceType<=6 Then      
 0 - IsNull(InvoiceAbstract.GoodsValue, 0)      
 Else      
 IsNull(InvoiceAbstract.GoodsValue, 0)      
 End,      
 "Goods Value (First Sale) (%c)"= convert(decimal(18,6),N'0'),    
 "Goods Value (Second Sale) (%c)"= convert(decimal(18,6),N'0'),    
 "Tax Suffered (%c)" = Case   
 When InvoiceType>=4 and InvoiceType<=6  Then      
 0 - IsNull(InvoiceAbstract.TotalTaxSuffered, 0)      
 Else      
 IsNull(InvoiceAbstract.TotalTaxSuffered, 0)      
 End,      
 "Productwise Discount (%c)" = case when InvoiceType>=4 and InvoiceType<=6      
        then 0-IsNull(ProductDiscount, 0)     
        else IsNull(ProductDiscount, 0) end,    
 "Discount (%c)" = Case   
 When InvoiceType>=4 and InvoiceType<=6  Then      
 0 - (IsNull(DiscountValue, 0) + IsNull(AddlDiscountValue, 0) )      
 Else      
 (IsNull(DiscountValue, 0) + IsNull(AddlDiscountValue, 0) )      
 End,      
 "Tax Applicable (%c)" = Case       
 When InvoiceType>=4 and InvoiceType<=6  Then      
 0 - IsNull(InvoiceAbstract.TotalTaxApplicable, 0)      
 Else      
 IsNull(InvoiceAbstract.TotalTaxApplicable, 0)      
 End      
into #DailySalesDetails    
FROM  InvoiceAbstract, VoucherPrefix      
WHERE  (InvoiceAbstract.Status & 128) = 0 AND      
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) = @DateSale AND       
 VoucherPrefix.TranID = N'INVOICE' AND      
 InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6)      
    
    
    
declare DailySalesReport cursor    
for    
select distinct N'Total LT on FS',N''    
union all    
select distinct N'ltfs ',tcd.taxcomponent_desc from     
invoicetaxcomponents itc
Inner Join invoicedetail idt On itc.invoiceid=idt.invoiceid and idt.product_code=itc.product_code and idt.taxid=itc.tax_code 
Inner Join invoiceabstract ia On itc.invoiceid=ia.invoiceid 
Inner Join taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code 
Left Outer Join customer c On ia.customerid=c.customerid where    
dbo.stripdatefromtime(ia.invoicedate) = @DateSale and    
(ia.status & 128 )=0 and          
isnull(c.locality,1)=1 and    
idt.saleid=1    
union all    
select N'Total CT on FS',N''    
union all    
select distinct N'CTFS ',tcd.taxcomponent_desc from  
invoicetaxcomponents itc
Inner Join  invoicedetail idt On itc.invoiceid=idt.invoiceid and idt.product_code=itc.product_code and idt.taxid=itc.tax_code 
Inner Join invoiceabstract ia On itc.invoiceid=ia.invoiceid 
Inner Join taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code 
Left Outer Join customer c On ia.customerid=c.customerid 
where    
dbo.stripdatefromtime(ia.invoicedate)=@DateSale and    
(ia.status & 128 )=0 and          
isnull(c.locality,1)=2 and    
idt.saleid=1    
union all    
select N'Total LT on SS',N''    
union all    
select distinct N'LTSS ',tcd.taxcomponent_desc from     
invoicetaxcomponents itc
Inner Join invoicedetail idt On itc.invoiceid=idt.invoiceid and idt.product_code=itc.product_code and idt.taxid=itc.tax_code
Inner Join invoiceabstract ia On itc.invoiceid=ia.invoiceid 
Inner Join taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code 
Left Outer Join customer c On ia.customerid=c.customerid
where  
dbo.stripdatefromtime(ia.invoicedate) =@DateSale  and    
(ia.status & 128 )=0 and          
isnull(c.locality,1)=1 and    
idt.saleid=2    
union all    
select N'Total CT on SS',N''    
union all    
select distinct N'CTSS ',tcd.taxcomponent_desc from     
invoicetaxcomponents itc
Inner Join invoicedetail idt On itc.invoiceid=idt.invoiceid and  idt.product_code=itc.product_code and idt.taxid=itc.tax_code
Inner Join invoiceabstract ia On itc.invoiceid=ia.invoiceid 
Inner Join taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code 
Left Outer Join customer c On ia.customerid=c.customerid
where    
dbo.stripdatefromtime(ia.invoicedate)=@DateSale  and    
(ia.status & 128 )=0 and          
isnull(c.locality,1)=2 and    
idt.saleid=2    
union all    
select N'Net Sales',N''    
    
open DailySalesReport    
fetch next from DailySalesReport into @Prefix, @TaxCompDesc     
while @@FETCH_STATUS=0    
begin    
 set @Query = N'alter table #DailySalesDetails add ['+@Prefix+rtrim(@TaxCompDesc)+N' (%c)] decimal(18,6)'    
 exec sp_executesql @Query
 fetch next from DailySalesReport into @Prefix, @TaxCompDesc     
end    
    
close DailySalesReport    
deallocate DailySalesReport    
    
    
declare DailySalesReport cursor     
for    

Select ia.invoiceid, tcd.taxcomponent_desc, isnull(locality,1), saleid, 
    sum( case when ia.invoicetype >= 4 and ia.invoicetype <= 6 then 0 - tax_value else tax_value end) 
from 
( select distinct iabs.invoiceid as invoiceid, idt.product_code as product_code, idt.taxid as taxid, 
    idt.saleid as saleid
    from invoiceabstract iabs, invoicedetail idt 
    where iabs.invoiceid = idt.invoiceid and 
        dbo.stripdatefromtime(iabs.invoicedate) = @DateSale and 
        (iabs.status & 128)=0
) Invoice 
Inner Join invoiceabstract ia On Invoice.invoiceid = ia.invoiceid 
Inner Join invoicetaxcomponents itc On itc.invoiceid = Invoice.invoiceid and itc.tax_code=Invoice.taxid and itc.product_code=Invoice.product_code 
Inner Join taxcomponentdetail tcd On tcd.taxcomponent_code = itc.tax_component_code 
Left Outer Join customer c On ia.customerid=c.customerid               
Group By ia.invoiceid,tcd.Taxcomponent_desc, locality, saleid        
  
open DailySalesReport    
fetch next from DailySalesReport into @InvoiceID, @TaxCompDesc, @locality, @SaleID, @TaxValue    
while @@FETCH_STATUS = 0    
begin    
    
 if isnull(@Locality,1) = 1    
  set @Prefix = N'LT'    
 else    
  set @Prefix = N'CT'    
    
 if @SaleID = 1    
  set @Prefix = @Prefix + N'FS '    
 else    
  set @Prefix = @Prefix + N'SS '    

if @TaxValue = 0 set @TaxValue = null    

if exists(Select a.name from Tempdb.dbo.Sysobjects A, Tempdb.dbo.SysColumns b 
    Where a.id = b.id and a.name like N'#DailySalesDetails%' 
    and b.Name like @Prefix+rtrim(@TaxCompDesc)+ N' (%c)' )
Begin
     set @Query = N'update #DailySalesDetails     
     set ['+@Prefix+rtrim(@TaxCompDesc)+N' (%c)]=('+convert(nvarchar,@TaxValue)+N')      
     where InvoiceID='''+convert(nvarchar,@InvoiceID)+''''    
	 exec sp_executesql @Query
end    
  fetch next from DailySalesReport into @InvoiceID, @TaxCompDesc, @locality, @SaleID, @TaxValue    
end    
close DailySalesReport    
deallocate DailySalesReport    
    
    
update DSD set [Goods Value (First Sale) (%c)]=    
(select sum(case when InvoiceType>=4 and InvoiceType<=6 then 0-(Quantity * SalePrice) 
    else (Quantity * SalePrice) end) from invoicedetail idt, invoiceabstract ia     
where     
ia.invoiceid=dsd.invoiceid and     
idt.invoiceid=ia.invoiceid and     
(status & 128) =0 and     
saleid=1    
)    
from #DailySalesDetails DSD    
    
update DSD set [Goods Value (Second Sale) (%c)]=    
(select sum(case when InvoiceType>=4 and InvoiceType<=6 then 0-(Quantity * SalePrice) 
    else (Quantity * SalePrice) end) from invoicedetail idt, invoiceabstract ia     
where     
ia.invoiceid=dsd.invoiceid and  
idt.invoiceid=ia.invoiceid and     
(status & 128) =0 and     
saleid=2    
)    
from #DailySalesDetails DSD    
    
    
update DSD set [Total LT on FS (%c)]=    
(select sum(case when InvoiceType>=4 and InvoiceType<=6 then 0-stpayable else stpayable end) 
    from invoicedetail idt, invoiceabstract ia     
where     
ia.invoiceid=dsd.invoiceid and     
idt.invoiceid=ia.invoiceid and (status & 128) =0 and     
saleid=1    
)    
from #DailySalesDetails DSD    
    
update DSD set [Total CT on FS (%c)]=    
(select sum(case when InvoiceType>=4 and InvoiceType<=6 then 0-cstpayable else cstpayable end) 
    from invoicedetail idt, invoiceabstract ia     
where     
ia.invoiceid=dsd.invoiceid and     
idt.invoiceid=ia.invoiceid and     
(status & 128) =0 and     
saleid=1    
)    
from #DailySalesDetails DSD    
    
update DSD set [Total LT on SS (%c)]=    
(select sum(case when InvoiceType>=4 and InvoiceType<=6 then 0-stpayable else stpayable end) 
    from invoicedetail idt, invoiceabstract ia     
where     
ia.invoiceid=dsd.invoiceid and     
idt.invoiceid=ia.invoiceid and     
(status & 128) =0 and     
saleid=2    
)    
from #DailySalesDetails DSD    
    
update DSD set [Total CT on SS (%c)]=    
(select sum(case when InvoiceType>=4 and InvoiceType<=6 then 0-cstpayable else cstpayable end) 
    from invoicedetail idt, invoiceabstract ia     
where     
ia.invoiceid=dsd.invoiceid and     
idt.invoiceid=ia.invoiceid and     
(status & 128) =0 and     
saleid=2    
)    
from #DailySalesDetails DSD    
    
update DSD set [Net Sales (%c)] = (    
 case     
  when InvoiceType>=4 and InvoiceType<=6 then 0-(NetValue - IsNull(Freight, 0))    
  else NetValue - IsNull(Freight, 0)     
 end)    
from #DailySalesDetails DSD, invoiceabstract ia    
where    
dsd.invoiceid = ia.invoiceid and (ia.status & 128) = 0     
    
update #DailySalesDetails set [Total LT on FS (%c)]=null where [Total LT on FS (%c)]=0    
update #DailySalesDetails set [Total CT on FS (%c)]=null where [Total CT on FS (%c)]=0    
update #DailySalesDetails set [Total LT on SS (%c)]=null where [Total LT on SS (%c)]=0    
update #DailySalesDetails set [Total CT on SS (%c)]=null where [Total CT on SS (%c)]=0    
update #DailySalesDetails set [Net Sales (%c)]=null where [Net Sales (%c)]=0    
update #DailySalesDetails set [Tax Suffered (%c)]=null where [Tax Suffered (%c)]=0    
    
select * from #DailySalesDetails    
    
drop table #DailySalesDetails    
    
end    
