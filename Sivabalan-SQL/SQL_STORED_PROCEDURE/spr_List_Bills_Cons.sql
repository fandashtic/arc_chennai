Create Procedure [dbo].[spr_List_Bills_Cons]  
(  
 @BranchName NVarChar(4000),
 @Vendor NVarChar(2550),    
 @FromDate DateTime,     
 @ToDate DateTime  
)    
AS    

Declare @FromDateBh DateTime
Declare @ToDateBh DateTime

Declare @Delimeter As Char(1)      
Set @Delimeter=Char(15)      

Set @FromDateBh = dbo.StripDateFromTime(@FromDate)      
Set @ToDateBh = dbo.StripDateFromTime(@ToDate)      

CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)        
If @BranchName = N'%'            
 Insert InTo #TmpBranch Select Distinct CompanyId From Reports  
Else            
 Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))  
   
Create Table #TmpVen(Vendor_Name NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
If @Vendor=N'%'    
   Insert InTo #TmpVen Select Vendor_Name From Vendors    
Else    
   Insert InTo #TmpVen Select * From dbo.sp_SplitIn2Rows(@Vendor,@Delimeter)    
    
	Declare @Cancelled NVarChar(50)  
	Declare @Amended NVarChar(50)    
	Declare @Open NVarChar(50)    

	Set @Cancelled = dbo.LookupDictionaryItem(N'Cancelled', Default)   
	Set @Amended = dbo.LookupDictionaryItem(N'Amended', Default)  
	Set @Open = dbo.LookupDictionaryItem(N'Open', Default)      
	
	Declare	@CIDSetUp As NVarChar(15)
	Select @CIDSetUp=RegisteredOwner From Setup 
	
	Select    
	 Cast(BillID As NVarChar)+ @CIDSetUp,
		"Distributor Code"=@CIDSetUp,  
	 "Bill ID" =   
	 Case     
	  When DocumentReference Is Null Then BillPrefix.Prefix + CAST(DocumentID AS NVarChar)    
	  Else BillAPrefix.Prefix + CAST(DocumentID AS NVarChar)    
	 End,    
	 "Bill Date" = BillDate, "CreditTerm"  = CreditTerm.Description,     
	 "Payment Date" = PaymentDate, "InvoiceReference" = InvoiceReference,    
	 "Vendor" = Vendors.Vendor_Name,  
	 "Gross Amount (%c)" =   
	  (Select Sum(Quantity * PurchasePrice)   
	   From BillDetail    
	   Where BillDetail.BillID = BillAbstract.BillID),    
	 "Tax Amount (%c)" = TaxAmount,     
	 "Discount%" = DIscount,    
	 "Discount Amount (%c)" = Cast(  
	  (Select Sum(Quantity * PurchasePrice)    
	   From BillDetail     
	   Where BillDetail.BillID = BillAbstract.BillID)   
	  * DIscount / 100 as Decimal(18,6)),    
	 "Adjustment Amount (%c)" = AdjustmentAmount,"Adjusted Amount (%c)" = AdjustedAmount,    
	 "Net Amount (%c)" = Billabstract.Value + TaxAmount + AdjustmentAmount,    
	 "GRNID" = GRNPrefix.Prefix + CAST(NewGRNID AS NVarChar),    
	 "Status" =     
	  Case Status    
	   When 0 Then @Open     
	   When 128 Then @Amended    
	   Else @Cancelled    
	  End,    
	 "Original Bill" =   
	  Case DocumentReference    
	   When Null Then N''    
	   Else BillPrefix.Prefix + CAST(DocumentReference AS NVarChar)    
	  End,    
	 "Branch" = ClientInformation.Description, "ST"  = TNGST, CST    
	From   
	 BillAbstract
	 Inner Join Vendors On BillAbstract.VendorID = Vendors.VendorID
	 Inner Join VoucherPrefix BillPrefix On BillPrefix.TranID = N'BILL'
	 Inner Join VoucherPrefix GRNPrefix On GRNPrefix.TranID = N'GOODS RECEIVED NOTE' 
	 Left Outer Join ClientInformation On BillAbstract.ClientID = ClientInformation.ClientID
	 Inner Join VoucherPrefix BillAPrefix On BillAPrefix.TranID = N'BILL AMENDMENT'
	 Left Outer Join CreditTerm On CreditTerm.CreditID = BillAbstract.CreditTerm    
	Where  dbo.StripDateFromTime(BillDate) = @FromDateBh AND 
	 dbo.StripDateFromTime(BillDate) = @ToDateBh AND    
	 Vendors.Vendor_Name in(Select Vendor_Name From #TmpVen) AND    
	 IsNull(BillAbstract.Status, 0) & 192 = 0     
Union ALL

 Select       
		Cast(RecordID As NVarChar),"Distributor Code" = CompanyId,"Bill ID" =Field1,"Bill Date" = Field2,
	 "CreditTerm"  = Field3, "Payment Date" = Field4, "InvoiceReference" = Field5,    
	 "Vendor" = Field6,"Gross Amount" = Field7,"Tax Amount" = Field8,"DIscount%" = Field9,    
	 "DIscount Amount" = Field10,	 "Adjustment Amount" = Field11,"Adjusted Amount"=Field12,
  "Net Amount" = Field13,"GRNID" = Field14,"Status" =Field15,"Original Bill" =Field16,
		"Branch" = Field17, "ST"  = Field18,"CST"=Field19
 From  
  Reports,ReportAbstractReceived   
 Where  
  Reports.ReportID In (Select Max(ReportID) From Reports Where ReportName = N'Purchase Bills'  
  And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Purchase Bills') Where FromDate = @FromDateBh And ToDate = @ToDateBh) Group by CompanyId)
  And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)  
  And ReportAbstractReceived.ReportID = Reports.ReportID  
  And Field1 <> N'Bill ID' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:' 
  And Field6 Like @Vendor  


	Drop Table #TmpVen    
	    

