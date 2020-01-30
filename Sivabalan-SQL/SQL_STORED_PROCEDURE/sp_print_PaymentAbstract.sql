CREATE procedure [dbo].[sp_print_PaymentAbstract] (@PaymentID int)
as 

Declare @CHEQUENO As NVarchar(50)
Declare @DDNO As NVarchar(50)
Declare @CASH As NVarchar(50)
Declare @CHEQUE As NVarchar(50)
Declare @DD As NVarchar(50)
Declare @BANKTRANSFER As NVarchar(50)
Declare @PETTYCASH As NVarchar(50)
Declare @TRANSACTIONCODE As NVarchar(50)

Set @CHEQUENO = dbo.LookupDictionaryItem(N'Cheque No. :', Default)
Set @DDNO = dbo.LookupDictionaryItem(N'DD No. :', Default)
Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default)
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)
Set @BANKTRANSFER = dbo.LookupDictionaryItem(N'Bank Transfer', Default)
Set @PETTYCASH = dbo.LookupDictionaryItem(N'Petty Cash', Default)
Set @TRANSACTIONCODE = dbo.LookupDictionaryItem(N'Transaction Code :', Default)


select "FullDocID" = FullDocID, "DocumentDate" = DocumentDate, "Vendor_Name" = Vendors.Vendor_Name, 
"VendorID" = Payments.VendorID, 
"Payment Description" =
Case PaymentMode    
	When 0 Then @CHEQUENO
	when 1 then @CHEQUENO
	when 2 then	
		Case 
			when payments.DDmode = 1 and (payments.Bankid is not null) then @CHEQUENO
			when payments.DDmode = 0 and (payments.Bankid is not null) then @DDNO
		End
	When 4 then @TRANSACTIONCODE
end,
"PaymentMode" = (case PaymentMode    
	when 0 then (case when Payments.Others =4 then @PETTYCASH else @CASH end)    	   
	when 1 then @CHEQUE 
	when 2 then	@DD
	When 4 then @BANKTRANSFER
	end),
"Account_Number" = Bank.Account_Number, 
"BankID" = Payments.BankID, 
"Cheq/DD No" = case PaymentMode When 2 Then  DDChequeNumber Else Cheque_Number End,
"Cheq/DD Date" = 
Case PaymentMode  
	When 2 Then 
		Case DDChequeNumber 
			When 0 Then Null
			Else DDChequeDate 
		End 
	When 4 Then Null
	Else Cheque_Date 
End,       
"Value" = Value, "Balance" = Balance, "BranchName" = BranchMaster.BranchName, 
"BankName" = BankMaster.BankName, "BankCode" = Payments.BankCode, "BranchCode" = Payments.BranchCode, 
"Status" = Status, 
"DD Description" =
Case 
	When Payments.PaymentMode = 2 and Payments.DDMode = 1 Then @DDNO
	Else N''
End,
"DD No." = 
Case  
	When Payments.PaymentMode = 2 and Payments.DDMode = 1 Then
		Case
			when ddchequenumber is null then null
			when ddchequenumber is not null then Cast(payments.Cheque_number as nvarchar(255))
		End
	Else N''
End,
"DD Chq Date" = Cheque_Date, "DDMode" = DDMode, "DDCharges" = DDCharges, "DDDetails" = DDDetails, 
"PayableTo" = PayableTo, "Cheque_ID" = Cheque_ID, 
"ChequeBookName" = case PaymentMode When 0 Then N' ' Else cheque_Book_Name End, "AdjAmount" = value - Balance,
"DocID" = Payments.DocumentReference, "DocType" = Payments.DocSerialtype,
"TIN Number" = TIN_Number,
"Transaction Code" = Memo,
"Payment Details" = 
case PaymentMode 
	When 2 Then  
		case
			when payments.DDmode = 1 then cast(payments.ddchequenumber as nvarchar(255))
			when payments.DDmode = 0 then Cast(payments.Cheque_number as char(255))
		end
	When 4 Then Memo
	Else Cast(Cheque_Number as nvarchar(255))
End
from Payments, Vendors, Bank, BankMaster, BranchMaster, Cheques      
where Payments.VendorID = Vendors.VendorID and      
Payments.BankID *= Bank.BankID and      
Payments.BankId *= Cheques.BankID and  
Payments.DocumentID = @PaymentID and      
Payments.BankCode *= BankMaster.BankCode and      
Payments.BranchCode *= BranchMaster.BranchCode  and    
Payments.Cheque_Id *=Cheques.Chequeid
