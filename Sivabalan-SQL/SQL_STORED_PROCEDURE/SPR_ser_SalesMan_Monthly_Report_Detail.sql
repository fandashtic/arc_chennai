CREATE Procedure SPR_ser_SalesMan_Monthly_Report_Detail(
@SalesManId Int,    
@FromDate DateTime,    
@ToDate DateTime,    
@Val_Volume Varchar(50))    
as    
    
DECLARE @oriFromDate DateTime    
DECLARE @oriToDate DateTime    
Declare @DynSQL varchar(8000)    
Declare @CumQty Decimal(18,6)    
Declare @CumVal Decimal(18,6)    
    
Create Table #Temp2(ItemCode Varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, QtyVal Decimal(18,6),Value Decimal(18,6))    
Create Table #FinalResult(ICode Varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemCode Varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemName Varchar(255))    
    
CREATE tABLE #dATECALENDAR    
(    
calid INTEGER IDENTITY(1,1),    
volumecolumn VARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS,  --Qty    
valuecolumn VARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS, --Value    
fromdate DATETIME,    
todate datetime)    
    
DECLARE @VolumeColumn varchar(1000)    
DECLARE @ValueColumn varchar(1000)    
    
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
		Select DateName(Month,@Fromdate) + Cast(year(@Fromdate) as varchar(5))+ 'Qty' ,DateName(Month,@Fromdate) + Cast(Year(@fromdate) as varchar(5)) +'Val',@Fromdate, dbo.MakeDayEnd(@Todate)    
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
   		Select DateName(Month,@TempFromdate) + Cast(year(@TempFromdate) as varchar(5))+ 'Qty' ,DateName(Month,@TempFromdate) + Cast(Year(@Tempfromdate) as varchar(5)) +'Val',@TempFromdate, dbo.MakeDayEnd(@TempTodate)    
    
    Select @TempFromdate=Dateadd(d,1,@TempTodate)        
    Select @Diff=@diff -1    
  End      
 End    
    
 Insert into #FinalResult (ICode, ItemCode, ItemName)    
   Select Distinct(InvoiceDetail.Product_Code),InvoiceDetail.Product_Code,Items.ProductName    
   From Items,InvoiceDetail,InvoiceAbstract    
   Where Items.Product_Code=Invoicedetail.Product_Code    
   And IsNull(InvoiceAbstract.Status,0) & 128=0    
   And InvoiceAbstract.Invoiceid=Invoicedetail.InvoiceId    
   And InvoiceAbstract.InvoiceDate between @Orifromdate and @oritodate    
   And ISnull(InvoiceAbstract.Salesmanid,0) =@Salesmanid    
   And InvoiceAbstract.Invoicetype in (1,3,4)    

 --Begin: Service Invoice Impact    
 Insert into #FinalResult (ICode, ItemCode, ItemName)    
   Select Distinct(SID.SpareCode),SID.SpareCode,Items.ProductName    
   From Items,ServiceInvoiceDetail SID,ServiceInvoiceAbstract SIA
   Where Items.Product_Code=isNull(SID.SpareCode,'')
   And SIA.ServiceInvoiceid=SID.ServiceInvoiceId    
   And isNull(SIA.Status,0) & 192 = 0    
   And SIA.ServiceInvoiceDate between @Orifromdate and @oritodate    
   And SIA.ServiceInvoicetype in (1) and @Salesmanid = 0
   And not Exists (select ICode from #FinalResult where ICode = isNull(SID.SpareCode,''))
--End: Service Invoice Impact

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
   Insert into #temp2      
     Select ItemCode,Sum(isNull(Qty,0)),Sum(isNull(Value,0)) from 	(
        Select #FinalResult.Itemcode,"Qty" = sum(Case InvoiceType When 4 then 0-Quantity Else Quantity end),  
                "Value" = Sum(Case InvoiceType When 4 then 0-Invoicedetail.Amount else Invoicedetail.Amount End )  
	     From InvoiceDetail,#FinalResult,INvoiceabstract    
	     Where #Finalresult.ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS = Invoicedetail.Product_Code    
	     And IsNull(InvoiceAbstract.Status,0) & 128=0    
	     And InvoiceAbstract.Invoiceid=Invoicedetail.InvoiceId    
	     And InvoiceAbstract.InvoiceDate between @fromdate and @todate    
	     And ISnull(InvoiceAbstract.Salesmanid,0) =@Salesmanid    
	     And InvoiceAbstract.Invoicetype in (1,3,4)    
	     Group by #Finalresult.ItemCode    

		--Begin: Service Module Impact
		Union All
		Select #FinalResult.Itemcode,sum(isNull(Quantity,0)),  
	                Sum(isNull(SID.NetValue,0))
	     From ServiceInvoiceDetail SID,#FinalResult,ServiceInvoiceabstract SIA
	     Where #Finalresult.ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS = isNull(SID.Sparecode,'')
	     And IsNull(SIA.Status,0) & 192 = 0    
	     And SIA.ServiceInvoiceid=SID.ServiceInvoiceId    
	     And SIA.ServiceInvoiceDate between @fromdate and @todate    
	     And SIA.ServiceInvoicetype in (1) and @Salesmanid = 0
	     And isNull(SID.SpareCode,'') <> '' 
		Group by #FinalResult.ItemCode
		--End: Service Module Impact    
	) as ResultSet
	Group by ItemCode

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
Drop table #DATECALENDAR    
Drop table #FinalResult    
Drop table #temp2    


