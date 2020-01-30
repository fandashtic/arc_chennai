CREATE procedure [dbo].[spr_list_Market_Credit_Report] (@DATE Datetime)
As
Declare @Prefix nvarchar(20)
Declare @OTHERS As NVarchar(50)

Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)

Select @Prefix = Prefix From Voucherprefix Where TranID = 'INVOICE'

Select cu.CustomerID, "CustomerID" = cu.CustomerID, "Customer Name" = Company_Name, 
"Beat Name" = IsNull([Description], @OTHERS), "Invoice Number" = @Prefix + Cast(InvoiceID As nvarchar), 
"Invoice Date" = InvoiceDate, "Pending Amount" = Balance, 
"Credit period in Days" = DateDiff(DD, InvoiceDate, @DATE), "Ageing of Credit" = 
DateDiff(DD, InvoiceDate, @DATE) * Balance From 
Customer cu, Beat, InvoiceAbstract ia Where cu.CustomerID = ia.CustomerID And ia.BeatID *=
Beat.BeatID And DateDiff(DD, PaymentDate, @DATE) > 0 And Balance > 0
