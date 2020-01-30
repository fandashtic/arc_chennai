CREATE Procedure sp_acc_PrintTransactionBySelection  
(  
@FromDoc Decimal(18,6),  
@ToDoc Decimal(18,6),  
@FromDate Datetime,  
@ToDate Datetime,  
@TransType Int,  
@Mode Int,  
@DocumentRef nVarChar(255) = N''  
)  
As  
DECLARE @PETTY_CASH_ACID INT  
DECLARE @RECEIPTS_TYPE INT   
DECLARE @FAPAYMENTS_TYPE INT  
DECLARE @APV_TYPE INT  
DECLARE @ARV_TYPE INT  
DECLARE @CHEQUEDEP_TYPE INT  
DECLARE @PETTYCASH_TYPE INT  
DECLARE @JOURNAL_TYPE INT  
  
SET @PETTY_CASH_ACID = 4  
SET @RECEIPTS_TYPE = 57  
SET @FAPAYMENTS_TYPE = 56  
SET @APV_TYPE = 53  
SET @ARV_TYPE = 54  
SET @CHEQUEDEP_TYPE = 25  
SET @PETTYCASH_TYPE = 55  
SET @JOURNAL_TYPE = 52  
  
If @TransType = @RECEIPTS_TYPE  
Begin  
 If @Mode = 0  
 Begin  
  If Len(@DocumentRef)= 0  
   Select DocumentID,FullDocID From Collections  
   Where ((CASE IsNumeric(DocReference)When 1 then CAST(DocReference as INT)End) Between @FromDoc And @ToDoc)  
   And DocumentDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
   And CustomerID Is NULL  
   Order By dbo.GetTrueVal(DocReference)  
  Else      
   Select DocumentID,FullDocID From Collections   
   Where DocReference Like @DocumentRef + N'%' + N'[0-9]'  
   And DocumentDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
   And (CASE IsNumeric(SubString(DocReference,Len(@DocumentRef)+1,Len(DocReference)))  
   When 1 then CAST(SubString(DocReference,Len(@DocumentRef)+1,Len(DocReference))as INT)End) Between @FromDoc And @ToDoc  
   And CustomerID Is NULL  
   Order By dbo.GetTrueVal(DocReference)  
 End  
 Else  
  Select DocumentID,FullDocID from Collections  
  Where dbo.GetTrueVal(FullDocID) Between CAST(@FromDoc As INT) And CAST(@ToDoc As INT)  
  And DocumentDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
  And CustomerID Is NULL  
  Order By dbo.GetTrueVal(FullDocID)  
End  
Else If @TransType = @FAPAYMENTS_TYPE  
 Begin  
 If @Mode = 0  
 Begin  
  If Len(@DocumentRef)= 0  
   Select DocumentID,FullDocID From Payments  
   Where ((CASE IsNumeric(DocRef)When 1 then CAST(DocRef as INT)End) Between @FromDoc And @ToDoc)  
   And DocumentDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
   And VendorID Is NULL And Others <> @PETTY_CASH_ACID And PaymentMode <> 5
   Order By dbo.GetTrueVal(DocRef)  
  Else      
   Select DocumentID,FullDocID From Payments  
   Where DocRef Like @DocumentRef + N'%' + N'[0-9]'  
   And DocumentDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
   And (CASE IsNumeric(SubString(DocRef,Len(@DocumentRef)+1,Len(DocRef)))  
   When 1 then CAST(SubString(DocRef,Len(@DocumentRef)+1,Len(DocRef))as INT)End) Between @FromDoc And @ToDoc  
   And VendorID Is NULL And Others <> @PETTY_CASH_ACID And PaymentMode <> 5
   Order By dbo.GetTrueVal(DocRef)  
 End  
 Else  
  Select DocumentID,FullDocID from Payments  
  Where dbo.GetTrueVal(FullDocID) Between CAST(@FromDoc As INT) And CAST(@ToDoc As INT)  
  And DocumentDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
  And VendorID Is NULL And Others <> @PETTY_CASH_ACID And PaymentMode <> 5
  Order By dbo.GetTrueVal(FullDocID)  
 End  
Else If @TransType = @APV_TYPE  
 Begin  
 If @Mode = 0  
 Begin  
  If Len(@DocumentRef)= 0  
   Select DocumentID,VoucherPrefix.Prefix + CAST(APVID As nVarChar) From APVAbstract, VoucherPrefix  
   Where ((CASE IsNumeric(DocumentReference)When 1 then CAST(DocumentReference as INT)End) Between @FromDoc And @ToDoc)  
   And APVDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
   And VoucherPrefix.TranID = N'ACCOUNTS PAYABLE VOUCHER'  
   Order By dbo.GetTrueVal(DocumentReference)  
  Else      
   Select DocumentID,VoucherPrefix.Prefix + CAST(APVID As nVarChar) From APVAbstract, VoucherPrefix  
   Where DocumentReference Like @DocumentRef + N'%' + N'[0-9]'  
   And APVDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
   And (CASE IsNumeric(SubString(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference)))  
   When 1 then CAST(SubString(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as INT)End) Between @FromDoc And @ToDoc  
   And VoucherPrefix.TranID = N'ACCOUNTS PAYABLE VOUCHER'  
   Order By dbo.GetTrueVal(DocumentReference)  
 End  
 Else  
  Select DocumentID,VoucherPrefix.Prefix + CAST(APVID As nVarChar) From APVAbstract, VoucherPrefix  
  Where APVID Between CAST(@FromDoc As INT) And CAST(@ToDoc As INT)  
  And APVDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
  And VoucherPrefix.TranID = N'ACCOUNTS PAYABLE VOUCHER'  
  Order By APVID  
 End  
Else If @TransType = @ARV_TYPE  
 Begin  
 If @Mode = 0  
 Begin  
  If Len(@DocumentRef)= 0  
   Select DocumentID,VoucherPrefix.Prefix + CAST(ARVID As nVarChar) From ARVAbstract, VoucherPrefix  
   Where ((CASE IsNumeric(DocRef)When 1 then CAST(DocRef as INT)End) Between @FromDoc And @ToDoc)  
   And ARVDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
   And VoucherPrefix.TranID = N'ACCOUNTS RECEIVABLE VOUCHER'  
   Order By dbo.GetTrueVal(DocRef)  
  Else      
   Select DocumentID,VoucherPrefix.Prefix + CAST(ARVID As nVarChar) From ARVAbstract, VoucherPrefix  
   Where DocRef Like @DocumentRef + N'%' + N'[0-9]'  
   And ARVDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
   And (CASE IsNumeric(SubString(DocRef,Len(@DocumentRef)+1,Len(DocRef)))  
   When 1 then CAST(SubString(DocRef,Len(@DocumentRef)+1,Len(DocRef))as INT)End) Between @FromDoc And @ToDoc  
   And VoucherPrefix.TranID = N'ACCOUNTS RECEIVABLE VOUCHER'  
   Order By dbo.GetTrueVal(DocRef)  
 End  
 Else  
  Select DocumentID,VoucherPrefix.Prefix + CAST(ARVID As nVarChar) From ARVAbstract, VoucherPrefix  
  Where ARVID Between CAST(@FromDoc As INT) And CAST(@ToDoc As INT)  
  And ARVDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
  And VoucherPrefix.TranID = N'ACCOUNTS RECEIVABLE VOUCHER'  
  Order By ARVID  
 End  
Else If @TransType = @CHEQUEDEP_TYPE  
 Begin  
  Select Deposits.DepositID,Deposits.FullDocID From Collections,Deposits  
  Where dbo.GetTrueVal(Deposits.FullDocID) Between CAST(@FromDoc As INT) And CAST(@ToDoc As INT)  
  And Deposits.DepositDate Between @FromDate And @ToDate And (IsNULL(Deposits.Status,0) & 128) = 0  
  And Collections.PaymentMode In (1,2) And IsNULL(Collections.DepositID, 0) <> 0 And (ISNULL(Collections.Status, 0) & 192) = 0  
  And Collections.DepositID = Deposits.DepositID And Collections.Deposit_To = Deposits.AccountID  
  Union  
  Select Deposits.DepositID,Deposits.FullDocID From Collections,Deposits,DepositsDetail  
  Where dbo.GetTrueVal(Deposits.FullDocID) Between CAST(@FromDoc As INT) And CAST(@ToDoc As INT)  
  And Deposits.DepositDate Between @FromDate And @ToDate And (IsNULL(Deposits.Status,0) & 128) = 0  
  And Collections.PaymentMode In (1,2) And IsNULL(Collections.DepositID, 0) <> 0 And (ISNULL(Collections.Status, 0) & 192) = 0  
  And Deposits.DepositID=DepositsDetail.DepositID And DepositsDetail.CollectionID=Collections.DocumentID  
  Order By Deposits.DepositID  
 End  
Else If @TransType = @PETTYCASH_TYPE  
 Begin  
  Select DocumentID,FullDocID from Payments  
  Where dbo.GetTrueVal(FullDocID) Between CAST(@FromDoc As INT) And CAST(@ToDoc As INT)  
  And DocumentDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
  And (Others = @PETTY_CASH_ACID Or PaymentMode = 5)  
  Order By dbo.GetTrueVal(FullDocID)  
 End  
Else If @TransType = @JOURNAL_TYPE  
 Begin  
  Select Distinct(TransactionID),VoucherPrefix.Prefix + CAST(DocumentNumber As nVarChar) From GeneralJournal, VoucherPrefix  
  Where DocumentNumber Between CAST(@FromDoc As INT) And CAST(@ToDoc As INT)  
  And TransactionDate Between @FromDate And @ToDate And (IsNULL(Status,0) & 128) = 0  
  And DocumentType In (26,37) And VoucherPrefix.TranID = N'MANUAL JOURNAL'  
  Order By TransactionID  
 End  

