CREATE procedure sp_acc_detailinfo(@contraid int,@fromaccountid int,@toaccountid int,
@paymenttype int)
as
select AdditionalInfo_Number,AdditionalInfo_Date,'Bank' = dbo.getbank(isnull(AdditionalInfo_BankCode,0)),
'AdditionalInfo_BankCode'= isnull(AdditionalInfo_BankCode,0),'Branch' = dbo.getbranch(isnull(AdditionalInfo_BranchCode,0)),
'AdditionalInfo_BranchCode' = AdditionalInfo_BranchCode, AdditionalInfo_Amount,
'AdditionalInfo_Qty' = isnull(AdditionalInfo_Qty,0),'AdditionalInfo_Value' = isnull(AdditionalInfo_Value,0),
'Party' = dbo.getaccountname(isnull(AdditionalInfo_Party,0)),'PartyID' = AdditionalInfo_Party,
'AdditionalInfo_Type'= isnull(AdditionalInfo_Type,0),'AdditionalInfo_FromSerialNo' = isnull(AdditionalInfo_FromSerialNo,0),
'AdditionalInfo_ToSerialNo' = isnull(AdditionalInfo_ToSerialNo,0),'DocumentReference' = isnull(DocumentReference,0),
'DocumentType' = isnull(DocumentType,0),OriginalID,Denominations,'InvoiceDate'= dbo.getinvoicedate(isnull(DocumentReference,0)),
AdditionalInfo_Customer,AdditionalInfo_CollectionID,
'AdditionalInfo_ServiceCharge' = IsNull(AdditionalInfo_ServiceCharge,0)
from ContraDetail Where ContraID = @contraid and FromAccountID = @fromaccountid 
and ToAccountID = @toaccountid and PaymentType = @paymenttype


