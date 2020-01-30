CREATE Procedure sp_acc_Get_BouncedCheques (@AccountID INT)    
As    
DECLARE @CUSTOMERACCOUNT INT,@OTHERACCOUNT INT,@EXPENSEACCOUNT INT    
DECLARE @GIFT_VOUCHER_ACID INT    
DECLARE @GIFT_VOUCHERID nVarChar(25)    
DECLARE @GIFT_VOUCHERID_ACName nVarChar(25)    
    
Set @GIFT_VOUCHER_ACID = 114 -- Gift Voucher Customer    
Set @GIFT_VOUCHERID = N'GIFT VOUCHER'
Set @GIFT_VOUCHERID_ACName = dbo.LookupDictionaryItem('GIFT VOUCHER',Default)    
    
Set @CUSTOMERACCOUNT = 0 -- Customer Account    
Set @OTHERACCOUNT = 1 -- Others Account    
Set @EXPENSEACCOUNT = 2 -- Expense Account    
    
If @AccountID=0    
 Begin    
  Select 'Account Name'= Case When Ltrim(Rtrim(Collections.CustomerID))=@GIFT_VOUCHERID     
  then @GIFT_VOUCHERID_ACName When Collections.CustomerID Is Not NULL then     
  (Select Company_Name from Customer Where CustomerID=Collections.CustomerID)     
  Else (Case When (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then     
  (Select AccountName from AccountsMaster Where AccountsMaster.AccountID=Collections.ExpenseAccount)     
  Else (Select AccountName from AccountsMaster Where AccountsMaster.AccountID=Collections.Others) End) End,     
  FullDocID,ChequeNumber,ChequeDate,BankName,Collections.BankCode,BranchName,     
  Collections.BranchCode,Collections.Value,DocumentID,dbo.sp_acc_GetBouncedNotes(DocumentID),Collections.SalesmanID,    
  Case When Collections.CustomerID Is Not NULL then Collections.CustomerID Else    
  (Case When (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then     
  CAST(ExpenseAccount as nvarchar(15)) Else CAST(Others as nvarchar(15)) End) End,    
  Case When Collections.CustomerID Is Not NULL then @CUSTOMERACCOUNT Else     
  (Case When (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then     
  @EXPENSEACCOUNT Else @OTHERACCOUNT  End) End,    
  Case When IsNULL(Others,0) <> 0 then IsNULL(ExpenseAccount,0) Else 0 End,    
  'Account ID'=Case When Ltrim(Rtrim(Collections.CustomerID))=@GIFT_VOUCHERID     
  then @GIFT_VOUCHER_ACID When Collections.CustomerID Is Not NULL then     
  (Select AccountID from Customer Where CustomerID=Collections.CustomerID)     
  Else (Case When (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then     
  (Collections.ExpenseAccount) Else (Collections.Others) End) End,RealisationDate    
  from Collections, BankMaster, BranchMaster     
  Where RealIsed = 2 And Collections.BankCode = BankMaster.BankCode And    
  Collections.BranchCode = BranchMaster.BranchCode And    
  Collections.BankCode = BranchMaster.BankCode And  
  ((dbo.sp_acc_IsAlreadyAdjustedNote(DocumentID)<>1  And IsNULL(DebitID,0) = 0) Or
  (IsNULL(DebitID,0)<>0 And	DebitID In (Select DebitID From DebitNote Where NoteValue = Balance And Flag = 2)))
  Order by 'Account Name','Account ID'    
 End    
Else    
 Begin    
  Select 'Account Name'= Case When Ltrim(Rtrim(Collections.CustomerID))=@GIFT_VOUCHERID then     
  @GIFT_VOUCHERID_ACName When Collections.CustomerID Is Not NULL then     
  (Select Company_Name from Customer Where CustomerID=Collections.CustomerID)     
  Else (Case When (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then    
  (Select AccountName from AccountsMaster Where AccountsMaster.AccountID=Collections.ExpenseAccount)     
  Else (Select AccountName from AccountsMaster Where AccountsMaster.AccountID=Collections.Others) End) End,    
  FullDocID, ChequeNumber, ChequeDate, BankName, Collections.BankCode, BranchName,     
  Collections.BranchCode,Collections.Value,DocumentID,dbo.sp_acc_GetBouncedNotes(DocumentID),Collections.SalesmanID,
  Case When Collections.CustomerID Is Not NULL then Collections.CustomerID Else    
  (Case When (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then     
  CAST(ExpenseAccount as nvarchar(15)) Else CAST(Others as nvarchar(15)) End) End,    
  Case When Collections.CustomerID Is Not NULL then @CUSTOMERACCOUNT Else  
  (Case When (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then     
  @EXPENSEACCOUNT Else @OTHERACCOUNT  End) End,    
  Case When IsNULL(Others,0) <> 0 then IsNULL(ExpenseAccount,0) Else 0 End,@AccountID,RealisationDate    
  from Collections, BankMaster, BranchMaster     
  Where ((Collections.CustomerID Is Not NULL     
  And Collections.CustomerID = (Select Customer.CustomerID from Customer     
  Where Customer.AccountID =@AccountID)) Or    
  (Collections.CustomerID Is NULL And IsNULL(Others,0) <> 0 And Collections.Others = @AccountID)    
  Or (Collections.CustomerID Is NULL And IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0 And Collections.ExpenseAccount = @AccountID))    
  And RealIsed = 2 And Collections.BankCode = BankMaster.BankCode And    
  Collections.BranchCode = BranchMaster.BranchCode And    
  Collections.BankCode = BranchMaster.BankCode And  
  ((dbo.sp_acc_IsAlreadyAdjustedNote(DocumentID)<>1  And IsNULL(DebitID,0) = 0) Or
  (IsNULL(DebitID,0)<>0 And	DebitID In (Select DebitID From DebitNote Where NoteValue = Balance And Flag = 2)))
 End 
