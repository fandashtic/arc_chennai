CREATE procedure [dbo].[sp_view_InvoicewiseCollectionDetail](@CollectionID as int)          
as          

Select "OriginalID" = cld.OriginalID, "DocumentDate" = cld.DocumentDate, "DocRef" = cld.DocRef, "DocumentValue" = cld.DocumentValue,        
"DocBalance" = ((case cld.DocumentType   
when 4 then (Select Isnull(sum(Balance),0) From InvoiceAbstract where InvoiceID=cld.DocumentID)   
when 5 then (Select Isnull(sum(Balance),0) From DebitNote where DebitID=cld.DocumentID) end)  
+ IsNull(cld.AdjustedAmount,0)+ IsNull(cld.Adjustment,0)), 
"Collected Amount" = cld.AdjustedAmount, "AdjustedAmount" = cld.AdjustedAmount, "Addl.Adjustment" = cld.ExtraCollection, 
"OutStanding" = (((case cld.DocumentType   
when 4 then (Select Isnull(sum(Balance),0) From InvoiceAbstract where InvoiceID=cld.DocumentID)   
when 5 then (Select Isnull(sum(Balance),0) From DebitNote where DebitID=cld.DocumentID) end)  
+ IsNull(cld.AdjustedAmount,0)+ IsNull(cld.Adjustment,0)) - cld.AdjustedAmount), 
"Discount%" = cld.Discount, "Adjustment" = cld.Adjustment, "DocumentID" = cld.DocumentID, 
"DocumentType" = case convert(numeric,cld.DocumentType)        
 when 1 then dbo.LookUpDictionaryItem(N'Sales Return',Default)
 when 2 then dbo.LookUpDictionaryItem(N'Credit Note',Default)       
 when 3 then dbo.LookUpDictionaryItem(N'Collections',Default)
 when 4 then dbo.LookUpDictionaryItem(N'Invoice',Default)
 when 5 then dbo.LookUpDictionaryItem(N'Debit Note',Default)
 when 6 then dbo.LookUpDictionaryItem(N'Retail Invoice',Default)
 when 7 then dbo.LookUpDictionaryItem(N'Retail Sales Return',Default)  
 end,
"PaymentMode" = case cl.PaymentMode when 0 then dbo.LookUpDictionaryItem(N'Cash',Default) when 1 then dbo.LookUpDictionaryItem(N'Cheque',Default) when 2 then dbo.LookUpDictionaryItem(N'DD',Default) end,
"ChequeNumber" = cl.ChequeNumber, "Cash/Cheque/DD Date" = case cl.PaymentMode 
when 0 then cl.DocumentDate else cl.ChequeDate end, 
"BankCode" = BankMaster.BankCode, "BranchCode" = BranchMaster.BranchCode, "BankName" = BankMaster.BankName,         
"BranchName" = BranchMaster.BranchName, "CustomerID" = cl.CustomerID, "Customer" = Customer.Company_Name 
from Collections cl, CollectionDetail cld, BankMaster, BranchMaster, Customer 
where cl.DocumentID in (Select DocumentID From InvoicewiseCollectionDetail Where CollectionID=@CollectionID) and cl.DocumentID=cld.CollectionID and 
cl.BankCode *= BankMaster.BankCode and cl.BranchCode *= BranchMaster.BranchCode and cl.CustomerID = Customer.CustomerID
