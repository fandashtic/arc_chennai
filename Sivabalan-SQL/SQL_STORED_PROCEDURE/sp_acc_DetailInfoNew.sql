CREATE Procedure sp_acc_DetailInfoNew(@ContraID INT, @FromAccountID INT,   
    @ToAccountID INT, @PaymentType INT)  
As  
Select 'AdditionalInfo_Number' = IsNULL(AdditionalInfo_Number,N''), AdditionalInfo_Date,   
'Bank' = IsNULL((Select BankName From BankMaster Where BankCode = AdditionalInfo_BankCode),N''),  
'AdditionalInfo_BankCode'= IsNULL(AdditionalInfo_BankCode, N''),  
'Branch' = IsNULL((Select BranchName From BranchMaster Where BankCode = AdditionalInfo_BankCode AND BranchCode = AdditionalInfo_BranchCode),N''),  
'AdditionalInfo_BranchCode' = IsNULL(AdditionalInfo_BranchCode,N''),   
'AdditionalInfo_Amount' = IsNULL(AdditionalInfo_Amount,0),  
'AdditionalInfo_Qty' = IsNULL(AdditionalInfo_Qty, 0),   
'AdditionalInfo_Value' = IsNULL(AdditionalInfo_Value, 0),  
'Party' = IsNULL(dbo.GetAccountName(IsNULL(AdditionalInfo_Party, 0)),N''),   
'PartyID' = IsNULL(AdditionalInfo_Party, 0),  
'AdditionalInfo_Type'= IsNULL(AdditionalInfo_Type, 0),   
'AdditionalInfo_FromSerialNo' = IsNULL(AdditionalInfo_FromSerialNo, 0),  
'AdditionalInfo_ToSerialNo' = IsNULL(AdditionalInfo_ToSerialNo, 0),   
'DocumentReference' = IsNULL(DocumentReference, 0),  
'DocumentType' = IsNULL(DocumentType, 0),   
'OriginalID' = IsNULL(OriginalID,N''),   
'Denominations' = IsNULL(Denominations,N''),   
'InvoiceDate'= (Select DocumentDate from Collections Where DocumentID = IsNULL(ContraDetail.DocumentReference,0)),  
'AdditionalInfo_Customer' = IsNULL(AdditionalInfo_Customer,N''),   
'AdditionalInfo_CollectionID' = IsNULL(AdditionalInfo_CollectionID,0),   
'AdditionalInfo_ServiceCharge' = IsNULL(AdditionalInfo_ServiceCharge, 0),  
'CollectionID' = IsNULL((Select FullDocID from Collections Where DocumentID = IsNULL(ContraDetail.DocumentReference,0)),N'')  
from ContraDetail Where ContraID = @ContraID AND FromAccountID = @FromAccountID   
AND ToAccountID = @ToAccountID AND PaymentType = @PaymentType 
