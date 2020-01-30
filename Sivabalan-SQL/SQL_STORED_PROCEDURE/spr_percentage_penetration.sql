CREATE PROCEDURE spr_percentage_penetration (@ProductHierarchy nvarchar(255),      
            @Category nvarchar(2550),      
               @FromDate datetime,      
         @ToDate datetime)        
As      
      
declare @TotalCustomer Decimal(18,6)      
declare @IndividualCust Decimal(18,6)      
declare @CustomerPer Decimal(18,6)      
declare @AlterSql nvarchar(4000)      
declare @ItemName nvarchar(255)      
declare @BeatName nvarchar(255)      
declare @ColName nvarchar(255)      
declare @Beat nvarchar(255)      
declare @OverallCustPer Decimal(18,6)      
declare @OverallTotalCust Decimal(18,6)      
declare @OverallPer Decimal(18,6)      
Declare @TOTALCUSTOMERS As NVarchar(50)
Declare @PERCENTAGE As NVarchar(50)

Set @TOTALCUSTOMERS = dbo.LookupDictionaryItem(N'Total Customers', Default)
Set @PERCENTAGE = dbo.LookupDictionaryItem(N'Percentage', Default)
     
--Creating Temp table #TempCategory      
Create Table #TempCategory(CategoryID int, Status int)        
Exec GetLeafCategories @ProductHierarchy, @Category      
      
--Creating Temp table #Temp1        
Select distinct invoicedetail.product_code into #Temp1         
from invoicedetail,invoiceabstract,Items,ItemCategories         
where invoicedetail.product_code=items.product_code         
and invoicedetail.invoiceid=invoiceabstract.invoiceid         
and invoiceabstract.invoicetype in (1,3) And (status & 128) = 0         
And ItemCategories.CategoryID = Items.CategoryID         
And ItemCategories.CategoryID in (Select CategoryID from #TempCategory)         
And InvoiceAbstract.InvoiceDate BETWEEN @FromDate AND @ToDate         
and items.active =1         
        
    
--Creating Temp table #T1        
select invoicedetail.product_code,invoiceabstract.customerid,invoiceabstract.beatid,beat.description         
into #T1        
from invoiceabstract,invoicedetail,beat,items,ItemCategories         
where invoicedetail.invoiceid = invoiceabstract.invoiceid and         
invoiceabstract.beatid = beat.beatid        
and invoiceabstract.invoicetype in (1,3) And (status & 128) = 0         
And ItemCategories.CategoryID = Items.CategoryID         
And ItemCategories.CategoryID in (Select CategoryID from #TempCategory)         
And InvoiceAbstract.InvoiceDate BETWEEN @FromDate AND @ToDate         
and items.active =1         
        
--Creating Temp table #T3        
select "Beatname" = #T1.description Collate SQL_Latin1_General_CP1_CI_AS,#T1.beatid,#T1.product_code,        
"per" = (count(distinct customerid)/dbo.getBeatCustCnt(#T1.beatId) )*100,          
"OverallPer" = (dbo.getTotalBeatCustCnt(#T1.beatId,@FromDate,@ToDate)/dbo.getBeatCustCnt(#T1.beatId) )*100        
into #T3        
from #T1 group by #T1.beatid,#T1.product_code,#T1.description    
        
--Creating Temp table #Final        
Create table #Final(EmptyCol nvarchar(50) Collate SQL_Latin1_General_CP1_CI_AS,RowName nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS)        
Insert into #Final (RowName) values (@TOTALCUSTOMERS)        
Insert into #Final (RowName) values (@PERCENTAGE)        
        
select @TotalCustomer = count(*) from customer where active = 1        
        
--Creating Cursor to insert ItemName as columns and Percentage of Customers        
Declare getItems cursor for select product_code from #Temp1        
Open getItems        
Fetch from getItems into @ItemName        
while @@fetch_status = 0        
Begin        
 Set @AlterSql = N'Alter Table #Final Add [' + @ItemName +  N'] Decimal(18,6) null'             
 Exec sp_executesql @AlterSql            
        
  Set @AlterSql = N'Update #Final set ['+ @ItemName + N'] = ( select count(distinct customerid) from invoiceabstract,invoicedetail,#Final where invoicedetail.product_code = N''' +   
 @ItemName + ''' and invoicedetail.invoiceid = invoiceabstract.invoiceid And invoiceabstract.invoicetype in (1,3) And (status & 128) = 0 And InvoiceAbstract.InvoiceDate BETWEEN '''   
 + Cast(@FromDate as nvarchar) + ''' AND '''+ Cast(@ToDate as nvarchar) + ''' And #Final.RowName = ''Total Customers'' )'        
  Exec sp_executesql @AlterSql            
  
set @IndividualCust = (select count(distinct customerid) from invoiceabstract,invoicedetail where invoicedetail.product_code = '' + @ItemName + ''   
and invoicedetail.invoiceid = invoiceabstract.invoiceid And InvoiceAbstract.InvoiceDate BETWEEN @FromDate AND @ToDate)         
Set @CustomerPer =  (@IndividualCust / @TotalCustomer )*100        
        
  Set @AlterSql = N'Update #Final set ['+ @ItemName + N'] = ' + cast( @CustomerPer as nvarchar) + N' where RowName = ''Percentage'' '        
        
  Exec sp_executesql @AlterSql            
        
Fetch Next from getItems into @ItemName        
End        
        
close getItems        
Deallocate getItems        
     
--Creating Cursor to insert BeatName        
Declare getBeat cursor for select distinct Beatname from #T3        
Open getBeat        
Fetch from getBeat into @BeatName        
while @@fetch_status = 0        
Begin        
  Set @AlterSql = N'Insert into #Final (RowName) values (N''' + @BeatName + ''')'        
  Exec sp_executesql @AlterSql         
        
Fetch Next from getBeat into @BeatName        
End        
        
close getBeat        
Deallocate getBeat        
        
--Creating Cursor to insert PercentageSales across beat        
Declare setBeatPer cursor for select #T3.product_code,Beatname Collate SQL_Latin1_General_CP1_CI_AS from #T3,#Temp1 where #T3.product_code = #Temp1.product_code        
Open setBeatPer        
Fetch from setBeatPer into @ColName,@Beat        
while @@fetch_status = 0        
Begin        
  Set @AlterSql = N'Update #Final set ['+ @ColName + '] = (select #T3.per from #Final,#T3 where #Final.RowName = #T3.Beatname and #T3.Beatname = N'''   
+ @Beat + ''' and #T3.Product_code = N''' + @ColName + ''') where #Final.RowName = N''' + @Beat + ''''         
  
  Exec sp_executesql @AlterSql        
        
Fetch Next from setBeatPer into @ColName,@Beat        
End        
        
close setBeatPer        
Deallocate setBeatPer        
        
--Adding and updating values for Overall percentage column        
        
Set @AlterSql = N'Alter Table #Final Add [OverallValue] Decimal(18,6) null'             
Exec sp_executesql @AlterSql         
         
select @OverallTotalCust = count(distinct customerid) from invoiceabstract,invoicedetail where   
invoicedetail.invoiceid = invoiceabstract.invoiceid  And InvoiceAbstract.InvoiceDate BETWEEN @FromDate AND @ToDate and invoiceabstract.invoicetype in (1,3) And   
(status & 128) = 0      
  
set @OverallCustPer = (@OverallTotalCust/@TotalCustomer)*100        
        
Set @AlterSql = N'Update #Final set [OverallValue] = '   
+ cast(@OverallTotalCust as nvarchar) + N' where #Final.RowName = ''Total Customers'''        
Exec sp_executesql @AlterSql            
        
Set @AlterSql = N'Update #Final set [OverallValue] = '   
+ cast(@OverallCustPer as nvarchar) + N' where #Final.RowName = ''Percentage'''        
Exec sp_executesql @AlterSql            
        
--Creating Cursor to insert OverallPercentageSales across beat        
Declare setOverallBeatPer cursor for select Beatname Collate SQL_Latin1_General_CP1_CI_AS from #T3        
Open setOverallBeatPer        
Fetch from setOverallBeatPer into @Beat        
while @@fetch_status = 0        
Begin        
  Set @AlterSql = N'Update #Final set [OverallValue] = (select distinct(#T3.OverallPer) from #Final,#T3 where #Final.RowName = #T3.Beatname Collate SQL_Latin1_General_CP1_CI_AS and #T3.Beatname = N'' Collate SQL_Latin1_General_CP1_CI_AS'   
+ @Beat + ''' ) where #Final.RowName = N''' + @Beat + ''''         
  Exec sp_executesql @AlterSql        
        
Fetch Next from setOverallBeatPer into @Beat        
End        
        
close setOverallBeatPer        
Deallocate setOverallBeatPer        
        
select * from #Final        
drop table #Final        
drop table #Temp1        
drop table #T1        
drop table #T3   
  

