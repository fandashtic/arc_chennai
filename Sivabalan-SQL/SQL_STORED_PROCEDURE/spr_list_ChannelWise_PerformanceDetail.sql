CREATE procedure spr_list_ChannelWise_PerformanceDetail                    
(                              
 @ChannelType int,                                   
 @CATNAME nvarchar(2550),                            
 @Channel nvarchar(2550),    
 @UOM nVarchar(2550),                            
 @FromDate Datetime,                             
 @ToDate Datetime                            
)                                    
As                                      
Declare @Delimeter as Char(1)                                
Set @Delimeter=Char(15)                
                            
Declare @tmpCat table(CategoryName nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS)                                  
                      
If @CATNAME='%'                                   
   Insert into @tmpCat select Category_Name from ItemCategories                                  
Else                                  
   Insert into @tmpCat select * from dbo.sp_SplitIn2Rows(@CATNAME,@Delimeter)                                  
                              
Declare @temp Table (CategoryID int, Category_Name nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,Status int)                                        
Declare @Continue int                                        
Declare @CategoryID int                                        
Set @Continue = 1                                        
Insert into @temp select CategoryID,Category_Name,0 From ItemCategories where Category_Name In (Select CategoryName from @tmpCat)                                 
If @CATNAME <> N'%'                                 
 begin                                
 While @Continue > 0                                 
  Begin                                        
   Declare Parent Cursor Static For Select CategoryID From @temp Where Status = 0                                        
   Open Parent                                   
   Fetch From Parent Into @CategoryID                                        
   While @@Fetch_Status = 0                                        
   Begin                                        
    Insert into @temp Select CategoryID, Category_Name, 0 From ItemCategories Where ParentID = @CategoryID                                        
    Update @temp Set Status = 1 Where CategoryID = @CategoryID                                        
    Fetch Next From Parent Into @CategoryID                                        
    End                                        
   Close Parent                                        
   DeAllocate Parent                                        
   Select @Continue = Count(*) From @temp Where Status = 0                                        
  End                                        
 end                               
                              
 Declare @temp1 table(PrCode nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS, PrName nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS, invmonth int, NetQty Decimal(18,6))                                    
                      
 Insert into @temp1 select items.product_code,items.productname,                                 
 month(invoiceabstract.invoicedate),                              
 case @UOM                              
   when 'Conversion Factor' then isnull(sum((case invoicetype when 4 then (0 - (Quantity)) else (Quantity) end) * (case when isnull(items.conversionfactor,0)=0 then 1 else items.conversionfactor end)),0)                                      
   when 'Reporting UOM'     then isnull(sum((case invoicetype when 4 then (0 - (Quantity)) else (Quantity) end) / (case when isnull(items.reportingunit,0)=0  then 1 else items.reportingunit end)),0)                                      
   When 'UOM 1'             then isnull(sum((case invoicetype when 4 then (0 - (Quantity)) else (Quantity) end) / (Case when isnull(items.uom1_conversion,0)=0  then 1 else items.uom1_conversion end)),0)                                  
   when 'UOM 2'             then isnull(sum((case invoicetype when 4 then (0 - (Quantity)) else (Quantity) end) / (case when isnull(items.uom2_conversion,0)=0 then 1 else items.uom2_conversion end)),0)                                      
   else                          isnull(sum( case invoicetype when 4 then (0 - (Quantity)) else (Quantity) end),0) end                              
 from  Invoiceabstract                  
 inner join invoicedetail on invoiceabstract.invoiceid = invoicedetail.invoiceid                             
 inner join items on items.product_code = invoicedetail.product_code                             
 inner join itemcategories on items.categoryid = itemcategories.categoryid                             
 inner join Customer on Customer.CustomerId = invoiceabstract.CustomerId                                     
 inner join Customer_Channel as Channel on Channel.ChannelType = Customer.ChannelType                  
 where   
 invoiceabstract.invoicetype in (1,3,4) and   
 (invoiceabstract.status & 128) = 0  and   
 channel.channelType = @ChannelType and                            
 invoicedate between @Fromdate and @ToDate and                           
 itemcategories.categoryid in                             
 (select categoryid from @temp)                                       
 group by items.product_code,items.productname,month(invoiceabstract.invoicedate), Channel.ChannelType, Channel.ChannelDesc, invoicetype,                                     
 items.ConversionFactor,items.ReportingUnit,items.UOM1_Conversion,items.UOM2_Conversion                               
                             
Declare @temp2 table  (ItemCode nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS, ItemName nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,                                     
 January Decimal(18,6),  February Decimal(18,6), March Decimal(18,6), April Decimal(18,6), May Decimal(18,6),                                    
 June Decimal(18,6), July Decimal(18,6), August Decimal(18,6), September Decimal(18,6), October Decimal(18,6), November Decimal(18,6), December Decimal(18,6),                            
 YearToDate Decimal(18,6))                                
                      
 Insert into @temp2                                    
 Select distinct PrCode, PrName, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 from @temp1                                    
                             
 Declare @PrCode nVarchar(255)                                     
 Declare @PrName nVarchar(255)                                     
 Declare @Inv_month int                                    
 Declare @Net_Qty Decimal(18,6)                                    
 Declare @Jan Decimal(18,6) declare  @Feb Decimal(18,6) declare  @Mar Decimal(18,6) declare  @Apr Decimal(18,6) declare  @May Decimal(18,6) declare  @Jun Decimal(18,6)                                    
 Declare @Jul Decimal(18,6) declare  @Aug Decimal(18,6) declare  @Sep Decimal(18,6) declare  @Oct Decimal(18,6) declare  @Nov Decimal(18,6) declare  @Dec Decimal(18,6)                                    
 Declare @FYear int                              
 Declare @YearToDate Decimal(18,6)                            
                             
 Declare Channel_cursor cursor for Select PrCode,PrName,invmonth, netQty from @temp1                                  
 open Channel_cursor                                    
 Fetch Next From Channel_cursor into @PrCode, @PrName, @Inv_month, @Net_Qty                             
 while @@Fetch_STATUS = 0                                    
 begin                                    
  set @Jan = 0  set @Feb = 0  set @Mar = 0 set @Apr = 0 set @May = 0 set @Jun = 0                       
  set @Jul = 0 set @Aug = 0 set @Sep = 0 set @Oct = 0 set @Nov = 0 set @Dec = 0                                    
  set @YearToDate = 0                            
                       
  if @Inv_month =  1  set @Jan = @Net_Qty                                     
  if @Inv_month =  2  set @Feb = @Net_Qty                        
  if @Inv_month =  3  set @Mar = @Net_Qty                              
  if @Inv_month =  4  set @Apr = @Net_Qty                              
  if @Inv_month =  5  set @May = @Net_Qty                 
  if @Inv_month =  6  set @Jun = @Net_Qty                              
                                    
  if @Inv_month =  7  set @Jul = @Net_Qty                              
  if @Inv_month =  8  set @Aug = @Net_Qty                                    
 if @Inv_month =  9  set @Sep = @Net_Qty                                    
  if @Inv_month =  10  set @Oct = @Net_Qty                                    
  if @Inv_month =  11  set @Nov = @Net_Qty                                    
  if @Inv_month =  12  set @Dec = @Net_Qty                                    
                            
  Set @YearToDate = @YearToDate + @Net_Qty                            
                              
  update @temp2 set January = isnull(January,0) + @Jan ,  February = isnull(February,0) + @Feb , March = isnull(March,0) + @Mar, April = isnull(April,0) + @Apr, May = isnull(May,0) + @May, June = isnull(June,0) + @Jun,                                     
 July = isnull(July,0) + @Jul, August = isnull(August,0) + @Aug, September = isnull(September, 0) + @Sep, October = isnull(October,0) + @Oct, November = isnull(November,0) + @Nov, December = isnull(December,0) + @Dec,                                    
  YearToDate = IsNull(YearToDate,0) + @YearToDate                            
  where ItemCode = @PrCode                            
                                    
  set @Jan = 0  set @Feb = 0  set @Mar = 0 set @Apr = 0 set @May = 0 set @Jun = 0                                     
  set @Jul = 0 set @Aug = 0 set @Sep = 0 set @Oct = 0 set @Nov = 0 set @Dec = 0                                    
  set @YearToDate = 0                            
  Fetch Next From Channel_cursor into @PrCode,@PrName , @Inv_month, @Net_Qty                                    
 end                                    
close Channel_cursor                                    
Deallocate Channel_cursor                                    
                            
select @FYear = Fiscalyear from setup                              
IF @FYEAR = 1                     
 select * from @temp2 ORDER BY ItemName                            
ELSE IF @FYEAR = 2                               
 SELECT Itemcode,"Item Code" = Itemcode,"Item Name" = ItemName,February,March,April,May,June,July,August,September,October,November,December,January,"Year To Date" = YearToDate from @temp2 ORDER BY ItemName                              
ELSE IF @FYEAR = 3                               
 SELECT Itemcode,"Item Code" = Itemcode,"Item Name" = ItemName,March,April,May,June,July,August,September,October,November,December,January,February,"Year To Date" = YearToDate from @temp2 ORDER BY ItemName                            
ELSE IF @FYEAR = 4                               
 SELECT Itemcode,"Item Code" = Itemcode,"Item Name" = ItemName,April,May,June,July,August,September,October,November,December,January,February,March,"Year To Date" = YearToDate from @temp2 ORDER BY ItemName                            
ELSE IF @FYEAR = 5                              
 SELECT Itemcode,"Item Code" = Itemcode,"Item Name" = ItemName,May,June,July,August,September,October,November,December,January,February,March,April,"Year To Date" = YearToDate from @temp2 ORDER BY ItemName                            
ELSE IF @FYEAR = 6                               
 SELECT Itemcode,"Item Code" = Itemcode,"Item Name" = ItemName,June,July,August,September,October,November,December,January,February,March,April,May,"Year To Date" = YearToDate from @temp2 ORDER BY ItemName    
ELSE IF @FYEAR = 7         
 SELECT Itemcode,"Item Code" = Itemcode,"Item Name" = ItemName,July,August,September,October,November,December,January,February,March,April,May,June,"Year To Date" = YearToDate from @temp2 ORDER BY ItemName                             
ELSE IF @FYEAR = 8                               
 SELECT Itemcode,"Item Code" = Itemcode,"Item Name" = ItemName,August,September,October,November,December,January,February,March,April,May,June,July,"Year To Date" = YearToDate from @temp2 ORDER BY ItemName                            
ELSE IF @FYEAR = 9                               
 SELECT Itemcode,"Item Code" = Itemcode,"Item Name" = ItemName,September,October,November,December,January,February,March,April,May,June,July,August,"Year To Date" = YearToDate from @temp2 ORDER BY ItemName                            
ELSE IF @FYEAR = 10                              
 SELECT Itemcode,"Item Code" = Itemcode,"Item Name" = ItemName,October,November,December,January,February,March,April,May,June,July,August,September,"Year To Date" = YearToDate from @temp2 ORDER BY ItemName    
ELSE IF @FYEAR = 11                
 SELECT Itemcode,"Item Code" = Itemcode,"Item Name" = ItemName,November,December,January,February,March,April,May,June,July,August,September,October,"Year To Date" = YearToDate from @temp2 ORDER BY ItemName                            
ELSE                               
 SELECT Itemcode,"Item Code" = Itemcode,"Item Name" = ItemName,December,January,February,March,April,May,June,July,August,September,October,November,"Year To Date" = YearToDate from @temp2 ORDER BY ItemName                            
                  

