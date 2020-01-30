CREATE Procedure Spr_KPISummary_Report_Detail   
(@Salesmancode as nvarchar(15),   
@Fromdate datetime, @Unused1 as NVarchar(100), @Unused2 as NVarchar(100))  
as           
Declare @CurSalesmanCode nVarchar(15)    
declare @insertfromdate nvarchar(25)              
Declare @CampaignName nvarchar(255)      
Declare @CurCampaignID nvarchar(15)   
declare @Cursalesmanid int  
Declare @CursalesmanDate datetime  
Declare @CurCampaigndate datetime  
  
set @insertfromdate = '01' + '/' +  Cast(DatePart(mm, @fromdate) as NVarchar(2)) + '/' + Cast(DatePart(yyyy, @fromdate) as nvarchar(4))            
        
Declare @Delimeter as Char(1)              
Set @Delimeter=Char(15)              
Create table #tmpSalesMan(SalesmanCode nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)              
if @Salesmancode = N'%'               
   Insert into #tmpSalesMan select SalesmanCode from Salesman Where Active = 1             
Else              
 Insert into #tmpSalesMan select * from dbo.sp_SplitIn2Rows(@salesmancode,@Delimeter)    
  
Create Table #Temp (  
  Date1 Datetime  
, SummaryDate datetime
, ActualVol   decimal(18,6)      
, ActualVoltodate  decimal(18,6)      
, ActualVolumeindex   decimal(18,6)        
, Totalcalls  int      
, Totalcallstodate  int      
, TotalcallIndex   decimal(18,6))   
  
Insert into #Temp(Date1) select distinct Dbo.StripDateFromTime(svabstract.svdate) from svabstract,salesman  
 Where svabstract.Salesmancode  = salesman.salesmancode  
 And svabstract.svdate between @insertfromdate and @fromdate  
 And salesman.salesmancode = @salesmancode  
Union  
 select Distinct Dbo.StripDateFromTime(Invoiceabstract.Invoicedate) from Invoiceabstract ,salesman  
 Where Invoiceabstract.Salesmanid  = salesman.Salesmanid  
 And Invoiceabstract.Invoicedate between @insertfromdate and @fromdate  
 And salesman.salesmanid in (select salesmanId from salesman where salesmancode = @salesmancode)  
  
Create Table #TmpCampaign(CampaignDate Datetime, CampaignID nVarchar(15),CampaignName nvarchar(255) , SalesmanCode nVarchar(15))      
Insert Into #TmpCampaign(CampaignID,CampaignName,SalesmanCode,CampaignDate) select  distinct  campaignMaster.campaignId,campaignMaster.campaignName  
 ,salesman.salesmancode,Dbo.StripDateFromTime(SVABSTRACT.svdate)     
 From campaignMaster, campaigncustomers,SVABSTRACT,Salesman    
 Where  SVABSTRACT.customerid = campaigncustomers.customerid       
 And campaignMaster.campaignId = campaigncustomers.CampaignId   
 and Salesman.salesmancode = SVABSTRACT.salesmancode  
  
declare @ActualvolDate bigint  
Declare @ActualQuantity Bigint  
declare @TotalCustomercalls int  
declare @totalcustcalldate int  
Declare @actualvolindex as decimal(18,6)  
declare @totcallindex as decimal(18,6)  
declare @distrubutionindex Decimal(18,6)  
Declare @Exec_Sql nvarchar(2000)  
Declare @CurCampaignName nvarchar(255)  
declare @distrubutionCall int  
declare @distrubutiondate int  
  
set @ActualvolDate= 0  
set @totalcustcalldate =0  
set @distrubutionindex =0  
  
DECLARE Salesman_Cursor CURSOR FOR   select distinct Date1 from #Temp   
OPEN Salesman_Cursor            
 FETCH NEXT FROM Salesman_Cursor INTO @CursalesmanDate  
 WHILE @@FETCH_STATUS = 0            
 BEGIN   
 Select @Cursalesmanid = SalesManID From Salesman   
 Where SalesmanCode = @salesmancode  
   
 set @ActualQuantity = Isnull((Select Sum(idt.Quantity)  
  From invoiceabstract as ivt , invoicedetail as idt    
  Where ivt.invoiceid = idt.invoiceid       
  And  Dbo.StripDateFromTime(ivt.Invoicedate) = Dbo.StripDateFromTime(@CursalesmanDate)  
  And ((IsNull(Ivt.Status,0) & 128) = 0)  
  And ivt.salesmanid = @Cursalesmanid   
  Group By Dbo.StripDateFromTime(ivt.Invoicedate)),0)  
  
 set @ActualvolDate = Isnull((Select Sum(idt.Quantity)  
  From invoiceabstract as ivt , invoicedetail as idt     
  Where ivt.invoiceid = idt.invoiceid       
  And ivt.salesmanid = @Cursalesmanid   
  And  Dbo.StripDateFromTime(ivt.Invoicedate) Between @insertfromdate and @CursalesmanDate  
  And ((IsNull(Ivt.Status,0) & 128) = 0)),0)   
  
 if @ActualQuantity = 0  
  set @actualvolindex = 0  
 else  
  set @actualvolindex = (@ActualvolDate / @ActualQuantity)  
   
 Set @TotalCustomercalls = Isnull((select  count(customerid) from svabstract   
 Where salesmancode = @salesmancode   
 And svdate = @CursalesmanDate   
 And ((IsNull(svabstract.Status,0) & 128) = 0)  
 And ((IsNull(svabstract.Status,0) & 32) = 0)  
 Group By Dbo.StripDateFromTime(svdate)),0)  
   
 set @totalcustcalldate = Isnull((select count(customerid) from svabstract   
 where salesmancode = @salesmancode   
 And ((IsNull(svabstract.Status,0) & 128) = 0)  
 And ((IsNull(svabstract.Status,0) & 32) = 0)  
 And svdate Between @insertfromdate and @CursalesmanDate),0)   
    
 if @TotalCustomercalls =0   
  set @totcallindex = 0  
 else  
  set @totcallindex = (@totalcustcalldate / @TotalCustomercalls)  
      
 Update #Temp set Date1 = @CursalesmanDate,SummaryDate =@CursalesmanDate,ActualVol =@ActualQuantity,ActualVoltodate = @ActualvolDate  
  ,ActualVolumeindex = @actualvolindex,Totalcalls = @TotalCustomercalls,Totalcallstodate=@totalcustcalldate  
  ,TotalcallIndex = @totcallindex where #Temp.date1 = @CursalesmanDate  
   
  set @ActualQuantity =0  
  set @ActualvolDate=0  
  set @actualvolindex = 0  
  set @TotalCustomercalls =0  
  set @totalcustcalldate =0  
        set @totcallindex = 0  
  
 FETCH NEXT FROM Salesman_Cursor INTO @CursalesmanDate     
 END      
CLOSE Salesman_Cursor            
DEALLOCATE Salesman_Cursor  
  
DECLARE Salesman_Cursor CURSOR FOR Select distinct CampaignName From #TmpCampaign      
OPEN Salesman_Cursor            
 FETCH NEXT FROM Salesman_Cursor INTO @CurCampaignName      
 WHILE @@FETCH_STATUS = 0            
 BEGIN                
 Set @Exec_Sql = 'Alter Table #Temp Add [' + @CurCampaignName + '] nVarchar(255)'     
 Exec sp_executesql @Exec_Sql       
 Set @Exec_Sql = 'Alter Table #Temp Add [' + @CurCampaignName + 'To Date] nVarchar(255)'       
 Exec sp_executesql @Exec_Sql  
 Set @Exec_Sql = 'Alter Table #Temp Add [' + @CurCampaignName + 'Index] nVarchar(255)'       
 Exec sp_executesql @Exec_Sql           
       
 FETCH NEXT FROM Salesman_Cursor INTO @CurCampaignName    
 END      
CLOSE Salesman_Cursor            
DEALLOCATE Salesman_Cursor   
  
DECLARE Salesman_Cursor CURSOR FOR Select distinct  CampaignID,CampaignName,salesmancode,CampaignDate From #TmpCampaign      
OPEN Salesman_Cursor            
 FETCH NEXT FROM Salesman_Cursor INTO @CurCampaignID,@CurCampaignName,@CurSalesmanCode,@CurCampaigndate      
 WHILE @@FETCH_STATUS = 0            
 BEGIN                
  
 set @distrubutionCall = Isnull((select Isnull(CampaignDrives.response,0)    
      from CampaignDrives,sVabstract  
      where sVabstract.salesmancode = @CurSalesmanCode    
      And Dbo.StripDateFromTime(sVabstract.svdate) = @CurCampaigndate   
      And sVabstract.Svnumber = CampaignDrives.svnumber  
      And ((IsNull(svabstract.Status,0) & 128) = 0)  
      And ((IsNull(svabstract.Status,0) & 32) = 0)  
   And CampaignDrives.CampaignID =  @CurCampaignID ),0)  
  
 Set @Exec_Sql = 'Update #Temp set [' + @CurCampaignName + '] = ''' + cast(@distrubutionCall as varchar) + ''''   
      + ' Where Dbo.StripDateFromTime(#temp.Date1) = ''' +  cast(Dbo.StripDateFromTime(@CurCampaigndate)  as varchar) + ''''  
  
 Exec sp_executesql @Exec_Sql       
   
 set @distrubutionDate = Isnull((select Isnull(CampaignDrives.response,0)    
    From CampaignDrives,sVabstract    
    Where sVabstract.salesmancode = @CurSalesmanCode  
    And Dbo.StripDateFromTime(sVabstract.svdate) between @insertfromdate  
    And @CurCampaigndate  
       And ((IsNull(svabstract.Status,0) & 128) = 0)  
       And ((IsNull(svabstract.Status,0) & 32) = 0)  
    And sVabstract.Svnumber = CampaignDrives.svnumber  
    And CampaignDrives.CampaignID = @CurCampaignID),0)  
   
 Set @Exec_Sql = 'Update #Temp set [' + @CurCampaignName + 'To date] = ' + cast(@distrubutionDate as varchar) + ''  
      + ' Where Dbo.StripDateFromTime(#temp.Date1) = ''' +  cast(Dbo.StripDateFromTime(@CurCampaigndate)  as varchar) + ''''  
 Exec sp_executesql @Exec_Sql    
  
 if @distrubutionCall = 0  
  set @distrubutionindex = 0  
 else  
  set @distrubutionindex = (@distrubutionDate / @distrubutionCall)   
  
 Set @Exec_Sql = 'Update #Temp set [' + @CurCampaignName + 'Index] = ' + cast(@distrubutionindex as varchar) + ''  
      + ' Where Dbo.StripDateFromTime(#temp.Date1) = ''' +  cast(Dbo.StripDateFromTime(@CurCampaigndate)  as varchar) + ''''  
 Exec sp_executesql @Exec_Sql     
  
 Set @distrubutionCall =0  
 Set @distrubutionDate =0  
  
 FETCH NEXT FROM Salesman_Cursor INTO  @CurCampaignID,@CurCampaignName,@CurSalesmanCode,@CurCampaigndate      
 END      
CLOSE Salesman_Cursor            
DEALLOCATE Salesman_Cursor   
  
select * from #temp  
drop table #temp  
  
  


