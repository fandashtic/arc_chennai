CREATE procedure [dbo].[spc_Payments] (@StartDate datetime, @EndDate datetime)
as
select DocumentID, DocumentDate, Cheque_Date, Value, Balance, PaymentMode, Bank.Bank_Name,
Cheque_Number, Vendors.AlternateCode, FullDocID, Cheque_ID
From Payments, Bank, Vendors
Where DocumentDate Between @StartDate And @EndDate And
Payments.BankID *= Bank.BankID And
Payments.VendorID = Vendors.VendorID
