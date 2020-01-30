CREATE Procedure sp_acc_clear_cheques(@BankID int,        
       @Fromdate datetime,        
       @Todate datetime,        
       @Mode Int = 0)        
As        
DECLARE @CUSTOMERACCOUNT Int,@OTHERACCOUNT Int, @EXPENSEACCOUNT Int        
DECLARE @ADDNEW_REALISATION Int, @CLOSE_REALISATION Int        
DECLARE @GIFT_VOUCHER_ACID INT
DECLARE @GIFT_VOUCHERID nVarchar(25)
DECLARE @GIFT_VOUCHER_ACName nVarchar(25)

Set @CUSTOMERACCOUNT = 0 --Customer Account        
Set @OTHERACCOUNT = 1 --Others Account        
Set @EXPENSEACCOUNT = 2        
Set @ADDNEW_REALISATION = 0        
Set @CLOSE_REALISATION = 1        
Set @GIFT_VOUCHER_ACID = 114
Set @GIFT_VOUCHERID = N'GIFT VOUCHER'
SET @GIFT_VOUCHER_ACName = dbo.LookupDictionaryItem('GIFT VOUCHER',Default)
        
If @Mode = @ADDNEW_REALISATION        
 Begin        
  Select Case when Collections.CustomerID Is Not Null then Collections.CustomerID Else        
  (Case when (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then Cast(ExpenseAccount as nvarchar(15)) Else Cast(Others as nvarchar(15)) End) End,        
  'Account Name' = 
		Case 
			When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACName
			when Collections.CustomerID Is Not Null then 
				(Select Company_Name from Customer where Customer.CustomerID=Collections.CustomerID)         
  			Else 
				(Case 
					when (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then 
						(Select AccountName from AccountsMaster where AccountsMaster.AccountID=Collections.ExpenseAccount) 
					Else         
  						(Select AccountName from AccountsMaster where AccountsMaster.AccountID=Collections.Others) 
				End) 
			End,        
  BankMaster.BankName, Collections.ChequeNumber, Collections.ChequeDate, Collections.Value, DocumentID,        
  PaymentMode, Case when Collections.CustomerID Is Not Null then @CUSTOMERACCOUNT Else         
  (Case when (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then @EXPENSEACCOUNT Else @OTHERACCOUNT  End) End,        
  'Account ID' = 
		Case 
			When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACID
			when Collections.CustomerID Is Not Null then 
				(Select AccountID from Customer where Customer.CustomerID=Collections.CustomerID)         
  			Else 
				(Case 
					when (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then (Collections.ExpenseAccount) 
					Else (Collections.Others) 
				End) 
		End 
  From Collections,Bank,BankMaster        
  Where Collections.Deposit_To = @BankID And dbo.stripdatefromtime(Collections.DepositDate) Between @Fromdate And @Todate And        
  IsNULL(Collections.Status,0) = 1 And Collections.PaymentMode in (1, 2) And Collections.Deposit_To = Bank.BankID And        
  Collections.BankCode = BankMaster.BankCode And IsNULL(Collections.Realised, 0) In (0,4,5) Order By 'Account Name','Account ID'        
  /*        
  ((Collections.CustomerID Is Not null And Collections.CustomerID = Customer.CustomerID) OR        
  (Collections.CustomerID Is null And Collections.others = Customer.CustomerID))        
  */        
 End        
Else If @Mode = @CLOSE_REALISATION        
 Begin        
  Select Case when Collections.CustomerID Is Not Null then Collections.CustomerID Else        
  (Case when (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then Cast(ExpenseAccount as nvarchar(15)) Else Cast(Others as nvarchar(15)) End) End,        
  'Account Name' = 
		Case 
			When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACName 
			when Collections.CustomerID Is Not Null then 
				(Select Company_Name from Customer where Customer.CustomerID=Collections.CustomerID)         
  			Else 
				(Case 
					when (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then 
						(Select AccountName from AccountsMaster where AccountsMaster.AccountID=Collections.ExpenseAccount) 
					Else      
  						(Select AccountName from AccountsMaster where AccountsMaster.AccountID=Collections.Others) 
				End) 
		End,        
  BankMaster.BankName, Collections.ChequeNumber, Collections.ChequeDate, Collections.Value, DocumentID,        
  PaymentMode, Case when Collections.CustomerID Is Not Null then @CUSTOMERACCOUNT Else         
  (Case when (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then @EXPENSEACCOUNT Else @OTHERACCOUNT  End) End,        
  'Account ID' = 
		Case 
			When Ltrim(Rtrim(Collections.CustomerID)) = @GIFT_VOUCHERID then @GIFT_VOUCHER_ACID
			when Collections.CustomerID Is Not Null then 
				(Select AccountID from Customer where Customer.CustomerID=Collections.CustomerID)         
  			Else 
				(Case 
					when (IsNULL(Others,0) = 0 And IsNULL(ExpenseAccount,0) <> 0) then (Collections.ExpenseAccount) 
					Else (Collections.Others) 
				End) 
		End, 
  Collections.RealisationDate, IsNULL(Collections.Realised,0),  
  'Bank Charges' = (Select IsNULL(Balance,0) from DebitNote Where DebitID = Collections.BankChargesDebitID) From Collections,Bank,BankMaster        
  Where Collections.Deposit_To = @BankID And dbo.stripdatefromtime(Collections.RealisationDate) Between @Fromdate And @Todate And        
  IsNULL(Collections.Status,0) = 1 And Collections.PaymentMode in (1, 2) And Collections.Deposit_To = Bank.BankID And        
  Collections.BankCode = BankMaster.BankCode And IsNULL(Collections.Realised, 0) In (1,2) Order By 'Account Name','Account ID'        
 End 

