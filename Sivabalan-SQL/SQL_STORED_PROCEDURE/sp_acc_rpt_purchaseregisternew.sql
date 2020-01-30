CREATE procedure sp_acc_rpt_purchaseregisternew(@fromdate datetime,@todate datetime,@TaxSplitUps nVarchar(4000))    
as          
DECLARE @LOCAL integer,@OUTSTATION integer,@vendorid nvarchar(15),@documentid integer,@locality integer          
DECLARE @billdate datetime,@value decimal(18,6),@tax decimal(18,6),@status integer,@prefix nvarchar(10)          
DECLARE @billid integer,@vendor nvarchar(30),@DOCTYPE integer,@returnprefix nvarchar(10),@RETURNTYPE integer          
DECLARE @returncount integer,@purchasecount integer,@invaliddate datetime          
          
DECLARE @LSTPurchase decimal(18,6)          
DECLARE @LST decimal(18,6)          
DECLARE @CSTPurchase decimal(18,6)          
DECLARE @CST decimal(18,6)          
          
DECLARE @LSTReturn decimal(18,6)          
DECLARE @CSTReturn decimal(18,6)          
          
DECLARE @PurchaseTotal decimal(18,6)          
DECLARE @ReturnTotal decimal(18,6)          
          
DECLARE @taxpercent nvarchar(128),@taxamount decimal(18,6),@purchase decimal(18,6)          
DECLARE @sztax nvarchar(20)          
DECLARE @DynamicSQL nvarchar(4000)          
DECLARE @Unused1 int          
DECLARE @szbill nvarchar(15)          
          
DECLARE @PURCHASETYPE nvarchar(30)          
DECLARE @PURCHASERETURNTYPE nvarchar(30)          
        
Declare @ToDatePair datetime        
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))        
          
SET @PURCHASETYPE = dbo.LookupDictionaryItem('Purchase',Default)          
SET @PURCHASERETURNTYPE = dbo.LookupDictionaryItem('Purchase Return',Default)          
          
SET @LOCAL =1          
SET @OUTSTATION =2          
SET @DOCTYPE=8           
SET @RETURNTYPE=11          
          
select @prefix = [Prefix] from [VoucherPrefix] where [TranID]=N'BILL'           
select @returnprefix =[Prefix] from [VoucherPrefix] where [TranID]=N'STOCK ADJUSTMENT PURCHASE RETURN'          
    
set dateformat dmy          
          
CREATE table #temp(BillID nvarchar(50),[Bill Date] datetime,Vendor nvarchar(255), ActualID integer,DocType integer,[Description] nvarchar(30), TaxType nvarchar(128), TaxAmount Decimal(18,6) null)          
          
CREATE table #TempPurchaseRegister(BillID nvarchar(50),[Bill Date] datetime,Vendor nvarchar(255),          
ActualID integer,DocType integer,[Document Reference] nvarchar(255),[LST No.] nvarchar(30),[CST No.] nvarchar(30),[TIN No.] nvarchar(100),[Description] nvarchar(30),Adjustments Decimal(18,6),Payments Decimal(18,6))          
------------------------CREATE TABLE TO STORE TAX % FOR PURCHASE RETURN----------------------    
Create Table #TempPurchaseReturnTax(LocalTax Decimal(18,6),CentralTax Decimal(18,6))    
----------------------------CREATE TABLES TO STORE TAX % SPLITUPS----------------------------    
Create Table #TempFirstSplit(DocumentID INT IDENTITY (1,1),FirstSplitRecords nvarchar(4000))        
Create Table #TempSecondSplit(SecondSplitRecords nvarchar(4000))        
-----------------------------------DECLARE CONSTANTS HERE------------------------------------    
DECLARE @FIRSTSPLIT nvarchar(15),@SECONDSPLIT nvarchar(15)        
DECLARE @ALL INT, @EXEMPTED INT, @TAXPERCENTAGES INT, @STATE INT    
DECLARE @PurchaseRegModeAll INT, @PurchaseRegModeExempted INT, @PurchaseRegModeTaxValues nvarchar(4000)    
---------------------------------SET VALUES FOR CONSTANTS HERE-------------------------------    
SET @ALL = 1    
SET @EXEMPTED = 2    
SET @TAXPERCENTAGES = 3    
SET @STATE = 1    
SET @FIRSTSPLIT = Char(1)        
SET @SECONDSPLIT = Char(2)         
-------------------------------------GET TAXMODE SPLITUPS------------------------------------    
Insert #TempFirstSplit        
Exec Sp_acc_SQLSplit @TaxSplitUps,@FIRSTSPLIT       
---------------------------ASSIGN THEM IN SALES REG MODE VARIABLES---------------------------    
Select @PurchaseRegModeAll = Cast(IsNull(FirstSplitRecords,0) As INT) from #TempFirstSplit Where DocumentID = @ALL    
Select @PurchaseRegModeExempted = Cast(IsNull(FirstSplitRecords,0) As INT) from #TempFirstSplit Where DocumentID = @EXEMPTED    
Select @PurchaseRegModeTaxValues = IsNull(FirstSplitRecords,N'') from #TempFirstSplit Where DocumentID = @TAXPERCENTAGES    
--------------------IF MODE = ALL THEN DISPLAY ALL RECORDS AS PER OLD DESIGN-----------------    
If @PurchaseRegModeAll = @STATE    
 BEGIN          
  insert into #temp          
  select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar) ,max(BillDate),          
  'Vendor' = dbo.GetVendor(max([BillAbstract].[BillID]),0),max([BillAbstract].[BillID]),@DOCTYPE,          
  @PURCHASETYPE,"TaxType" = cast(TaxSuffered as nvarchar) + dbo.LookupDictionaryItem('% Tax',Default), "Value" =sum([BillDetail].[TaxAmount])          
  from [BillDetail],[BillAbstract],[Vendors] where [BillDate] between @fromdate and @ToDatePair          
  and [BillAbstract].[BillID]= [BillDetail].[BillID]and [BillAbstract].[VendorID] = [Vendors].[VendorID]          
  and isnull([Vendors].[Locality],0)=@LOCAL and [TaxSuffered]<> 0 AND (isnull(Status,0) & 128) = 0 AND           
  (isnull(Status,0) & 64)=0 Group By [BillDetail].[BillID], cast(TaxSuffered as nvarchar) + dbo.LookupDictionaryItem('% Tax',Default)          
  union all          
  select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar),max(BillDate),          
  'Vendor' =dbo.GetVendor(max([BillAbstract].[BillID]),0),max([BillAbstract].[BillID]),@DOCTYPE,          
  @PURCHASETYPE,CASE WHEN max(TaxSuffered) = 0 THEN dbo.LookupDictionaryItem('0Local Tax Exempted',Default) ELSE cast(max(TaxSuffered) as nvarchar) + dbo.LookupDictionaryItem('% Purchase',Default) END,          
  sum(Amount) from [BillDetail] ,[BillAbstract],Vendors where [BillDate] between @fromdate and @ToDatePair          
  and [BillAbstract].[BillID]= [BillDetail].[BillID] and [BillAbstract].[VendorID] = [Vendors].[VendorID]          
  and isnull([Vendors].[Locality],0)=@LOCAL AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0   /*and [TaxSuffered]<> 0*/          
  Group By [BillAbstract].[BillID], cast(TaxSuffered as nvarchar)+ dbo.LookupDictionaryItem('% Purchase',Default)          
  order by  cast(TaxSuffered as nvarchar) + dbo.LookupDictionaryItem('% Tax',Default)           
            
  insert into #temp          
  select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar) ,max(BillDate),          
  'Vendor' = dbo.GetVendor(max([BillAbstract].[BillID]),0),max([BillAbstract].[BillID]),@DOCTYPE,          
  @PURCHASETYPE,"TaxType" = dbo.LookupDictionaryItem('CST%',Default), "Value" = sum([BillDetail].[TaxAmount])          
  from [BillDetail],[BillAbstract],[Vendors]where [BillDate] between @fromdate and @ToDatePair          
  and [BillAbstract].[BillID]= [BillDetail].[BillID]and [BillAbstract].[VendorID] = [Vendors].[VendorID]           
  and isnull([Vendors].[Locality],0)=@OUTSTATION AND (isnull(Status,0) & 128) = 0           
  AND (isnull(Status,0) & 64)=0 group by [BillDetail].[BillID]          
  union all          
  select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar),max(BillDate),          
  'Vendor' = dbo.GetVendor(max([BillAbstract].[BillID]),0),max([BillAbstract].[BillID]),@DOCTYPE,          
  @PURCHASETYPE,dbo.LookupDictionaryItem('CST Purchase',Default),  sum(Amount) from [BillDetail] ,[BillAbstract],Vendors          
  where [BillDate] between @fromdate and @ToDatePair and [BillAbstract].[BillID]= [BillDetail].[BillID]           
  and [BillAbstract].[VendorID] = [Vendors].[VendorID]and isnull([Vendors].[Locality],0)=@OUTSTATION          
  AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0 group by [BillDetail].[BillID]           
  having sum([BillDetail].[TaxAmount])<> 0          
  union all          
  select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar) ,max(BillDate),          
  'Vendor' = dbo.GetVendor(max([BillAbstract].[BillID]),0),max([BillAbstract].[BillID]),@DOCTYPE,          
  @PURCHASETYPE,"TaxType" = case when sum(isnull([BillDetail].[TaxAmount],0))=0 then dbo.LookupDictionaryItem('CST Exempted',Default) else dbo.LookupDictionaryItem('CST%',Default) end,          
  "Value" = sum([Amount])from [BillDetail],[BillAbstract],[Vendors]          
  where [BillDate] between @fromdate and @ToDatePair          
 and [BillAbstract].[BillID]= [BillDetail].[BillID]and [BillAbstract].[VendorID] = [Vendors].[VendorID]           
  and isnull([Vendors].[Locality],0)=@OUTSTATION AND (isnull(Status,0) & 128) = 0           
  AND (isnull(Status,0) & 64)=0 group by [BillDetail].[BillID] having sum([BillDetail].[TaxAmount])= 0          
            
  insert into #temp          
  select 'BillID'= @prefix + cast([BillAbstract].[DocumentID]as nvarchar) ,BillDate,          
  'Vendor' = dbo.GetVendor([BillAbstract].[BillID],0),[BillAbstract].[BillID],@DOCTYPE,          
  @PURCHASETYPE,"TaxType" = dbo.LookupDictionaryItem(' 0Net Value',Default),           
  "Value" = Isnull([BillAbstract].[Value],0) + isnull([BillAbstract].[TaxAmount],0) + isnull([BillAbstract].[AdjustmentAmount],0)          
  from [BillAbstract],[Vendors] where [BillDate] between @fromdate and @ToDatePair          
  and [BillAbstract].[VendorID] = [Vendors].[VendorID]          
  and (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0           
            
  insert into #temp          
  select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar) ,max(AdjustmentDate),          
  'Vendor' = dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
  @RETURNTYPE,@PURCHASERETURNTYPE,"TaxType" = cast(AdjustmentReturnDetail.Tax as nvarchar) + dbo.LookupDictionaryItem('% Tax',Default),           
  "Value" = SUM(([Quantity]*[Rate])*(AdjustmentReturnDetail.Tax)/100)
  from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],[Vendors] where [AdjustmentDate] between @fromdate and @ToDatePair          
  and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID] and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]          
  and isnull([Vendors].[Locality],0)=@LOCAL and [Tax] <> 0 AND (isnull(Status,0) & 128) = 0 AND           
  (isnull(Status,0) & 64) = 0 Group By [AdjustmentReturnDetail].[AdjustmentID], cast(AdjustmentReturnDetail.Tax as nvarchar) + dbo.LookupDictionaryItem('% Tax',Default)          
  union all          
  select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar),max(AdjustmentDate),          
  'Vendor' =dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
  @RETURNTYPE,@PURCHASERETURNTYPE,CASE WHEN max(AdjustmentReturnDetail.Tax) = 0 THEN dbo.LookupDictionaryItem('0Local Tax Exempted',Default) ELSE cast(max(AdjustmentReturnDetail.Tax) as nvarchar) + dbo.LookupDictionaryItem('% Purchase',Default) END,          
  SUM([Quantity]*[Rate]) from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],Vendors where [AdjustmentDate] between @fromdate and @ToDatePair       
  and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID] and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]          
  and isnull([Vendors].[Locality],0)=@LOCAL AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0   /*and [TaxSuffered]<> 0*/          
  Group By [AdjustmentReturnAbstract].[AdjustmentID], cast(AdjustmentReturnDetail.Tax as nvarchar)+ dbo.LookupDictionaryItem('% Purchase',Default)          
  order by cast(AdjustmentReturnDetail.Tax as nvarchar) + dbo.LookupDictionaryItem('% Tax',Default)          
            
  insert into #temp          
  select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar) ,max(AdjustmentDate),          
  'Vendor' = dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
  @RETURNTYPE,@PURCHASERETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('CST%',Default), "Value" = SUM(([Quantity]*[Rate])*(AdjustmentReturnDetail.Tax)/100)
  from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],[Vendors]where [AdjustmentDate] between @fromdate and @ToDatePair          
  and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID]and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]          
  and isnull([Vendors].[Locality],0)=@OUTSTATION AND (isnull(Status,0) & 128) = 0           
  AND (isnull(Status,0) & 64)=0 group by [AdjustmentReturnDetail].[AdjustmentID]          
  union all          
  select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar),max(AdjustmentDate),       
  'Vendor' = dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
  @RETURNTYPE,@PURCHASERETURNTYPE,dbo.LookupDictionaryItem('CST Purchase',Default), SUM([Quantity]*[Rate]) from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],Vendors          
  where [AdjustmentDate] between @fromdate and @ToDatePair and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID]           
  and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]and isnull([Vendors].[Locality],0)=@OUTSTATION          
  AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0 group by [AdjustmentReturnDetail].[AdjustmentID]          
  union all          
  select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar) ,max(AdjustmentDate),          
  'Vendor' = dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
  @RETURNTYPE,@PURCHASERETURNTYPE,"TaxType" = case when sum(isnull([AdjustmentReturnDetail].[Tax],0))=0 then dbo.LookupDictionaryItem('CST Exempted',Default) else dbo.LookupDictionaryItem('CST%',Default) end,          
  "Value" = SUM([Quantity]*[Rate]) from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],[Vendors]          
  where [AdjustmentDate] between @fromdate and @ToDatePair          
  and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID]and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]          
  and isnull([Vendors].[Locality],0)=@OUTSTATION AND (isnull(Status,0) & 128) = 0           
  AND (isnull(Status,0) & 64)=0 group by [AdjustmentReturnDetail].[AdjustmentID]          
  having sum([AdjustmentReturnDetail].[Tax])=0          
          
  /*          
  insert into #temp          
  select 'BillID' = @returnprefix + cast([DocumentID]as nvarchar), dbo.stripdatefromtime([AdjustmentDate]),          
  'Vendor'=[Vendors].[Vendor_Name],[AdjustmentID],@RETURNTYPE,@PURCHASERETURNTYPE,dbo.LookupDictionaryItem('0Local Tax Exempted',Default),          
  [Value] from [AdjustmentReturnAbstract],[Vendors] where (dbo.stripdatefromtime([AdjustmentDate]) between @fromdate and @todate)          
  AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0          
  and [Vendors].[VendorID]= [AdjustmentReturnAbstract].[VendorID]       
  and isnull([Vendors].[Locality],0)=@LOCAL          
            
  insert into #temp          
  select 'BillID' = @returnprefix + cast([DocumentID]as nvarchar), dbo.stripdatefromtime([AdjustmentDate]),          
  'Vendor'=[Vendors].[Vendor_Name],[AdjustmentID],@RETURNTYPE,@PURCHASERETURNTYPE,dbo.LookupDictionaryItem('CST Exempted',Default),          
  [Value] from [AdjustmentReturnAbstract],[Vendors] where (dbo.stripdatefromtime([AdjustmentDate]) between @fromdate and @todate)          
  AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0          
  and [Vendors].[VendorID]= [AdjustmentReturnAbstract].[VendorID]          
  and isnull([Vendors].[Locality],0)=@OUTSTATION  */          
      
  insert into #temp          
  select 'BillID' = @returnprefix + cast([DocumentID]as nvarchar),[AdjustmentDate],          
  'Vendor'=[Vendors].[Vendor_Name],[AdjustmentID],@RETURNTYPE,@PURCHASERETURNTYPE,dbo.LookupDictionaryItem(' 0Net Value',Default),          
  [Total_Value] from [AdjustmentReturnAbstract],[Vendors] where [AdjustmentDate] between @fromdate and @ToDatePair          
  and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]             
  AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0          
 END    
-----------IF SALES REG MODE IS EXEMPTED(ONLY EXEMPTED) THEN DISPLAY EXEMPTED RECORDS--------    
Else If @PurchaseRegModeExempted = @STATE AND IsNull(@PurchaseRegModeTaxValues,N'') = N''    
 BEGIN    
  insert into #temp          
  select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar),max(BillDate),          
  'Vendor' = dbo.GetVendor(max([BillAbstract].[BillID]),0), max([BillAbstract].[BillID]),@DOCTYPE,          
  @PURCHASETYPE, "Tax Type" = dbo.LookupDictionaryItem('0Local Tax Exempted',Default), Sum(Amount)     
  from [BillDetail] ,[BillAbstract],Vendors where [BillDate] between @fromdate and @ToDatePair      
  and [BillAbstract].[BillID]= [BillDetail].[BillID] and [BillAbstract].[VendorID] = [Vendors].[VendorID]          
  and isnull([Vendors].[Locality],0)=@LOCAL AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)= 0  and [TaxSuffered] = 0    
  Group By [BillAbstract].[BillID]         
    
  insert into #temp          
  select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar) ,max(BillDate),          
  'Vendor' = dbo.GetVendor(max([BillAbstract].[BillID]),0),max([BillAbstract].[BillID]),@DOCTYPE,          
  @PURCHASETYPE,"TaxType" = dbo.LookupDictionaryItem('CST Exempted',Default),"Value" = sum([Amount])    
  from [BillDetail],[BillAbstract],[Vendors] where [BillDate] between @fromdate and @ToDatePair          
  and [BillAbstract].[BillID]= [BillDetail].[BillID]and [BillAbstract].[VendorID] = [Vendors].[VendorID]           
  and isnull([Vendors].[Locality],0)=@OUTSTATION AND (isnull(Status,0) & 128) = 0           
  AND (isnull(Status,0) & 64)= 0 And BillDetail.TaxSuffered = 0    
  Group by [BillDetail].[BillID] having sum([BillDetail].[TaxAmount])= 0          
    
  insert into #temp          
  select 'BillID'= @prefix + cast([BillAbstract].[DocumentID]as nvarchar) ,BillDate,          
  'Vendor' = dbo.GetVendor([BillAbstract].[BillID],0),[BillAbstract].[BillID],@DOCTYPE,          
  @PURCHASETYPE,"TaxType" = dbo.LookupDictionaryItem(' 0Net Value',Default),           
  "Value" = Isnull([BillAbstract].[Value],0) + isnull([BillAbstract].[TaxAmount],0) + isnull([BillAbstract].[AdjustmentAmount],0)          
  from [BillAbstract],[Vendors] where [BillDate] between @fromdate and @ToDatePair          
  and [BillAbstract].[VendorID] = [Vendors].[VendorID]          
  and [BillAbstract].[BillID] in (Select ActualID from #temp Where DocType = @DOCTYPE)    
  and (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0           
  ---------------------------------------PURCHASE RETURN TYPE----------------------------    
  insert into #temp          
  select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar),max(AdjustmentDate),          
  'Vendor' =dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
  @RETURNTYPE,@PURCHASERETURNTYPE, "Tax Type" = dbo.LookupDictionaryItem('0Local Tax Exempted',Default),    
  SUM([Quantity]*[Rate]) from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],Vendors where [AdjustmentDate] between @fromdate and @ToDatePair       
  and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID] and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]          
  and isnull([Vendors].[Locality],0)=@LOCAL AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0  and [AdjustmentReturnDetail].[Tax] = 0    
  Group By [AdjustmentReturnAbstract].[AdjustmentID]    
    
  insert into #temp            
  select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar) ,max(AdjustmentDate),          
  'Vendor' = dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
  @RETURNTYPE,@PURCHASERETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('CST Exempted',Default),     
  "Value" = SUM([Quantity]*[Rate]) from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],[Vendors]          
  where [AdjustmentDate] between @fromdate and @ToDatePair          
  and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID]and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]          
  and isnull([Vendors].[Locality],0)=@OUTSTATION AND (isnull(Status,0) & 128) = 0           
  AND (isnull(Status,0) & 64)= 0 AND [AdjustmentReturnDetail].[Tax] = 0    
  group by [AdjustmentReturnDetail].[AdjustmentID]          
  having sum([AdjustmentReturnDetail].[Tax])= 0          
    
  insert into #temp          
  select 'BillID' = @returnprefix + cast([DocumentID]as nvarchar),[AdjustmentDate],          
  'Vendor'=[Vendors].[Vendor_Name],[AdjustmentID],@RETURNTYPE,@PURCHASERETURNTYPE,dbo.LookupDictionaryItem(' 0Net Value',Default),          
  [Total_Value] from [AdjustmentReturnAbstract],[Vendors] where [AdjustmentDate] between @fromdate and @ToDatePair          
  and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]             
  and [AdjustmentID] in (Select ActualID from #temp Where DocType = @RETURNTYPE)    
  AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0          
 END    
-----------IF SALES REG MODE IS TAXVALUES THEN DISPLAY CORRESPONDING RECORDS ONLY------------    
Else If IsNull(@PurchaseRegModeTaxValues,N'') <> N''    
 BEGIN    
  --------------------------------GET ALL THE TAX CODE SPLITUPS--------------------------    
  Insert #TempSecondSplit        
  Exec Sp_acc_SQLSplit @PurchaseRegModeTaxValues,@SECONDSPLIT       
  ---------------------------GET TAX % FOR PURCHASE RETURN TYPE--------------------------    
  Insert Into #TempPurchaseReturnTax    
  Select Percentage, CST_Percentage from Tax Where Tax_Code In (Select SecondSplitRecords from #TempSecondSplit)    
  ---------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS-----------------------    
  If @PurchaseRegModeExempted = @STATE    
   BEGIN    
    insert into #temp          
    select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar),max(BillDate),          
    'Vendor' = dbo.GetVendor(max([BillAbstract].[BillID]),0), max([BillAbstract].[BillID]),@DOCTYPE,          
    @PURCHASETYPE, "Tax Type" = dbo.LookupDictionaryItem('0Local Tax Exempted',Default), Sum(Amount)     
    from [BillDetail] ,[BillAbstract],Vendors where [BillDate] between @fromdate and @ToDatePair          
    and [BillAbstract].[BillID]= [BillDetail].[BillID] and [BillAbstract].[VendorID] = [Vendors].[VendorID]          
    and isnull([Vendors].[Locality],0)=@LOCAL AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)= 0 and [TaxSuffered] = 0    
    Group By [BillAbstract].[BillID]         
   END    
  ---------------------------------------------------------------------------------------    
  insert into #temp          
  select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar) ,max(BillDate),          
  'Vendor' = dbo.GetVendor(max([BillAbstract].[BillID]),0),max([BillAbstract].[BillID]),@DOCTYPE,          
  @PURCHASETYPE,"TaxType" = cast(TaxSuffered as nvarchar) + dbo.LookupDictionaryItem('% Tax',Default), "Value" =sum([BillDetail].[TaxAmount])          
  from [BillDetail],[BillAbstract],[Vendors] where [BillDate] between @fromdate and @ToDatePair          
  and [BillAbstract].[BillID]= [BillDetail].[BillID]and [BillAbstract].[VendorID] = [Vendors].[VendorID]          
  AND BillDetail.TaxCode In (Select SecondSplitRecords from #TempSecondSplit)    
  and isnull([Vendors].[Locality],0)=@LOCAL and [TaxSuffered]<> 0 AND (isnull(Status,0) & 128) = 0 AND           
  (isnull(Status,0) & 64)=0 Group By [BillDetail].[BillID], cast(TaxSuffered as nvarchar) + dbo.LookupDictionaryItem('% Tax',Default)          
  union all          
  select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar),max(BillDate),          
  'Vendor' =dbo.GetVendor(max([BillAbstract].[BillID]),0),max([BillAbstract].[BillID]),@DOCTYPE,          
  @PURCHASETYPE,"Tax Type" = cast(max(TaxSuffered) as nvarchar) + dbo.LookupDictionaryItem('% Purchase',Default),sum(Amount)    
  from [BillDetail] ,[BillAbstract],Vendors where [BillDate] between @fromdate and @ToDatePair          
  and [BillAbstract].[BillID]= [BillDetail].[BillID] and [BillAbstract].[VendorID] = [Vendors].[VendorID]          
  AND BillDetail.TaxCode In (Select SecondSplitRecords from #TempSecondSplit)    
  and isnull([Vendors].[Locality],0)=@LOCAL AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0 and [TaxSuffered] <> 0    
  Group By [BillAbstract].[BillID], cast(TaxSuffered as nvarchar)+ dbo.LookupDictionaryItem('% Purchase',Default)          
  order by  cast(TaxSuffered as nvarchar) + dbo.LookupDictionaryItem('% Tax',Default)           
  ---------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS-----------------------    
  If @PurchaseRegModeExempted = @STATE    
   BEGIN    
    insert into #temp          
    select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar) ,max(BillDate),          
    'Vendor' = dbo.GetVendor(max([BillAbstract].[BillID]),0),max([BillAbstract].[BillID]),@DOCTYPE,          
    @PURCHASETYPE,"TaxType" = dbo.LookupDictionaryItem('CST Exempted',Default),"Value" = sum([Amount])    
    from [BillDetail],[BillAbstract],[Vendors] where [BillDate] between @fromdate and @ToDatePair          
    and [BillAbstract].[BillID]= [BillDetail].[BillID]and [BillAbstract].[VendorID] = [Vendors].[VendorID]           
    and isnull([Vendors].[Locality],0)=@OUTSTATION AND (isnull(Status,0) & 128) = 0           
    AND (isnull(Status,0) & 64)= 0 And BillDetail.TaxSuffered = 0    
    Group by [BillDetail].[BillID] having sum([BillDetail].[TaxAmount])= 0          
   END    
  ---------------------------------------------------------------------------------------    
  insert into #temp          
  select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar) ,max(BillDate),          
  'Vendor' = dbo.GetVendor(max([BillAbstract].[BillID]),0),max([BillAbstract].[BillID]),@DOCTYPE,          
  @PURCHASETYPE,"TaxType" = dbo.LookupDictionaryItem('CST%',Default), "Value" = sum([BillDetail].[TaxAmount])          
  from [BillDetail],[BillAbstract],[Vendors]where [BillDate] between @fromdate and @ToDatePair          
  and [BillAbstract].[BillID]= [BillDetail].[BillID]and [BillAbstract].[VendorID] = [Vendors].[VendorID]           
  AND BillDetail.TaxCode In (Select SecondSplitRecords from #TempSecondSplit) And BillDetail.TaxSuffered <> 0    
  and isnull([Vendors].[Locality],0)=@OUTSTATION AND (isnull(Status,0) & 128) = 0           
  AND (isnull(Status,0) & 64)=0 group by [BillDetail].[BillID]          
  union all          
  select 'BillID'= @prefix + cast(max([BillAbstract].[DocumentID])as nvarchar),max(BillDate),          
  'Vendor' = dbo.GetVendor(max([BillAbstract].[BillID]),0),max([BillAbstract].[BillID]),@DOCTYPE,          
  @PURCHASETYPE,dbo.LookupDictionaryItem('CST Purchase',Default),  sum(Amount) from [BillDetail] ,[BillAbstract],Vendors          
  where [BillDate] between @fromdate and @ToDatePair and [BillAbstract].[BillID]= [BillDetail].[BillID]           
  and [BillAbstract].[VendorID] = [Vendors].[VendorID] and isnull([Vendors].[Locality],0)=@OUTSTATION          
  AND BillDetail.TaxCode In (Select SecondSplitRecords from #TempSecondSplit) And BillDetail.TaxSuffered <> 0    
  AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0 group by [BillDetail].[BillID]           
  having sum([BillDetail].[TaxAmount])<> 0          
            
  insert into #temp          
  select 'BillID'= @prefix + cast([BillAbstract].[DocumentID]as nvarchar) ,BillDate,          
  'Vendor' = dbo.GetVendor([BillAbstract].[BillID],0),[BillAbstract].[BillID],@DOCTYPE,          
  @PURCHASETYPE,"TaxType" = dbo.LookupDictionaryItem(' 0Net Value',Default),           
  "Value" = Isnull([BillAbstract].[Value],0) + isnull([BillAbstract].[TaxAmount],0) + isnull([BillAbstract].[AdjustmentAmount],0)          
  from [BillAbstract],[Vendors] where [BillDate] between @fromdate and @ToDatePair          
  and [BillAbstract].[VendorID] = [Vendors].[VendorID]          
  and [BillAbstract].[BillID] in (Select ActualID from #temp Where DocType = @DOCTYPE)    
  and (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0           
  ---------------------------------------PURCHASE RETURN--------------------------------- 
  ---------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS-----------------------    
  If @PurchaseRegModeExempted = @STATE    
   BEGIN    
    insert into #temp          
    select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar),max(AdjustmentDate),          
    'Vendor' =dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
    @RETURNTYPE,@PURCHASERETURNTYPE, "Tax Type" = dbo.LookupDictionaryItem('0Local Tax Exempted',Default),    
    SUM([Quantity]*[Rate]) from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],Vendors where [AdjustmentDate] between @fromdate and @ToDatePair   
    and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID] and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]          
    and isnull([Vendors].[Locality],0)=@LOCAL AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0  and [AdjustmentReturnDetail].[Tax] = 0    
    Group By [AdjustmentReturnAbstract].[AdjustmentID]    
   END    
  ---------------------------------------------------------------------------------------    
  insert into #temp          
  select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar) ,max(AdjustmentDate),          
  'Vendor' = dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
  @RETURNTYPE,@PURCHASERETURNTYPE,"TaxType" = cast(AdjustmentReturnDetail.Tax as nvarchar) + dbo.LookupDictionaryItem('% Tax',Default),           
  "Value" = SUM(([Quantity]*[Rate])*(AdjustmentReturnDetail.Tax)/100)
  from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],[Vendors] where [AdjustmentDate] between @fromdate and @ToDatePair          
  and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID] and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]          
  and [AdjustmentReturnDetail].[Tax] In (Select LocalTax from #TempPurchaseReturnTax)     
  and isnull([Vendors].[Locality],0)=@LOCAL and [Tax] <> 0 AND (isnull(Status,0) & 128) = 0     
  AND (isnull(Status,0) & 64) = 0 Group By [AdjustmentReturnDetail].[AdjustmentID], cast(AdjustmentReturnDetail.Tax as nvarchar) + dbo.LookupDictionaryItem('% Tax',Default)          
  union all          
  select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar),max(AdjustmentDate),          
'Vendor' =dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
  @RETURNTYPE,@PURCHASERETURNTYPE,"Tax Type" = Cast(max(AdjustmentReturnDetail.Tax) as nvarchar) + dbo.LookupDictionaryItem('% Purchase',Default),          
  SUM([Quantity]*[Rate]) from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],Vendors where [AdjustmentDate] between @fromdate and @ToDatePair       
  and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID] and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]          
  and [AdjustmentReturnDetail].[Tax] In (Select LocalTax from #TempPurchaseReturnTax) And [AdjustmentReturnDetail].[Tax] <> 0    
  and isnull([Vendors].[Locality],0)=@LOCAL AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0     
  Group By [AdjustmentReturnAbstract].[AdjustmentID], cast(AdjustmentReturnDetail.Tax as nvarchar)+ dbo.LookupDictionaryItem('% Purchase',Default)          
  order by cast(AdjustmentReturnDetail.Tax as nvarchar) + dbo.LookupDictionaryItem('% Tax',Default)          
  ---------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS-----------------------    
  If @PurchaseRegModeExempted = @STATE    
   BEGIN    
    insert into #temp            
    select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar) ,max(AdjustmentDate),          
    'Vendor' = dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
    @RETURNTYPE,@PURCHASERETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('CST Exempted',Default),     
    "Value" = SUM([Quantity]*[Rate]) from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],[Vendors]          
    where [AdjustmentDate] between @fromdate and @ToDatePair          
    and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID]and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]          
    and isnull([Vendors].[Locality],0)=@OUTSTATION AND (isnull(Status,0) & 128) = 0           
    AND (isnull(Status,0) & 64)= 0 AND [AdjustmentReturnDetail].[Tax] = 0    
    group by [AdjustmentReturnDetail].[AdjustmentID]          
    having sum([AdjustmentReturnDetail].[Tax])= 0          
   END    
  ---------------------------------------------------------------------------------------            
  insert into #temp          
  select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar) ,max(AdjustmentDate),          
  'Vendor' = dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
  @RETURNTYPE,@PURCHASERETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('CST%',Default), "Value" = SUM(([Quantity]*[Rate])*(AdjustmentReturnDetail.Tax)/100)
  from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],[Vendors]where [AdjustmentDate] between @fromdate and @ToDatePair          
  and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID]and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]          
  and [AdjustmentReturnDetail].[Tax] In (Select CentralTax from #TempPurchaseReturnTax) And [AdjustmentReturnDetail].[Tax] <> 0    
  and isnull([Vendors].[Locality],0)=@OUTSTATION AND (isnull(Status,0) & 128) = 0           
  AND (isnull(Status,0) & 64)=0 group by [AdjustmentReturnDetail].[AdjustmentID]          
  union all          
  select 'BillID'= @returnprefix + cast(max([AdjustmentReturnAbstract].[DocumentID])as nvarchar),max(AdjustmentDate),          
  'Vendor' = dbo.GetVendor(max([AdjustmentReturnAbstract].[AdjustmentID]),1),max([AdjustmentReturnAbstract].[AdjustmentID]),          
  @RETURNTYPE,@PURCHASERETURNTYPE,dbo.LookupDictionaryItem('CST Purchase',Default),SUM([Quantity]*[Rate]) from [AdjustmentReturnDetail],[AdjustmentReturnAbstract],Vendors 
  where [AdjustmentDate] between @fromdate and @ToDatePair and [AdjustmentReturnAbstract].[AdjustmentID]= [AdjustmentReturnDetail].[AdjustmentID]           
  and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]and isnull([Vendors].[Locality],0)=@OUTSTATION          
  and [AdjustmentReturnDetail].[Tax] In (Select LocalTax from #TempPurchaseReturnTax) And [AdjustmentReturnDetail].[Tax] <> 0    
  AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0 group by [AdjustmentReturnDetail].[AdjustmentID]              
          
  insert into #temp          
  select 'BillID' = @returnprefix + cast([DocumentID]as nvarchar),[AdjustmentDate],          
  'Vendor'=[Vendors].[Vendor_Name],[AdjustmentID],@RETURNTYPE,@PURCHASERETURNTYPE,dbo.LookupDictionaryItem(' 0Net Value',Default),          
  [Total_Value] from [AdjustmentReturnAbstract],[Vendors] where [AdjustmentDate] between @fromdate and @ToDatePair          
  and [AdjustmentReturnAbstract].[VendorID] = [Vendors].[VendorID]             
  and [AdjustmentID] in (Select ActualID from #temp Where DocType = @RETURNTYPE)    
  AND (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)=0          
 END    
------------------------------END OF PURCHASEREGMODE CONDITION CHECKS---------------------------    
Insert Into #TempPurchaseRegister(BillID,[Bill Date],Vendor,ActualID,DocType,[Document Reference],[LST No.],[CST No.],[TIN No.],[Description],Adjustments,Payments)  
Select BillID,[Bill Date],Vendor,ActualID,DocType,
(Select DocIDReference from BillAbstract where BillID = #Temp.ActualID),      
dbo.sp_acc_getVendorCSTLSTNumber(ActualID,1),  
dbo.sp_acc_getVendorCSTLSTNumber(ActualID,2),      
dbo.sp_acc_getVendorCSTLSTNumber(ActualID,3),      
[Description],dbo.sp_acc_GetBillF11Adjusments(ActualID,DocType),dbo.sp_acc_GetOctroiPayments(ActualID,DocType) from #Temp    
Group By BillID,[Bill Date],Vendor,ActualID,DocType,[Description]           
          
DECLARE PivotTable CURSOR KEYSET FOR          
select distinct(taxtype) from #temp           
OPEN PivotTable          
FETCH FROM PivotTable INTO @taxpercent          
          
WHILE @@FETCH_STATUS =0          
BEGIN          
 Set @DynamicSQL = N'Alter Table #TempPurchaseRegister Add [' + @TaxPercent + N'] Decimal(18,6) Null'          
 exec sp_executesql @DynamicSQL          
           
 FETCH NEXT FROM PivotTable INTO @taxpercent          
END          
CLOSE PivotTable          
DEALLOCATE PivotTable          
          
Declare @ActualID Int          
Declare @taxtype1 nvarchar(128)          
          
DECLARE PurchaseRegister1 CURSOR KEYSET FOR          
select ActualID,DocType,Taxtype,TaxAmount from #temp          
OPEN PurchaseRegister1          
FETCH FROM PurchaseRegister1 INTO @ActualID,@DocType,@Taxtype1,@TaxAmount          
          
WHILE @@FETCH_STATUS =0          
BEGIN          
 Set @DynamicSQL = N'Update #TempPurchaseRegister Set [' + @TaxType1 + N'] = ' +  Cast(0 as nvarchar)           
 exec sp_executesql @DynamicSQL          
          
 FETCH NEXT FROM PurchaseRegister1 INTO @ActualID,@DocType,@Taxtype1,@TaxAmount          
END          
CLOSE PurchaseRegister1          
DEALLOCATE PurchaseRegister1          
          
DECLARE PurchaseRegister CURSOR KEYSET FOR          
select ActualID,DocType,Taxtype,TaxAmount from #temp          
OPEN PurchaseRegister          
FETCH FROM PurchaseRegister INTO @ActualID,@DocType,@Taxtype1,@TaxAmount          
          
WHILE @@FETCH_STATUS =0          
BEGIN          
 Set @DynamicSQL = N'Update #TempPurchaseRegister Set [' + @TaxType1 + N'] = ' +  Cast(@TaxAmount as nvarchar) + N' Where ActualID = ' + Cast(@ActualID as nvarchar) + N' And DocType = ' + Cast(@DocType as nvarchar)          
 exec sp_executesql @DynamicSQL          
          
 FETCH NEXT FROM PurchaseRegister INTO @ActualID,@DocType,@Taxtype1,@TaxAmount          
END          
CLOSE PurchaseRegister          
DEALLOCATE PurchaseRegister          
Select * from #TempPurchaseRegister Order By [Description], [Bill Date]          
          
Drop table #Temp          
Drop table #TempPurchaseRegister 


