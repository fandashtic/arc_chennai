CREATE Procedure sp_acc_rpt_salesreg(@Fromdate DateTime,@Todate DateTime,@TaxSplitUps nVarChar(4000),@IsTINNoSorting Int=0)
As
DECLARE @Prefix nVarChar(15)            
DECLARE @ServicePrefix nVarChar(15)
DECLARE @LOCAL Integer            
DECLARE @OUTSTATION Integer            
DECLARE @SALES Integer            
DECLARE @SALESRETURN Integer            
DECLARE @SALESTYPE nVarChar(20)            
DECLARE @SALESRETURNTYPE nVarChar(20)            
DECLARE @SERVICE Integer
DECLARE @SERVICETYPE nVarChar(50)
DECLARE @IsServiceVersion INT
            
Declare @TodatePair DateTime            
Set @TodatePair=DateAdd(s, 0-1, DateAdd(dd, 1, @Todate))            
            
SET @LOCAL=1            
SET @OUTSTATION=2            
SET @SALES=4            
SET @SALESRETURN=7
SET @SERVICE=88            
SET @SALESTYPE=dbo.LookupDictionaryItem('Sales',Default)            
SET @SALESRETURNTYPE=dbo.LookupDictionaryItem('Sales Return',Default)            
SET @SERVICETYPE=dbo.LookupDictionaryItem('Sales - Service Invoice',Default)

DECLARE @TaxPercent nVarChar(128),@TaxAmount Decimal(18,6)
DECLARE @DynamicSQL nVarChar(4000)            
DECLARE @DocType Integer
            
Select @Prefix=[Prefix] from [VoucherPrefix] where [TranID]=N'INVOICE'              
Select @ServicePrefix=[Prefix] from [VoucherPrefix] Where [TranID]=N'SERVICEINVOICE'
-------------------------Check whether it is a service version?------------------------------
If Exists(Select * from dbo.SysObjects Where ID = Object_ID(N'[dbo].[ServiceInvoiceAbstract]') And OBJECTPROPERTY(ID, N'IsUserTable') = 1)
   And Exists(Select * from dbo.SysObjects Where ID = Object_ID(N'[dbo].[ServiceInvoiceDetail]') And OBJECTPROPERTY(ID, N'IsUserTable') = 1)
   And Exists(Select * from dbo.SysObjects Where ID = Object_ID(N'[dbo].[ServiceInvoiceTaxComponents]') And OBJECTPROPERTY(ID, N'IsUserTable') = 1) 
 Begin
  SET @IsServiceVersion = 1
 End
---------------------------------------------------------------------------------------------
CREATE Table #Temp(SerialNo Int IDENTITY(1,1),InvoiceID nVarChar(50),[Invoice Date] DateTime,Customer nVarChar(255),             
ActualID Integer,DocType Integer,[Description] nVarChar(50),TaxType nVarChar(128),            
TaxAmount Decimal(18,6) NULL) -- ,TaxComponentValue Decimal(18,6))            
            
CREATE Table #TempRegister(InvoiceID nVarChar(50),[Invoice Date] DateTime,Customer nVarChar(255),      
ActualID Integer,DocType Integer,[Document Reference] nVarChar(255),[LST No.] nVarChar(100),[CST No.] nVarChar(100),[TIN No.] nVarChar(100),[Description] nVarChar(50))
      
Create Table #TempSecondSalesReg    
(DocumentID nVarChar(50),InvoiceDate DateTime,Customer nVarChar(255),InvoiceID Int,TaxDescription nVarChar(255),TaxValue Decimal(18,6))    
    
Create Table #TempFirstSalesReg    
(DocumentID nVarChar(50),InvoiceDate DateTime,Customer nVarChar(255),InvoiceID Int,TaxDescription nVarChar(255),TaxValue Decimal(18,6))    
    
Create Table #TempSecondSalesRetReg    
(DocumentID nVarChar(50),InvoiceDate DateTime,Customer nVarChar(255),InvoiceID Int,TaxDescription nVarChar(255),TaxValue Decimal(18,6))    
    
Create Table #TempFirstSalesRetReg    
(DocumentID nVarChar(50),InvoiceDate DateTime,Customer nVarChar(255),InvoiceID Int,TaxDescription nVarChar(255),TaxValue Decimal(18,6))    

Create Table #TempSecondServiceSalesReg    
(DocumentID nVarChar(50),InvoiceDate DateTime,Customer nVarChar(255),InvoiceID Int,TaxDescription nVarChar(255),TaxValue Decimal(18,6))    
    
Create Table #TempFirstServiceSalesReg    
(DocumentID nVarChar(50),InvoiceDate DateTime,Customer nVarChar(255),InvoiceID Int,TaxDescription nVarChar(255),TaxValue Decimal(18,6))    
----------------------------CREATE TableS TO STORE TAX % SPLITUPS----------------------------  
Create Table #TempFirstSplit(DocumentID INT IDENTITY (1,1),FirstSplitRecords nVarChar(4000))      
Create Table #TempSecondSplit(SecondSplitRecords nVarChar(4000))      
-----------------------------------DECLARE CONSTANTS HERE------------------------------------  
DECLARE @FIRSTSPLIT nvarchar(15),@SECONDSPLIT nvarchar(15)      
DECLARE @ALL INT, @EXEMPTED INT, @TaxPercentAGES INT, @STATE INT  
DECLARE @SalesRegModeAll INT, @SalesRegModeExempted INT, @SalesRegModeTaxValues nvarchar(4000)  
---------------------------------SET VALUES FOR CONSTANTS HERE-------------------------------  
SET @ALL = 1  
SET @EXEMPTED = 2  
SET @TaxPercentAGES = 3  
SET @STATE = 1  
SET @FIRSTSPLIT = Char(1)      
SET @SECONDSPLIT = Char(2)       
-------------------------------------GET TAXMODE SPLITUPS------------------------------------  
Insert #TempFirstSplit      
Exec Sp_acc_SQLSplit @TaxSplitUps,@FIRSTSPLIT     
---------------------------ASSIGN THEM IN SALES REG MODE VARIABLES---------------------------  
Select @SalesRegModeAll = CAST(IsNULL(FirstSplitRecords,0) As INT) from #TempFirstSplit Where DocumentID = @ALL  
Select @SalesRegModeExempted = CAST(IsNULL(FirstSplitRecords,0) As INT) from #TempFirstSplit Where DocumentID = @EXEMPTED  
Select @SalesRegModeTaxValues = IsNULL(FirstSplitRecords,N'') from #TempFirstSplit Where DocumentID = @TaxPercentAGES  
--------------------IF MODE = ALL THEN DISPLAY ALL RECORDS AS PER OLD DESIGN-----------------  
If @SalesRegModeAll = @STATE  
 BEGIN  
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  Select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem('SecondSale Tax Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]            
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And (IsNULL(InvoiceDetail.SaleID,0)= 2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
  And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])<> 2            
  Group By [invoiceDetail].[InvoiceID]            
              
  Insert Into #TempSecondSalesReg    
  select 'InvoiceID'= @Prefix + CAST(DocumentID as nvarchar),InvoiceDate,      
  'Customer'=dbo.getcustomer(InvoiceAbstract.InvoiceID),InvoiceAbstract.InvoiceID,      
  CAST(CAST(MAX(TaxCode) as Decimal(18,6)) as nvarchar) +  N'%(' + (CAST( CAST(Tax_Percentage as Decimal(18,6)) as nvarchar) + N'% ' + TaxComponent_desc + N')'),    
  'Tax Value' = (Select Sum(Tax_Value) From InvoiceTaxComponents i1 where i1.InvoiceID = InvoiceAbstract.InvoiceID And i1.Product_Code = InvoiceDetail.Product_Code And i1.Tax_Code = InvoiceDetail.TaxID And i1.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code)      
  from [InvoiceDetail],[InvoiceAbstract],InvoiceTaxComponents,TaxComponentDetail where [InvoiceDate] between @Fromdate And @TodatePair       
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]      
  And InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID      
  And InvoiceDetail.Product_Code = InvoiceTaxComponents.Product_Code      
  And InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code      
  And InvoiceTaxComponents.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code      
  And [TaxCode]<> 0 And [TaxCode2]=0       
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0      
  And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)      
  And IsNULL(SalePrice,0) > 0     
  Group By [invoiceDetail].[InvoiceID],InvoiceAbstract.InvoiceID,DocumentID,InvoiceDate,    
  Tax_Percentage,TaxComponent_desc,InvoiceDetail.TaxID,InvoiceTaxComponents.Tax_Component_Code,    
  InvoiceDetail.Product_Code,TaxComponentDetail.TaxComponent_Code    
  order by (CAST(CAST(MAX([TaxCode])as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default))      
    
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)    
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" =(CAST(CAST(MAX([TaxCode])as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default)), "Value" = sum(STPayable)       
  from [InvoiceDetail],[InvoiceAbstract] where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0             
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
  Group By [invoiceDetail].[InvoiceID], (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default))            
  union all            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,(CAST( CAST(MAX(TaxCode) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale',Default)), sum(Amount) - (sum(STPayable))            
  from [InvoiceDetail],[InvoiceAbstract]where [InvoiceDate] between @Fromdate And @TodatePair            
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0             
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
  Group By [invoiceDetail].[InvoiceID], (CAST(TaxCode as nvarchar) + dbo.LookupDictionaryItem('% SecondSale',Default))              
  union all            
  Select DocumentID,InvoiceDate,Customer,InvoiceID,@SALES,@SALESTYPE,TaxDescription,Sum(TaxValue) From #TempSecondSalesReg    
  Group By InvoiceID,DocumentID,TaxDescription,InvoiceDate,Customer    
              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem('0FirstSale Tax Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And IsNULL(InvoiceDetail.SaleID,0)=1            
  And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])<> 2            
  Group By [invoiceDetail].[InvoiceID]            
    
  Insert Into #TempFirstSalesReg      
  select 'InvoiceID'= @Prefix + CAST(DocumentID as nvarchar),InvoiceDate,      
  'Customer'=dbo.getcustomer([InvoiceAbstract].[InvoiceID]),[InvoiceAbstract].[InvoiceID],      
  CAST(CAST(MAX(TaxCode) as Decimal(18,6)) as nvarchar) +  N'%(' +(CAST(CAST(Tax_Percentage as Decimal(18,6)) as nvarchar) + N'% ' + TaxComponent_desc + N')'),    
  'Tax Value' = (Select Sum(Tax_Value) From InvoiceTaxComponents i1 where i1.InvoiceID = InvoiceAbstract.InvoiceID And i1.Product_Code = InvoiceDetail.Product_Code And i1.Tax_Code = InvoiceDetail.TaxID And i1.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code)      
  from [InvoiceDetail],[InvoiceAbstract],InvoiceTaxComponents,TaxComponentDetail      
  where [InvoiceDate] between @Fromdate And @TodatePair       
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]      
  And InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID      
  And InvoiceDetail.Product_Code = InvoiceTaxComponents.Product_Code      
  And InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code      
  And InvoiceTaxComponents.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code      
  And [TaxCode]<> 0 And [TaxCode2]=0       
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0      
  And IsNULL(InvoiceDetail.SaleID,0)=1 And IsNULL(SalePrice,0) > 0      
  Group By [invoiceDetail].[InvoiceID],[InvoiceAbstract].[InvoiceID],DocumentID,InvoiceDate,     
  (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default)), CAST(TaxCode as Decimal(18,6)),Tax_Percentage,TaxComponent_desc,      
  InvoiceDetail.TaxID,InvoiceTaxComponents.Tax_Component_Code,InvoiceDetail.Product_Code,TaxComponentDetail.TaxComponent_Code          
  order by (CAST(CAST(MAX([TaxCode]) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default))      
              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" =(CAST(CAST(MAX([TaxCode]) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default)), "Value" = sum(STPayable)             
  from [InvoiceDetail],[InvoiceAbstract] where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0             
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And IsNULL(InvoiceDetail.SaleID,0)=1            
  Group By [invoiceDetail].[InvoiceID], (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default))            
  union all            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,(CAST(CAST(MAX(TaxCode)as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale',Default)), sum(Amount) - (sum(STPayable))            
  from [InvoiceDetail],[InvoiceAbstract]where [InvoiceDate] between @Fromdate And @TodatePair            
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0             
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And IsNULL(InvoiceDetail.SaleID,0)=1            
  Group By [invoiceDetail].[InvoiceID], (CAST(TaxCode as nvarchar) + dbo.LookupDictionaryItem('% FirstSale',Default))              
  union all            
  Select DocumentID,InvoiceDate,'Customer'=Customer,InvoiceID,@SALES,@SALESTYPE,TaxDescription,Sum(TaxValue) From #TempFirstSalesReg    
  Group By InvoiceID,TaxDescription,InvoiceDate,Customer,DocumentID    
    
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,'CST Sales',sum(Amount) - (sum(CSTPayable)) from [InvoiceDetail],[InvoiceAbstract]              
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]<> 0 And [TaxCode]=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  Group By [invoiceDetail].[InvoiceID]            
  union all            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem('CST%',Default), "Value" = sum(CSTPayable) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]<> 0 And [TaxCode]=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  Group By [invoiceDetail].[InvoiceID]            
                        
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem('CST Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And IsNULL([TaxCode2],0)= 0 And IsNULL([TaxCode],0)=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])=2            
  Group By [invoiceDetail].[InvoiceID]            
              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem(' 0Net Value',Default), "Value" = sum(IsNULL(NetValue,0)- IsNULL(Freight,0))              
  from [InvoiceAbstract] where [InvoiceDate] between @Fromdate And @TodatePair            
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  Group By [InvoiceAbstract].[InvoiceID]            
  ------------------------------------Service Invoice----------------------------------------
  If @IsServiceVersion = @STATE
   Begin
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),            
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem('SecondSale Tax Exempted',Default),
    'Value'=Sum([ServiceInvoiceDetail].[NetValue]) from [ServiceInvoiceDetail],[ServiceInvoiceAbstract] 
    Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair 
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N'' And [LSTPayable]=0 And [CSTPayable]=0 
    And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0 And [SaleTax]=0
    And (IsNULL(ServiceInvoiceDetail.SaleID,0)=2 Or IsNULL(ServiceInvoiceDetail.SaleID,0)=0)            
    And dbo.sp_acc_ser_GetCustomerLocality([ServiceInvoiceAbstract].[ServiceInvoiceID])<>2
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID]            
              
    Insert Into #TempSecondServiceSalesReg    
    Select 'InvoiceID'=@ServicePrefix + CAST(DocumentID as nvarchar),ServiceInvoiceDate,
    'Customer'=dbo.sp_acc_ser_GetCustomer(ServiceInvoiceAbstract.ServiceInvoiceID),ServiceInvoiceAbstract.ServiceInvoiceID,
    CAST(CAST(MAX(SaleTax) as Decimal(18,6)) as nvarchar) + N'%(' + (CAST(CAST(Tax_Percentage as Decimal(18,6)) as nvarchar) + N'% ' + TaxComponent_desc + N')'),
    'Tax Value'=(Select Sum(Tax_Value) From ServiceInvoiceTaxComponents SIT 
    Where SIT.SerialNo=ServiceInvoiceDetail.SerialNo And SIT.TaxComponent_Code=TaxComponentDetail.TaxComponent_Code)
    from ServiceInvoiceDetail,ServiceInvoiceAbstract,ServiceInvoiceTaxComponents,TaxComponentDetail 
    Where [ServiceInvoiceDate] between @Fromdate And @TodatePair       
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]      
    And ServiceInvoiceDetail.SerialNo=ServiceInvoiceTaxComponents.SerialNo
    And ServiceInvoiceTaxComponents.TaxComponent_Code=TaxComponentDetail.TaxComponent_Code      
    And [LSTPayable]<>0 And [CSTPayable]=0 And [SaleTax]<>0 And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And (IsNULL(Status,0) & 64)=0 And (IsNULL(Status,0) & 128)=0 And IsNULL(ServiceInvoiceDetail.NetValue,0) > 0
    And (IsNULL(ServiceInvoiceDetail.SaleID,0)=2 Or IsNULL(ServiceInvoiceDetail.SaleID,0)=0)
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],ServiceInvoiceAbstract.ServiceInvoiceID,
    DocumentID,ServiceInvoiceDate,Tax_Percentage,TaxComponent_desc,ServiceInvoiceDetail.SerialNo,
    ServiceInvoiceTaxComponents.TaxCode,ServiceInvoiceTaxComponents.TaxComponent_Code,TaxComponentDetail.TaxComponent_Code
    Order by (CAST(CAST(MAX([SaleTax])as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default))      
    
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,
    'TaxType'=(CAST(CAST(MAX([SaleTax])as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default)),'Value'=Sum(LSTPayable)
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract] Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And [LSTPayable]<>0 And [CSTPayable]=0 And [SaleTax]<>0 And (IsNULL(Status,0) & 128)=0
    And (IsNULL(Status,0) & 64)=0 And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And (IsNULL(ServiceInvoiceDetail.SaleID,0)=2 Or IsNULL(ServiceInvoiceDetail.SaleID,0)= 0)            
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],(CAST([SaleTax] as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default))
    Union ALL
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,
    (CAST( CAST(MAX(SaleTax) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale',Default)),(Sum(ServiceInvoiceDetail.NetValue)-Sum(LSTPayable))
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract] Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID] 
    And [LSTPayable]<>0 And [CSTPayable]=0 And [SaleTax]<>0 And (IsNULL(Status,0) & 128)=0
    And (IsNULL(Status,0) & 64)=0 And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And (IsNULL(ServiceInvoiceDetail.SaleID,0)=2 or IsNULL(ServiceInvoiceDetail.SaleID,0)= 0)
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],(CAST(SaleTax as nvarchar) + dbo.LookupDictionaryItem('% SecondSale',Default))
    Union ALL
    Select DocumentID,InvoiceDate,Customer,InvoiceID,@SERVICE,@SERVICETYPE,TaxDescription,Sum(TaxValue) From #TempSecondServiceSalesReg
    Group By InvoiceID,DocumentID,TaxDescription,InvoiceDate,Customer    
              
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,
    'TaxType'=dbo.LookupDictionaryItem('0FirstSale Tax Exempted',Default),'Value'=Sum(ServiceInvoiceDetail.NetValue) 
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract] Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N'' And [LSTPayable]=0 And [CSTPayable]=0 And [SaleTax]=0 
    And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0 And IsNULL(ServiceInvoiceDetail.SaleID,0)=1
    And dbo.sp_acc_ser_GetCustomerLocality([ServiceInvoiceAbstract].[ServiceInvoiceID])<> 2
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID]
    
    Insert Into #TempFirstServiceSalesReg
    Select 'InvoiceID'= @ServicePrefix + CAST(DocumentID as nvarchar),ServiceInvoiceDate,
    'Customer'=dbo.sp_acc_ser_GetCustomer([ServiceInvoiceAbstract].[ServiceInvoiceID]),[ServiceInvoiceAbstract].[ServiceInvoiceID],
    CAST(CAST(MAX(SaleTax) as Decimal(18,6)) as nvarchar) + N'%(' +(CAST(CAST(Tax_Percentage as Decimal(18,6)) as nvarchar) + N'% ' + TaxComponent_desc + N')'),
    'Tax Value'=(Select Sum(Tax_Value) From ServiceInvoiceTaxComponents SIT 
    Where SIT.SerialNo=ServiceInvoiceDetail.SerialNo And SIT.TaxComponent_Code=TaxComponentDetail.TaxComponent_Code)      
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract],ServiceInvoiceTaxComponents,TaxComponentDetail      
    Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair       
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]      
    And ServiceInvoiceDetail.SerialNo=ServiceInvoiceTaxComponents.SerialNo
    And ServiceInvoiceTaxComponents.TaxComponent_Code=TaxComponentDetail.TaxComponent_Code      
    And [LSTPayable]<>0 And [CSTPayable]=0 And [SaleTax]<>0 And (IsNULL(Status,0) & 128)=0
    And (IsNULL(Status,0) & 64)=0 And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N'' 
    And IsNULL(ServiceInvoiceDetail.SaleID,0)=1 And IsNULL(ServiceInvoiceDetail.NetValue,0) > 0
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],ServiceInvoiceAbstract.ServiceInvoiceID,
    DocumentID,ServiceInvoiceDate,(CAST([SaleTax] as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default)),CAST(SaleTax as Decimal(18,6)),
    Tax_Percentage,TaxComponent_desc,ServiceInvoiceDetail.SerialNo,ServiceInvoiceTaxComponents.TaxCode,
    ServiceInvoiceTaxComponents.TaxComponent_Code,TaxComponentDetail.TaxComponent_Code
    Order by (CAST(CAST(MAX([SaleTax]) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default))      
              
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,
    'TaxType'=(CAST(CAST(MAX([SaleTax]) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default)),'Value'=Sum(LSTPayable)
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract] Where [ServiceInvoiceDate] between @Fromdate And @TodatePair
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And [LSTPayable]<>0 And [CSTPayable]=0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0 
    And [SaleTax]<>0 And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N'' And IsNULL(ServiceInvoiceDetail.SaleID,0)=1
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],(CAST([SaleTax] as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default))
    Union ALL
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,
    (CAST(CAST(MAX(SaleTax)as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale',Default)),(Sum(ServiceInvoiceDetail.NetValue)-Sum(LSTPayable))
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract] Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And [LSTPayable]<>0 And [CSTPayable]=0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    And [SaleTax]<>0 And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N'' And IsNULL(ServiceInvoiceDetail.SaleID,0)=1
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],(CAST(SaleTax as nvarchar) + dbo.LookupDictionaryItem('% FirstSale',Default))
    Union ALL
    Select DocumentID,InvoiceDate,Customer,InvoiceID,@SERVICE,@SERVICETYPE,TaxDescription,Sum(TaxValue) From #TempFirstServiceSalesReg
    Group By InvoiceID,TaxDescription,InvoiceDate,Customer,DocumentID
    
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,dbo.LookupDictionaryItem('CST Sales',Default),
    Sum(ServiceInvoiceDetail.NetValue)-(Sum(CSTPayable)) from [ServiceInvoiceDetail],[ServiceInvoiceAbstract]
    Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And [CSTPayable]<>0 And [LSTPayable]=0 And [SaleTax]<>0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID]            
    Union ALL
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem('CST%',Default),
    'Value'=Sum(CSTPayable) from [ServiceInvoiceDetail],[ServiceInvoiceAbstract]
    Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And [CSTPayable]<>0 And [LSTPayable]=0 And [SaleTax]<>0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID]            
                        
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem('CST Exempted',Default),
    'Value'=Sum(ServiceInvoiceDetail.NetValue) from [ServiceInvoiceDetail],[ServiceInvoiceAbstract]
    Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair 
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And IsNULL([CSTPayable],0)=0 And IsNULL([LSTPayable],0)=0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    And dbo.sp_acc_ser_GetCustomerLocality([ServiceInvoiceAbstract].[ServiceInvoiceID])=2 And [SaleTax]=0
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID]            
              
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem(' 0Net Value',Default),
    'Value'=(Sum(ServiceInvoiceDetail.NetValue)-Sum(IsNULL(Freight,0))) from [ServiceInvoiceAbstract],[ServiceInvoiceDetail]
    Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],[ServiceInvoiceAbstract].[ServiceInvoiceID]
   End
  -------------------------------------Sales Return------------------------------------------            
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('SecondSale Tax Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
  And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID]) <> 2            
  Group By [invoiceDetail].[InvoiceID]            
              
  Insert Into #TempSecondSalesRetReg      
  select 'InvoiceID'= @Prefix + CAST(DocumentID as nvarchar),InvoiceDate,      
  'Customer'=dbo.getcustomer([InvoiceAbstract].[InvoiceID]),[InvoiceAbstract].[InvoiceID],      
  CAST(CAST(MAX(TaxCode) as Decimal(18,6)) as nvarchar) +  N'%(' + (CAST(CAST(Tax_Percentage as Decimal(18,6)) as nvarchar) + N'% ' + TaxComponent_desc + N')'),    
  'Tax Value' = (Select Sum(Tax_Value) From InvoiceTaxComponents i1 where i1.InvoiceID = InvoiceAbstract.InvoiceID And i1.Product_Code = InvoiceDetail.Product_Code And i1.Tax_Code = InvoiceDetail.TaxID And i1.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code)      
  from [InvoiceDetail],[InvoiceAbstract],InvoiceTaxComponents,TaxComponentDetail      
  where [InvoiceDate] between @Fromdate And @TodatePair       
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]      
  And InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID      
  And InvoiceDetail.Product_Code = InvoiceTaxComponents.Product_Code      
  And InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code      
  And InvoiceTaxComponents.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code      
  And [TaxCode]<> 0 And [TaxCode2]=0  And [InvoiceType]=4       
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0       
  And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)      
  And IsNULL(SalePrice,0) > 0      
  Group By [invoiceDetail].[InvoiceID],[InvoiceAbstract].[InvoiceID],DocumentID,InvoiceDate,     
  (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default)), Tax_Percentage,TaxComponent_desc,    
  InvoiceDetail.TaxID,InvoiceTaxComponents.Tax_Component_Code,InvoiceDetail.Product_Code,TaxComponentDetail.TaxComponent_Code        
  order by (CAST( CAST(MAX([TaxCode]) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default))      
    
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = (CAST( CAST(MAX([TaxCode]) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default)),"Value" = sum(STPayable)            
  from [InvoiceDetail],[InvoiceAbstract] where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0  And [InvoiceType]=4             
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
  Group By [invoiceDetail].[InvoiceID], (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default))            
  union all            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,(CAST(CAST(MAX(TaxCode)as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale',Default)), sum(Amount) - (sum(STPayable))             
  from [InvoiceDetail],[InvoiceAbstract]where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0 And [InvoiceType]=4             
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And (IsNULL(InvoiceDetail.SaleID,0)= 2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
  Group By [invoiceDetail].[InvoiceID],(CAST(TaxCode as nvarchar) + dbo.LookupDictionaryItem('% SecondSale',Default))            
  union            
  Select DocumentID,InvoiceDate,'Customer'=Customer,InvoiceID,@SALESRETURN,@SALESRETURNTYPE,TaxDescription,Sum(TaxValue) From #TempSecondSalesRetReg    
  Group By InvoiceID,TaxDescription,InvoiceDate,Customer,DocumentID              

  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('FirstSale Tax Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And IsNULL(InvoiceDetail.SaleID,0)=1            
  And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])<> 2            
  Group By [invoiceDetail].[InvoiceID]            
    
  Insert Into #TempFirstSalesRetReg      
  select 'InvoiceID'= @Prefix + CAST(DocumentID as nvarchar),InvoiceDate,      
  'Customer'=dbo.getcustomer([InvoiceAbstract].[InvoiceID]),[InvoiceAbstract].[InvoiceID],      
  CAST(CAST(MAX(TaxCode) as Decimal(18,6)) as nvarchar) +  N'%(' + (CAST(CAST(Tax_Percentage as Decimal(18,6)) as nvarchar) + N'% ' + TaxComponent_desc + N')'),    
  'Tax Value' = (Select Sum(Tax_Value) From InvoiceTaxComponents i1 where i1.InvoiceID = InvoiceAbstract.InvoiceID And i1.Product_Code = InvoiceDetail.Product_Code And i1.Tax_Code = InvoiceDetail.TaxID And i1.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code)      
  from [InvoiceDetail],[InvoiceAbstract],InvoiceTaxComponents,TaxComponentDetail      
  where [InvoiceDate] between @Fromdate And @TodatePair       
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]      
  And InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID      
  And InvoiceDetail.Product_Code = InvoiceTaxComponents.Product_Code      
  And InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code      
  And InvoiceTaxComponents.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code      
  And [TaxCode]<> 0 And [TaxCode2]=0  And [InvoiceType]=4       
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0       
  And IsNULL(InvoiceDetail.SaleID,0)=1 And IsNULL(SalePrice,0) > 0      
  Group By [invoiceDetail].[InvoiceID],[InvoiceAbstract].[InvoiceID],DocumentID,InvoiceDate,    
  (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default)),CAST(TaxCode as Decimal(18,6)),Tax_Percentage,TaxComponent_desc,      
  InvoiceDetail.TaxID,InvoiceTaxComponents.Tax_Component_Code,InvoiceDetail.Product_Code,TaxComponentDetail.TaxComponent_Code        
  order by (CAST(CAST(MAX([TaxCode])as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default))      
    
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = (CAST(CAST(MAX([TaxCode])as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default)),"Value" = sum(STPayable)            
  from [InvoiceDetail],[InvoiceAbstract] where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0  And [InvoiceType]=4             
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And IsNULL(InvoiceDetail.SaleID,0)=1            
  Group By [invoiceDetail].[InvoiceID], (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default))            
  union all            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,(CAST( CAST(MAX(TaxCode)as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale',Default)), sum(Amount) - (sum(STPayable))             
  from [InvoiceDetail],[InvoiceAbstract]where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0 And [InvoiceType]=4             
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And IsNULL(InvoiceDetail.SaleID,0)=1            
  Group By [invoiceDetail].[InvoiceID],(CAST(TaxCode as nvarchar) + dbo.LookupDictionaryItem('% FirstSale',Default))            
  union            
  Select DocumentID,InvoiceDate,'Customer'=Customer,InvoiceID,@SALESRETURN,@SALESRETURNTYPE,TaxDescription,Sum(TaxValue) From #TempFirstSalesRetReg    
  Group By InvoiceID,TaxDescription,InvoiceDate,Customer,DocumentID    
              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,dbo.LookupDictionaryItem('CST Sales',Default),sum(Amount) - (sum(CSTPayable)) from            
  [InvoiceDetail],[InvoiceAbstract]where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode2]<> 0 And [TaxCode]=0 And [InvoiceType]=4           
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  Group By [invoiceDetail].[InvoiceID]            
  union all            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('CST%',Default), "Value" = sum(CSTPayable) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]<> 0 And [TaxCode]=0 And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  Group By [invoiceDetail].[InvoiceID]            
              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('CST Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])=2            
  Group By [invoiceDetail].[InvoiceID]            
              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem(' 0Net value',Default), "Value" = sum(IsNULL(NetValue,0) - IsNULL(Freight,0)) from [InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  Group By [InvoiceAbstract].[InvoiceID]            
 END  
-----------IF SALES REG MODE IS EXEMPTED(ONLY EXEMPTED) THEN DISPLAY EXEMPTED RECORDS--------  
Else If @SalesRegModeExempted = @STATE And IsNULL(@SalesRegModeTaxValues,N'') = N''  
 BEGIN  
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  Select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem('SecondSale Tax Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]            
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And (IsNULL(InvoiceDetail.SaleID,0)= 2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
  And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])<> 2            
  Group By [invoiceDetail].[InvoiceID]            
              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem('0FirstSale Tax Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]        
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And IsNULL(InvoiceDetail.SaleID,0)=1            
  And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])<> 2            
  Group By [invoiceDetail].[InvoiceID]             
                       
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem('CST Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And IsNULL([TaxCode2],0)= 0 And IsNULL([TaxCode],0)=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])=2            
  Group By [invoiceDetail].[InvoiceID]            
              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem(' 0Net Value',Default), "Value" = sum(IsNULL(InvoiceAbstract.NetValue,0)- IsNULL(InvoiceAbstract.Freight,0))  
  from [InvoiceAbstract] where [InvoiceDate] Between @Fromdate And @TodatePair    
  And InvoiceAbstract.InvoiceID In (Select ActualID from #Temp Where DocType = @SALES)          
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  Group By [InvoiceAbstract].[InvoiceID]            
  ------------------------------------Service Invoice---------------------------------------
  If @IsServiceVersion = @STATE
   Begin
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem('SecondSale Tax Exempted',Default),
    'Value'=Sum(ServiceInvoiceDetail.NetValue) from [ServiceInvoiceDetail],[ServiceInvoiceAbstract]
    Where [ServiceInvoiceDate] between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And [CSTPayable]=0 And [LSTPayable]=0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    And (IsNULL(ServiceInvoiceDetail.SaleID,0)=2 Or IsNULL(ServiceInvoiceDetail.SaleID,0)= 0)
    And dbo.sp_acc_ser_GetCustomerLocality([ServiceInvoiceAbstract].[ServiceInvoiceID])<> 2 And [SaleTax]=0
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID]
              
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem('0FirstSale Tax Exempted',Default),
    'Value'=Sum(ServiceInvoiceDetail.NetValue) from [ServiceInvoiceDetail],[ServiceInvoiceAbstract]
    Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And [CSTPayable]=0 And [LSTPayable]=0 And [SaleTax]=0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    And IsNULL(ServiceInvoiceDetail.SaleID,0)=1 And dbo.sp_acc_ser_GetCustomerLocality([ServiceInvoiceAbstract].[ServiceInvoiceID])<> 2
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID]
                       
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem('CST Exempted',Default),
    'Value'=Sum(ServiceInvoiceDetail.NetValue) from [ServiceInvoiceDetail],[ServiceInvoiceAbstract]
    Where [ServiceInvoiceDate] between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And IsNULL([CSTPayable],0)=0 And IsNULL([LSTPayable],0)=0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    And dbo.sp_acc_ser_GetCustomerLocality([ServiceInvoiceAbstract].[ServiceInvoiceID])=2 And [SaleTax]=0
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID]
              
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem(' 0Net Value',Default),
    'Value'=(Sum(ServiceInvoiceDetail.NetValue)-Sum(IsNULL(Freight,0))) from [ServiceInvoiceAbstract],[ServiceInvoiceDetail]
    Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    And ServiceInvoiceAbstract.ServiceInvoiceID In (Select ActualID from #Temp Where DocType = @SERVICE)
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],[ServiceInvoiceAbstract].[ServiceInvoiceID]            
   End
  -------------------------------------Sales Return------------------------------------------            
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('SecondSale Tax Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
  And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID]) <> 2            
  Group By [invoiceDetail].[InvoiceID]            
              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('FirstSale Tax Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And IsNULL(InvoiceDetail.SaleID,0)=1   
  And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])<> 2            
  Group By [invoiceDetail].[InvoiceID]            
   
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('CST Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])=2            
  Group By [invoiceDetail].[InvoiceID]            
              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem(' 0Net value',Default), "Value" = sum(IsNULL(NetValue,0) - IsNULL(Freight,0))   
  from [InvoiceAbstract] where [InvoiceDate] between @Fromdate And @TodatePair   
  And InvoiceAbstract.InvoiceID In (Select ActualID from #Temp Where DocType = @SALESRETURN)  
  And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  Group By [InvoiceAbstract].[InvoiceID]            
 END  
-----------IF SALES REG MODE IS TAXVALUES THEN DISPLAY CORRESPONDING RECORDS ONLY------------  
Else If IsNULL(@SalesRegModeTaxValues,N'') <> N''  
 BEGIN  
  --------------------------------GET ALL THE TAX CODE SPLITUPS--------------------------  
  Insert #TempSecondSplit      
  Exec Sp_acc_SQLSplit @SalesRegModeTaxValues,@SECONDSPLIT     
  ---------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS-----------------------  
  IF @SalesRegModeExempted = @STATE  
   BEGIN  
    Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
    [Description],TaxType,TaxAmount)            
    Select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
    'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
    @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem('SecondSale Tax Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]            
    where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
    And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
    And (IsNULL(InvoiceDetail.SaleID,0)= 2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
    And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])<> 2            
    Group By [invoiceDetail].[InvoiceID]            
   END  
  ---------------------------------------------------------------------------------------              
  Insert Into #TempSecondSalesReg    
  select 'InvoiceID'= @Prefix + CAST(DocumentID as nvarchar),InvoiceDate,      
  'Customer'=dbo.getcustomer(InvoiceAbstract.InvoiceID),InvoiceAbstract.InvoiceID,      
  CAST(CAST(MAX(TaxCode) as Decimal(18,6)) as nvarchar) +  N'%(' + (CAST( CAST(Tax_Percentage as Decimal(18,6)) as nvarchar) + N'% ' + TaxComponent_desc + N')'),    
  'Tax Value' = (Select Sum(Tax_Value) From InvoiceTaxComponents i1 where i1.InvoiceID = InvoiceAbstract.InvoiceID And i1.Product_Code = InvoiceDetail.Product_Code And i1.Tax_Code = InvoiceDetail.TaxID And i1.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code)      
  from [InvoiceDetail],[InvoiceAbstract],InvoiceTaxComponents,TaxComponentDetail where [InvoiceDate] between @Fromdate And @TodatePair       
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]      
  And InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID      
  And InvoiceDetail.Product_Code = InvoiceTaxComponents.Product_Code      
  And InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code      
  And InvoiceTaxComponents.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code      
  And [TaxCode]<> 0 And [TaxCode2]=0   
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0      
  And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)      
  And IsNULL(SalePrice,0) > 0     
  Group By [invoiceDetail].[InvoiceID],InvoiceAbstract.InvoiceID,DocumentID,InvoiceDate,    
  Tax_Percentage,TaxComponent_desc,InvoiceDetail.TaxID,InvoiceTaxComponents.Tax_Component_Code,    
  InvoiceDetail.Product_Code,TaxComponentDetail.TaxComponent_Code    
  order by (CAST(CAST(MAX([TaxCode])as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default))      
    
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)    
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" =(CAST(CAST(MAX([TaxCode])as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default)), "Value" = sum(STPayable)       
  from [InvoiceDetail],[InvoiceAbstract] where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0             
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
  Group By [invoiceDetail].[InvoiceID], (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default))            
  union all            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,(CAST( CAST(MAX(TaxCode) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale',Default)), sum(Amount) - (sum(STPayable))            
  from [InvoiceDetail],[InvoiceAbstract]where [InvoiceDate] between @Fromdate And @TodatePair            
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0             
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
  Group By [invoiceDetail].[InvoiceID], (CAST(TaxCode as nvarchar) + dbo.LookupDictionaryItem('% SecondSale',Default))              
  union all            
  Select DocumentID,InvoiceDate,Customer,InvoiceID,@SALES,@SALESTYPE,TaxDescription,Sum(TaxValue) From #TempSecondSalesReg    
  Group By InvoiceID,DocumentID,TaxDescription,InvoiceDate,Customer    
  ---------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS-----------------------  
  IF @SalesRegModeExempted = @STATE  
   BEGIN  
    Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
    [Description],TaxType,TaxAmount)            
    select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
    'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
    @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem('0FirstSale Tax Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
    where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
    And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
    And IsNULL(InvoiceDetail.SaleID,0)=1            
    And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])<> 2            
    Group By [invoiceDetail].[InvoiceID]            
   END  
  ---------------------------------------------------------------------------------------              
  Insert Into #TempFirstSalesReg      
  select 'InvoiceID'= @Prefix + CAST(DocumentID as nvarchar),InvoiceDate,      
  'Customer'=dbo.getcustomer([InvoiceAbstract].[InvoiceID]),[InvoiceAbstract].[InvoiceID],      
  CAST(CAST(MAX(TaxCode) as Decimal(18,6)) as nvarchar) +  N'%(' +(CAST(CAST(Tax_Percentage as Decimal(18,6)) as nvarchar) + N'% ' + TaxComponent_desc + N')'),    
  'Tax Value' = (Select Sum(Tax_Value) From InvoiceTaxComponents i1 where i1.InvoiceID = InvoiceAbstract.InvoiceID And i1.Product_Code = InvoiceDetail.Product_Code And i1.Tax_Code = InvoiceDetail.TaxID And i1.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code)      
  from [InvoiceDetail],[InvoiceAbstract],InvoiceTaxComponents,TaxComponentDetail      
  where [InvoiceDate] between @Fromdate And @TodatePair       
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]      
  And InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID      
  And InvoiceDetail.Product_Code = InvoiceTaxComponents.Product_Code      
  And InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code      
  And InvoiceTaxComponents.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code      
  And [TaxCode]<> 0 And [TaxCode2]=0       
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0      
  And IsNULL(InvoiceDetail.SaleID,0)=1 And IsNULL(SalePrice,0) > 0      
  Group By [invoiceDetail].[InvoiceID],[InvoiceAbstract].[InvoiceID],DocumentID,InvoiceDate,     
  (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default)), CAST(TaxCode as Decimal(18,6)),Tax_Percentage,TaxComponent_desc,      
  InvoiceDetail.TaxID,InvoiceTaxComponents.Tax_Component_Code,InvoiceDetail.Product_Code,TaxComponentDetail.TaxComponent_Code          
  order by (CAST(CAST(MAX([TaxCode]) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default))      
              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" =(CAST(CAST(MAX([TaxCode]) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default)), "Value" = sum(STPayable)             
  from [InvoiceDetail],[InvoiceAbstract] where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0             
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And IsNULL(InvoiceDetail.SaleID,0)=1            
  Group By [invoiceDetail].[InvoiceID], (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default))            
  union all            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,(CAST(CAST(MAX(TaxCode)as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale',Default)), sum(Amount) - (sum(STPayable))            
  from [InvoiceDetail],[InvoiceAbstract]where [InvoiceDate] between @Fromdate And @TodatePair            
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0             
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And IsNULL(InvoiceDetail.SaleID,0)=1            
  Group By [invoiceDetail].[InvoiceID], (CAST(TaxCode as nvarchar) + dbo.LookupDictionaryItem('% FirstSale',Default))              
  union all            
  Select DocumentID,InvoiceDate,'Customer'=Customer,InvoiceID,@SALES,@SALESTYPE,TaxDescription,Sum(TaxValue) From #TempFirstSalesReg    
  Group By InvoiceID,TaxDescription,InvoiceDate,Customer,DocumentID    
    
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,dbo.LookupDictionaryItem('CST Sales',Default),sum(Amount) - (sum(CSTPayable)) from [InvoiceDetail],[InvoiceAbstract]              
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And [TaxCode2]<> 0 And [TaxCode]=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0  
  Group By [invoiceDetail].[InvoiceID]            
  union all            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem('CST%',Default), "Value" = sum(CSTPayable) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And [TaxCode2]<> 0 And [TaxCode]=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  Group By [invoiceDetail].[InvoiceID]            
  ---------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS-----------------------  
  IF @SalesRegModeExempted = @STATE  
   BEGIN  
    Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
    [Description],TaxType,TaxAmount)            
    select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
    'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
    @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem('CST Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
    where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
    And IsNULL([TaxCode2],0)= 0 And IsNULL([TaxCode],0)=0 And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
    And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])=2            
    Group By [invoiceDetail].[InvoiceID]            
   END  
  ---------------------------------------------------------------------------------------              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALES,@SALESTYPE,"TaxType" = dbo.LookupDictionaryItem(' 0Net Value',Default), "Value" = sum(IsNULL(NetValue,0)- IsNULL(Freight,0))              
  from [InvoiceAbstract] where [InvoiceDate] between @Fromdate And @TodatePair            
  And InvoiceAbstract.InvoiceID In (Select ActualID from #Temp Where DocType = @SALES)          
  And [InvoiceType]<>4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  Group By [InvoiceAbstract].[InvoiceID]            
  ------------------------------------Service Invoice----------------------------------------
  If @IsServiceVersion = @STATE
   Begin
    ------------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS----------------------
    IF @SalesRegModeExempted = @STATE  
     BEGIN  
      Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
      Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
      'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
      MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem('SecondSale Tax Exempted',Default),
      'Value'=Sum(ServiceInvoiceDetail.NetValue) from [ServiceInvoiceDetail],[ServiceInvoiceAbstract]
      Where [ServiceInvoiceDate] Between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
      And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
      And [CSTPayable]=0 And [LSTPayable]=0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
      And (IsNULL(ServiceInvoiceDetail.SaleID,0)=2 Or IsNULL(ServiceInvoiceDetail.SaleID,0)=0)
      And dbo.sp_acc_ser_GetCustomerLocality([ServiceInvoiceAbstract].[ServiceInvoiceID])<> 2 And [SaleTax]=0
      Group By [ServiceInvoiceDetail].[ServiceInvoiceID]
     END  
    -------------------------------------------------------------------------------------------              
    Insert Into #TempSecondServiceSalesReg
    Select 'InvoiceID'=@ServicePrefix + CAST(DocumentID as nvarchar),ServiceInvoiceDate,
    'Customer'=dbo.sp_acc_ser_GetCustomer(ServiceInvoiceAbstract.ServiceInvoiceID),ServiceInvoiceAbstract.ServiceInvoiceID,
    CAST(CAST(MAX(SaleTax) as Decimal(18,6)) as nvarchar) + N'%(' + (CAST( CAST(Tax_Percentage as Decimal(18,6)) as nvarchar) + N'% ' + TaxComponent_desc + N')'),
    'Tax Value' = (Select Sum(Tax_Value) From ServiceInvoiceTaxComponents SIT 
    Where SIT.SerialNo=ServiceInvoiceDetail.SerialNo And SIT.TaxComponent_Code=TaxComponentDetail.TaxComponent_Code)
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract],ServiceInvoiceTaxComponents,TaxComponentDetail 
    Where [ServiceInvoiceDate] between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>''
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And ServiceInvoiceDetail.SerialNo = ServiceInvoiceTaxComponents.SerialNo
    And ServiceInvoiceTaxComponents.TaxComponent_Code = TaxComponentDetail.TaxComponent_Code
    And [LSTPayable]<>0 And [CSTPayable]=0 And IsNULL(ServiceInvoiceDetail.NetValue,0) > 0
    And ServiceInvoiceTaxComponents.TaxCode In (Select SecondSplitRecords from #TempSecondSplit)  
    And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0 And [SaleTax]<>0
    And (IsNULL(ServiceInvoiceDetail.SaleID,0)=2 Or IsNULL(ServiceInvoiceDetail.SaleID,0)=0)
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],ServiceInvoiceAbstract.ServiceInvoiceID,
    DocumentID,ServiceInvoiceDate,Tax_Percentage,TaxComponent_desc,ServiceInvoiceDetail.SerialNo,
    ServiceInvoiceTaxComponents.TaxCode,ServiceInvoiceTaxComponents.TaxComponent_Code,TaxComponentDetail.TaxComponent_Code
    Order by (CAST(CAST(MAX([SaleTax])as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default))      

    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,
    'TaxType'=(CAST(CAST(MAX([SaleTax])as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default)),'Value'=Sum(LSTPayable)
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract],[ServiceInvoiceTaxComponents]
    Where [ServiceInvoiceDate] between @Fromdate And @TodatePair
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And [ServiceInvoiceTaxComponents].[SerialNo] = [ServiceInvoiceDetail].[SerialNo]
    And [LSTPayable]<>0 And [CSTPayable]=0 And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And ServiceInvoiceTaxComponents.TaxCode In (Select SecondSplitRecords from #TempSecondSplit)
    And [SaleTax]<>0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    And (IsNULL(ServiceInvoiceDetail.SaleID,0)=2 Or IsNULL(ServiceInvoiceDetail.SaleID,0)=0)
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],(CAST([SaleTax] as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default))
    Union ALL
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,
    (CAST(CAST(MAX(SaleTax) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale',Default)),Sum(ServiceInvoiceDetail.NetValue)-(Sum(LSTPayable))
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract],[ServiceInvoiceTaxComponents]
    Where [ServiceInvoiceDate] between @Fromdate And @TodatePair
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And [ServiceInvoiceTaxComponents].[SerialNo] = [ServiceInvoiceDetail].[SerialNo]
    And [LSTPayable]<>0 And [CSTPayable]=0 And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And ServiceInvoiceTaxComponents.TaxCode In (Select SecondSplitRecords from #TempSecondSplit)
    And [SaleTax]<>0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0             
    And (IsNULL(ServiceInvoiceDetail.SaleID,0)=2 Or IsNULL(ServiceInvoiceDetail.SaleID,0)=0)
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],(CAST(SaleTax as nvarchar) + dbo.LookupDictionaryItem('% SecondSale',Default))
    Union ALL
    Select DocumentID,InvoiceDate,Customer,InvoiceID,@SERVICE,@SERVICETYPE,TaxDescription,Sum(TaxValue) From #TempSecondServiceSalesReg
    Group By InvoiceID,DocumentID,TaxDescription,InvoiceDate,Customer
    ---------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS-----------------------  
    IF @SalesRegModeExempted = @STATE  
     BEGIN  
      Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
      Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
      'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
      MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem('0FirstSale Tax Exempted',Default),
      'Value'=Sum(ServiceInvoiceDetail.NetValue) from [ServiceInvoiceDetail],[ServiceInvoiceAbstract]
      where [ServiceInvoiceDate] between @Fromdate And @TodatePair And [SaleTax]=0
      And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
      And [CSTPayable]=0 And [LSTPayable]=0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
      And dbo.sp_acc_ser_GetCustomerLocality([ServiceInvoiceAbstract].[ServiceInvoiceID])<> 2
      And IsNULL(ServiceInvoiceDetail.SaleID,0)=1 And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
      Group By [ServiceInvoiceDetail].[ServiceInvoiceID]            
     END  
    ---------------------------------------------------------------------------------------              
    Insert Into #TempFirstServiceSalesReg      
    Select 'InvoiceID'=@ServicePrefix + CAST(DocumentID as nvarchar),ServiceInvoiceDate,
    'Customer'=dbo.sp_acc_ser_GetCustomer([ServiceInvoiceAbstract].[ServiceInvoiceID]),ServiceInvoiceAbstract.ServiceInvoiceID,
    CAST(CAST(MAX(SaleTax) as Decimal(18,6)) as nvarchar) + N'%(' +(CAST(CAST(Tax_Percentage as Decimal(18,6)) as nvarchar) + N'% ' + TaxComponent_desc + N')'),
    'Tax Value'=(Select Sum(Tax_Value) From ServiceInvoiceTaxComponents SIT
    Where SIT.SerialNo=ServiceInvoiceDetail.SerialNo And SIT.TaxComponent_Code=TaxComponentDetail.TaxComponent_Code)
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract],ServiceInvoiceTaxComponents,TaxComponentDetail
    Where [ServiceInvoiceDate] between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]      
    And ServiceInvoiceDetail.SerialNo = ServiceInvoiceTaxComponents.SerialNo
    And ServiceInvoiceTaxComponents.TaxComponent_Code = TaxComponentDetail.TaxComponent_Code
    And [LSTPayable]<>0 And [CSTPayable]=0 And IsNULL(ServiceInvoiceDetail.NetValue,0) > 0
    And ServiceInvoiceTaxComponents.TaxCode In (Select SecondSplitRecords from #TempSecondSplit)
    And [SaleTax]<>0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0 And IsNULL(ServiceInvoiceDetail.SaleID,0)=1
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],[ServiceInvoiceAbstract].[ServiceInvoiceID],
    DocumentID,ServiceInvoiceDate,(CAST([SaleTax] as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default)),CAST(SaleTax as Decimal(18,6)),
    Tax_Percentage,TaxComponent_desc,ServiceInvoiceDetail.SerialNo,ServiceInvoiceTaxComponents.TaxCode,
    ServiceInvoiceTaxComponents.TaxComponent_Code,TaxComponentDetail.TaxComponent_Code
    Order by (CAST(CAST(MAX([SaleTax]) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default))
              
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,
    'TaxType'=(CAST(CAST(MAX([SaleTax]) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default)),'Value'=Sum(LSTPayable)
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract],[ServiceInvoiceTaxComponents]
    where [ServiceInvoiceDate] between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And ServiceInvoiceDetail.SerialNo = ServiceInvoiceTaxComponents.SerialNo
    And [LSTPayable]<>0 And [CSTPayable]=0 And IsNULL(ServiceInvoiceDetail.SaleID,0)=1
    And ServiceInvoiceTaxComponents.TaxCode In (Select SecondSplitRecords from #TempSecondSplit)
    And [SaleTax]<>0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0 
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],(CAST([SaleTax] as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default))
    Union ALL
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,
    (CAST(CAST(MAX(SaleTax)as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale',Default)),Sum(ServiceInvoiceDetail.NetValue)-(Sum(LSTPayable))
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract],[ServiceInvoiceTaxComponents]
    Where [ServiceInvoiceDate] between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And ServiceInvoiceDetail.SerialNo = ServiceInvoiceTaxComponents.SerialNo
    And [LSTPayable]<>0 And [CSTPayable]=0 And IsNULL(ServiceInvoiceDetail.SaleID,0)=1
    And ServiceInvoiceTaxComponents.TaxCode In (Select SecondSplitRecords from #TempSecondSplit)
    And [SaleTax]<>0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],(CAST(SaleTax as nvarchar) + dbo.LookupDictionaryItem('% FirstSale',Default))
    Union ALL
    Select DocumentID,InvoiceDate,'Customer'=Customer,InvoiceID,@SERVICE,@SERVICETYPE,TaxDescription,Sum(TaxValue) From #TempFirstServiceSalesReg
    Group By InvoiceID,TaxDescription,InvoiceDate,Customer,DocumentID    
    
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,dbo.LookupDictionaryItem('CST Sales',Default),Sum(ServiceInvoiceDetail.NetValue)-(Sum(CSTPayable)) 
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract],[ServiceInvoiceTaxComponents]
    Where [ServiceInvoiceDate] between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And ServiceInvoiceDetail.SerialNo = ServiceInvoiceTaxComponents.SerialNo
    And ServiceInvoiceTaxComponents.TaxCode In (Select SecondSplitRecords from #TempSecondSplit)
    And [CSTPayable]<>0 And [LSTPayable]=0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID]
    Union ALL
    Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem('CST%',Default),'Value'=Sum(CSTPayable)
    from [ServiceInvoiceDetail],[ServiceInvoiceAbstract],[ServiceInvoiceTaxComponents]
    Where [ServiceInvoiceDate] between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And ServiceInvoiceDetail.SerialNo = ServiceInvoiceTaxComponents.SerialNo
    And ServiceInvoiceTaxComponents.TaxCode In (Select SecondSplitRecords from #TempSecondSplit)
    And [CSTPayable]<>0 And [LSTPayable]=0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID]
    ---------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS-----------------------  
    IF @SalesRegModeExempted = @STATE  
     BEGIN  
      Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
      Select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
      'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
      MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem('CST Exempted',Default),'Value'=Sum(ServiceInvoiceDetail.NetValue)
      from [ServiceInvoiceDetail],[ServiceInvoiceAbstract],[ServiceInvoiceTaxComponents]
      where [ServiceInvoiceDate] between @Fromdate And @TodatePair And IsNULL(ServiceInvoiceDetail.SpareCode,N'')<>N''
      And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
      And ServiceInvoiceDetail.SerialNo = ServiceInvoiceTaxComponents.SerialNo And [SaleTax]=0
      And IsNULL([CSTPayable],0)=0 And IsNULL([LSTPayable],0)=0 And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
      And dbo.sp_acc_ser_GetCustomerLocality([ServiceInvoiceAbstract].[ServiceInvoiceID])=2            
      Group By [ServiceInvoiceDetail].[ServiceInvoiceID]            
     END  
    ---------------------------------------------------------------------------------------              
    Insert Into #Temp(InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description],TaxType,TaxAmount)
    select 'InvoiceID'=@ServicePrefix + CAST(MAX(DocumentID) as nvarchar),MAX(ServiceInvoiceDate),
    'Customer'=dbo.sp_acc_ser_GetCustomer(MAX([ServiceInvoiceAbstract].[ServiceInvoiceID])),
    MAX([ServiceInvoiceAbstract].[ServiceInvoiceID]),@SERVICE,@SERVICETYPE,'TaxType'=dbo.LookupDictionaryItem(' 0Net Value',Default),
    'Value'=(Sum(ServiceInvoiceDetail.NetValue)-Sum(IsNULL(Freight,0))) from [ServiceInvoiceAbstract],[ServiceInvoiceDetail] 
    Where [ServiceInvoiceDate] between @Fromdate And @TodatePair And (IsNULL(Status,0) & 128)=0 And (IsNULL(Status,0) & 64)=0
    And [ServiceInvoiceAbstract].[ServiceInvoiceID]=[ServiceInvoiceDetail].[ServiceInvoiceID]
    And ServiceInvoiceAbstract.ServiceInvoiceID In (Select ActualID from #Temp Where DocType = @SERVICE)          
    Group By [ServiceInvoiceDetail].[ServiceInvoiceID],[ServiceInvoiceAbstract].[ServiceInvoiceID]            
   End
  -------------------------------------Sales Return------------------------------------------            
  ---------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS-----------------------  
  IF @SalesRegModeExempted = @STATE  
   BEGIN  
    Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
    [Description],TaxType,TaxAmount)            
    select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
    'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
    @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('SecondSale Tax Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
    where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
    And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
    And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
    And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID]) <> 2            
    Group By [invoiceDetail].[InvoiceID]            
   END  
  ---------------------------------------------------------------------------------------              
  Insert Into #TempSecondSalesRetReg      
  select 'InvoiceID'= @Prefix + CAST(DocumentID as nvarchar),InvoiceDate,      
  'Customer'=dbo.getcustomer([InvoiceAbstract].[InvoiceID]),[InvoiceAbstract].[InvoiceID],      
  CAST(CAST(MAX(TaxCode) as Decimal(18,6)) as nvarchar) +  N'%(' + (CAST(CAST(Tax_Percentage as Decimal(18,6)) as nvarchar) + N'% ' + TaxComponent_desc + N')'),    
  'Tax Value' = (Select Sum(Tax_Value) From InvoiceTaxComponents i1 where i1.InvoiceID = InvoiceAbstract.InvoiceID And i1.Product_Code = InvoiceDetail.Product_Code And i1.Tax_Code = InvoiceDetail.TaxID And i1.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code)      
  from [InvoiceDetail],[InvoiceAbstract],InvoiceTaxComponents,TaxComponentDetail      
  where [InvoiceDate] between @Fromdate And @TodatePair       
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]      
  And InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID      
  And InvoiceDetail.Product_Code = InvoiceTaxComponents.Product_Code      
  And InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code      
  And InvoiceTaxComponents.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code      
  And [TaxCode]<> 0 And [TaxCode2]=0  And [InvoiceType]=4       
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0       
  And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)      
  And IsNULL(SalePrice,0) > 0      
  Group By [invoiceDetail].[InvoiceID],[InvoiceAbstract].[InvoiceID],DocumentID,InvoiceDate,     
  (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default)), Tax_Percentage,TaxComponent_desc,    
  InvoiceDetail.TaxID,InvoiceTaxComponents.Tax_Component_Code,InvoiceDetail.Product_Code,TaxComponentDetail.TaxComponent_Code        
  order by (CAST( CAST(MAX([TaxCode]) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default))      
    
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = (CAST( CAST(MAX([TaxCode]) as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default)),"Value" = sum(STPayable)            
  from [InvoiceDetail],[InvoiceAbstract] where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0  And [InvoiceType]=4             
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And (IsNULL(InvoiceDetail.SaleID,0)=2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
  Group By [invoiceDetail].[InvoiceID], (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% SecondSale Tax',Default))            
  union all            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,(CAST(CAST(MAX(TaxCode)as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% SecondSale',Default)), sum(Amount) - (sum(STPayable))             
  from [InvoiceDetail],[InvoiceAbstract]where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0 And [InvoiceType]=4             
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And (IsNULL(InvoiceDetail.SaleID,0)= 2 or IsNULL(InvoiceDetail.SaleID,0)= 0)            
  Group By [invoiceDetail].[InvoiceID],(CAST(TaxCode as nvarchar) + dbo.LookupDictionaryItem('% SecondSale',Default))            
  union            
  Select DocumentID,InvoiceDate,'Customer'=Customer,InvoiceID,@SALESRETURN,@SALESRETURNTYPE,TaxDescription,Sum(TaxValue) From #TempSecondSalesRetReg    
  Group By InvoiceID,TaxDescription,InvoiceDate,Customer,DocumentID              
  ---------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS-----------------------  
  IF @SalesRegModeExempted = @STATE  
   BEGIN  
    Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
    [Description],TaxType,TaxAmount)            
    select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
    'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
    @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('FirstSale Tax Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
    where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
    And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
    And IsNULL(InvoiceDetail.SaleID,0)=1            
    And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])<> 2            
    Group By [invoiceDetail].[InvoiceID]            
   END  
  ---------------------------------------------------------------------------------------              
  Insert Into #TempFirstSalesRetReg      
  select 'InvoiceID'= @Prefix + CAST(DocumentID as nvarchar),InvoiceDate,      
  'Customer'=dbo.getcustomer([InvoiceAbstract].[InvoiceID]),[InvoiceAbstract].[InvoiceID],      
  CAST(CAST(MAX(TaxCode) as Decimal(18,6)) as nvarchar) +  N'%(' + (CAST(CAST(Tax_Percentage as Decimal(18,6)) as nvarchar) + N'% ' + TaxComponent_desc + N')'),    
  'Tax Value' = (Select Sum(Tax_Value) From InvoiceTaxComponents i1 where i1.InvoiceID = InvoiceAbstract.InvoiceID And i1.Product_Code = InvoiceDetail.Product_Code And i1.Tax_Code = InvoiceDetail.TaxID And i1.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code)      
  from [InvoiceDetail],[InvoiceAbstract],InvoiceTaxComponents,TaxComponentDetail      
  where [InvoiceDate] between @Fromdate And @TodatePair       
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]      
  And InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID      
  And InvoiceDetail.Product_Code = InvoiceTaxComponents.Product_Code      
  And InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code      
  And InvoiceTaxComponents.Tax_Component_Code = TaxComponentDetail.TaxComponent_Code      
  And [TaxCode]<> 0 And [TaxCode2]=0  And [InvoiceType]=4       
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0       
  And IsNULL(InvoiceDetail.SaleID,0)=1 And IsNULL(SalePrice,0) > 0      
  Group By [invoiceDetail].[InvoiceID],[InvoiceAbstract].[InvoiceID],DocumentID,InvoiceDate,    
  (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default)),CAST(TaxCode as Decimal(18,6)),Tax_Percentage,TaxComponent_desc,      
  InvoiceDetail.TaxID,InvoiceTaxComponents.Tax_Component_Code,InvoiceDetail.Product_Code,TaxComponentDetail.TaxComponent_Code        
  order by (CAST(CAST(MAX([TaxCode])as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default))      
    
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = (CAST(CAST(MAX([TaxCode])as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default)),"Value" = sum(STPayable)            
  from [InvoiceDetail],[InvoiceAbstract] where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0  And [InvoiceType]=4             
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  And IsNULL(InvoiceDetail.SaleID,0)=1            
  Group By [invoiceDetail].[InvoiceID], (CAST([TaxCode] as nvarchar) + dbo.LookupDictionaryItem('% FirstSale Tax',Default))            
  union all            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,(CAST( CAST(MAX(TaxCode)as Decimal(18,6)) as nvarchar) + dbo.LookupDictionaryItem('% FirstSale',Default)), sum(Amount) - (sum(STPayable))             
  from [InvoiceDetail],[InvoiceAbstract]where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode]<> 0 And [TaxCode2]=0 And [InvoiceType]=4             
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0            
  And IsNULL(InvoiceDetail.SaleID,0)=1            
  Group By [invoiceDetail].[InvoiceID],(CAST(TaxCode as nvarchar) + dbo.LookupDictionaryItem('% FirstSale',Default))            
  union            
  Select DocumentID,InvoiceDate,'Customer'=Customer,InvoiceID,@SALESRETURN,@SALESRETURNTYPE,TaxDescription,Sum(TaxValue) From #TempFirstSalesRetReg    
  Group By InvoiceID,TaxDescription,InvoiceDate,Customer,DocumentID    
              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,dbo.LookupDictionaryItem('CST Sales',Default),sum(Amount) - (sum(CSTPayable)) from            
  [InvoiceDetail],[InvoiceAbstract]where [InvoiceDate] between @Fromdate And @TodatePair             
  And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]And [TaxCode2]<> 0 And [TaxCode]=0 And [InvoiceType]=4             
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  Group By [invoiceDetail].[InvoiceID]            
  union all            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('CST%',Default), "Value" = sum(CSTPayable) from [InvoiceDetail],[InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
  And InvoiceDetail.TaxID In (Select SecondSplitRecords from #TempSecondSplit)  
  And [TaxCode2]<> 0 And [TaxCode]=0 And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  Group By [invoiceDetail].[InvoiceID]            
  ---------------------IF EXEMPTED THEN (ONLY) DISPLAY ITS RECORDS-----------------------  
  IF @SalesRegModeExempted = @STATE  
   BEGIN  
    Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
    [Description],TaxType,TaxAmount)            
    select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
    'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
    @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem('CST Exempted',Default), "Value" = sum(Amount) from [InvoiceDetail],[InvoiceAbstract]             
    where [InvoiceDate] between @Fromdate And @TodatePair And [InvoiceAbstract].[InvoiceID]= [InvoiceDetail].[InvoiceID]            
    And [TaxCode2]= 0 And [TaxCode]=0 And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
    And dbo.getcustomerlocal([InvoiceAbstract].[InvoiceID])=2            
    Group By [invoiceDetail].[InvoiceID]            
   END  
  ---------------------------------------------------------------------------------------              
  Insert Into #Temp(InvoiceID ,[Invoice Date],Customer,ActualID,DocType,            
  [Description],TaxType,TaxAmount)            
  select 'InvoiceID'= @Prefix + CAST(MAX(DocumentID) as nvarchar),MAX(InvoiceDate),            
  'Customer'=dbo.getcustomer(MAX([InvoiceAbstract].[InvoiceID])),MAX([InvoiceAbstract].[InvoiceID]),            
  @SALESRETURN,@SALESRETURNTYPE,"TaxType" = dbo.LookupDictionaryItem(' 0Net value',Default), "Value" = sum(IsNULL(NetValue,0) - IsNULL(Freight,0)) from [InvoiceAbstract]             
  where [InvoiceDate] between @Fromdate And @TodatePair             
  And InvoiceAbstract.InvoiceID In (Select ActualID from #Temp Where DocType = @SALESRETURN)  
  And [InvoiceType]=4 And (IsNULL(Status,0) & 128) = 0 And (IsNULL(Status,0) & 64)= 0             
  Group By [InvoiceAbstract].[InvoiceID]            
 END  
------------------------------END OF SALESREGMODE CONDITION CHECKS---------------------------  
Insert Into #TempRegister(InvoiceID,[Invoice Date],Customer,[Document Reference],[LST No.],[CST No.],[TIN No.],ActualID,DocType,[Description])
Select InvoiceID,[Invoice Date],Customer,
(Select Docreference from InvoiceAbstract Where InvoiceID = #Temp.ActualID),
ltrim(rtrim(dbo.sp_acc_getCustomerCSTLSTNumber(ACTUALID,1))),         
ltrim(rtrim(dbo.sp_acc_getCustomerCSTLSTNumber(ACTUALID,2))),    
ltrim(rtrim(dbo.sp_acc_getCustomerCSTLSTNumber(ACTUALID,3))),    
ActualID,DocType,[Description]
from #Temp Where DocType In (@SALES,@SALESRETURN)
Group By InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description]

If @IsServiceVersion = @STATE
 Begin
  Insert Into #TempRegister(InvoiceID,[Invoice Date],Customer,[Document Reference],[LST No.],[CST No.],[TIN No.],ActualID,DocType,[Description])
  Select InvoiceID,[Invoice Date],Customer,
  (Select Docreference from ServiceInvoiceAbstract Where ServiceInvoiceID=#Temp.ActualID),
  ltrim(rtrim(dbo.sp_acc_ser_getCustomerCSTLSTNumber(ACTUALID,1))),         
  ltrim(rtrim(dbo.sp_acc_ser_getCustomerCSTLSTNumber(ACTUALID,2))),    
  ltrim(rtrim(dbo.sp_acc_ser_getCustomerCSTLSTNumber(ACTUALID,3))),    
  ActualID,DocType,[Description] from #Temp Where DocType = @SERVICE
  Group By InvoiceID,[Invoice Date],Customer,ActualID,DocType,[Description]
 End

DECLARE PivotTable CURSOR KEYSET FOR            
Select Distinct(taxtype) from #Temp -- order by SerialNo            
OPEN PivotTable            
FETCH FROM PivotTable Into @TaxPercent            
  
WHILE @@FETCH_STATUS =0            
BEGIN            
 Set @DynamicSQL = N'Alter Table #TempRegister Add [' + @TaxPercent + N'] Decimal(18,6) NULL'            
 Exec sp_executesql @DynamicSQL            
  
 FETCH NEXT FROM PivotTable Into @TaxPercent            
END            
CLOSE PivotTable            
DEALLOCATE PivotTable            
            
Declare @ActualID Int   
Declare @taxtype1 nvarchar(128)            
            
DECLARE ScanRegister1 CURSOR KEYSET FOR            
Select ActualID,DocType,Taxtype,TaxAmount from #Temp            
OPEN ScanRegister1            
FETCH FROM ScanRegister1 Into @ActualID,@DocType,@Taxtype1,@TaxAmount            
            
WHILE @@FETCH_STATUS =0            
BEGIN            
 Update #TempRegister            
 Set @DynamicSQL = N'Update #TempRegister Set [' + @TaxType1 + N'] = ' +  CAST(0 as nvarchar)             
 Exec sp_executesql @DynamicSQL            
            
 FETCH NEXT FROM ScanRegister1 Into @ActualID,@DocType,@Taxtype1,@TaxAmount            
END            
CLOSE ScanRegister1            
DEALLOCATE ScanRegister1            
            
DECLARE ScanRegister CURSOR KEYSET FOR            
Select ActualID,DocType,Taxtype,TaxAmount from #Temp            
OPEN ScanRegister            
FETCH FROM ScanRegister Into @ActualID,@DocType,@Taxtype1,@TaxAmount            
            
WHILE @@FETCH_STATUS =0            
BEGIN            
 Update #TempRegister            
 Set @DynamicSQL = N'Update #TempRegister Set [' + @TaxType1 + N'] = ' +  CAST(@TaxAmount as nvarchar) + N' Where ActualID = ' + CAST(@ActualID as nvarchar) + N' And DocType = ' + CAST(@DocType as nvarchar)            
 Exec sp_executesql @DynamicSQL            
  
 FETCH NEXT FROM ScanRegister Into @ActualID,@DocType,@Taxtype1,@TaxAmount            
END            
CLOSE ScanRegister            
DEALLOCATE ScanRegister            

If @IsTINNoSorting = @STATE
 /* This Part is been used to sort the Result Set Based on the TIN No.
 Note: Currently this part doesnt supports service version*/
 Begin 
  Select *,'DocSort' = 1 from #TempRegister 
  Where IsNULL([TIN No.],N'') <> N'' And [DocType]=@SALES
  Union ALL
  Select *,'DocSort' = 2 from #TempRegister
  Where IsNULL([TIN No.],N'') = N'' And [DocType]=@SALES
  Union ALL
  Select *,'DocSort' = 3 from #TempRegister
  Where IsNULL([TIN No.],N'') <> N'' And [DocType]=@SALESRETURN
  Union ALL
  Select *,'DocSort' = 4 from #TempRegister
  Where IsNULL([TIN No.],N'') = N'' And [DocType]=@SALESRETURN
  Order By [DocSort],[Description],[Invoice Date]
 End
Else
 Begin
  Select * from #TempRegister Order By [Description],[Invoice Date]
 End
            
Drop Table #Temp            
Drop Table #TempRegister            
Drop Table #TempSecondSalesReg    
Drop Table #TempFirstSalesReg    
Drop Table #TempSecondServiceSalesReg    
Drop Table #TempFirstServiceSalesReg    
Drop Table #TempSecondSalesRetReg    
Drop Table #TempFirstSalesRetReg
Drop Table #TempSecondSplit
Drop Table #TempFirstSplit
