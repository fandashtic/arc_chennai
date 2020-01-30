CREATE procedure sp_acc_rpt_list_Cash_Payments(     
       @FromDate DateTime,      
       @ToDate DateTime)      
as      
Select "Paymentid" = Payments.Documentid, "Payment ID" = FullDocId, "Date" = Payments.DocumentDate,
"Type"= Case When Payments.Others Is not NULL Then dbo.LookupDictionaryItem('Others',Default) Else dbo.LookupDictionaryItem('Vendors',Default) End,  	 
'Payment Type' = Case When VendorID Is NULL Then
Case When IsNULL(Others,0) <> 0 And IsNULL(ExpenseAccount,0) <> 0 Then
dbo.LookupDictionaryItem('Payment to Party for Expense',Default) Else Case When IsNULL(Others,0) = 0  And IsNULL(ExpenseAccount,0) <> 0
Then dbo.LookupDictionaryItem('Payment to Expense',Default) Else dbo.LookupDictionaryItem('Payment to Party',Default) End End Else ' ' End,
"Party" = Case When Payments.others Is NULL Then (Select Vendor_Name From Vendors where VendorID=Payments.VendorID) 
Else (Select AccountName from AccountsMaster where AccountID= IsNULL(Payments.Others,0)) End,
"Payment Mode" = Case When Payments.Others =4 Then dbo.LookupDictionaryItem('Petty Cash',Default) Else dbo.LookupDictionaryItem('Cash',Default) End,
"Value" = Payments.Value , "Excess Payment" = Balance
from Payments    
where Payments.Paymentmode = 0    
And (IsNULL(Payments.Status,0)&64)= 0
And IsNULL(Payments.Status,0)<> 128
And dbo.stripdatefromtime(Payments.DocumentDate) BetWeen @FromDate And @ToDate     
Order By Payments.DocumentDate
