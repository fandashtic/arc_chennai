CREATE procedure [dbo].[spr_List_SalesReturnInvoices_Cons]
(
 @BranchName NVarChar(4000),
 @UOMDesc NVarChar(30),
	@FROMDATE DateTime,  
 @TODATE DateTime
)  
As 
	Declare @FromDateBh DateTime
	Declare @ToDateBh DateTime

 Set @FromDateBh = dbo.StripDateFromTime(@FromDate)      
 Set @ToDateBh = dbo.StripDateFromTime(@ToDate)      

	Declare @Delimeter as Char(1)        
 Set @Delimeter=Char(15)  

	Declare @Damages NVarChar(50)    
	Declare @Saleable NVarChar(50)    
	Declare @Cancelled NVarChar(50)    

	Set @Damages = dbo.LookupDictionaryItem(N'Damages', Default)    
	Set @Saleable = dbo.LookupDictionaryItem(N'Saleable', Default)    
	Set @Cancelled = dbo.LookupDictionaryItem(N'Cancelled', Default)    

 CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)        
 If @BranchName = N'%'            
  Insert InTo #TmpBranch Select Distinct CompanyId From Reports  
 Else            
  Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))  
   
	Declare	@CIDSetUp As NVarChar(15)
	Select @CIDSetUp=RegisteredOwner From Setup 

	Select  
		Cast(InvoiceID As NVarChar)+ @CIDSetUp,
		"Distributor Code"=@CIDSetUp,"InvoiceID" = SRPrefix.Prefix + Cast(DocumentID As NVarChar),   
	 "Doc Reference"=DocReference,"Date" = InvoiceDate,"Customer" = Customer.Company_Name,  
	 "Goods Value (%c)" = GoodsValue,"Product Discount (%c)" = ProductDiscount,  
	 "Discount%" = DiscountPercentage,"Discount (%c)" = DiscountValue,   
	 "Addn. Discount%" = Cast(AdditionalDiscount As NVarChar) + N'%',
		"Addn. Discount (%c)" = AddlDiscountValue,"Tax Suffered (%c)" = TotalTaxSuffered,  
	 "Tax Applicable (%c)" = TotalTaxApplicable,"Freight (%c)" = Freight,   
	 "Net Value (%c)" =		Case Status & 128 When 0 Then Cast(NetValue As NVarChar) Else '' End,   
	 "(Can)Net Value (%c)" =	Case Status & 128 When 0 Then '' Else Cast(NetValue As NVarChar) End,  
	 "Adjusted Reference" = dbo.GetSalesReturnReference(InvoiceID),  
	 "Reference" = NewReference,   
	 "Branch" = ClientInformation.Description,  
	 "Balance (%c)" = Balance,  
	 "Type" = Case When (Status & 32) <> 0 Then @Damages Else @Saleable End,  
	 "Status" = Case Status & 128 When 0 Then '' Else @Cancelled End,  
	 "Salesman" = SM.Salesman_Name  
	From  
		InvoiceAbstract, Customer, VoucherPrefix SRPrefix, 
		VoucherPrefix RefPrefix,ClientInformation, Salesman SM  
	Where   
		InvoiceType = 4 AND dbo.StripDateFromTime(InvoiceDate) = @FROMDATEBH AND 
		dbo.StripDateFromTime(InvoiceDate) = @TODATEBH AND  
	 InvoiceAbstract.CustomerID = Customer.CustomerID AND  
	 SRPrefix.TranID = N'SALES RETURN' AND  
	 RefPrefix.TranID = N'INVOICE' AND  
	 InvoiceAbstract.ClientID *= ClientInformation.ClientID and   
	 InvoiceAbstract.SalesmanID *= SM.SalesmanID

Union All

 Select 
		Cast(RecordID As NVarChar),"Distributor Code" = CompanyId,"InvoiceID" = Field1,  
		"Doc Reference"=Field2,"Date" = Field3,"Customer" =Field4,"Goods Value (%c)" = Field5,
		"Product Discount (%c)" = Field6,"Discount%" =Field7 ,"Discount (%c)" = Field8,   
	 "Addn. Discount%" = Field9,"Addn. Discount (%c.)" = Field10,"Tax Suffered (%c)" = Field11,  
	 "Tax Applicable (%c)" = Field12,"Freight (%c.)" = Field13,	 "Net Value (%c)" =	Field14,
	 "(Can)Net Value (%c)" =	Field15,"Adjusted Reference" = Field16,"Reference" = Field17,   
	 "Branch" = Field18,"Balance (%c)" = Field19,"Type" = Field20,"Status" = Field21,"Salesman" = Field22
 From  
  Reports,ReportAbstractReceived   
 Where  
  Reports.ReportID In (Select ReportID From Reports Where ReportName = N'Sales Return Invoice')  
  And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)  
  And ReportAbstractReceived.ReportID = Reports.ReportID  
  And Field1 <> N'InvoiceID' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:' 
  And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Sales Return Invoice') Where FromDate = @FromDateBh And ToDate = @ToDateBh)
