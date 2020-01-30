CREATE procedure [dbo].[spr_month_wise_sales_wise_beat] (@CATNAME nvarchar(2550), @Beat nvarchar(2550),       
    @fromDate datetime, @ToDate datetime)        
As          
  
Declare @Delimeter as Char(1)    
Declare @OTHERS As NVarchar(50)  
  
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)  
Set @Delimeter=Char(15)    
-- Leaf level Category items is not getting loaded when we select parent category.  
--Create table #tmpCat(CategoryName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create table #tmpBeat(BeatName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create Table #tempCategory (CategoryID Int, Status Int)  
Exec GetLeafCategories '%', @CATNAME
Select Distinct CategoryID InTo #tmpCat From #tempCategory  

-- if @CATNAME='%'     
--    Insert into #tmpCat select Category_Name from ItemCategories    
-- Else    
--    Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@CATNAME,@Delimeter)    
    
if @Beat='%'    
   Insert into #tmpBeat select Description from Beat    
Else    
   Insert into #tmpBeat select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter)    
  
  
Create Table #temp(CategoryID int, Category_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Status int)          
 Declare @Continue int          
 Declare @CategoryID int          
Set @Continue = 1          
Insert into #temp select CategoryID,Category_Name,0 From ItemCategories where CategoryID In (Select CategoryID  from #tmpCat)   
if @CATNAME not like '%'   
begin  
While @Continue > 0   
Begin          
 Declare Parent Cursor Static For          
 Select CategoryID From #temp Where Status = 0          
 Open Parent     
 Fetch From Parent Into @CategoryID          
 While @@Fetch_Status = 0          
 Begin          
  Insert into #temp Select CategoryID, Category_Name, 0 From ItemCategories Where ParentID = @CategoryID          
  Update #temp Set Status = 1 Where CategoryID = @CategoryID          
  Fetch Next From Parent Into @CategoryID          
 End          
 Close Parent          
 DeAllocate Parent          
 Select @Continue = Count(*) From #temp Where Status = 0          
End          
  
end -- end for cat rec code  
create table #temp1 (beatid int, [description] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, invmonth int, netvalue Decimal(18,6))      
insert into #temp1      
select  -- invoiceabstract.invoiceid, invoicedetail.product_code,       
 isnull(beat.beatid,0),   
 case isnull(beat.beatid,0) when 0 then @OTHERS else beat.description end,   
 month(invoiceabstract.invoicedate),       
 sum( case invoicetype when 4 then (0 - (amount))       
 else (amount) end )       
from invoiceabstract
Inner Join  invoicedetail On invoiceabstract.invoiceid = invoicedetail.invoiceid
Inner Join items On items.product_code = invoicedetail.product_code
Left Outer Join beat On beat.beatid = invoiceabstract.beatid
Inner Join itemcategories On items.categoryid = itemcategories.categoryid
where beat.description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) and       
 invoiceabstract.invoicetype in (1,2,3,4) and      
 itemcategories.categoryid in (select categoryid from #temp)   and      
 (invoiceabstract.status & 128) = 0  and      
 invoicedate between @Fromdate and @todate      
group by month(invoiceabstract.invoicedate),  -- invoiceabstract.invoiceid, invoicedetail.product_code,       
 beat.beatid, beat.description, invoicetype       
-- select * from #temp    order by categoryid  
drop table #temp      
Create table #temp2 (beatid int, [description] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,       
 January Decimal(18,6),  February Decimal(18,6), March Decimal(18,6), April Decimal(18,6), May Decimal(18,6),      
 June Decimal(18,6), July Decimal(18,6), August Decimal(18,6), September Decimal(18,6), October Decimal(18,6), November Decimal(18,6), December Decimal(18,6))  
  -- invmonth int, netvalue Decimal(18,6))      
insert into #temp2      
-- initialize values to 0 for all months  
Select distinct beatid, [description] , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 from #temp1      
declare @Beat_id int       
declare @Inv_month int      
declare @Net_Value Decimal(18,6)      
Declare @Jan Decimal(18,6) declare  @Feb Decimal(18,6) declare  @Mar Decimal(18,6) declare  @Apr Decimal(18,6) declare  @May Decimal(18,6) declare  @Jun Decimal(18,6)      
declare @Jul Decimal(18,6) declare  @Aug Decimal(18,6) declare  @Sep Decimal(18,6) declare  @Oct Decimal(18,6) declare  @Nov Decimal(18,6) declare @Dec Decimal(18,6)      
--Declaring Cursor      
Declare beat_cursor cursor for Select beatid, invmonth, netvalue from #temp1    
open beat_cursor      
Fetch Next From beat_cursor into @Beat_id , @Inv_month, @Net_Value      
while @@Fetch_STATUS = 0      
begin      
 set @Jan = 0  set @Feb = 0  set @Mar = 0 set @Apr = 0 set @May = 0 set @Jun = 0       
 set @Jul = 0 set @Aug = 0 set @Sep = 0 set @Oct = 0 set @Nov = 0 set @Dec = 0      
 if @Inv_month =  1  set @Jan = @Net_Value       
 if @Inv_month =  2  set @Feb = @Net_Value      
 if @Inv_month =  3  set @Mar = @Net_Value      
 if @Inv_month =  4  set @Apr = @Net_Value      
 if @Inv_month =  5  set @May = @Net_Value      
 if @Inv_month =  6  set @Jun = @Net_Value      
      
 if @Inv_month =  7  set @Jul = @Net_Value      
 if @Inv_month =  8  set @Aug = @Net_Value      
 if @Inv_month =  9  set @Sep = @Net_Value      
 if @Inv_month =  10  set @Oct = @Net_Value      
 if @Inv_month =  11  set @Nov = @Net_Value      
 if @Inv_month =  12  set @Dec = @Net_Value      
 update #temp2 set January = isnull(January,0) + @Jan ,  February = isnull(February,0) + @Feb , March = isnull(March,0) + @Mar, April = isnull(April,0) + @Apr, May = isnull(May,0) + @May, June = isnull(June,0) + @Jun,       
  July = isnull(July,0) + @Jul, August = isnull(August,0) + @Aug, September = isnull(September, 0) + @Sep, October = isnull(October,0) + @Oct, November = isnull(November,0) + @Nov, December = isnull(December,0) + @Dec      
 where beatid = @Beat_Id      
 set @Jan = 0  set @Feb = 0  set @Mar = 0 set @Apr = 0 set @May = 0 set @Jun = 0       
 set @Jul = 0 set @Aug = 0 set @Sep = 0 set @Oct = 0 set @Nov = 0 set @Dec = 0      
 Fetch Next From beat_cursor into @Beat_id , @Inv_month, @Net_Value      
end      
select * from #temp2      
close beat_cursor      
Deallocate beat_cursor      
drop table #temp1      
drop table #temp2   
Drop table #tmpCat  
Drop table #tmpBeat  
  
  
  


