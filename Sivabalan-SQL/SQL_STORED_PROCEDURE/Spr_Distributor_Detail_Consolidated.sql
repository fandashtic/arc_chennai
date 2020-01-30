
Create Procedure Spr_Distributor_Detail_Consolidated(@ItemCode nVarchar(30),@Category nvarchar(30), @Channel nvarchar(30), @Uom nVarchar(50), @FromDate Datetime, @Todate DateTime)               
As                  
Declare @Delimeter as Char(1)                          
Declare @Voucher as nVarchar(10)              
Set @Delimeter=Char(15)                  
Declare @ComIDReport NVarchar(50)
Declare @ComIDSetup NVarchar(50)
Declare @RecID NVarchar(50)
Set DateFormat DMY                  
set @Voucher = (Select Prefix From VoucherPrefix Where TranId = N'Invoice')              
Set @FromDate= dbo.StripDateFromTime(@FromDate)          
Set @Todate= dbo.StripDateFromTime(@Todate)         
             
Create Table #TmpChannel( ChannelType nVarchar(30) collate SQL_Latin1_General_CP1_CI_AS)              
Insert into #TmpChannel(ChannelType) Values('')
if @Channel ='%'  
   Insert into #TmpChannel select ChannelType from customer
Else                      
   Insert into #TmpChannel Select ChannelType From customer_channel Where ChannelDesc In (select * from dbo.sp_SplitIn2Rows(@Channel,@Delimeter))                      
                   
Create Table #TmpChannelName(ChannelName NVarChar(255))  
Insert into #TmpChannelName(ChannelName) Values('')
Insert Into #TmpChannelName Select ChannelDesc From Customer_Channel Where ChannelType In(Select ChannelType From #TmpChannel)  
          
Create Table #TmpDistribut(CustomerID nVarchar(15) collate SQL_Latin1_General_CP1_CI_AS,[Cust Code] nVarchar(15) collate SQL_Latin1_General_CP1_CI_AS,
[Cust Name] nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,[Cust Channel] nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,          
[Quantity] Decimal(18,6),[Sales Value] Decimal(18,6),[Last Purchased On] DateTime,[Invoice No] nVarchar(30) collate SQL_Latin1_General_CP1_CI_AS, [Doc No] nVarchar(30) collate SQL_Latin1_General_CP1_CI_AS)          

Select @ComIDReport = Right(@ItemCode,(Select Len(RegisteredOwner) From Setup))

Select @ComIDSetup = RegisteredOwner From Setup 

If @ComIDReport = @ComIDSetup 

Begin

Select @ItemCode = Left(@ItemCode,Len(@ItemCode)-(Select Len(RegisteredOwner) From Setup))

Insert Into #TmpDistribut(CustomerID,[Cust Code],[Cust Name],[Cust Channel],      
[Quantity],[Sales Value],[Last Purchased On],[Invoice No] , [Doc No])      
      
Select CUST.CustomerID, CUST.CustomerID, CUST.Company_Name,
	(Select ChannelDesc From Customer_Channel CC Where CC.ChannelType = CUST.ChannelType) ,              
          
 -- Quantity      
(              
 case @UOM                  
   when 'Conversion Factor' then isnull(sum((case invoicetype when 4 then (0 - (INVDT.Quantity))when 5 then (0 - (INVDT.Quantity))when 6 then (0 - (INVDT.Quantity))             
 else (INVDT.Quantity) end) * (case when isnull(IT.conversionfactor,0)=0 then 1 else IT.conversionfactor end)),0)                          
   when 'Reporting UOM'     then isnull(sum((case invoicetype when 4 then (0 - (INVDT.Quantity))when 5 then (0 - (INVDT.Quantity))when 6 then (0 - (INVDT.Quantity))            
  else (INVDT.Quantity) end) / (case when isnull(IT.reportingunit,0)=0  then 1 else IT.reportingunit end)),0)                          
   When 'UOM 1'             then isnull(sum((case invoicetype when 4 then (0 - (INVDT.Quantity))when 5 then (0 - (INVDT.Quantity))when 6 then (0 - (INVDT.Quantity))             
 else (INVDT.Quantity) end) / (Case when isnull(IT.uom1_conversion,0)=0  then 1 else IT.uom1_conversion end)),0)                          
   when 'UOM 2'             then isnull(sum((case invoicetype when 4 then (0 - (INVDT.Quantity))when 5 then (0 - (INVDT.Quantity))when 6 then (0 - (INVDT.Quantity))             
 else (INVDT.Quantity) end) / (case when isnull(IT.uom2_conversion,0)=0 then 1 else IT.uom2_conversion end)),0)                          
   else                          isnull(sum( case invoicetype when 4 then (0 - (INVDT.Quantity))when 5 then (0 - (INVDT.Quantity))when 6 then (0 - (INVDT.Quantity)) else (INVDT.Quantity) end),0) end    ),              
          
--Sales Value      
 SUM(Case When INVAB.InvoiceType In (4,5,6) Then (0 - INVDT.Amount) Else INVDT.Amount End),                
          
--Last Purchased On      
(Select MAX(INV.InvoiceDate) From Invoiceabstract Inv, InvoiceDetail IDT Where Inv.InvoiceId = IDT.InvoiceID And dbo.StripDateFromTime(Inv.InvoiceDate) >= @FromDate And dbo.StripDateFromTime(Inv.InvoiceDate) <=@ToDate And IDT.Product_Code = @ItemCode     
  
         
 And INV.CustomerID = CUST.CustomerID And (IsNull(INV.Status,0) & 192) = 0 ),              
          
--Invoice No      
(Select @Voucher + Cast(DocumentId as Varchar) From Invoiceabstract Where InvoiceId = (Select MAX(INV.InvoiceId) From Invoiceabstract Inv, InvoiceDetail IDT Where  Inv.InvoiceId = IDT.InvoiceID And dbo.StripDateFromTime(Inv.InvoiceDate) >= @FromDate      
  
     
And dbo.StripDateFromTime(Inv.InvoiceDate) <=@ToDate And IDT.Product_Code = @ItemCode And INV.CustomerID = CUST.CustomerID And (IsNull(INV.Status,0) & 192) = 0 )),              
          
--Doc No      
(Select Distinct(DocReference) From Invoiceabstract Where DocumentID  in (Select Max(INV.DocumentID) From Invoiceabstract Inv, InvoiceDetail IDT Where Inv.InvoiceId = IDT.InvoiceID And dbo.StripDateFromTime(Inv.InvoiceDate) >= @FromDate           
And dbo.StripDateFromTime(Inv.InvoiceDate)<= @ToDate And IDT.Product_Code = @ItemCode And INV.CustomerID = CUST.CustomerID) And (IsNull(Status,0) & 192) = 0 )
          
From  Customer CUST  ,InvoiceAbstract INVAB, InvoiceDetail INVDT, Items IT
Where  
	INVAB.InvoiceID = INVDT.InvoiceID                
 And (IsNull(INVAB.Status,0) & 128) = 0  
 And IsNull(CUST.ChannelType,'') In (Select ChannelType collate SQL_Latin1_General_CP1_CI_AS From #TmpChannel)              
 And INVAB.CustomerId = CUST.CustomerID               
 And dbo.StripDateFromTime(INVAB.InvoiceDate) >= @FromDate               
 And dbo.StripDateFromTime(INVAB.InvoiceDate) <= @ToDate               
 And INVDT.Product_code = @ItemCode               
 And INVDT.Product_code = IT.Product_Code              
 And CUST.CustomerCategory <> 4               
 And CUST.CustomerCategory <> 5              
Group By CUST.CustomerID, CUST.Company_Name,CUST.ChannelType

Select * from #TmpDistribut      

Drop Table #TmpDistribut          

End
              
Else

Begin

Select @RecID = Left(@ItemCode,CharIndex(Char(15),@Itemcode)-1)
Select @ItemCode = Substring(@ItemCode,CharIndex(Char(15),@ItemCode) + 1,Len(@ItemCode)- CharIndex(Char(15),@ItemCode))    
Select
'',
"Cust Code" = ReportDetailReceived.Field1,
"Cust Name" = ReportDetailReceived.Field2,
"Cust Channel" = ReportDetailReceived.Field3,
"Quantity" = 
Case @UOM
When N'Base UOM' Then 
ReportDetailReceived.Field4
When N'Conversion Factor' Then 
ReportDetailReceived.Field4 * IsNull(Items.ConversionFactor,1)
When N'UOM 1' Then 
ReportDetailReceived.Field4 / IsNull(Items.UOM1_Conversion,1)
When N'UOM 2' Then 
ReportDetailReceived.Field4 / IsNull(Items.UOM2_Conversion,1)
When N'Reporting UOM' Then 
ReportDetailReceived.Field4 / IsNull(Items.ReportingUnit,1)
End,
"Sales Value" = ReportDetailReceived.Field5,
"Last Purchased On" = ReportDetailReceived.Field6,
"Invoice No" = ReportDetailReceived.Field7,
"Doc No" = ReportDetailReceived.Field8
From ReportDetailReceived,Items
Where 
ReportDetailReceived.Field1 <> N'Cust Code' And ReportDetailReceived.Field1 <> N'SubTotal:' And
ReportDetailReceived.Field1 <> N'GrandTotal:' And ReportDetailReceived.RecordID = @RecID And
IsNull(ReportDetailReceived.Field3,'') In (Select ChannelName collate SQL_Latin1_General_CP1_CI_AS From #TmpChannelName) And
Product_code = @Itemcode
End

Drop Table #TmpChannel
Drop Table #TmpChannelName

