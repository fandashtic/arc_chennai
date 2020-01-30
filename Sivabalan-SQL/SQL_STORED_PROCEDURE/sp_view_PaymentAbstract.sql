CREATE procedure [dbo].[sp_view_PaymentAbstract] (@PaymentID int)
as      
select "FullDocID" = FullDocID, "DocumentDate" = DocumentDate, "Vendor_Name" = Vendors.Vendor_Name, 
"VendorID" = Payments.VendorID, "PaymentMode" = PaymentMode, "Account_Number" = Bank.Account_Number, 
"BankID" = Payments.BankID, 
"Cheq/DD No" = case PaymentMode When 2 Then  Cast(DDChequeNumber as nvarchar) When 4 Then Memo Else Cast(Cheque_Number as nvarchar)End,
"Cheq/DD Date" = 
Case PaymentMode  
When 2 Then 
	Case DDChequeDate 
		When Null Then Cheque_Date 
		Else DDChequeDate 
	End 
When 4 Then Null
Else Cheque_Date 
End,       
"Value" = Value, "Balance" = Balance, "BranchName" = BranchMaster.BranchName, 
"BankName" = BankMaster.BankName, "BankCode" = Payments.BankCode, "BranchCode" = Payments.BranchCode, 
"Status" = Status, "DD Chq No" = Case PaymentMode When 2 Then Cheque_Number Else NULL End,
"DD Chq Date" = 
Case PaymentMode
	when 4 Then Null
	Else Cheque_Date
End,
"DDMode" = DDMode, "DDCharges" = DDCharges, "DDDetails" = DDDetails, 
"PayableTo" = PayableTo, "Cheque_ID" = Cheque_ID, 
"ChequeBookName" = case PaymentMode When 0 Then N' ' Else cheque_Book_Name End, "AdjAmount" = value - Balance,
"DocID" = Payments.DocumentReference, "DocType" = Payments.DocSerialtype,
"TIN Number" = TIN_Number,"Bank Txn Code" = isnull(Memo,N'')
from 
Payments
Inner Join Vendors on Payments.VendorID = Vendors.VendorID
Left Outer Join Bank on Payments.BankID = Bank.BankID
Left Outer Join Cheques on Payments.BankId = Cheques.BankID and Payments.Cheque_Id = Cheques.Chequeid
Left Outer Join BankMaster on Payments.BankCode = BankMaster.BankCode
Left Outer Join BranchMaster on Payments.BranchCode = BranchMaster.BranchCode
where 
--Payments.VendorID = Vendors.VendorID and      
--Payments.BankID *= Bank.BankID and      
--Payments.BankId *= Cheques.BankID and  
Payments.DocumentID = @PaymentID 
--and      
--Payments.BankCode *= BankMaster.BankCode and      
--Payments.BranchCode *= BranchMaster.BranchCode  and    
--Payments.Cheque_Id *=Cheques.Chequeid
