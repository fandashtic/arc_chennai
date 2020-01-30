
CREATE PROCEDURE sp_acc_get_open_checks(@AccountID Int,                        
        @FROMDATE datetime,                        
        @TODATE datetime,                        
        @Mode Int = 0)                        
AS                        
Begin                        
DECLARE @ADDNEW_DEPOSIT INT                        
DECLARE @CLOSE_DEPOSIT INT                        
DECLARE @VIEW_DEPOSIT INT                
DECLARE @AccountName nvarchar(50)                        
DECLARE @GIFT_VOUCHER_ACID INT  
DECLARE @GIFT_VOUCHERID nVarchar(25)  
DECLARE @GIFT_VOUCHER_ACName nVarchar(25)  
  
SET @ADDNEW_DEPOSIT = 0                        
SET @CLOSE_DEPOSIT = 1                        
SET @VIEW_DEPOSIT = 2                
SET @GIFT_VOUCHER_ACID = 114  
SET @GIFT_VOUCHERID = N'GIFT VOUCHER'  
SET @GIFT_VOUCHER_ACName = dbo.LookupDictionaryItem('GIFT VOUCHER',Default)  
               
If @Mode = 0                        
 Begin                        
  If @AccountID=0                        
   Begin                        
    Select 'Account Name'=  
  case   
   When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACName  
   when Collections.CustomerID is Not NULL then                         
       (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
   else                         
       (  
    case when ISNULL(Others,0) <> 0 then dbo.getaccountname(Others)   
    else dbo.getaccountname(ExpenseAccount)   
    end  
    )   
  end,   
 ChequeNumber, ChequeDate, Collections.Value,                         
    FullDocID, DocumentID,BankMaster.BankName, BranchMaster.BranchName, Collections.PaymentMode,                        
    'Account ID'=  
  case   
   When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACID  
   when Collections.CustomerID is Not NULL then                         
       (Select AccountID from Customer where CustomerID=Collections.CustomerID)   
   else                         
       (  
     case   
      when ISNULL(Others,0) <> 0 then Others   
      else ExpenseAccount   
     end  
    )   
  end  
    FROM Collections, BankMaster, BranchMaster                        
    WHERE dbo.stripdatefromtime(ChequeDate) BETWEEN @FROMDATE And @TODATE                        
    And PaymentMode in (1, 2) And (ISNULL(DepositID, 0) = 0 Or IsNULL(DepositID,0) <> 0 And IsNULL(Status,0)=2) And                        
    Collections.BankCode = BankMaster.BankCode And Collections.BranchCode = BranchMaster.BranchCode And                        
    BankMaster.BankCode = BranchMaster.BankCode And (((IsNULL(Collections.RetailUserWise, 0) & 1) = 0) Or             
    (((IsNULL(Collections.RetailUserWise, 0) & 1) = 1) And Collections.DocumentID In            
    (Select DocumentReference from ContraDetail, ContraAbstract Where DocumentType = 2           
    And PaymentType = 2 And (IsNULL(ContraAbstract.Status, 0) & 192) = 0 And ContraAbstract.ContraID = ContraDetail.ContraID))) And            
    (ISNULL(Collections.Status, 0) & 192) = 0  order by 'Account Name','Account ID', ChequeDate,ChequeNumber                    
   End                        
  Else                        
   Begin                        
    Select 'Account Name'=  
  case   
   When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACName  
   when Collections.CustomerID is Not NULL then  
       (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
   else  
       (    
    case when ISNULL(Others,0) <> 0 then dbo.getaccountname(Others)   
    else dbo.getaccountname(ExpenseAccount)   
    end  
    )   
  end,   
 ChequeNumber, ChequeDate, Collections.Value,                         
    FullDocID, DocumentID, BankMaster.BankName, BranchMaster.BranchName, Collections.PaymentMode,@AccountID                        
FROM Collections, BankMaster, BranchMaster                        
    WHERE ((Collections.CustomerID Is Not NULL                         
    And Collections.CustomerID = (Select Customer.CustomerID From Customer                         
    Where Customer.AccountID =@AccountID)) Or                        
    (Collections.CustomerID Is NULL And ISNULL(Others,0) <> 0 And Collections.Others = @AccountID)                        
    Or (Collections.CustomerID Is NULL And ISNULL(Others,0) = 0 And ISNULL(ExpenseAccount,0) <> 0 And Collections.ExpenseAccount = @AccountID))                        
    And dbo.stripdatefromtime(ChequeDate) BETWEEN @FROMDATE And @TODATE                        
    And PaymentMode in (1, 2) And (ISNULL(DepositID, 0) = 0 Or IsNULL(DepositID,0) <> 0 And IsNULL(Status,0)=2) And                        
    Collections.BankCode = BankMaster.BankCode And Collections.BranchCode = BranchMaster.BranchCode And       
    BankMaster.BankCode = BranchMaster.BankCode And (((IsNULL(Collections.RetailUserWise, 0) & 1) = 0) Or             
    (((IsNULL(Collections.RetailUserWise, 0) & 1) = 1) And Collections.DocumentID In            
    (Select DocumentReference from ContraDetail, ContraAbstract Where DocumentType = 2           
    And PaymentType = 2 And (IsNULL(ContraAbstract.Status, 0) & 192) = 0 And ContraAbstract.ContraID = ContraDetail.ContraID))) And            
    (IsNULL(Collections.Status, 0) & 192) = 0 Order by ChequeDate,ChequeNumber                       
   End                        
 End                        
Else If @Mode = @CLOSE_DEPOSIT                        
 Begin                        
  If @AccountID=0                        
   Begin                        
    Select 'Document ID' = Deposits.FullDocID, Collections.ChequeNumber, Collections.ChequeDate, Collections.Value,                         
    Collections.FullDocID, Collections.DocumentID, BankMaster.BankName, BranchMaster.BranchName, Collections.PaymentMode,                        
    'Deposit ID'=Deposits.DepositID, Deposits.Value,   
 'Account Name'=  
  case   
   When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACName  
   when Collections.CustomerID is Not NULL then                         
       (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
   else  
       (  
     case when ISNULL(Others,0) <> 0 then dbo.getaccountname(Others)   
     else dbo.getaccountname(ExpenseAccount)   
    end  
    )   
  end,                         
    'Bank Account'=(Select Account_Number from Bank Where BankID = Collections.Deposit_To), Deposits.DepositDate,                  
    'Bank Account Bank'=(Select BankMaster.BankName from BankMaster Where BankMaster.BankCode = (Select Bank.BankCode from Bank Where BankID = Collections.Deposit_To)),                      
    'Bank Account Branch'=(Select BranchMaster.BranchName from BranchMaster             
    Where BranchMaster.BranchCode = (Select Bank.BranchCode from Bank Where BankID = Collections.Deposit_To)            
    And BranchMaster.BankCode = (Select Bank.BankCode from Bank Where BankID = Collections.Deposit_To))                      
    FROM Collections, BankMaster, BranchMaster , Deposits                       
    WHERE dbo.StripDateFromTime(Deposits.DepositDate) BETWEEN @FROMDATE And @TODATE And                      
    Collections.PaymentMode in (1, 2) And IsNULL(Collections.DepositID, 0) <> 0 And                        
    Collections.DepositID = Deposits.DepositID And Collections.Deposit_To = Deposits.AccountID And                      
    Collections.BankCode = BankMaster.BankCode And Collections.BranchCode = BranchMaster.BranchCode And                        
    BankMaster.BankCode = BranchMaster.BankCode And (ISNULL(Deposits.Status, 0) & 192) = 0 And                       
    Deposits.DepositID Not In (Select Deposits.DepositID from Deposits,Collections Where Deposits.DepositID = Collections.DepositID And                       
    Collections.Deposit_To = Deposits.AccountID And IsNULL(Collections.Status, 0) = 1 And IsNULL(Collections.DepositID, 0) <> 0 And                      
    (ISNULL(Deposits.Status, 0) & 192) = 0 And IsNULL(Collections.Realised,0) Not In (0,4,5) And Collections.PaymentMode in (1,2)) And               
    IsNULL(Collections.Status, 0) = 1 And IsNULL(Collections.Realised,0) In (0,4,5) Order By 'Deposit ID','Document ID'                        
   End                        
  Else                        
   Begin                        
    Select 'Document ID' = Deposits.FullDocID, Collections.ChequeNumber, Collections.ChequeDate, Collections.Value,                         
    Collections.FullDocID, Collections.DocumentID, BankMaster.BankName, BranchMaster.BranchName, Collections.PaymentMode,                        
    'Deposit ID'=Deposits.DepositID, Deposits.Value,   
 'Account Name'=   
  case  
   When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACName   
   when Collections.CustomerID is Not NULL then  
       (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
   else  
       (  
     case   
      when ISNULL(Others,0) <> 0 then dbo.getaccountname(Others)   
      else dbo.getaccountname(ExpenseAccount)   
     end  
    )   
   end,                         
    'Bank Account'=(Select Account_Number from Bank Where BankID = Collections.Deposit_To), Deposits.DepositDate,                      
    'Bank Account Bank'=(Select BankMaster.BankName from BankMaster Where BankMaster.BankCode = (Select Bank.BankCode from Bank Where BankID = Collections.Deposit_To)),                      
    'Bank Account Branch'=(Select BranchMaster.BranchName from BranchMaster             
    Where BranchMaster.BranchCode = (Select Bank.BranchCode from Bank Where BankID = Collections.Deposit_To)            
    And BranchMaster.BankCode = (Select Bank.BankCode from Bank Where BankID = Collections.Deposit_To))                      
    FROM Collections, BankMaster, BranchMaster , Deposits                       
    WHERE dbo.StripDateFromTime(Deposits.DepositDate) BETWEEN @FROMDATE And @TODATE And                      
    Collections.PaymentMode in (1, 2) And IsNULL(Collections.DepositID, 0) <> 0 And                        
    Collections.DepositID = Deposits.DepositID And Collections.Deposit_To = Deposits.AccountID And                      
    Collections.BankCode = BankMaster.BankCode And Collections.BranchCode = BranchMaster.BranchCode And                        
    BankMaster.BankCode = BranchMaster.BankCode And (ISNULL(Deposits.Status, 0) & 192) = 0 And                       
    Deposits.DepositID Not In (Select Deposits.DepositID from Deposits,Collections Where Deposits.DepositID = Collections.DepositID And                       
    Collections.Deposit_To = Deposits.AccountID And IsNULL(Collections.Status, 0) = 1 And IsNULL(Collections.DepositID, 0) <> 0 And                      
    (ISNULL(Deposits.Status, 0) & 192) = 0 And IsNULL(Collections.Realised,0) Not In (0,4,5) And Collections.PaymentMode In (1,2)) And                      
    IsNULL(Collections.Status, 0) = 1 And IsNULL(Collections.Realised,0) In (0,4,5) And Deposits.AccountID = @AccountID                      
   End                        
 End                        
Else If @Mode = @VIEW_DEPOSIT                        
 Begin                        
  If @AccountID=0                        
   Begin                        
    Select 'Document ID' = Deposits.FullDocID, Collections.ChequeNumber, Collections.ChequeDate, Collections.Value,                         
    Collections.FullDocID, Collections.DocumentID, BankMaster.BankName, BranchMaster.BranchName, Collections.PaymentMode,                        
    'Deposit ID'=Deposits.DepositID, Deposits.Value,   
 'Account Name'=  
  case   
   When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACName   
   when Collections.CustomerID is Not NULL then  
       (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
   else  
       (  
     case   
      when ISNULL(Others,0) <> 0 then dbo.getaccountname(Others)   
      else dbo.getaccountname(ExpenseAccount)   
     end  
    )   
   end,  
 'Bank Account'=(Select Account_Number from Bank Where BankID = Collections.Deposit_To), Deposits.DepositDate,                  
    'Bank Account Bank'=(Select BankMaster.BankName from BankMaster Where BankMaster.BankCode = (Select Bank.BankCode from Bank Where BankID = Collections.Deposit_To)),                      
    'Bank Account Branch'=(Select BranchMaster.BranchName from BranchMaster             
    Where BranchMaster.BranchCode = (Select Bank.BranchCode from Bank Where BankID = Collections.Deposit_To)            
    And BranchMaster.BankCode = (Select Bank.BankCode from Bank Where BankID = Collections.Deposit_To)),              
    'Status'=IsNULL(Deposits.Status,0),'Staff Name'=dbo.GetAccountName(IsNULL(Deposits.StaffID,0))              
    FROM Collections, BankMaster, BranchMaster, Deposits              
    WHERE dbo.StripDateFromTime(Deposits.DepositDate) BETWEEN @FROMDATE And @TODATE And                      
    Collections.PaymentMode in (1, 2) And IsNULL(Collections.DepositID, 0) <> 0 And (ISNULL(Deposits.Status, 0) & 192) = 0 And              
    Collections.DepositID = Deposits.DepositID And Collections.Deposit_To = Deposits.AccountID And                      
    Collections.BankCode = BankMaster.BankCode And Collections.BranchCode = BranchMaster.BranchCode And                        
    BankMaster.BankCode = BranchMaster.BankCode And (IsNULL(Collections.Status, 0) & 192) = 0        
    Union         
    Select 'Document ID' = Deposits.FullDocID, Collections.ChequeNumber, Collections.ChequeDate, Collections.Value,                         
    Collections.FullDocID, Collections.DocumentID, BankMaster.BankName, BranchMaster.BranchName, Collections.PaymentMode,                        
    'Deposit ID'=Deposits.DepositID, Deposits.Value,   
 'Account Name'=  
  case   
   When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACName   
   when Collections.CustomerID is Not NULL then  
       (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
   else  
       (  
     case   
      when ISNULL(Others,0) <> 0 then dbo.getaccountname(Others)   
      else dbo.getaccountname(ExpenseAccount)   
     end  
    )   
  end,                         
    'Bank Account'=(Select Account_Number from Bank Where BankID = Deposits.AccountID), Deposits.DepositDate,                  
    'Bank Account Bank'=(Select BankMaster.BankName from BankMaster Where BankMaster.BankCode = (Select Bank.BankCode from Bank Where BankID = Deposits.AccountID)),                      
    'Bank Account Branch'=(Select BranchMaster.BranchName from BranchMaster             
    Where BranchMaster.BranchCode = (Select Bank.BranchCode from Bank Where BankID = Deposits.AccountID)            
    And BranchMaster.BankCode = (Select Bank.BankCode from Bank Where BankID = Collections.Deposit_To)),              
    'Status'=IsNULL(Deposits.Status,0),'Staff Name'=dbo.GetAccountName(IsNULL(Deposits.StaffID,0))              
    FROM Collections, BankMaster, BranchMaster, Deposits,DepositsDetail              
    WHERE dbo.StripDateFromTime(Deposits.DepositDate) BETWEEN @FROMDATE And @TODATE And                      
    Collections.PaymentMode in (1, 2) And IsNULL(Collections.DepositID, 0) <> 0 And (ISNULL(Deposits.Status, 0) & 192) <> 0 And              
    Deposits.DepositID=DepositsDetail.DepositID And DepositsDetail.CollectionID=Collections.DocumentID And              
    Collections.BankCode = BankMaster.BankCode And Collections.BranchCode = BranchMaster.BranchCode And                        
    BankMaster.BankCode = BranchMaster.BankCode And (IsNULL(Collections.Status, 0) & 192) = 0                        
   End                        
  Else                        
   Begin                        
    Select 'Document ID' = Deposits.FullDocID, Collections.ChequeNumber, Collections.ChequeDate, Collections.Value,                         
    Collections.FullDocID, Collections.DocumentID, BankMaster.BankName, BranchMaster.BranchName, Collections.PaymentMode,                        
    'Deposit ID'=Deposits.DepositID, Deposits.Value,   
 'Account Name'=  
  case   
   When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACName   
   when Collections.CustomerID is Not NULL then  
       (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
   else  
       (  
     case   
      when ISNULL(Others,0) <> 0 then dbo.getaccountname(Others)   
      else dbo.getaccountname(ExpenseAccount)   
     end  
    )   
   end,                         
    'Bank Account'=(Select Account_Number from Bank Where BankID = Collections.Deposit_To), Deposits.DepositDate,                      
    'Bank Account Bank'=(Select BankMaster.BankName from BankMaster Where BankMaster.BankCode = (Select Bank.BankCode from Bank Where BankID = Collections.Deposit_To)),                      
    'Bank Account Branch'=(Select BranchMaster.BranchName from BranchMaster             
    Where BranchMaster.BranchCode = (Select Bank.BranchCode from Bank Where BankID = Collections.Deposit_To)            
    And BranchMaster.BankCode = (Select Bank.BankCode from Bank Where BankID = Collections.Deposit_To)),                      
    'Status'=IsNULL(Deposits.Status,0),'Staff Name'=dbo.GetAccountName(IsNULL(Deposits.StaffID,0))              
    FROM Collections, BankMaster, BranchMaster, Deposits  
    WHERE dbo.StripDateFromTime(Deposits.DepositDate) BETWEEN @FROMDATE And @TODATE And                      
    Collections.PaymentMode in (1, 2) And IsNULL(Collections.DepositID, 0) <> 0 And (ISNULL(Deposits.Status, 0) & 192) = 0 And                
    Collections.DepositID = Deposits.DepositID And Collections.Deposit_To = Deposits.AccountID And          
    Collections.BankCode = BankMaster.BankCode And Collections.BranchCode = BranchMaster.BranchCode And                        
    BankMaster.BankCode = BranchMaster.BankCode And (IsNULL(Collections.Status, 0) & 192) = 0 And Deposits.AccountID = @AccountID                      
    Union              
    Select 'Document ID' = Deposits.FullDocID, Collections.ChequeNumber, Collections.ChequeDate, Collections.Value,                         
    Collections.FullDocID, Collections.DocumentID, BankMaster.BankName, BranchMaster.BranchName, Collections.PaymentMode,                        
    'Deposit ID'=Deposits.DepositID, Deposits.Value,   
 'Account Name'=  
  case   
   When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACName   
   when Collections.CustomerID is Not NULL then                         
       (Select Company_Name from Customer where CustomerID=Collections.CustomerID)   
   else                         
       (  
     case   
      when ISNULL(Others,0) <> 0 then dbo.getaccountname(Others)   
      else dbo.getaccountname(ExpenseAccount)   
     end  
    )   
  end,                         
    'Bank Account'=(Select Account_Number from Bank Where BankID = Deposits.AccountID), Deposits.DepositDate,                  
    'Bank Account Bank'=(Select BankMaster.BankName from BankMaster Where BankMaster.BankCode = (Select Bank.BankCode from Bank Where BankID = Deposits.AccountID)),                      
    'Bank Account Branch'=(Select BranchMaster.BranchName from BranchMaster             
    Where BranchMaster.BranchCode = (Select Bank.BranchCode from Bank Where BankID = Deposits.AccountID)            
    And BranchMaster.BankCode = (Select Bank.BankCode from Bank Where BankID = Collections.Deposit_To)),              
    'Status'=IsNULL(Deposits.Status,0),'Staff Name'=dbo.GetAccountName(IsNULL(Deposits.StaffID,0))              
    FROM Collections, BankMaster, BranchMaster , Deposits,DepositsDetail                       
    WHERE dbo.StripDateFromTime(Deposits.DepositDate) BETWEEN @FROMDATE And @TODATE And                      
    Collections.PaymentMode in (1, 2) And IsNULL(Collections.DepositID, 0) <> 0 And (ISNULL(Deposits.Status, 0) & 192) <> 0 And     
    Deposits.DepositID=DepositsDetail.DepositID And DepositsDetail.CollectionID=Collections.DocumentID And              
    Collections.BankCode = BankMaster.BankCode And Collections.BranchCode = BranchMaster.BranchCode And                        
    BankMaster.BankCode = BranchMaster.BankCode And (IsNULL(Collections.Status, 0) & 192) = 0 And Deposits.AccountID = @AccountID Order By 'Deposit ID','Document ID'                                
   End                        
 End                        
End   
