CREATE procedure [dbo].[spr_Daily_Collection_Stmt_Detail] (@PaymentMode nvarchar(255),          
         @FromDate Datetime,          
         @ToDate Datetime)          
As          

Declare @ADVANCE As NVarchar(50)

Set @ADVANCE = dbo.LookupDictionaryItem(N'Advance', Default)

IF Rtrim(@PaymentMode) = N'Post Dated Cheque' 

BEGIN


 Select N'Collection',          
 "CollectionNo" = Collections.FullDocID,          
 "Bank" = BankMaster.BankName,          
 "Branch" = BranchMaster.BranchName,          
 "ChequeNo" = Collections.ChequeNumber,          
 "Cheque Date" = Collections.ChequeDate,          
 "CustomerID" = Collections.CustomerID,          
 "Customer" = Customer.Company_Name,          
 "DocumentID" = CollectionDetail.OriginalID,          
 "DocumentDate" = CollectionDetail.DocumentDate,          
 "Amount (%c)" = Case CollectionDetail.DocumentType          
 When 4 Then          
 CollectionDetail.DocumentValue          
 When 5 Then          
 CollectionDetail.DocumentValue          
 Else          
 0 - CollectionDetail.DocumentValue          
 End,          
 "Amount Adjusted (%c)" = Case CollectionDetail.DocumentType          
 When 4 Then          
 CollectionDetail.AdjustedAmount          
 When 5 Then          
 CollectionDetail.AdjustedAmount          
 Else          
 0 - CollectionDetail.AdjustedAmount          
 End,          
 "Addln. Adjustment (%c)" = Case CollectionDetail.DocumentType          
 When 4 Then          
 CollectionDetail.ExtraCollection          
 When 5 Then          
 CollectionDetail.ExtraCollection          
 Else          
 0 - CollectionDetail.ExtraCollection          
 End           
 From Collections, CollectionDetail, Customer, BankMaster, BranchMaster          
 Where Collections.DocumentID = CollectionDetail.CollectionID And          
 Collections.DocumentDate Between @FromDate And @ToDate And          
 IsNull(Collections.Status, 0) & 128 = 0 And          
 Collections.PaymentMode = 1 And          
 Collections.BankCode *= BankMaster.BankCode And          
 Collections.BranchCode *= BranchMaster.BranchCode And          
 Collections.BankCode *= BranchMaster.BankCode And          
 Collections.CustomerID = Customer.CustomerID And          
 CollectionDetail.AdjustedAmount > 0 And          
 dbo.StripDateFromTime(Collections.ChequeDate) > dbo.StripDateFromTime(@FromDate)          
     
 Union All        
     
 Select N'Collection',          
 "CollectionNo" = Collections.FullDocID,          
 "Bank" = BankMaster.BankName,          
 "Branch" = BranchMaster.BranchName,          
 "ChequeNo" = Case IsNull(Collections.ChequeNumber, 0)          
 When 0 Then          
 Null          
 Else          
 Collections.ChequeNumber          
 End,          
 "Cheque Date" = Case Collections.PaymentMode          
 When 1 Then          
 Collections.ChequeDate          
 Else          
 Null          
 End,          
 "CustomerID" = Collections.CustomerID,          
 "Customer" = Customer.Company_Name,          
 "DocumentID" = @ADVANCE,        
 "DocumentDate" = Null,        
 "Amount (%c)" = Collections.Balance,        
 "Amount Adjusted (%c)" = 0,        
 "Addln. Adjustment (%c)" = 0        
 From Collections, Customer, BankMaster, BranchMaster          
 Where         
 Collections.DocumentDate Between @FromDate And @ToDate And          
 IsNull(Collections.Status, 0) & 128 = 0 And          
 Collections.PaymentMode = 1 And          
 Collections.BankCode *= BankMaster.BankCode And          
 Collections.BranchCode *= BranchMaster.BranchCode And          
 Collections.BankCode *= BranchMaster.BankCode And          
 Collections.CustomerID = Customer.CustomerID And          
 Collections.Balance > 0        
 Order By CollectionNo       
End

ELSE IF Rtrim(@PaymentMode) = N'Cheque'
BEGIN
     
 Select N'Retail Invoice',           
 "CollectionNo" = VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID As nvarchar),           
 "Bank" = Null,           
 "Branch" = Null,          
 "PaymentDetails" = Case dbo.GetAmountCollectedEx(InvoiceAbstract.PaymentDetails, @PaymentMode)          
 When N'' Then          
 Null          
 Else          
 dbo.GetAmountCollectedEx(InvoiceAbstract.PaymentDetails, @PaymentMode)          
 End,          
 "Cheque Date" = Null,          
 "CustomerID" = InvoiceAbstract.CustomerID,          
 "Customer" = Cash_Customer.CustomerName,          
 "DocumentID" = VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID As nvarchar),          
 "Document Date" = InvoiceAbstract.InvoiceDate,          
 "Amount (%c)" = InvoiceAbstract.NetValue,          
 "Amount Adjusted (%c)" = dbo.GetAmountCollected(InvoiceAbstract.PaymentDetails, @PaymentMode +N':'),          
 "Addln. Adjustment (%c)" = Null          
 From InvoiceAbstract, Cash_Customer, VoucherPrefix          
 Where InvoiceAbstract.InvoiceType = 2 And          
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And          
 InvoiceAbstract.InvoiceDate Between @Fromdate And @ToDate And          
 InvoiceAbstract.CustomerID *= Cast(Cash_Customer.CustomerID As nvarchar) And          
 VoucherPrefix.TranID = N'INVOICE' And          
 dbo.GetAmountCollected(InvoiceAbstract.PaymentDetails, @PaymentMode +N':') <> 0          
     
 Union All          
     
 Select N'Collection',          
 "CollectionNo" = Collections.FullDocID,          
 "Bank" = BankMaster.BankName,          
 "Branch" = BranchMaster.BranchName,          
 "ChequeNo" = cast ( Case IsNull(Collections.ChequeNumber, 0)          
 When 0 Then          
 Null          
 Else          
 Collections.ChequeNumber          
 End as nvarchar) ,          
 "Cheque Date" = Case Collections.PaymentMode          
 When 1 Then          
 Collections.ChequeDate          
 Else          
 Null          
 End,          
 "CustomerID" = Collections.CustomerID,          
 "Customer" = Customer.Company_Name,          
 "DocumentID" = CollectionDetail.OriginalID,          
 "DocumentDate" = CollectionDetail.DocumentDate,          
 "Amount (%c)" = Case CollectionDetail.DocumentType          
 When 4 Then          
 CollectionDetail.DocumentValue          
 When 5 Then          
 CollectionDetail.DocumentValue          
 Else          
 0 - CollectionDetail.DocumentValue          
 End,          
 "Amount Adjusted (%c)" = Case CollectionDetail.DocumentType          
 When 4 Then          
 CollectionDetail.AdjustedAmount          
 When 5 Then          
 CollectionDetail.AdjustedAmount          
 Else          
 0 - CollectionDetail.AdjustedAmount          
 End,          
 "Addln. Adjustment (%c)" = Case CollectionDetail.DocumentType          
 When 4 Then          
 CollectionDetail.ExtraCollection          
 When 5 Then          
 CollectionDetail.ExtraCollection          
 Else          
 0 - CollectionDetail.ExtraCollection          
 End           
 From Collections, CollectionDetail, Customer, BankMaster, BranchMaster          
 Where Collections.DocumentID = CollectionDetail.CollectionID And          
 Collections.DocumentDate Between @FromDate And @ToDate And          
 IsNull(Collections.Status, 0) & 128 = 0 And          
 Collections.PaymentMode = 1 And          
 Collections.BankCode *= BankMaster.BankCode And          
 Collections.BranchCode *= BranchMaster.BranchCode And          
 Collections.BankCode *= BranchMaster.BankCode And          
 Collections.CustomerID = Customer.CustomerID And          
 CollectionDetail.AdjustedAmount > 0 And          
 dbo.StripDateFromTime(Collections.ChequeDate) = dbo.StripDateFromTime(@FromDate)           
     
     
 Union All        
     
     
 Select N'Collection',          
 "CollectionNo" = Collections.FullDocID,          
 "Bank" = BankMaster.BankName,          
 "Branch" = BranchMaster.BranchName,          
 "ChequeNo" = cast (Case IsNull(Collections.ChequeNumber, 0)          
 When 0 Then          
 Null          
 Else          
 Collections.ChequeNumber         
 End as nvarchar) ,     
 "Cheque Date" = Case Collections.PaymentMode          
 When 1 Then          
 Collections.ChequeDate          
 Else          
 Null          
 End,          
 "CustomerID" = Collections.CustomerID,          
 "Customer" = Customer.Company_Name,          
 "DocumentID" = @ADVANCE,        
 "DocumentDate" = Null,          
 "Amount (%c)" = Collections.Balance,        
 "Amount Adjusted (%c)" = 0,        
 "Addln. Adjustment (%c)" = 0        
 From Collections, Customer, BankMaster, BranchMaster          
 Where         
 Collections.DocumentDate Between @FromDate And @ToDate And          
 IsNull(Collections.Status, 0) & 128 = 0 And          
 Collections.PaymentMode = 1 And          
 Collections.BankCode *= BankMaster.BankCode And          
 Collections.BranchCode *= BranchMaster.BranchCode And          
 Collections.BankCode *= BranchMaster.BankCode And          
 Collections.CustomerID = Customer.CustomerID And          
 Collections.Balance > 0        
 Order By CollectionNo        
End          

ELSE
BEGIN
 Select N'Retail Invoice',           
 "CollectionNo" = VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID As nvarchar),           
 "Bank" = Null,           
 "Branch" = Null,          
 "PaymentDetails" = Case dbo.GetAmountCollectedEx(InvoiceAbstract.PaymentDetails, Rtrim(@PaymentMode))          
 When N'' Then          
 Null          
 Else          
 dbo.GetAmountCollectedEx(InvoiceAbstract.PaymentDetails, @PaymentMode)          
 End,          
 "Cheque Date" = Null,          
 "CustomerID" = InvoiceAbstract.CustomerID,          
 "Customer" = Cash_Customer.CustomerName,          
 "DocumentID" = VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID As nvarchar),          
 "Document Date" = InvoiceAbstract.InvoiceDate,          
 "Amount (%c)" = InvoiceAbstract.NetValue,          
 "Amount Adjusted (%c)" = dbo.GetAmountCollected(InvoiceAbstract.PaymentDetails, Rtrim(@PaymentMode) + N':'),          
 "Addln. Adjustment (%c)" = Null          
 From InvoiceAbstract, Cash_Customer, VoucherPrefix          
 Where InvoiceAbstract.InvoiceType = 2 And          
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And          
 InvoiceAbstract.InvoiceDate Between @Fromdate And @ToDate And          
 InvoiceAbstract.CustomerID *= Cast(Cash_Customer.CustomerID As nvarchar) And          
 VoucherPrefix.TranID = N'INVOICE' And          
 dbo.GetAmountCollected(InvoiceAbstract.PaymentDetails, Rtrim(@PaymentMode) + N':') <> 0    

 Union All          
     
 Select N'Collection',          
 "CollectionNo" = Collections.FullDocID,          
 "Bank" = BankMaster.BankName,          
 "Branch" = BranchMaster.BranchName,          
 "ChequeNo" = cast (Case IsNull(Collections.ChequeNumber, 0)          
 When 0 Then          
 Null          
 Else          
 Collections.ChequeNumber          
 End as nvarchar) ,          
 "Cheque Date" = Case Collections.PaymentMode          
 When 1 Then          
 Collections.ChequeDate          
 Else          
 Null          
 End,          
 "CustomerID" = Collections.CustomerID,          
 "Customer" = Customer.Company_Name,          
 "DocumentID" = CollectionDetail.OriginalID,          
 "DocumentDate" = CollectionDetail.DocumentDate,          
 "Amount (%c)" = Case CollectionDetail.DocumentType          
 When 4 Then          
 CollectionDetail.DocumentValue          
 When 5 Then          
 CollectionDetail.DocumentValue          
 Else          
 0 - CollectionDetail.DocumentValue          
 End,          
 "Amount Adjusted (%c)" = Case CollectionDetail.DocumentType          
 When 4 Then          
 CollectionDetail.AdjustedAmount          
 When 5 Then          
 CollectionDetail.AdjustedAmount          
 Else          
 0 - CollectionDetail.AdjustedAmount          
 End,          
 "Addln. Adjustment (%c)" = Case CollectionDetail.DocumentType          
 When 4 Then  
 CollectionDetail.ExtraCollection          
 When 5 Then          
 CollectionDetail.ExtraCollection          
 Else          
 0 - CollectionDetail.ExtraCollection          
 End           
 From Collections, CollectionDetail, Customer, BankMaster, BranchMaster          
 Where Collections.DocumentID = CollectionDetail.CollectionID And          
 Collections.DocumentDate Between @FromDate And @ToDate And          
 IsNull(Collections.Status, 0) & 128 = 0 And          
 Collections.PaymentMode = Case @PaymentMode
 When N'Cash'  then
 0
 When N'Cheque' then
 1
When N'DD' then
2
 End
 And          
 Collections.BankCode *= BankMaster.BankCode And          
 Collections.BranchCode *= BranchMaster.BranchCode And          
 Collections.BankCode *= BranchMaster.BankCode And          
 Collections.CustomerID = Customer.CustomerID And          
 CollectionDetail.AdjustedAmount > 0    
 Union All        
     
 Select N'Collection',          
 "CollectionNo" = Collections.FullDocID,          
 "Bank" = BankMaster.BankName,          
 "Branch" = BranchMaster.BranchName,          
 "ChequeNo" = cast(Case IsNull(Collections.ChequeNumber, 0)          
 When 0 Then          
 Null          
 Else          
 Collections.ChequeNumber          
 End as nvarchar),          
 "Cheque Date" = Case Collections.PaymentMode          
 When 1 Then          
 Collections.ChequeDate          
 Else          
 Null          
 End,          
 "CustomerID" = Collections.CustomerID,          
 "Customer" = Customer.Company_Name,          
 "DocumentID" = @ADVANCE,        
 "DocumentDate" = Null,        
 "Amount (%c)" = Collections.Balance,        
 "Amount Adjusted (%c)" = 0,        
 "Addln. Adjustment (%c)" = 0        
 From Collections, Customer, BankMaster, BranchMaster          
 Where         
 Collections.DocumentDate Between @FromDate And @Todate And          
 IsNull(Collections.Status, 0) & 128 = 0 And          
 Collections.PaymentMode = Case @PaymentMode
 When N'Cash' then
 0
 When N'Cheque' then
 1
When N'DD' then
 2
 End
 And          

 Collections.BankCode *= BankMaster.BankCode And          
 Collections.BranchCode *= BranchMaster.BranchCode And          
 Collections.BankCode *= BranchMaster.BankCode And          
 Collections.CustomerID = Customer.CustomerID And          
 Collections.Balance > 0        
 Order By CollectionNo      
End
