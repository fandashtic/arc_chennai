CREATE Procedure spr_list_partywise_monthwise_sales (
@CHANNEL nvarchar(2550), 
@BEAT nvarchar(2550), 
@CUSTNAME nvarchar(2550), 
@UOM nvarchar(2550), 
@FROMDATE datetime, 
@TODATE datetime)        
As          
Declare @FYear as int  
Declare @Delimeter as Char(1)    
Declare @OTHERS As NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)
Set @Delimeter=Char(15)    
Create table #tmpCust(CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
Create table #tmpBeat(BeatID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
  
If @CHANNEL = '%'  
 If @CUSTNAME='%'  
  Insert into #tmpCust Select Distinct CustomerID from Customer        
 else  
  Insert into #tmpCust Select CustomerID from Customer where Company_Name in (select * from dbo.sp_SplitIn2Rows(@CUSTNAME,@Delimeter))    
else  
 If @CUSTNAME='%'  
  Insert into #tmpCust Select Distinct CustomerID from Customer Where ChannelType in (Select Distinct ChannelType from Customer_Channel where ChannelDesc in (select * from dbo.sp_SplitIn2Rows(@CHANNEL,@Delimeter)))  
 else  
  Insert into #tmpCust Select Distinct CustomerID from Customer Where ChannelType in (Select Distinct ChannelType from Customer_Channel where ChannelDesc in (select * from dbo.sp_SplitIn2Rows(@CHANNEL,@Delimeter))) and Company_Name in (select * from dbo.sp_SplitIn2Rows(@CUSTNAME,@Delimeter))  
  
if @BEAT='%'      
 Begin  
   Insert into #tmpBeat Select BeatID from Beat      
   insert into #tmpBeat values('0')  
 End  
Else      
   Insert into #tmpBeat Select BeatId from Beat where [Description] in (Select * from dbo.sp_SplitIn2Rows(@BEAT,@Delimeter))  
  
Create table #temp1 (CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Description] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CityName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, invmonth int, netvalue Decimal(18,6))        
insert into #temp1        
Select    
 isnull(Customer.CustomerID,0), Customer.Company_Name,     
 isnull((Select [Description] from Beat where isnull(Beat.BeatId,0)=isnull(Invoiceabstract.beatid,0)),@OTHERS) as Beat,  
 (Select CityName from City where CityId=Customer.CityID) as CityName,  
 month(invoiceabstract.invoicedate),         
 case @UOM   
 When 'UOM 1' then Sum(case invoicetype when 4 then (0 - (Quantity)) else (Quantity) end)/Isnull((Case Items.UOM1_Conversion When 0 then 1 else Items.UOM1_Conversion End),1)         
 When 'UOM 2' then Sum(case invoicetype when 4 then (0 - (Quantity)) else (Quantity) end)/Isnull((Case Items.UOM2_Conversion When 0 then 1 else Items.UOM2_Conversion End),1)         
 When 'Reporting UOM' then Sum(case invoicetype when 4 then (0 - (Quantity)) else (Quantity) end)/Isnull((Case Items.ReportingUnit When 0 then 1 else Items.ReportingUnit End),1)  
 When 'Conversion Factor' then Sum(case invoicetype when 4 then (0 - (Quantity)) else (Quantity) end)*Isnull((Case Items.ConversionFactor When 0 then 1 else Items.ConversionFactor End),1)  
 Else Sum(case invoicetype when 4 then (0 - (Quantity)) else (Quantity) end)  
 End  
from Invoiceabstract, Invoicedetail, Items, Customer   
where Invoiceabstract.invoiceid = Invoicedetail.invoiceid and        
 Customer.CustomerID = Invoiceabstract.CustomerID and  
 Customer.CustomerID in (select CustomerID from #tmpCust) and   
 isnull(InvoiceAbstract.Beatid,0) In (Select BeatID from #tmpBeat) and         
 Invoiceabstract.invoicetype in (1,3,4) and        
 (Invoiceabstract.status & 128) = 0  and        
 invoicedate between @Fromdate and @Todate and  
 Items.Product_Code = InvoiceDetail.Product_Code  
Group by month(invoiceabstract.invoicedate),   
Invoiceabstract.BeatID,  
Customer.CustomerID,Customer.Company_Name, Customer.CityID,   
Invoicetype,   
Items.UOM1_Conversion, Items.UOM2_Conversion, Items.ReportingUnit,Items.ConversionFactor          
  
Create table #temp2 (CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Beat nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CityName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,        
 January Decimal(18,6),  February Decimal(18,6), March Decimal(18,6), April Decimal(18,6), May Decimal(18,6),        
 June Decimal(18,6), July Decimal(18,6), August Decimal(18,6), September Decimal(18,6), October Decimal(18,6), November Decimal(18,6), December Decimal(18,6),  
 [Total] Decimal(18,6), [Avg(Per Month)] Decimal(18,6))    
  
  
-- Initialize values to 0 for 12 months, total, avg per month    
Insert into #temp2        
Select Distinct CustomerID, CustomerName, [Description], CityName, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 from #temp1        
  
Declare @Cust_id nvarchar(255)         
Declare @Beat_Desc nvarchar(255)         
Declare @Inv_month int        
Declare @Net_Value Decimal(18,6)        
Declare @Jan Decimal(18,6) declare  @Feb Decimal(18,6) declare  @Mar Decimal(18,6) declare  @Apr Decimal(18,6) declare  @May Decimal(18,6) declare  @Jun Decimal(18,6)        
Declare @Jul Decimal(18,6) declare  @Aug Decimal(18,6) declare  @Sep Decimal(18,6) declare  @Oct Decimal(18,6) declare  @Nov Decimal(18,6) declare  @Dec Decimal(18,6)        
  
Declare Cust_cursor cursor for Select CustomerID, [Description], invmonth, netvalue from #temp1      
open Cust_cursor        
Fetch Next From Cust_cursor into @Cust_ID, @Beat_Desc, @Inv_month, @Net_Value        
while @@Fetch_STATUS = 0        
begin        
 set @Jan = 0 set @Feb = 0 set @Mar = 0 set @Apr = 0 set @May = 0 set @Jun = 0         
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
  
 Update #temp2 set January = isnull(January,0) + @Jan ,  February = isnull(February,0) + @Feb , March = isnull(March,0) + @Mar, April = isnull(April,0) + @Apr, May = isnull(May,0) + @May, June = isnull(June,0) + @Jun,         
  July = isnull(July,0) + @Jul, August = isnull(August,0) + @Aug, September = isnull(September, 0) + @Sep, October = isnull(October,0) + @Oct, November = isnull(November,0) + @Nov, December = isnull(December,0) + @Dec, [Total] = isnull([Total],0) + @Net_Value        
 Where CustomerID = @Cust_ID and Beat = @Beat_Desc   
 Set @Jan = 0  set @Feb = 0  set @Mar = 0 set @Apr = 0 set @May = 0 set @Jun = 0         
 Set @Jul = 0 set @Aug = 0 set @Sep = 0 set @Oct = 0 set @Nov = 0 set @Dec = 0        
 Fetch Next From Cust_cursor into @Cust_ID, @Beat_Desc, @Inv_month, @Net_Value        
End  
        
Update #Temp2 set [Avg(Per Month)]=([Total] / 12) where [Total] <> 0  
  
Select @FYear = FiscalYear from setup  
If @FYear = 1  
Select CustomerID, CustomerName, Beat, CityName, January, February, March, April, May, June, July, August, September, October, November, December, [Total], [Avg(Per Month)] from #temp2 Order by Beat, CityName, CustomerName  
else if @FYear = 2  
Select CustomerID, CustomerName, Beat, CityName, February, March, April, May, June, July, August, September, October, November, December, January, [Total], [Avg(Per Month)] from #temp2 Order by Beat, CityName, CustomerName  
else if @FYear = 3  
Select CustomerID, CustomerName, Beat, CityName, March, April, May, June, July, August, September, October, November, December, January, February, [Total], [Avg(Per Month)] from #temp2 Order by Beat, CityName, CustomerName  
else if @FYear = 4  
Select CustomerID, CustomerName, Beat, CityName, April, May, June, July, August, September, October, November, December, January, February, March, [Total], [Avg(Per Month)] from #temp2 Order by Beat, CityName, CustomerName  
else if @FYear = 5  
Select CustomerID, CustomerName, Beat, CityName, May, June, July, August, September, October, November, December, January, February, March, April, [Total], [Avg(Per Month)] from #temp2 Order by Beat, CityName, CustomerName  
else if @FYear = 6  
Select CustomerID, CustomerName, Beat, CityName, June, July, August, September, October, November, December, January, February, March, April, May, [Total], [Avg(Per Month)] from #temp2 Order by Beat, CityName, CustomerName  
else if @FYear = 7  
Select CustomerID, CustomerName, Beat, CityName, July, August, September, October, November, December, January, February, March, April, May, June, [Total], [Avg(Per Month)] from #temp2 Order by Beat, CityName, CustomerName  
else if @FYear = 8  
Select CustomerID, CustomerName, Beat, CityName, August, September, October, November, December, January, February, March, April, May, June, July, [Total], [Avg(Per Month)] from #temp2 Order by Beat, CityName, CustomerName  
else if @FYear = 9  
Select CustomerID, CustomerName, Beat, CityName, September, October, November, December, January, February, March, April, May, June, July, August, [Total], [Avg(Per Month)] from #temp2 Order by Beat, CityName, CustomerName  
else if @FYear = 10  
Select CustomerID, CustomerName, Beat, CityName, October, November, December, January, February, March, April, May, June, July, August, September, [Total], [Avg(Per Month)] from #temp2 Order by Beat, CityName, CustomerName  
else if @FYear = 11  
Select CustomerID, CustomerName, Beat, CityName, November, December, January, February, March, April, May, June, July, August, September, October, [Total], [Avg(Per Month)] from #temp2 Order by Beat, CityName, CustomerName  
else if @FYear = 12  
Select CustomerID, CustomerName, Beat, CityName, December, January, February, March, April, May, June, July, August, September, October, November, [Total], [Avg(Per Month)] from #temp2 Order by Beat, CityName, CustomerName  
  
Close Cust_cursor        
Deallocate Cust_cursor        
Drop table #temp1        
Drop table #temp2     
Drop table #tmpCust    
Drop table #tmpBeat    
  

