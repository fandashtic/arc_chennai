CREATE Procedure spr_Daily_sales (@FROMDATE DATETIME, @TODATE DATETIME)                  
As                  
Begin                
                
Set DateFormat DMY          
                
Declare @InvoiceDate DateTime                
Declare @InvoiceType NVarchar(10)                
Declare @Locality NVarchar(10)                
Declare @TaxValue Decimal(18,6)                
Declare @Prefix Varchar(50)                
Declare @TaxCompDesc NVarchar(50)                
Declare @Query Nvarchar(4000)                
Declare @SaleID NVarchar(10)                
                
Select "InvDate" =dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),                  
"InvoiceDate" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),                  
"Goods Value(Sales) (%c)" = Convert(Decimal(18,6),'0'),                  
"Goods Value (First Sale) (%c)"= Convert(Decimal(18,6),'0'),                
"Goods Value (Second Sale) (%c)"= Convert(Decimal(18,6),'0'),                
"Goods Value(Sales Return Damages) (%c)" = Sum(Case InvoiceType                  
When 4 Then                  
Case Status & 32                   
When 0 Then                  
0                  
Else                  
IsNull(GoodsValue, 0)                  
End                  
when 6 Then                
IsNull(GoodsValue, 0)                
Else                  
0                  
End),                  
"Goods Value(Sales Return Saleable) (%c)" = Sum(Case InvoiceType                  
When 5 Then                  
IsNull(GoodsValue, 0)                  
When 4 Then                  
 Case Status & 32                   
 When 0 Then                  
 IsNull(GoodsValue, 0)                  
 Else                  
 0                  
 End                  
Else                  
0                  
End),                  
"Total Tax Suffered (%c)" = Sum(Case InvoiceType                  
When 4 Then                  
0 - IsNull(TotalTaxSuffered, 0)                  
When 5 Then                  
0 - IsNull(TotalTaxSuffered, 0)                  
When 6 Then                  
0 - IsNull(TotalTaxSuffered, 0)                  
Else                  
IsNull(TotalTaxSuffered, 0)                  
End),                  
"Productwise Discount (%c)" = sum(case InvoiceType                 
       when 4 then 0-IsNull(ProductDiscount, 0)                 
       when 5 then 0-IsNull(ProductDiscount, 0)                 
       when 6 then 0-IsNull(ProductDiscount, 0)                 
       else IsNull(ProductDiscount, 0) end),                
"Total Discount (%c)" = Sum(Case InvoiceType                  
When 4 Then                  
0 - (IsNull(DiscountValue, 0) + IsNull(AddlDiscountValue, 0) )                  
When 5 Then                  
0 - (IsNull(DiscountValue, 0) + IsNull(AddlDiscountValue, 0) )                  
When 6 Then                  
0 - (IsNull(DiscountValue, 0) + IsNull(AddlDiscountValue, 0) )                  
Else                  
(IsNull(DiscountValue, 0) + IsNull(AddlDiscountValue, 0) )                  
End),                  
"Total Tax Applicable (%c)" = Sum(Case InvoiceType                  
When 4 Then                  
0 - IsNull(TotalTaxApplicable, 0)                  
When 5 Then                  
0 - IsNull(TotalTaxApplicable, 0)                  
When 6 Then                  
0 - IsNull(TotalTaxApplicable, 0)                  
Else                  
IsNull(TotalTaxApplicable, 0)                  
End)                  
into #DailySalesAbstract                
From InvoiceAbstract                  
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And                  
InvoiceAbstract.Status & 128 = 0 And                  
InvoiceType in (1, 2, 3, 4, 5,6)                  
Group By dbo.StripDateFromTime(InvoiceDate)                
order by dbo.StripDateFromTime(InvoiceDate)                  
                
    
          
Declare DailySalesReport CURSOR    
For        
Select Distinct N'Total LT on FS',N''        
Union All        
Select Distinct N'LTFS ',tcd.taxcomponent_desc From         
invoicetaxcomponents itc
Inner Join invoicedetail idt On itc.invoiceid=idt.invoiceid and  idt.product_code=itc.product_code and idt.taxid=itc.tax_code 
Inner Join invoiceabstract ia On itc.invoiceid=ia.invoiceid
Inner Join taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code 
Left Outer Join customer c On ia.customerid=c.customerid 
Where ia.invoicedate between @FromDate and @ToDate  and        
(ia.status & 128 )=0 and        
isnull(c.locality,1)=1 and        
idt.saleid=1        
Union All        
Select N'Total CT on FS',N''        
Union All        
Select Distinct N'CTFS ',tcd.taxcomponent_desc From         
invoicetaxcomponents itc
Inner Join invoicedetail idt On itc.invoiceid=idt.invoiceid and idt.product_code=itc.product_code and idt.taxid=itc.tax_code 
Inner Join invoiceabstract ia On itc.invoiceid=ia.invoiceid 
Inner Join taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code
Left Outer Join customer c On ia.customerid=c.customerid 
Where 
ia.invoicedate between @FromDate and @ToDate and               
(ia.status & 128 )=0 and              
isnull(c.locality,1)=2 and        
idt.saleid=1        
Union All        
Select N'Total LT on SS',N''        
Union All        
Select Distinct N'LTSS ',tcd.taxcomponent_desc From         
invoicetaxcomponents itc
Inner Join invoicedetail idt On itc.invoiceid=idt.invoiceid and idt.product_code=itc.product_code and idt.taxid=itc.tax_code 
Inner Join invoiceabstract ia On itc.invoiceid=ia.invoiceid 
Inner Join taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code 
Left Outer Join customer c On ia.customerid=c.customerid
Where        
ia.invoicedate between @FromDate and @ToDate and               
(ia.status & 128 )=0 and              
isnull(c.locality,1)=1 and        
idt.saleid=2        
Union All        
Select N'Total CT on SS',N''        
Union All        
Select Distinct N'CTSS ',tcd.taxcomponent_desc From         
invoicetaxcomponents itc
Inner Join invoicedetail idt On itc.invoiceid=idt.invoiceid and idt.product_code=itc.product_code and  idt.taxid=itc.tax_code 
Inner Join invoiceabstract ia On itc.invoiceid=ia.invoiceid 
Inner Join taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code 
Left Outer Join customer c On ia.customerid=c.customerid 
Where        
ia.invoicedate between @FromDate and @ToDate and               
(ia.status & 128 )=0 and              
isnull(c.locality,1)=2 and        
idt.saleid=2        
Union All        
Select N'Net Sales',N''        
        
Open DailySalesReport        
Fetch Next From DailySalesReport Into @Prefix, @TaxCompDesc         
While @@FETCH_STATUS=0        
Begin    
 Set @Query = N'alter table #DailySalesAbstract add ['+@Prefix+rtrim(@TaxCompDesc)+N' (%c)] decimal(18,6)'    
 Exec sp_executesql @Query    
 Fetch Next From DailySalesReport Into @Prefix, @TaxCompDesc     
End    
      
Close DailySalesReport        
Deallocate DailySalesReport        
 
        
Declare DailySalesReport CURSOR    
For        
Select dbo.stripdatefromtime(ia.invoicedate), tcd.taxcomponent_desc, isnull(locality,1), saleid, 
    sum( case when ia.invoicetype >= 4 and ia.invoicetype <= 6 then 0 - tax_value else tax_value end) 
from 
( select distinct iabs.invoiceid as invoiceid, idt.product_code as product_code, idt.taxid as taxid, idt.saleid as saleid
    from invoiceabstract iabs, invoicedetail idt 
    where iabs.invoiceid = idt.invoiceid and 
        iabs.invoicedate between @FromDate and @ToDate and 
    (iabs.status & 128)=0
) Invoice 
Inner Join invoiceabstract ia On Invoice.invoiceid = ia.invoiceid 
Inner Join invoicetaxcomponents itc On itc.invoiceid = Invoice.invoiceid and itc.tax_code=Invoice.taxid and itc.product_code=Invoice.product_code 
Inner Join taxcomponentdetail tcd On tcd.taxcomponent_code = itc.tax_component_code
Left Outer Join customer c On ia.customerid=c.customerid                
Group By dbo.stripdatefromtime(ia.invoicedate),tcd.Taxcomponent_desc, locality, saleid        

        
Open DailySalesReport        
Fetch Next From DailySalesReport Into @InvoiceDate, @TaxCompDesc, @locality, @SaleID, @TaxValue        
While @@FETCH_STATUS = 0        
Begin        
         
 If isnull(@Locality,1) = 1        
  Set @Prefix = N'LT'        
 Else        
  Set @Prefix = N'CT'        
        
 If @SaleID = 1        
  Set @Prefix = @Prefix + N'FS '        
 Else        
  Set @Prefix = @Prefix + N'SS '        
        
 If @TaxValue = 0 Set @TaxValue = null        
 If exists(Select a.name from Tempdb.dbo.Sysobjects A, Tempdb.dbo.SysColumns b 
    Where a.id = b.id and a.name like N'#DailySalesAbstract%' 
    and b.Name like @Prefix+rtrim(@TaxCompDesc)+ N' (%c)' )    
 Begin    
    Set @Query = N'update #DailySalesAbstract         
    set ['+@Prefix+rtrim(@TaxCompDesc)+N' (%c)]=('+convert(nvarchar,@TaxValue)+')          
    where InvoiceDate='''+convert(nvarchar,dbo.stripdatefromtime(@InvoiceDate))+''''        
 Exec sp_executesql @Query
 End        
      
Fetch Next From DailySalesReport Into @InvoiceDate, @TaxCompDesc, @locality, @SaleID, @TaxValue        
End        
Close DailySalesReport        
Deallocate DailySalesReport        

Declare @temp table(InvDate DateTime,S Decimal(18,6),LT Decimal(18,6),CT Decimal(18,6),SaleId NVarchar(10))
      
-- Select "InvDate" = dbo.StripDateFromTime(InvoiceDate),    
-- "S"= Sum(Case When InvoiceType >= 4 And InvoiceType <= 6 Then 0-(Quantity * SalePrice) Else (Quantity * SalePrice) End),      
-- "LT"= Sum(Case When InvoiceType >= 4 And InvoiceType <= 6 Then 0 - stpayable Else stpayable End),      
-- "CT"= Sum(Case When InvoiceType >= 4 And InvoiceType <= 6 Then 0 - Cstpayable Else cstpayable End),      
-- "SaleId" = SaleId Into @temp     
-- From InvoiceDetail idt, InvoiceAbstract ia               
-- Where idt.invoiceid=ia.invoiceid And (status & 128) =0     
-- And invoicedate Between  @Fromdate And @Todate     
-- Group By dbo.StripDateFromTime(InvoiceDate),SaleId      
Insert into @temp
Select "InvDate" = dbo.StripDateFromTime(InvoiceDate),    
"S"= Sum(Case When InvoiceType >= 4 And InvoiceType <= 6 Then 0-(Quantity * SalePrice) Else (Quantity * SalePrice) End),      
"LT"= Sum(Case When InvoiceType >= 4 And InvoiceType <= 6 Then 0 - stpayable Else stpayable End),      
"CT"= Sum(Case When InvoiceType >= 4 And InvoiceType <= 6 Then 0 - Cstpayable Else cstpayable End),      
"SaleId" = SaleId 
From InvoiceDetail idt, InvoiceAbstract ia               
Where idt.invoiceid=ia.invoiceid And (status & 128) =0     
And invoicedate Between  @Fromdate And @Todate     
Group By dbo.StripDateFromTime(InvoiceDate),SaleId        

Update DSA Set [Goods Value(Sales) (%c)]=              
(Select Sum(S) From @temp TMP Where TMP.InvDate = DSA.InvoiceDate),    
[Goods Value (First Sale) (%c)]=              
(Select Sum(S) From @temp TMP Where TMP.InvDate = DSA.InvoiceDate And SaleId =1),    
[Goods Value (Second Sale) (%c)]=              
(Select Sum(S) From @temp TMP Where TMP.InvDate = DSA.InvoiceDate And SaleId = 2),              
[Total LT on FS (%c)]=              
(Select Sum(LT) From @temp TMP Where TMP.InvDate = DSA.InvoiceDate And SaleId = 1),    
[Total LT on SS (%c)]=              
(Select Sum(LT) From @temp TMP Where TMP.InvDate = DSA.InvoiceDate And SaleId = 2),    
[Total CT on FS (%c)]=              
(Select Sum(CT) From @temp TMP Where TMP.InvDate = DSA.InvoiceDate And SaleId = 1),    
[Total CT on SS (%c)]=              
(Select Sum(CT) From @temp TMP Where TMP.InvDate = DSA.InvoiceDate And SaleId = 2)              
from #DailySalesAbstract DSA              
     
Update DSA set [Net Sales (%c)] =               
(select sum(case           
  when invoicetype >= 4 and invoicetype <= 6 then 0-(NetValue - IsNull(Freight, 0))              
  else NetValue - IsNull(Freight, 0)               
 end) from invoiceabstract ia               
 where dsa.invoicedate = dbo.stripdatefromtime(ia.invoicedate) and (ia.status & 128) = 0)              
from #DailySalesAbstract dsa, invoiceabstract ia              
where              
dsa.invoicedate = dbo.stripdatefromtime(ia.invoicedate)              
    
update #DailySalesAbstract set [Total LT on FS (%c)]=null where [Total LT on FS (%c)]=0            
update #DailySalesAbstract set [Total CT on FS (%c)]=null where [Total CT on FS (%c)]=0            
update #DailySalesAbstract set [Total LT on SS (%c)]=null where [Total LT on SS (%c)]=0            
update #DailySalesAbstract set [Total CT on SS (%c)]=null where [Total CT on SS (%c)]=0            
update #DailySalesAbstract set [Net Sales (%c)]=null where [Net Sales (%c)]=0            
      
select * from #DailySalesAbstract                
               
drop table #DailySalesAbstract                

end                
