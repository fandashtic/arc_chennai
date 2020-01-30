CREATE Procedure [dbo].[sp_Acc_List_CreditNote_Cons]
(
	@BranchName NVarChar(4000),
	@FromDate DateTime,  
 @ToDate DateTime
)  
As  
	Declare @FromDateBh DateTime
	Declare @ToDateBh DateTime

 Set @FromDateBh = dbo.StripDateFromTime(@FromDate)      
 Set @ToDateBh = dbo.StripDateFromTime(@ToDate)    

	Declare @Delimeter as Char(1)        
 Set @Delimeter=Char(15)  

 CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)        
 If @BranchName = N'%'            
  Insert InTo #TmpBranch Select Distinct CompanyId From Reports  
 Else            
  Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))  

	Declare @Others NVarchar(50)    
	Declare @Vendor NVarchar(50)    
	Declare @Customer NVarchar(50)    
	Declare @Cancelled NVarchar(50)  
	Declare @Amended NVarchar(50)    
	Declare @Open NVarchar(50)    
	Declare @Closed NVarchar(50)  

	Set @Others = dbo.LookupDictionaryItem(N'Others', Default)    
	Set @Vendor = dbo.LookupDictionaryItem(N'Vendor', Default)    
	Set @Customer = dbo.LookupDictionaryItem(N'Customer', Default)    
	Set @Cancelled = dbo.LookupDictionaryItem(N'Cancelled', Default)   
	Set @Amended = dbo.LookupDictionaryItem(N'Amended', Default)  
	Set @Open = dbo.LookupDictionaryItem(N'Open', Default)      
	Set @Closed = dbo.LookupDictionaryItem(N'Closed', Default)    

	Declare	@CIDSetUp As NVarChar(15)
	Select @CIDSetUp=RegisteredOwner From Setup 


If Not Exists (Select * From ReportData Where Parent = 137)/*(Parent)137 = CreditNote Report*/  
	Select 
		Cast(CreditID As NVarChar),"Distributor Code"=@CIDSetUp,
		"Credit ID" = VoucherPrefix.Prefix + Cast(DocumentID as NVarChar),"Date" = DocumentDate,  
		"Type"=
			Case 
				When (CreditNote.CustomerID Is Null And CreditNote.VendorID Is Null) Then dbo.LookupDictionaryItem(@Others,Default) 
				Else (Case When CreditNote.CustomerID Is Null Then dbo.LookupDictionaryItem(@Vendor,Default) Else dbo.LookupDictionaryItem(@Customer,Default) End) 
			End,    
		"Account Name"=
			Case 
				When (CreditNote.CustomerID Is Null And CreditNote.VendorID Is Null) Then dbo.getaccountname(Isnull(Others,0)) 
				Else (Case When CreditNote.CustomerID Is Null Then Vendors.Vendor_Name Else Customer.Company_Name End) 
			End, 
		"Doc Ref" = DocRef, "Value" = NoteValue,  
		"Expense"=dbo.getaccountname(Isnull(CreditNote.AccountID,0)),"Remarks" = Memo,  
		"Status" =   
			Case   
			 When IsNull(Status,0) & 64 <> 0 Then dbo.LookupDictionaryItem(@Cancelled,Default)   
			 When Isnull(status & 128,0 ) = 128 And Isnull(RefDocid,0) <> 0 Then dbo.LookupDictionaryItem(@Amended,Default)      
			 When Isnull(status & 128,0 ) = 128 And Isnull(RefDocid,0) = 0  Then dbo.LookupDictionaryItem(@Amended,Default)      
			 When Isnull(status & 128,0 ) = 0 And Isnull(RefDocid,0) <> 0  Then dbo.LookupDictionaryItem(@Open,Default)      
			 When Isnull(status,0) = 0 And Balance = 0 And Isnull(RefDocid,0) = 0 Then dbo.LookupDictionaryItem(@Closed,Default)  
			 When Isnull(status,0) = 0 And Balance > 0 And Isnull(RefDocid,0) = 0 Then dbo.LookupDictionaryItem(@Open,Default)  
			End  
	From 
	CreditNote
	Left Join Customer on creditNote.CustomerID = Customer.CustomerID
	left Join Vendors on CreditNote.VendorID = Vendors.VendorID
	Inner Join VoucherPrefix on VoucherPrefix.TranID = N'CREDIT NOTE'
		--CreditNote, VoucherPrefix, Customer, Vendors  
	Where 
		--CreditNote.CustomerID *= Customer.CustomerID And  
		--CreditNote.VendorID *= Vendors.VendorID And  
		dbo.StripDateFromTime(CreditNote.DocumentDate) = @FromDateBh And 
		dbo.StripDateFromTime(CreditNote.DocumentDate)	= @ToDateBh 
		--And VoucherPrefix.TranID = N'CREDIT NOTE'
  
	Union All

 Select       
		Field1,"Distributor Code"=CompanyId,"Credit ID"=Field1,"Date"=Field2,"Type"= Field3,
		"Account Name"=Field4,"Doc Ref"=Field5,"Value (%c)"=Field6,"Expense"=Field7,
		"Remarks"=Field8,"Status"=Field9
 From  
  Reports,ReportAbstractReceived   
 Where  
  Reports.ReportID In (Select ReportID From Reports Where ReportName = N'Credit Notes')  
  And ReportAbstractReceived.ReportID = Reports.ReportID
  And Field1 <> N'Credit ID' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:' 
  And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)
  And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Credit Notes') Where FromDate = @FromDateBh And ToDate = @ToDateBh)

Else  
	Select 
			Cast(CreditID As NVarChar),"Distributor Code"=@CIDSetUp,"Credit ID" = VoucherPrefix.Prefix + Cast(DocumentID as NVarChar),
		"Date" = DocumentDate,  
		"Type"=
			Case 
				When (CreditNote.CustomerID Is Null And CreditNote.VendorID Is Null) Then dbo.LookupDictionaryItem(@Others,Default) 
				Else (Case When CreditNote.CustomerID Is Null Then dbo.LookupDictionaryItem(@Vendor,Default) Else dbo.LookupDictionaryItem(@Customer,Default) End) 
			End,    
		"Account Name"=
			Case 
				When (CreditNote.CustomerID Is Null And CreditNote.VendorID Is Null) Then dbo.getaccountname(Isnull(Others,0)) 
				Else (Case When CreditNote.CustomerID Is Null Then Vendors.Vendor_Name Else Customer.Company_Name End) 
			End, 
		"Doc Ref" = DocRef, "Value" = NoteValue,"Remarks" = Memo,  
		"Status" =   
		Case   
		 When IsNull(Status,0) & 64 <> 0 Then dbo.LookupDictionaryItem(@Cancelled,Default)   
		 When Isnull(status & 128,0 ) = 128 And Isnull(RefDocid,0) <> 0 Then dbo.LookupDictionaryItem(@Amended,Default)      
		 When Isnull(status & 128,0 ) = 128 And Isnull(RefDocid,0) = 0  Then dbo.LookupDictionaryItem(@Amended,Default)      
		 When Isnull(status & 128,0 ) = 0 And Isnull(RefDocid,0) <> 0  Then dbo.LookupDictionaryItem(@Open,Default)      
		 When Isnull(status,0) = 0 And Balance = 0 And Isnull(RefDocid,0) = 0 Then dbo.LookupDictionaryItem(@Closed,Default)  
		 When Isnull(status,0) = 0 And Balance > 0 And Isnull(RefDocid,0) = 0 Then dbo.LookupDictionaryItem(@Open,Default)  
		End  
	From 
		--CreditNote, VoucherPrefix, Customer, Vendors  
	CreditNote
	Left Join Customer on creditNote.CustomerID = Customer.CustomerID
	left Join Vendors on CreditNote.VendorID = Vendors.VendorID
	Inner Join VoucherPrefix on VoucherPrefix.TranID = N'CREDIT NOTE'
	Where 
		--CreditNote.CustomerID *= Customer.CustomerID And  
		--CreditNote.VendorID *= Vendors.VendorID And  
		dbo.StripDateFromTime(CreditNote.DocumentDate) = @FromDateBh And 
		dbo.StripDateFromTime(CreditNote.DocumentDate)	= @ToDateBh 
		--And VoucherPrefix.TranID = N'CREDIT NOTE'

	Union All

 Select       
		Field1,"Distributor Code"=CompanyId,"Credit ID"=Field1,"Date"=Field2,"Type"= Field3,
		"Account Name"=Field4,"Doc Ref"=Field5,"Value (%c)"=Field6,
		"Remarks"=Field8,"Status"=Field9
 From  
  Reports,ReportAbstractReceived   
 Where  
  Reports.ReportID In (Select ReportID From Reports Where ReportName = N'Credit Notes')  
  And ReportAbstractReceived.ReportID = Reports.ReportID
  And Field1 <> N'Credit ID' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:' 
  And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)
  And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Credit Notes') Where FromDate = @FromDateBh And ToDate = @ToDateBh)

