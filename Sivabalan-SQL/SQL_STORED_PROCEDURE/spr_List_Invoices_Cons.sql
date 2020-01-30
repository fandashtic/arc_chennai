CREATE procedure [dbo].[spr_List_Invoices_Cons]    
(          
 @BranchName NVarChar(4000),    
 @DocType NVarChar(100),    
 @UOMDesc NVarChar(30),  
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
  
 Declare @Credit NVarChar(50)      
 Declare @Cash NVarChar(50)      
 Declare @Cheque NVarChar(50)      
 Declare @DD NVarChar(50)      
  
 Set @Credit = dbo.LookupDictionaryItem(N'Credit', Default)      
 Set @Cash = dbo.LookupDictionaryItem(N'Cash', Default)      
 Set @Cheque = dbo.LookupDictionaryItem(N'Cheque', Default)      
 Set @DD = dbo.LookupDictionaryItem(N'DD', Default)      
  
 Declare @INV As NVarChar(50)   
 Select @INV = Prefix From VoucherPrefix Where TranID = N'INVOICE'     
  
 CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)          
 If @BranchName = N'%'              
  Insert InTo #TmpBranch Select Distinct CompanyId From Reports    
 Else              
  Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))    
  
 Declare @CIDSetUp As NVarChar(15)  
 Select @CIDSetUp=RegisteredOwner From Setup   
     
 Select      
  Cast(Cast(InvoiceID As NVarChar)+ @CIDSetUp As NVarChar),  
  "Distributor Code"=@CIDSetUp,  
  "InvoiceID" = Cast(@INV + Cast(DocumentID As NVarChar)As NVarChar),    
  "Doc Ref" = InvoiceAbstract.DocReference, "Date" = InvoiceDate,     
  "Payment Mode" =     
    Case IsNull(PaymentMode,0)            
     When 0 Then @Credit            
     When 1 Then @Cash           
     When 2 Then @Cheque            
     When 3 Then @DD            
     Else  @Credit            
    End,            
  "Payment Date" = PaymentDate, "Credit Term" = CreditTerm.Description,            
  "CustomerID" = Customer.CustomerID, "Customer" = Customer.Company_Name,            
  "Forum Code" = Customer.AlternateCode, "Goods Value (%c)" = GoodsValue,             
  "Product Discount (%c)" = ProductDiscount,            
  "Trade Discount%" = Cast(Cast(DiscountPercentage as Decimal(18,6)) As NVarChar) + N'%',             
  "Trade Discount (%c)" = Cast(InvoiceAbstract.GoodsValue * (DiscountPercentage /100) as Decimal(18,6)),            
  "Addl Discount" = Cast(AdditionalDiscount As NVarChar) + N'%',            
  "Addl Discount (%c)" = InvoiceAbstract.GoodsValue * (AdditionalDiscount / 100),            
  "Freight (%c)"=Freight, "Net Value (%c)" = NetValue,  
  "Net Volume" = Cast((    
   Case     
    When @UOMdesc = N'UOM1' then     
     (Select Sum(dbo.sp_Get_ReportingQty(Quantity,Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)) from Items, InvoiceDetail     
     Where Items.Product_Code = InvoiceDetail.Product_Code and     
     InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)    
    When @UOMdesc = N'UOM2' then     
     (Select Sum(dbo.sp_Get_ReportingQty(Quantity,Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)) from Items, InvoiceDetail     
     Where Items.Product_Code = InvoiceDetail.Product_Code and     
      InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)    
    Else    
     (Select Sum(Quantity) from Items, InvoiceDetail     
     Where Items.Product_Code = InvoiceDetail.Product_Code and     
     InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)    
   End) as NVarChar),     
  "Adj Ref" = IsNull(InvoiceAbstract.AdjRef, N''),            
  "Adjusted Amount (%c)" = IsNull(InvoiceAbstract.AdjustedAmount, 0),            
  "Balance (%c)" = InvoiceAbstract.Balance,            
  "Collected Amount (%c)" = NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0),            
  "Branch" = ClientInformation.Description, "Beat" = Beat.Description,            
  "Salesman" = Salesman.Salesman_Name,            
  "Reference" =             
   Case Status & 15            
    When 1 Then  N''            
    When 2 Then  N''            
    When 4 Then  N''            
    When 8 Then  N''            
   END + Cast(NewReference As NVarChar),            
  "Round Off (%c)" = RoundOffAmount,"Document Type" = DocSerialType,          
  "Total TaxSuffered Value (%c)" =  TotalTaxSuffered,  
  "Total SalesTax Value (%c)" = TotalTaxApplicable          
 From     
  InvoiceAbstract, Customer, CreditTerm, ClientInformation, Beat, Salesman             
 Where    
  InvoiceType in (1,3) And   
  dbo.StripDateFromTime(InvoiceDate) = @FromDateBh And   
  dbo.StripDateFromTime(InvoiceDate) = @ToDateBh And            
  InvoiceAbstract.CustomerID = Customer.CustomerID And            
  InvoiceAbstract.CreditTerm *= CreditTerm.CreditID And             
  InvoiceAbstract.ClientID *= ClientInformation.ClientID And            
  InvoiceAbstract.BeatID *= Beat.BeatID And            
  InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And             
  (InvoiceAbstract.Status & 128) = 0 And            
  InvoiceAbstract.DocSerialType Like @DocType  
  
Union All  
  
 Select         
  Cast(RecordID As NVarChar),"Distributor Code" = CompanyId,"InvoiceID" = Field1,    
  "Doc Ref" = Field2,"Date" = Field3, "Payment Mode" =Field4,"Payment Date" = Field5,            
  "Credit Term" = Field6,"CustomerID" = Field7,"Customer" = Field8,"Forum Code" = Field9,    
  "Goods Value (%c)" = Field10,"Product Discount (%c)" = Field11,"Trade Discount%" = Field12,    
  "Trade Discount (%c)" = Field13,"Addl Discount" = Field14,"Addl Discount (%c)" = Field15,    
  "Freight (%c)"=Field16,"Net Value (%c)" = Field17,   
  "Net Volume"=Cast((    
   Case     
    When @UOMdesc = N'UOM1' then     
     (Select   
       Sum(dbo.sp_Get_ReportingQty(Cast(RDR.Field4 As Decimal(18,6)),Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End))   
      From   
       Items, ReportDetailReceived RDR     
     Where   
      Items.Product_Code = RDR.Field1 And     
      RDR.RecordID =ReportAbstractReceived.RecordID And  
      RDR.Field4 <> N'Quantity')    
    When @UOMdesc = N'UOM2' then     
     (Select   
       Sum(dbo.sp_Get_ReportingQty(Cast(RDR.Field4 As Decimal(18,6)),Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End))   
      From   
       Items, ReportDetailReceived RDR      
      Where   
      Items.Product_Code = RDR.Field1 And     
      RDR.RecordID =ReportAbstractReceived.RecordID And  
      RDR.Field4 <> N'Quantity')   
    Else    
     (Select   
       Sum(Cast(RDR.Field4 As Decimal(18,6)))   
      From   
       Items, ReportDetailReceived RDR         
      Where   
      Items.Product_Code = RDR.Field1 And     
      RDR.RecordID =ReportAbstractReceived.RecordID And  
      RDR.Field4 <> N'Quantity')    
   End) as NVarChar),     
  "Adj Ref" = Field19,    
  "Adjusted Amount (%c)" = Field20,"Balance (%c)" = Field21, "Collected Amount (%c)" = Field22,    
  "Branch" = Field23,"Beat" = Field24,"Salesman" = Field25,"Reference" = Field26,  
  "Round Off (%c)" = Field27,"Document Type" = Field28,  
  "Total TaxSuffered Value (%c)" = Field29,"Total SalesTax Value (%c)" = Field30        
 From    
  Reports,ReportAbstractReceived     
 Where    
  Reports.ReportID In (Select Max(ReportID) From Reports Where ReportName = N'Invoices'
  And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Invoices') Where FromDate = @FromDateBh And ToDate = @ToDateBh) Group by CompanyId)
  And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)    
  And ReportAbstractReceived.ReportID = Reports.ReportID    
  And Field1 <> N'InvoiceID' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:'   
  And Field28 Like @DocType
