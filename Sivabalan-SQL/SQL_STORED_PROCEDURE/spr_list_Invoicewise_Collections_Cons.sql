CREATE procedure [dbo].[spr_list_Invoicewise_Collections_Cons]  
(  
 @BranchName NVarChar(4000),    
 @FromDateBh DateTime,        
 @ToDateBh DateTime  
)        
As      
  
Declare @FromDate DateTime  
Declare @ToDate DateTime  
  
Set @FromDate = dbo.StripDateFromTime(@FromDateBh)        
Set @ToDate = dbo.StripDateFromTime(@ToDateBh)       
  
Declare @CREDIT As NVarChar(50)      
Declare @CASH As NVarChar(50)      
Declare @CHEQUE As NVarChar(50)      
Declare @DD As NVarChar(50)      
Declare @OTHERS As NVarChar(50)      
Declare @INVOICE As NVarChar(50)      
Declare @RETAILINVOICE As NVarChar(50)      
Declare @SALESRETURNSALEABLE As NVarChar(50)      
Declare @SALESRETURNDAMAGES As NVarChar(50)      
Declare @SALESRETURN As NVarChar(50)      
Declare @INVOICEAMENDMENT As NVarChar(50)      
  
Set @CREDIT = dbo.LookupDictionaryItem(N'Credit', Default)      
Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)      
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default)      
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)      
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)      
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)      
Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice' , Default)      
Set @SALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'Sales Return - Saleable', Default)      
Set @SALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'Sales Return - Damages', Default)      
Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)      
Set @INVOICEAMENDMENT = dbo.LookupDictionaryItem(N'Invoice Amendment', Default)      
  
Declare @Delimeter as Char(1)          
Set @Delimeter=Char(15)    
  
CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)          
If @BranchName = N'%'              
 Insert InTo #TmpBranch Select Distinct CompanyId From Reports    
Else              
 Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))    
  
Declare @CIDSetUp As NVarChar(15)  
Select @CIDSetUp=RegisteredOwner From Setup   
        
Select   
 Cast(InvoiceID As NVarChar) + @CIDSetUp,     
 "Distributor Code" = @CIDSetUp,    
 "InvoiceID" = VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID as NVarChar),        
 "Doc Ref" = InvoiceAbstract.DocReference,        
 "Invoice Date" = InvoiceAbstract.InvoiceDate,         
 "Customer" = Customer.Company_Name,        
 "Salesman" = Salesman.Salesman_Name,         
 "Payment Mode" =   
  Case IsNull(PaymentMode,0)        
   When 0 Then @CREDIT        
   When 1 Then @CASH        
   When 2 Then @CHEQUE        
   When 3 Then @DD        
   Else @CREDIT      
  End,        
 "Net Value (%c)" =    
  Case InvoiceType        
   When 4 then 0 - InvoiceAbstract.NetValue        
   Else InvoiceAbstract.NetValue        
  End,         
 "Balance (%c)" =   
  Case InvoiceType   
   When 4 Then 0-(InvoiceAbstract.Balance)   
   Else InvoiceAbstract.Balance   
  End,      
 "Type" =   
  Case InvoiceType        
   When 1 then  @INVOICE      
   When 3 Then  @INVOICEAMENDMENT      
   When 4 Then  @SALESRETURN      
  End,      
 "Rounded Net Value (%c)"  = NetValue + RoundOffAmount      
From   
 InvoiceAbstract, Customer, Salesman, VoucherPrefix        
Where   
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) = @FromDate And   
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) = @ToDate And        
 InvoiceAbstract.InvoiceType in (1, 3, 4) And        
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And        
 InvoiceAbstract.CustomerID = Customer.CustomerID And        
 InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And        
 VoucherPrefix.TranID = 'INVOICE'  
        
Union All        
  
Select   
 Cast(InvoiceID As NVarChar) + @CIDSetUp,     
 "Distributor Code" = @CIDSetUp,    
 "InvoiceID" = VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID as NVarChar),        
 "Doc Ref" = InvoiceAbstract.DocReference,"Invoice Date" = InvoiceAbstract.InvoiceDate,         
 "Customer" = Customer.Company_Name, "Salesman" = Salesman.Salesman_Name,      
 "Payment Mode" =   
  Case IsNull(PaymentMode,0)        
   When 0 Then @CREDIT      
   When 1 Then @OTHERS      
  End,        
 "Net Value (%c)" =   
  Case InvoiceType        
   When 5 Then 0 - IsNull(InvoiceAbstract.NetValue, 0)      
   When 6 then 0 - IsNull(InvoiceAbstract.NetValue, 0)      
   Else IsNull(InvoiceAbstract.NetValue, 0)      
  End,         
 "Balance (%c)" =   
  Case InvoiceType        
   When 5 Then 0 - IsNull(InvoiceAbstract.Balance, 0)      
   When 6 Then 0 - IsNull(InvoiceAbstract.Balance, 0)      
   Else IsNull(InvoiceAbstract.Balance, 0)      
  End,         
 "Type" =   
  Case InvoiceType        
   When 5 then @SALESRETURNSALEABLE      
   When 6 then @SALESRETURNDAMAGES      
   Else @RETAILINVOICE      
  End,      
 "Rounded Net Value (%c)"  = NetValue + RoundOffAmount      
From   
 InvoiceAbstract, Customer, Salesman, VoucherPrefix        
Where   
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And        
 InvoiceAbstract.InvoiceType In (2, 5, 6) And        
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And        
 InvoiceAbstract.CustomerID *= Customer.CustomerID And        
 InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And        
 VoucherPrefix.TranID = 'INVOICE'        
    
Union ALL    
    
Select    
 Cast(RecordID As NVarChar),CompanyID,RAR.Field1,RAR.Field2,RAR.Field3,RAR.Field4,      
 RAR.Field5,RAR.Field6,RAR.Field7,RAR.Field8,RAR.Field9,RAR.Field10      
From   
 Reports,ReportAbstractReceived RAR   
Where   
 Reports.ReportID In (Select Max(ReportID) From Reports Where ReportName = N'Collections - Invoicewise'
	And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Collections - Invoicewise') Where FromDate = @FromDate And ToDate = @ToDate) Group By CompanyId)  
 And Reports.ReportID = RAR.ReportID And    
 ReportName = 'Collections - Invoicewise' And    
 Field1 <> N'InvoiceID' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:'   
 And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)
