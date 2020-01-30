CREATE PROCEDURE Spr_QuotationMasterList(@CustomerID nvarchar(2550), @FromDate DateTime, @ToDate DateTime)    
AS    
Declare @Delimeter as Char(1)  
Declare @YES As NVarchar(50)  
Declare @NO As NVarchar(50)  
Set @YES = dbo.LookupDictionaryitem(N'Yes', Default)  
Set @NO = dbo.LookupDictionaryitem(N'No', Default)  

Declare @ITEMWISE As NVarchar(50)  
Declare @CATEGORYWISE As NVarchar(50)  
Declare @MANUFACTURERWISE As NVarchar(50)  
Declare @UNIVERSALDISCOUNT  As NVarchar(50)    
Set @ITEMWISE = dbo.LookupDictionaryitem(N'Itemwise', Default)  
Set @CATEGORYWISE = dbo.LookupDictionaryitem(N'Categorywise', Default)  
Set @MANUFACTURERWISE = dbo.LookupDictionaryitem(N'Manufacturerwise', Default)  
Set @UNIVERSALDISCOUNT = dbo.LookupDictionaryitem(N'Universal Discount', Default)  
  
Declare @KeyAcc as nVarChar(25)
Declare @Wholesale as nVarChar(25)
Declare @Others as nVarChar(25)

Set @KeyAcc = dbo.LookupDictionaryitem(N'Key Account', Default)  
Set @Wholesale = dbo.LookupDictionaryitem(N'Wholesale', Default)  
Set @Others = dbo.LookupDictionaryitem(N'Others', Default)  

Declare @WDCode NVarchar(255)    
Declare @WDDest NVarchar(255)    
Declare @CompaniesToUploadCode NVarchar(255)    

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
Select Top 1 @WDCode = RegisteredOwner From Setup  

If @CompaniesToUploadCode = N'ITC001'
	Set @WDDest= @WDCode  
Else  
  Begin  
	Set @WDDest= @WDCode  
	Set @WDCode= @CompaniesToUploadCode  
  End      
 
Set @Delimeter=Char(15)      
Declare @tmpCustomer table(Customer_ID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @CustomerID='%'       
   Insert into @tmpCustomer select CustomerID from Customer      
Else      
   Insert into @tmpCustomer select * from dbo.sp_SplitIn2Rows(@CustomerID,@Delimeter)      

Create Table #tmpQuotIDs (QuotIDs Int)

Insert into #tmpQuotIDs (QuotIDs)
Select Distinct ID.QuotationID 
From InvoiceAbstract IA 
Join InvoiceDetail ID On ID.InvoiceID = IA.InvoiceID And IsNull(ID.QuotationID,0) > 0
Where IA.InvoiceType in (1,3) And IA.Status &128 = 0 
And  IA.InvoiceDate  BETWEEN @FromDate AND @ToDate 
    
Select  "Quotation ID" = QA.QuotationID,
"WD Code"=@WDCode, "WD Dest"=@WDDest,"FromDate" = @FromDate, "ToDate"=@ToDate,
"Quotation Name" = QA.QuotationName,
"Quotation Date" = (Convert(varchar(10), QA.CreationDate, 103)+ ' ' + Convert(varchar(10), QA.CreationDate, 108)),     -- "Quotation Date" = QA.QuotationDate,     
"Valid From Date" = QA.ValidFromDate, "Valid To Date" = QA.ValidToDate,     
"Type" = Case QA.QuotationLevel WHEN 1 THEN @ITEMWISE WHEN 2 THEN @CATEGORYWISE WHEN 3 THEN @MANUFACTURERWISE  ELSE @UNIVERSALDISCOUNT  END,     
"CustomerID" = QC.CustomerID, "Customer Name" = C.Company_Name, 
"Customer Channel Type" = OLCls.Channel_Type_Desc, --CC.ChannelDesc ,
"Active" = Case QA.Active WHEN 1 THEN @YES ELSE @NO END,
"Special Tax" = Case When QA.SpecialTax = 1 Then @YES Else @NO End,
"Quotation Type" = Case When QA.QuotationType = 1 Then @KeyAcc When QA.QuotationType = 2 Then @Wholesale When QA.QuotationType = 3 Then @Others Else N'' End
, "Last Modified Date" = (Convert(varchar(10), QA.LastModifiedDate, 103)+ ' ' + Convert(varchar(10), QA.LastModifiedDate, 108))
From QuotationAbstract QA
Join QuotationCustomers QC On QC.QuotationID = QA.QuotationID 
Join Customer C On C.CustomerID = QC.CustomerID And C.CustomerID in (Select Customer_ID from @tmpCustomer)
--Join Customer_Channel CC On CC.ChannelType = C.ChannelType And CC.ChannelDesc Not In ('WD')
Join tbl_mERP_OLClassMapping OLClsM On OLClsM.CustomerID = C.CustomerID And OLClsM.Active = 1
Join tbl_mERP_OLClass OLCls On OLCls.ID = OLClsM.OLClassID And OLCls.Channel_Type_Desc Not In ('WD')
Where QA.QuotationType Not In  (4)  And QA.QuotationLevel in (1,2) 
And ( 
( ( ( @FromDate Between QA.ValidFromDate  And QA.ValidToDate) Or (@ToDate Between QA.ValidFromDate  And QA.ValidToDate   )) And QA.Active = 1) OR 
(Qa.QuotationID in (Select  Quotids from #tmpQuotIDs)) 
)

Drop Table #tmpQuotIDs 
