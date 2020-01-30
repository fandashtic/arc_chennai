CREATE procedure [dbo].[spr_get_BeatItemSales_pidilite]      
(        
 @ProdHierarchy nvarchar(255),         
 @SelectedCategory nvarchar(2550),        
 @Beats nVarchar(2550),       
 @UOM nvarchar(20),        
 @FromDate datetime,        
 @ToDate datetime         
)        
as         
begin        
--First version of thie report was named 'Beatwise Itemwise Sales'.        
--Then changed to 'Beatwise Categorywise Sales'.        
--BUT THE STORED PROCEDURE NAME REMAINS THE SAME (spr_get_BeatItemSales).        
declare @BeatID int,         
  @Beat nvarchar(510),         
  @CurrCategoryID int,         
  @CurrCategoryName nvarchar(510),         
  @Query nvarchar(4000),        
  @MappingInvoice nvarchar(1000),        
  @MappingDispatch nvarchar(1000)        
      
      
Declare @Delimeter as Char(1)            
Set @Delimeter=Char(15)            
Create table #tmpBeat(BeatID Int)            
      
if @Beats = N'%'            
   Insert into #tmpBeat select BeatID from Beat            
Else            
   Insert into #tmpBeat select BeatID From Beat Where Description In (select * from dbo.sp_SplitIn2Rows(@Beats, @Delimeter))      
      
Create Table #tempCategory (CategoryID int, Status int)                
Exec GetLeafCategories @ProdHierarchy, @SelectedCategory         
        
--Temp table to take Open DispatchAbstract for the given date, along with Beat        
create table #DispatchAbstractBeat        
(        
 DispatchID int,        
 CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,        
 DispatchDate datetime,        
 BeatID int,        
 Beat nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,        
 Status int        
)        
        
If @Beats = N'%'      
Begin      
insert into #DispatchAbstractBeat        
select distinct DA.DispatchID, DA.CustomerID, DA.DispatchDate, BS.BeatID,        
Isnull(cast((select Description from beat where beatid = BS.BeatID) as nvarchar),N'Others'), DA.Status        
from DispatchAbstract DA, Beat_Salesman BS        
where        
 DA.CustomerID *= BS.CustomerID        
 and (DA.Status & 192) = 0         
 and DA.DispatchDate between @FromDate and @ToDate        
End      
Else      
Begin      
insert into #DispatchAbstractBeat        
select distinct DA.DispatchID, DA.CustomerID, DA.DispatchDate, BS.BeatID,        
Isnull(cast((select Description from beat where beatid = BS.BeatID) as nvarchar),N'Others'), DA.Status        
from DispatchAbstract DA, Beat_Salesman BS        
where        
 DA.CustomerID = BS.CustomerID        
 and (DA.Status & 192) = 0 And      
 Bs.BeatID In (select BeatID From #tmpBeat)      
 and DA.DispatchDate between @FromDate and @ToDate        
End      
        
      
--temp table to store all the customers from         
--Open Dispatch, Open Invoice and Sales Return for the given date        
create table #BeatCust        
(        
 BeatID int,        
 Beat nvarchar(510),        
 CustomerID nvarchar(30)        
)        
      
if @Beats = N'%'      
Begin      
insert into #BeatCust        
select Distinct DA.BeatID, DA.Beat, DA.CustomerID        
from #DispatchAbstractBeat DA        
union        
select         
 Distinct Beat.BeatID, isnull(Beat.Description,N'Others'), IA.CustomerID        
from         
 beat, InvoiceAbstract IA, InvoiceDetail IDt, Items It         
where         
 IA.BeatID *= Beat.BeatID         
 and IA.InvoiceID = IDt.InvoiceID         
 and IDt.Product_Code = It.Product_Code         
 and It.CategoryID in (select categoryid from #tempCategory)        
 and IA.InvoiceDate between @FromDate and @ToDate         
 and IA.InvoiceType in (1,3,4)        
 and (IA.Status & 192) = 0         
group by Beat.BeatID, Beat.Description, IA.CustomerID        
End      
Else      
Begin      
insert into #BeatCust        
select Distinct DA.BeatID, DA.Beat, DA.CustomerID        
from #DispatchAbstractBeat DA        
union        
select         
 Distinct Beat.BeatID, isnull(Beat.Description,N'Others'), IA.CustomerID        
from         
 beat, InvoiceAbstract IA, InvoiceDetail IDt, Items It         
where         
 IA.BeatID = Beat.BeatID         
 and IA.InvoiceID = IDt.InvoiceID         
 and IDt.Product_Code = It.Product_Code         
 and It.CategoryID in (select categoryid from #tempCategory)        
 and Beat.BeatID In (select BeatID From #tmpBeat)      
 and IA.InvoiceDate between @FromDate and @ToDate         
 and IA.InvoiceType in (1,3,4)        
 and (IA.Status & 192) = 0         
group by Beat.BeatID, Beat.Description, IA.CustomerID        
End      
      
--temp table to store distinct numbers Customers among the above taken Dispath and Invoice        
--this table is the final report        
create table #BeatCategorySales        
(        
 BeatID int,        
 Beat nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,        
 [Outlet Count] numeric        
)        
        
insert into #BeatCategorySales        
select distinct beatid, beat, count(customerid) from #BeatCust        
group by beatid, beat        
        
drop table #BeatCust        
        
--cursor to add Categoy as colums to the #BeatCategorySales table;         
--also to update the sum of quantity for each category.        
declare BeatItemCursor cursor scroll        
for        
        
select distinct IC.CategoryID, IC.Category_Name         
from #DispatchAbstractBeat DA, DispatchDetail DDt, Items It        
, ItemCategories IC        
where        
 DA.DispatchID = DDt.DispatchID         
 and DDt.Product_Code = It.Product_Code         
 and It.CategoryID in (Select CategoryID from #TempCategory)        
 and It.CategoryID = IC.CategoryID        
union        
        
select distinct IC.CategoryID, IC.Category_Name         
from InvoiceAbstract IA, InvoiceDetail IDt, Items It, ItemCategories IC        
where        
 IA.InvoiceID = IDt.InvoiceID         
 and IDt.Product_Code = It.Product_Code         
 and It.CategoryID in (Select CategoryID from #TempCategory)        
 and It.CategoryID = IC.CategoryID        
 and IA.InvoiceType <> 2         
 and (IA.Status & 192) = 0         
 and IA.InvoiceDate between @FromDate and @ToDate        
 order by IC.Category_Name        
        
open BeatItemCursor        
fetch next from BeatItemCursor into @CurrCategoryID, @CurrCategoryName         
        
--variable that will hold the column mapping of Dispatch,         
--to update the Category wise sum of quantity        
set @MappingDispatch =N' It.Product_Code = DDt.Product_Code         
    and DA.DispatchID = DDt.DispatchID         
    and isnull(#BeatCategorySales.Beat,''Others'') = DA.Beat'        
        
--variable that will hold the column mapping of Invoice,         
--to update the Category wise sum of quantity        
set @MappingInvoice =N' It.Product_Code = IDt.Product_Code         
    and IA.InvoiceID = IDt.InvoiceID         
    and isnull(IA.BeatID,0) = (case #BeatCategorySales.Beat when ''Others''         
       then 0 else #BeatCategorySales.BeatID end)         
    and IA.InvoiceType <> 2         
    and (IA.Status & 192) = 0         
    and IA.InvoiceDate between ''' + convert(nvarchar, @FromDate) + N''' and         
     ''' + convert(nvarchar, @ToDate) + N''''        
        
while @@FETCH_STATUS = 0         
begin        
 set @Query = N'alter table #BeatCategorySales add [' + @CurrCategoryName + N'] numeric(18,2)'        
 exec (@Query)        
 if (upper(@UOM)) = N'CONVERSION FACTOR'        
 begin        
  set @Query =         
  N'update #BeatCategorySales set [' + @CurrCategoryName + N'] = (        
   select sum((DDt.Quantity) *         
   case Isnull(It.ConversionFactor,0) when 0 then 1 else isnull(It.ConversionFactor,1) end)        
   from #DispatchAbstractBeat DA, DispatchDetail DDt, Items It/*, ItemHierarchy IH, 
     ItemCategories IC*/, ConversionTable CT        
   where         
    It.CategoryID = ' + cast( @CurrCategoryID as nvarchar) + N' and        
    ' + @MappingDispatch + N'         
    and It.ConversionUnit *= CT.ConversionID)'        
  exec (@Query)        
        
  set @Query =         
  N'update #BeatCategorySales         
  set [' + @CurrCategoryName + N'] =  isnull([' + @CurrCategoryName + N'],0) + isnull((        
  select sum((case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end) *         
  case Isnull(It.ConversionFactor,0) when 0 then 1 else isnull(It.ConversionFactor,1) end)         
  from InvoiceAbstract IA, InvoiceDetail IDt, Items It/*, ItemHierarchy IH,         
    ItemCategories IC*/, ConversionTable CT        
  where         
   It.CategoryID = ' + cast( @CurrCategoryID as nvarchar) + N' and        
   ' + @MappingInvoice +  N' and        
   It.ConversionUnit *= CT.ConversionID         
   ),0)'        
  exec (@Query)        
        
 end        
    
else if (upper(@UOM)) = N'UOM1'        
 begin        
  set @Query =         
  N'update #BeatCategorySales set [' + @CurrCategoryName + N'] = (       
      
   Select Sum(Qty) From (select "Qty" = sum(DDt.Quantity)/(case IsNull(IT.UOM1_Conversion,0) when 0 then 1 else IT.UOM1_Conversion end)              
   from #DispatchAbstractBeat DA, DispatchDetail DDt, Items It/*, ItemHierarchy IH,         
     ItemCategories IC*/       
   where         
    It.CategoryID = ' + cast( @CurrCategoryID as nvarchar) + N' and        
    ' + @MappingDispatch + N'  group by IT.UOM1_Conversion)Ab) '        
  exec (@Query)        
      
  set @Query =         
  N'update #BeatCategorySales         
  set [' + @CurrCategoryName + N'] =  isnull([' + @CurrCategoryName + N'],0) + isnull(      
      
  (Select Sum(Qty) From (select "Qty" = sum((case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end))/      
  (case IsNull(UOM1_Conversion,0) when 0 then 1 else IT.UOM1_Conversion end)          
  from InvoiceAbstract IA, InvoiceDetail IDt, Items It/*, ItemHierarchy IH,         
    ItemCategories IC*/      
  where         
   It.CategoryID = ' + cast( @CurrCategoryID as nvarchar) + N' and        
   ' + @MappingInvoice +  N' group by IT.UOM1_Conversion     
       
   )Ab),0)'        
  exec (@Query)        
        
 end        
else if (upper(@UOM)) = N'UOM2'        
 begin        
  set @Query =         
  N'update #BeatCategorySales set [' + @CurrCategoryName + N'] = (       
      
   Select Sum(Qty) From (select"Qty" = sum(DDt.Quantity)/(case IsNull(IT.UOM2_Conversion,0) when 0 then 1 else IT.UOM2_Conversion end)              
   from #DispatchAbstractBeat DA, DispatchDetail DDt, Items It/*, ItemHierarchy IH,         
     ItemCategories IC*/       
   where         
    It.CategoryID = ' + cast( @CurrCategoryID as nvarchar) + N' and        
    ' + @MappingDispatch + N' group by IT.UOM2_Conversion )AB) '        
  exec (@Query)        
      
  set @Query =         
  N'update #BeatCategorySales         
  set [' + @CurrCategoryName + N'] =  isnull([' + @CurrCategoryName + N'],0) + isnull(      
      
  (Select Sum(Qty) From (select "Qty" = sum((case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end))/      
  (case IsNull(UOM2_Conversion,0) when 0 then 1 else IT.UOM2_Conversion end)          
  from InvoiceAbstract IA, InvoiceDetail IDt, Items It/*, ItemHierarchy IH,         
    ItemCategories IC*/      
  where         
   It.CategoryID = ' + cast( @CurrCategoryID as nvarchar) + N' and        
   ' + @MappingInvoice +  N'   group by IT.UOM2_Conversion      
       
   )Ab),0)'        
  exec (@Query)        
 end        
    
else if (upper(@UOM)=N'Reporting UOM')      
 begin      
  set @Query =       
  N'update #BeatCategorySales       
  set [' + @CurrCategoryName + N'] = (      
   select sum((DDt.Quantity) /       
case Isnull(It.ReportingUnit,0) when 0 then 1 else isnull(It.ReportingUnit,1) end)       
   from #DispatchAbstractBeat DA, DispatchDetail DDt, Items It/*, ItemHierarchy IH,       
     ItemCategories IC*/      
   where       
    It.CategoryID = ' + cast( @CurrCategoryID as nvarchar) + N' and      
    ' + @MappingDispatch + N' )'      
  exec (@Query)      
      
  set @Query =       
  N'update #BeatCategorySales       
  set [' + @CurrCategoryName + N'] = isnull([' + @CurrCategoryName + N'],0) + isnull((      
   select sum((case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end) /       
   case Isnull(It.ReportingUnit,0) when 0 then 1 else isnull(It.ReportingUnit,1) end)       
   from InvoiceAbstract IA, InvoiceDetail IDt, Items It/*, ItemHierarchy IH,       
     ItemCategories IC*/      
   where       
    It.CategoryID = ' + cast( @CurrCategoryID as nvarchar) + N' and      
    ' + @MappingInvoice + N' ),0)'      
  exec (@Query)      
 end      
 else -- Sales UOM        
 begin        
  set @Query =         
  N'update #BeatCategorySales         
  set [' + @CurrCategoryName + N'] = (        
   select sum(DDt.Quantity)        
   from #DispatchAbstractBeat DA, DispatchDetail DDt, Items It/*, ItemHierarchy IH,         
     ItemCategories IC*/        
   where         
    It.CategoryID = ' + cast( @CurrCategoryID as nvarchar) + N' and        
    ' + @MappingDispatch + N' )'        
  exec (@Query)        
        
  set @Query =         
  N'update #BeatCategorySales         
  set [' + @CurrCategoryName + N'] =  isnull([' + @CurrCategoryName + N'],0) + isnull((        
   select sum(case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end)        
   from InvoiceAbstract IA, InvoiceDetail IDt, Items It/*, ItemHierarchy IH,         
     ItemCategories IC*/        
   where         
    It.CategoryID = ' + cast( @CurrCategoryID as nvarchar) + N' and        
    ' + @MappingInvoice + N' ),0)'        
  exec (@Query)        
 end        
        
 exec (N'update #BeatCategorySales         
    set [' + @CurrCategoryName + N'] = null         
    where [' + @CurrCategoryName + N'] = 0' )        
 fetch next from BeatItemCursor into @CurrCategoryID, @CurrCategoryName         
end        
        
alter table #BeatCategorySales add [Total Amount] Decimal(18,6)        
        
set @Query = N'        
update #BeatCategorySales         
set [Total Amount] =         
 (        
  select sum(DDt.SalePrice * DDt.Quantity)        
  from #DispatchAbstractBeat DA, DispatchDetail DDt, Items It        
  where         
   It.CategoryID in (select categoryid from #TempCategory) and        
   ' + @MappingDispatch + N'        
 )        
'        
exec (@Query)        
        
set @Query = N'        
update #BeatCategorySales         
set [Total Amount] = isnull([Total Amount],0) +         
 isnull((        
  select sum(IDt.Amount)        
  from InvoiceAbstract IA, InvoiceDetail IDt, Items It        
  where         
   It.CategoryID in (select categoryid from #TempCategory) and        
   ' + @MappingInvoice + N'        
 ),0)        
'        
exec (@Query)        
        
close BeatItemCursor        
deallocate BeatItemCursor        
        
select * from #BeatCategorySales order by beatid        
        
drop table #BeatCategorySales        
drop table #DispatchAbstractBeat        
drop table #tempCategory        
end
