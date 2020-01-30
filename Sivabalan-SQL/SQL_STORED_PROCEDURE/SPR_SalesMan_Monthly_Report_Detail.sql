CREATE Procedure SPR_SalesMan_Monthly_Report_Detail(    
@SalesManId Int,    
@FromDate DateTime,    
@ToDate DateTime,    
@Val_Volume nVarchar(50))    
as    
    
dECLARE @oriFromDate DateTime    
dECLARE @oriToDate DateTime    
Declare @DynSQL nvarchar(4000)    
Declare @CumQty Decimal(18,6)    
Declare @CumVal Decimal(18,6)    
Set @Val_Volume = dbo.LookupDictionaryItem2(@Val_Volume, Default)
    
Create Table #Temp2(ItemCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, QtyVal Decimal(18,6),Value Decimal(18,6))    
Create Table #FinalResult(ICode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemName nVarchar(255))    
    
cREATE tABLE #dATECALENDAR    
(    
calid INTEGER IDENTITY(1,1),    
volumecolumn nVARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS,  --Qty    
valuecolumn nVARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS, --Value    
fromdate DATETIME,    
todate datetime)    
    
dECLARE @VolumeColumn nvarchar(1000)    
dECLARE @ValueColumn nvarchar(1000)    
    
Declare @TempFromDate datetime    
Declare @TempToDate datetime    
Declare @diff integer    
Declare @cont integer    
    
    
    
    
Set dateformat dmy    
Select @oriFromdate=@Fromdate    
Select @oriTodate=@Todate    
    
Select @Fromdate=Dbo.Stripdatefromtime(@Fromdate)    
Select @Todate=Dbo.Stripdatefromtime(@Todate)    
    
Select  @Diff = Datediff(m,@FromDate,@ToDate)    
If(@diff=0)    
 Begin    
  Insert into #dateCalendar    
   Select DateName(Month,@Fromdate) + Cast(year(@Fromdate) as nvarchar(5))+ 'Qty' ,DateName(Month,@Fromdate) + Cast(Year(@fromdate) as nvarchar(5)) +'Val',@Fromdate, dbo.MakeDayEnd(@Todate)    
 End    
Else    
 Begin     
  Select @TempFromdate=@Fromdate      
  Select @diff=@diff+1    
  While (@Diff >0)    
  Begin    
   Select @Temptodate=Dateadd(d,0-Datepart(d,dateadd(m,1,@tempFromdate)),dateadd(m,1,@tempFromdate))    
   If(@temptodate >=@todate) Select @temptodate=@todate    
   Insert into #dateCalendar        
    Select DateName(Month,@TempFromdate) + Cast(year(@TempFromdate) as nvarchar(5))+ 'Qty' ,DateName(Month,@TempFromdate) + Cast(Year(@Tempfromdate) as nvarchar(5)) +'Val',@TempFromdate, dbo.MakeDayEnd(@TempTodate)    
    
    Select @TempFromdate=Dateadd(d,1,@TempTodate)        
    Select @Diff=@diff -1    
  End      
 End    
    
 Insert into #FinalResult (ICode, ItemCode, ItemName)    
   Select Distinct(InvoiceDetail.Product_Code),InvoiceDetail.Product_Code,Items.ProductName    
   From Items,InvoiceDetail,InvoiceAbstract    
   Where Items.Product_Code=Invoicedetail.Product_Code    
   And InvoiceAbstract.Status & 128=0    
   And InvoiceAbstract.Invoiceid=Invoicedetail.InvoiceId    
   And InvoiceAbstract.InvoiceDate between @Orifromdate and @oritodate    
   And ISnull(InvoiceAbstract.Salesmanid,0) =@Salesmanid    
   And InvoiceAbstract.Invoicetype in (1,3,4)    
    
 Declare InvoiceInfo cURSOR For    
  Select VolumeColumn,ValueColumn,Fromdate,Todate from #datecalendar    
 Open InvoiceInfo    
  Fetch next From InvoiceInfo into @VolumeColumn,@ValueColumn,@Fromdate,@Todate    
 While @@FETCH_STATUS = 0              
 Begin              
  --Create Dynamic Col    
  If ((@Val_Volume = 'Qty') or (@Val_Volume ='All'))     
   Begin    
    Set @DynSQL = 'Alter Table #FinalResult ADD [' + @VolumeColumn + '] Decimal(18,6) default(0) not null'                    
    exec (@DynSQL)     
   End    
  If ((@Val_Volume = 'Value') or (@Val_Volume ='All'))     
   Begin    
    Set @DynSQL = 'Alter Table #FinalResult ADD [' + @ValueColumn + '] Decimal(18,6) default(0) not null'                     
    exec (@DynSQL)     
   End    
       
   Delete  from #temp2    
    
  --fetch Values      
    INsert into #temp2      
  
        Select #FinalResult.Itemcode,sum(Case InvoiceType When 4 then 0-Quantity Else Quantity end),  
                Sum(Case InvoiceType When 4 then 0-Invoicedetail.Amount else Invoicedetail.Amount End )  
     From InvoiceDetail,#FinalResult,INvoiceabstract    
     Where #Finalresult.ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS = Invoicedetail.Product_Code    
     And InvoiceAbstract.Status & 128=0    
     And InvoiceAbstract.Invoiceid=Invoicedetail.InvoiceId    
     And InvoiceAbstract.InvoiceDate between @fromdate and @todate    
     And ISnull(InvoiceAbstract.Salesmanid,0) =@Salesmanid    
     And InvoiceAbstract.Invoicetype in (1,3,4)    
     Group by #Finalresult.ItemCode    
    
   If ((@Val_Volume = 'Qty') or (@Val_Volume ='All'))     
   Begin    
    Set @DynSQL ='Update #FinalResult Set [' + @VolumeColumn + ']= #temp2.QtyVal From #FinalResult,#Temp2 Where #temp2.Itemcode COLLATE SQL_Latin1_General_CP1_CI_AS=#FinalResult.ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS'     
    exec (@DynSQL)     
   End    
   If ((@Val_Volume = 'Value') or (@Val_Volume ='All'))     
   Begin    
    Set @DynSQL ='Update #FinalResult Set [' + @ValueColumn + ']= #temp2.Value From #FinalResult,#Temp2 Where #temp2.Itemcode COLLATE SQL_Latin1_General_CP1_CI_AS=#FinalResult.ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS'     
    exec (@DynSQL)     
   End    
  Fetch next From InvoiceInfo into @VolumeColumn,@ValueColumn,@Fromdate,@Todate    
 End    
 Close InvoiceInfo    
 Deallocate InvoiceInfo    
    
Select * from #FinalResult    
-- Select * from #datecalendar    
Drop table #dATECALENDAR    
Drop table #FinalResult    
Drop table #temp2    


