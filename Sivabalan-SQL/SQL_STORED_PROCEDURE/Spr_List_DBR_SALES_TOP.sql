CREATE Procedure Spr_List_DBR_SALES_TOP(@beatdesc nvarchar(2550),@channelDesc nvarchar(2550),  
@cusCode nvarchar(2550),  
@UOMdesc nvarchar(30),@fromdate datetime,@todate datetime)  
As  
declare @execSql1 nvarchar(1500)  
  
Declare @Delimeter as Char(1)    
Declare @NOBEAT As NVarchar(50)

Set @NOBEAT = dbo.LookupDictionaryItem(N'No beat', Default)

Set @Delimeter=Char(15)    
  
Create table #tmpBeat([Description] nvarchar(255))    
Create table #tmpChnl(ChannelDesc nvarchar(255))    
Create table #tmpCus(CustomerID nvarchar(255))    
  
if @beatdesc='%'     
   Insert into #tmpBeat select [Description] from Beat    
Else    
   Insert into #tmpBeat select * from dbo.sp_SplitIn2Rows(@beatdesc, @Delimeter)    
    
if @channelDesc ='%'    
   Insert into #tmpChnl select ChannelDesc from Customer_Channel    
Else    
   Insert into #tmpChnl select * from dbo.sp_SplitIn2Rows(@channelDesc, @Delimeter)    
  
if @cusCode ='%'    
   Insert into #tmpCus select CustomerID from Customer    
Else    
   Insert into #tmpCus select * from dbo.sp_SplitIn2Rows(@cusCode, @Delimeter)    
  
  
Create table #temp1   
(  Custid nvarchar(30),  
   CustName nvarchar(30),  
   beatdesc nvarchar(30),  
   Channeldesc nvarchar(30)    
)  
  
Create table #temp2   
(  Custid nvarchar(30),  
   Productcode nvarchar(30),  
   CnvFactor Decimal(18,6),  
   ReportUnit Decimal(18,6),  
   Qty Decimal(18,6),  
   Amt Decimal(18,6),  
   defaultUOM integer,     
   ReportUOM integer,  
   ConvUOM integer,   
)  
  
set @execsql1='Set quoted_identifier off;Select Customer.CustomerID, Customer.Company_Name, Beat.Description,Customer_Channel.ChannelDesc '  
set @execSql1= @execSql1+ 'From (((Customer Left Outer Join Beat_Salesman On Customer.CustomerID = Beat_SalesMan.CustomerID) '  
set @execSql1= @execSql1+ 'Left Outer Join Beat On Beat.BeatID = Beat_Salesman.BeatID) '  
set @execSql1= @execSql1+ 'Left Outer Join Customer_Channel On Customer_Channel.ChannelType = Customer.ChannelType) Where 1=1 '  
  
if(@channeldesc <> '%')  
 begin  
  set @execSql1= @execSql1 + 'And Customer_Channel.ChannelDesc In (Select ChannelDesc From  #tmpChnl)'  
 end  
  
if(@cuscode <> '%')  
 begin  
  set @execSql1= @execSql1 + ' And Customer.CustomerID In ( Select CustomerID From #tmpCus)'  
 end  
  
if (@beatdesc <>'%')  
  
 begin  
  set @execSql1= @execSql1 + ' And Beat.Description In ( Select [Description] From  #tmpBeat )'  
 end  
  
  
  set @execSql1= @execSql1 + ' And Customer.Customerid in ( Select Customerid from InvoiceAbstract where Invoicedate between "'+  cast(@fromdate As nvarchar) + '" and "'+ cast(@Todate As nvarchar) + '" and  (Status & 128)=0 and InvoiceType <> 2)'        
  
insert into #temp1  
execute (@execsql1)  
  
  
insert into #temp2  
Select Invoiceabstract.CustomerId,Invoicedetail.Product_code,  
ConversionFactor,ReportingUnit,  
Case When Invoiceabstract.InvoiceType <> 4 then Invoicedetail.Quantity  
     Else 0-Invoicedetail.Quantity  
End,  
Case When Invoiceabstract.InvoiceType <> 4 then Invoicedetail.Amount  
     Else 0-Invoicedetail.Amount  
End,  
Items.UOM,Items.ReportingUOM,Items.ConversionUnit  
from Invoicedetail,Items,Invoiceabstract  
Where Invoicedetail.Product_code=Items.Product_code  
and Invoicedetail.Invoiceid=Invoiceabstract.Invoiceid  
and Invoiceabstract.CustomerId in ( Select Custid from #temp1)  
and Invoiceabstract.Invoicedate  between @fromdate and @todate  
and (Invoiceabstract.Status & 128)=0  
AND INvoiceabstract.InvoiceType <>2  
  
Update #temp2 set CnvFactor=1 where CnvFactor=0  
  
Declare @curcusid nvarchar(100)  
Declare  setCur  cursor For  
   Select Custid From #Temp1   
Open SetCur  
Fetch next from SetCur into @curcusid  
while @@fetch_status=0  
begin  
     Update #temp2  Set defaultUOM=(Select Max(DefaultUOM) from #temp2 where Custid=@curcusid)where Custid=@curcusid  
     Update #temp2 Set ReportUOM=(Select Max(ReportUOM) from #temp2 where Custid=@curcusid)where Custid=@curcusid  
     Update #temp2 Set ConvUOM= (Select MAx(ConvUOM) from #temp2 where Custid=@curcusid)where Custid=@curcusid  
     Fetch next from SetCur into @curcusid  
  
end  
close SetCur  
Deallocate SetCur  
  
if(@UOMDesc ='Sales UOM')  
   begin  
 Select #temp2.Custid,"Beat"=Case when #temp1.beatDESC IS NULL then @NOBEAT
                                         else #temp1.beatDESC  
                                     end,  
        "KOB"=#temp1.ChannelDesc,  
        "Customer Code"=#temp2.Custid, "Customer Name"=#temp1.CustName,   
        "Sales UOM"=dbo.fn_GetUOMDesc(#temp2.defaultUOM,0),       
        "Total Quantity"= Sum(#temp2.Qty),        
 "Sales Value"=Sum(#temp2.Amt) from #temp2,#temp1  
        Where #temp1.Custid=#temp2.Custid  
        Group by #temp2.custid,#temp1.CustName,#temp1.Channeldesc,#temp1.beatDESC,#temp2.defaultUOM  
   end  
  
else if(@UOMDesc ='Conversion Factor')  
   begin  
 Select #temp2.Custid,"Beat"=Case when #temp1.beatDESC IS NULL then @NOBEAT
                                         else #temp1.beatDESC  
                                     end,  
        "KOB"=#temp1.ChannelDesc,  
        "Customer Code"=#temp2.Custid, "Customer Name"=#temp1.CustName,   
        "Conversion Factor UOM"=dbo.fn_GetUOMDesc(#temp2.ConvUOM,1),       
        "Total Quantity"= Sum(#temp2.Qty * #temp2.CnvFactor),        
 "Sales Value"=Sum(#temp2.Amt) from #temp2,#temp1  
        Where #temp1.Custid=#temp2.Custid  
        Group by #temp2.custid,#temp1.CustName,#temp1.Channeldesc,#temp1.beatDESC,#temp2.ConvUOM  
   end  
else   
   begin  
 Select #temp2.Custid,"Beat"=Case when #temp1.beatDESC IS NULL then @NOBEAT
                                         else #temp1.beatDESC  
                                     end,  
        "KOB"=#temp1.ChannelDesc,  
        "Customer Code"=#temp2.Custid, "Customer Name"=#temp1.CustName,   
        "Reporting UOM"=dbo.fn_GetUOMDesc(#temp2.ReportUOM,0),       
        "Total Quantity"=Sum(#temp2.Qty/#temp2.ReportUnit),        
 "Sales Value"=Sum(#temp2.Amt) from #temp2,#temp1  
        Where #temp1.Custid=#temp2.Custid  
        Group by #temp2.custid,#temp1.CustName,#temp1.Channeldesc,#temp1.beatDESC,#temp2.ReportUOM  
  end  
  
  
  
drop table #temp1  
drop table #temp2  
drop table #tmpBeat  
drop table #tmpChnl  
drop table #tmpCus  

