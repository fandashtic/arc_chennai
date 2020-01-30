Create Procedure spr_OpenReceivedDO (@Manufacturer nVarchar(100),@AsOnDate DateTime)
as
Declare @WDCode NVarchar(255),@WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)
Declare @Delimeter Char(1)
Set @Delimeter = Char(15)
Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload        
Select Top 1 @WDCode = RegisteredOwner From Setup
set dateformat dmy
set @Manufacturer ='%'
Create Table #TempManufacturer(Mname nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
If @Manufacturer = N'%'
Insert into #TempManufacturer Select Manufacturer_Name From Manufacturer
else
Insert into #TempManufacturer Select * From Dbo.sp_SplitIn2Rows(@Manufacturer, @Delimeter)
If @CompaniesToUploadCode='ITC001'        
Begin        
 Set @WDDest= @WDCode        
End        
Else        
Begin        
 Set @WDDest= @WDCode        
 Set @WDCode= @CompaniesToUploadCode        
End    
Create Table #TempConsolidateOpenDO ([WD Code] NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[WD Dest] NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
 [InvoiceNo] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[InvoiceDate] Datetime,
 [Item Code] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Item Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
 [Invoiced Qty] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Processed Qty] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #TempInvNo (InvoiceId Integer)
Insert Into #TempInvNo select Distinct RA.InvoiceID as InvoiceID from InvoiceAbstractReceived RA,InvoiceDetailReceived RD,Items I, Manufacturer M 
Where IsNull(RA.status,0) & 1 = 0 and IsNull(RA.Status,0) & 32 <> 0  and
RA.InvoiceDate<=dbo.StripDateFromTime(@AsOnDate) and
RA.InvoiceID=RD.InvoiceID and
I.Active = 1 and
RD.Product_code=I.Product_code and
IsNull(RD.Pending,0) <> 0 and
I.ManufacturerID = M.ManufacturerID and
M.Manufacturer_name In (Select MName from #TempManufacturer)

Insert Into #TempConsolidateOpenDO ([WD Code] ,[WD Dest] ,[InvoiceNo],[InvoiceDate], [Item Code],[Item Name],[Invoiced Qty],[Processed Qty])
select "WD Code"=@WDCode,"WD Dest"=@WDDest,
"InvoiceNo"=RA.DocumentID,
"InvoiceDate"=RA.InvoiceDate,
"Item Code" = RD.Product_code,
"Item Name" =I.ProductName,
"Invoiced Qty" = Sum(IsNull(RD.Quantity,0)),
"Processed Qty" = Sum(IsNull(RD.Quantity,0)) - Sum(IsNull(RD.Pending,0))
from InvoiceAbstractReceived RA,InvoiceDetailReceived RD,Items I,#TempInvNo TI--, Manufacturer M 
Where --IsNull(RA.status,0) & 1 = 0 and IsNull(RA.Status,0) & 32 <> 0  and
--RA.InvoiceDate<=dbo.StripDateFromTime(@AsOnDate) and
RA.InvoiceID=TI.InvoiceID and
RA.InvoiceID=RD.InvoiceID and
I.Active = 1 and
RD.Product_code=I.Product_code --and
--IsNull(RD.Pending,0) <> 0 and
--I.ManufacturerID = M.ManufacturerID and
--M.Manufacturer_name In (Select MName from #TempManufacturer)
Group by RA.InvoiceDate,RD.Product_code,I.ProductName,RA.DocumentID
--Select * From #TempConsolidateOpenDO    
--Consolidate
Declare @SUBTOTAL NVarchar(50)        
Declare @GRNTOTAL NVarchar(50) 
Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)         
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)         

If (Select Count(*) From Reports Where ReportName = 'Open Received DO' And ParameterID in         
 (Select ParameterID From dbo.GetReportParametersForCPL('Open Received DO') Where         
 ToDate = dbo.StripDateFromTime(@AsOnDate))) >=1        
Begin        
 Insert Into #TempConsolidateOpenDO ([WD Code] ,[WD Dest] ,[InvoiceNo],[InvoiceDate], [Item Code],[Item Name],[Invoiced Qty],[Processed Qty])
 Select 
 "WD Code" = ReportDetailReceived.Field1,  
 "WD Dest" = ReportDetailReceived.Field2,    
 "InvoiceNo"=ReportDetailReceived.Field3,
"InvoiceDate"=ReportDetailReceived.Field4,
"Item Code" = ReportDetailReceived.Field5,
"Item Name" =ReportDetailReceived.Field6,
"Invoiced Qty" = ReportDetailReceived.Field7,
"Processed Qty" = ReportDetailReceived.Field8 
 From ReportAbstractReceived,ReportDetailReceived,Items
 Where ReportAbstractReceived.RecordID = ReportDetailReceived.RecordID And       
 ReportAbstractReceived.ReportID in                 
  (Select Distinct ReportID From Reports                       
  Where ReportName = 'Open Received DO'
  And ParameterID in (Select ParameterID From dbo.GetReportParametersForCPL('Open Received DO') Where                
  ToDate =  dbo.StripDateFromTime(@AsOnDate)))        
 And ReportDetailReceived.Field1 <> @SUBTOTAL            
 And ReportDetailReceived.Field1 <> @GRNTOTAL         
End      
--Select "WD Code",* From #TempConsolidateOpenDO Order By [WD Code] ,[WD Dest] , [InvoiceNo],[InvoiceDate], [Item Code]
Select [WD Code] As WDCode, [WD Code],[WD Dest] ,[InvoiceNo],[InvoiceDate], [Item Code],[Item Name],"Invoiced Qty" = cast([Invoiced Qty] as Decimal(18,6)),"Processed Qty" = Cast([Processed Qty] as Decimal(18,6)) From #TempConsolidateOpenDO Order By [WD Code] ,[WD Dest] , [InvoiceNo],[InvoiceDate], [Item Code]
