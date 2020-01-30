CREATE Procedure sp_acc_rpt_Daily_Collection_Stmt_Detail (@PaymentMode nvarchar(255),            
         @FromDate Datetime,            
         @ToDate Datetime)            
As            
IF Rtrim(@PaymentMode) = dbo.LookupDictionaryItem('Post Dated Cheque',Default)   
  
BEGIN  
  
  
 Select 'Collection',            
 "CollectionNo" = Collections.FullDocID,            
 "Account Number" = Null,  
 "Bank" = BankMaster.BankName,            
 "Branch" = BranchMaster.BranchName,            
 "ChequeNo" = Collections.ChequeNumber,            
 "Cheque Date" = Collections.ChequeDate,            
--  "CustomerID" = Collections.CustomerID,            
--  "Customer" = Customer.Company_Name,            
 "Type"= case when  Collections.Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,      
 "Account Name" = Case when  Collections.others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
 else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,       
 "DocumentID" = CollectionDetail.OriginalID,            
 "DocumentDate" = CollectionDetail.DocumentDate,            
 "Amount (%c)" = Case CollectionDetail.DocumentType            
 When 4 Then            
 CollectionDetail.DocumentValue            
 When 5 Then            
 CollectionDetail.DocumentValue            
 When 6 Then            
 CollectionDetail.DocumentValue            
 Else            
 0 - CollectionDetail.DocumentValue            
 End,            
 "Amount Adjusted (%c)" = Case CollectionDetail.DocumentType            
 When 4 Then            
 CollectionDetail.AdjustedAmount            
 When 5 Then            
 CollectionDetail.AdjustedAmount            
 When 6 Then            
 CollectionDetail.AdjustedAmount            
 Else            
 0 - CollectionDetail.AdjustedAmount            
 End,            
 "Addln. Adjustment (%c)" = Case CollectionDetail.DocumentType            
 When 4 Then            
 --Show Adjustment column Value When negative  
 Case   
   When CollectionDetail.Adjustment<0 then CollectionDetail.Adjustment  
   Else CollectionDetail.ExtraCollection            
 End   
 When 5 Then            
 --Show Adjustment column Value When negative  
 Case   
   When CollectionDetail.Adjustment<0 then CollectionDetail.Adjustment  
   Else CollectionDetail.ExtraCollection            
 End   
 When 6 Then            
 --Show Adjustment column Value When negative  
 Case   
   When CollectionDetail.Adjustment<0 then CollectionDetail.Adjustment  
   Else CollectionDetail.ExtraCollection            
 End   
 Else            
 0 - CollectionDetail.ExtraCollection            
 End             
 From Collections
 Inner Join CollectionDetail On Collections.DocumentID = CollectionDetail.CollectionID 
 Left Outer Join  BankMaster On Collections.BankCode = BankMaster.BankCode 
 Left Outer Join BranchMaster On Collections.BranchCode = BranchMaster.BranchCode And Collections.BankCode = BranchMaster.BankCode
 Where Collections.DocumentDate Between @FromDate And @ToDate And            
 IsNull(Collections.Status, 0) & 128 = 0 And Collections.PaymentMode = 1 And            
-- Collections.CustomerID = Customer.CustomerID And            
 CollectionDetail.AdjustedAmount > 0 And            
 dbo.StripDateFromTime(Collections.ChequeDate) > dbo.StripDateFromTime(@FromDate)            
       
 Union All          
       
 Select 'Collection',            
 "CollectionNo" = Collections.FullDocID,            
 "Account Number" = Null,  
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
--  "CustomerID" = Collections.CustomerID,            
--  "Customer" = Customer.Company_Name,            
 "Type"= case when  Collections.Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,      
 "Account Name" = Case when  Collections.others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
 else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,       
 "DocumentID" = dbo.LookupDictionaryItem('Advance',Default),          
 "DocumentDate" = Null,          
 "Amount (%c)" = Collections.Balance,          
 "Amount Adjusted (%c)" = 0,          
 "Addln. Adjustment (%c)" = 0          
 From Collections
 Left Outer Join BankMaster On Collections.BankCode = BankMaster.BankCode 
 Left Outer Join  BranchMaster On Collections.BranchCode = BranchMaster.BranchCode And Collections.BankCode = BranchMaster.BankCode
 Where Collections.DocumentDate Between @FromDate And @ToDate And            
 IsNull(Collections.Status, 0) & 128 = 0 And            
 Collections.PaymentMode = 1 And            
 
-- Collections.CustomerID = Customer.CustomerID And            
 Collections.Balance > 0          
 Order By CollectionNo         
End  
  
ELSE IF Rtrim(@PaymentMode) = dbo.LookupDictionaryItem('Cheque',Default)  
BEGIN  
       
 Select 'Retail Invoice',             
 "CollectionNo" = VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID As nVarchar),             
 "Account Number" = Null,  
 "Bank" = Null,             
 "Branch" = Null,            
 "PaymentDetails" = Case dbo.GetAmountCollectedEx(InvoiceAbstract.PaymentDetails, @PaymentMode)            
 When N'' Then            
 Null            
 Else            
 dbo.GetAmountCollectedEx(InvoiceAbstract.PaymentDetails, @PaymentMode)            
 End,            
 "Cheque Date" = Null,            
  "Type" = dbo.LookupDictionaryItem('Retail Customer',Default),          
 "Account Name" = Cash_Customer.CustomerName,          
 "DocumentID" = case  IsNULL(InvoiceAbstract.GSTFlag ,0)
                When 0 then VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID As nVarchar) else  IsNULL(InvoiceAbstract.GSTFullDocID,'')
                End,           
 "Document Date" = InvoiceAbstract.InvoiceDate,            
 "Amount (%c)" = InvoiceAbstract.NetValue,            
 "Amount Adjusted (%c)" = dbo.GetAmountCollected(InvoiceAbstract.PaymentDetails, @PaymentMode +N':'),            
 "Addln. Adjustment (%c)" = Null            
 From InvoiceAbstract
 Left Outer Join Cash_Customer On InvoiceAbstract.CustomerID = Cast(Cash_Customer.CustomerID As nVarchar)
 Inner Join VoucherPrefix On VoucherPrefix.TranID = N'INVOICE' 
 Where InvoiceAbstract.InvoiceType = 2 And            
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And            
 InvoiceAbstract.InvoiceDate Between @Fromdate And @ToDate And            
 dbo.GetAmountCollected(InvoiceAbstract.PaymentDetails, @PaymentMode +N':') <> 0            
 
 Union All            
       
 Select 'Collection',            
 "CollectionNo" = Collections.FullDocID,            
 "Account Number" = Null,  
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
--  "CustomerID" = Collections.CustomerID,            
--  "Customer" = Customer.Company_Name,            
 "Type"= case when  Collections.Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,      
 "Account Name" = Case when  Collections.others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
 else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,       
 "DocumentID" = CollectionDetail.OriginalID,            
 "DocumentDate" = CollectionDetail.DocumentDate,            
 "Amount (%c)" = Case CollectionDetail.DocumentType            
 When 4 Then            
 CollectionDetail.DocumentValue            
 When 5 Then            
 CollectionDetail.DocumentValue            
 When 6 Then            
 CollectionDetail.DocumentValue            
 Else            
 0 - CollectionDetail.DocumentValue            
 End,            
 "Amount Adjusted (%c)" = Case CollectionDetail.DocumentType            
 When 4 Then            
 CollectionDetail.AdjustedAmount            
 When 5 Then            
 CollectionDetail.AdjustedAmount            
 When 6 Then            
 CollectionDetail.AdjustedAmount            
 Else            
 0 - CollectionDetail.AdjustedAmount            
 End,            
 "Addln. Adjustment (%c)" = Case CollectionDetail.DocumentType            
 When 4 Then            
 --Show Adjustment column Value When negative  
 Case   
   When CollectionDetail.Adjustment<0 then CollectionDetail.Adjustment  
   Else CollectionDetail.ExtraCollection            
 End   
  
 When 5 Then            
 --Show Adjustment column Value When negative  
 Case   
   When CollectionDetail.Adjustment<0 then CollectionDetail.Adjustment  
   Else CollectionDetail.ExtraCollection            
 End   
  
 When 6 Then            
 --Show Adjustment column Value When negative  
 Case   
   When CollectionDetail.Adjustment<0 then CollectionDetail.Adjustment  
   Else CollectionDetail.ExtraCollection            
 End   
  
 Else            
 0 - CollectionDetail.ExtraCollection            
 End             
 From Collections
Left Outer Join CollectionDetail On Collections.DocumentID = CollectionDetail.CollectionID
 Left Outer Join BankMaster On Collections.BankCode = BankMaster.BankCode 
 Left Outer Join BranchMaster On Collections.BranchCode = BranchMaster.BranchCode And Collections.BankCode = BranchMaster.BankCode 
 Where Collections.DocumentDate Between @FromDate And @ToDate And            
 IsNull(Collections.Status, 0) & 128 = 0 And            
 Collections.PaymentMode = 1 And            
-- Collections.CustomerID = Customer.CustomerID And            
 CollectionDetail.AdjustedAmount > 0 And            
 dbo.StripDateFromTime(Collections.ChequeDate) = dbo.StripDateFromTime(@FromDate)             
       
       
 Union All          
       
       
 Select 'Collection',            
 "CollectionNo" = Collections.FullDocID,            
 "Account Number" = Null,  
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
--  "CustomerID" = Collections.CustomerID,            
--  "Customer" = Customer.Company_Name,            
 "Type"= case when  Collections.Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,      
 "Account Name" = Case when  Collections.others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
 else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,       
 "DocumentID" = dbo.LookupDictionaryItem('Advance',Default),         
 "DocumentDate" = Null,            
 "Amount (%c)" = Collections.Balance,          
 "Amount Adjusted (%c)" = 0,          
 "Addln. Adjustment (%c)" = 0          
 From Collections
 Left Outer Join BankMaster On Collections.BankCode = BankMaster.BankCode 
 Left Outer Join BranchMaster On Collections.BranchCode = BranchMaster.BranchCode And Collections.BankCode = BranchMaster.BankCode 
 Where Collections.DocumentDate Between @FromDate And @ToDate And            
 IsNull(Collections.Status, 0) & 128 = 0 And            
 Collections.PaymentMode = 1 And            
-- Collections.CustomerID = Customer.CustomerID And            
 Collections.Balance > 0          
 Order By CollectionNo          
End            
  
ELSE  
BEGIN  
 Select 'Retail Invoice',             
 "CollectionNo" = VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID As nVarchar),             
 "Account Number" = Null,  
 "Bank" = Null,             
 "Branch" = Null,            
 "PaymentDetails" = Cast( Case dbo.GetAmountCollectedEx(InvoiceAbstract.PaymentDetails, Rtrim(@PaymentMode))            
 When N'' Then            
 Null            
 Else   
 dbo.GetAmountCollectedEx(InvoiceAbstract.PaymentDetails, @PaymentMode)            
 End as nVarchar),            
 "Cheque Date" = Null,            
 "Type" = dbo.LookupDictionaryItem('Retail Customer',Default),          
 "Account Name" = Cash_Customer.CustomerName,          
 "DocumentID" =  case  IsNULL(InvoiceAbstract.GSTFlag ,0)
                When 0 then VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID As nVarchar) else  IsNULL(InvoiceAbstract.GSTFullDocID,'')
                End,                      
 "Document Date" = InvoiceAbstract.InvoiceDate,            
 "Amount (%c)" = InvoiceAbstract.NetValue,            
 "Amount Adjusted (%c)" = dbo.GetAmountCollected(InvoiceAbstract.PaymentDetails, Rtrim(@PaymentMode) + N':'),            
 "Addln. Adjustment (%c)" = Null            
 From InvoiceAbstract
 Left Outer Join Cash_Customer On InvoiceAbstract.CustomerID = Cast(Cash_Customer.CustomerID As nVarchar)
 Inner Join VoucherPrefix  On  VoucherPrefix.TranID = N'INVOICE'                      
 Where InvoiceAbstract.InvoiceType = 2 And IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And InvoiceAbstract.InvoiceDate Between @Fromdate And @ToDate And            
 dbo.GetAmountCollected(InvoiceAbstract.PaymentDetails, Rtrim(@PaymentMode) + N':') <> 0      
  
 Union All            
       
 Select 'Collection',            
 "CollectionNo" = Collections.FullDocID,            
 "Account Number" =   
 Isnull((Select Bank.Account_Number from Bank where Bank.BankId = Isnull(Collections.BankId,0)),N''),  
 "Bank" = BankMaster.BankName,            
 "Branch" = BranchMaster.BranchName,            
 "ChequeNo" =   
 Case PaymentMode  
 When 4 Then Cast(Collections.Memo as nVarchar)  
  Else  
  Case IsNull(Collections.ChequeNumber, 0)            
   When 0 Then            
   Null            
   Else            
   Cast(Collections.ChequeNumber as nVarchar)  
  End   
 End,  
 "Cheque Date" = Case Collections.PaymentMode            
 When 1 Then            
 Collections.ChequeDate            
 Else            
 Null            
 End,            
--  "CustomerID" = Collections.CustomerID,            
--  "Customer" = Customer.Company_Name,            
 "Type"= case when  Collections.Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,      
 "Account Name" = Case when  Collections.others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
 else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,       
 "DocumentID" = CollectionDetail.OriginalID,            
 "DocumentDate" = CollectionDetail.DocumentDate,            
 "Amount (%c)" = Case CollectionDetail.DocumentType            
 When 4 Then     
 CollectionDetail.DocumentValue            
 When 5 Then            
 CollectionDetail.DocumentValue            
 When 6 Then            
 CollectionDetail.DocumentValue            
 Else            
 0 - CollectionDetail.DocumentValue            
 End,            
 "Amount Adjusted (%c)" = Case CollectionDetail.DocumentType            
 When 4 Then            
 CollectionDetail.AdjustedAmount            
 When 5 Then            
 CollectionDetail.AdjustedAmount            
 When 6 Then            
 CollectionDetail.AdjustedAmount            
 Else            
 0 - CollectionDetail.AdjustedAmount            
 End,            
 "Addln. Adjustment (%c)" = Case CollectionDetail.DocumentType            
 When 4 Then        
 --Show Adjustment column Value When negative  
 Case   
   When CollectionDetail.Adjustment<0 then CollectionDetail.Adjustment  
   Else CollectionDetail.ExtraCollection            
 End   
  
 When 5 Then            
 --Show Adjustment column Value When negative  
 Case   
   When CollectionDetail.Adjustment<0 then CollectionDetail.Adjustment  
   Else CollectionDetail.ExtraCollection            
 End   
  
 When 6 Then            
 --Show Adjustment column Value When negative  
 Case   
   When CollectionDetail.Adjustment<0 then CollectionDetail.Adjustment  
   Else CollectionDetail.ExtraCollection            
 End   
  
 Else            
 0 - CollectionDetail.ExtraCollection            
 End             
 From Collections
 Inner Join CollectionDetail On  Collections.DocumentID = CollectionDetail.CollectionID
 Left Outer Join BankMaster On Collections.BankCode = BankMaster.BankCode
 Left Outer Join BranchMaster On Collections.BranchCode = BranchMaster.BranchCode And Collections.BankCode = BranchMaster.BankCode 
 Where Collections.DocumentDate Between @FromDate And @ToDate And            
 IsNull(Collections.Status, 0) & 128 = 0 And            
 Collections.PaymentMode = Case @PaymentMode  
 When dbo.LookupDictionaryItem('Cash',Default)  then  
 0  
 When dbo.LookupDictionaryItem('Cheque',Default) then  
 1  
 When dbo.LookupDictionaryItem('DD',Default) then  
 2  
 When dbo.LookupDictionaryItem('Credit Card',Default) then  
 3  
 When dbo.LookupDictionaryItem('Bank Transfer',Default) then  
 4  
 When dbo.LookupDictionaryItem('Coupon',Default) then  
 5  
 End  And            
 --Collections.CustomerID = Customer.CustomerID And            
 CollectionDetail.AdjustedAmount > 0      
 Union All          
       
 Select 'Collection',            
 "CollectionNo" = Collections.FullDocID,            
 "Account Number" =   
 Isnull((Select Bank.Account_Number from Bank where Bank.BankId = Isnull(Collections.BankId,0)),N''),  
 "Bank" = BankMaster.BankName,            
 "Branch" = BranchMaster.BranchName,            
 "ChequeNo" =   
 Case PaymentMode  
 When 4 Then Cast(Collections.Memo as nvarchar)  
 Else  
  Case IsNull(Collections.ChequeNumber, 0)            
    When 0 Then            
    Null            
    Else            
    cast(Collections.ChequeNumber as nvarchar)  
   End   
 End,  
 "Cheque Date" = Case Collections.PaymentMode            
 When 1 Then            
 Collections.ChequeDate            
 Else            
 Null            
 End,            
--  "CustomerID" = Collections.CustomerID,            
--  "Customer" = Customer.Company_Name,            
 "Type"= case when  Collections.Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,      
 "Account Name" = Case when  Collections.others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
 else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,       
 "DocumentID" = dbo.LookupDictionaryItem('Advance',Default),          
 "DocumentDate" = Null,          
 "Amount (%c)" = Collections.Balance,          
 "Amount Adjusted (%c)" = 0,          
 "Addln. Adjustment (%c)" = 0          
 From Collections
 Left Outer Join BankMaster On Collections.BankCode = BankMaster.BankCode 
 Left Outer Join BranchMaster On Collections.BranchCode = BranchMaster.BranchCode And Collections.BankCode = BranchMaster.BankCode 
 Where Collections.DocumentDate Between @FromDate And @Todate And            
 IsNull(Collections.Status, 0) & 128 = 0 And            
 Collections.PaymentMode = Case @PaymentMode  
 When dbo.LookupDictionaryItem('Cash',Default) then  
 0  
 When dbo.LookupDictionaryItem('Cheque',Default) then  
 1  
 When dbo.LookupDictionaryItem('DD',Default) then  
 2  
 When dbo.LookupDictionaryItem('Credit Card',Default) then  
 3  
 When dbo.LookupDictionaryItem('Bank Transfer',Default) then  
 4  
 When dbo.LookupDictionaryItem('Coupon',Default) then  
 5  
 End  And            
-- Collections.CustomerID = Customer.CustomerID And            
 Collections.Balance > 0          
 Order By CollectionNo        
End  

