CREATE Procedure sp_AutoGenerate_CLOCreditNote(@CLOCrID Int)
AS
Begin
Declare @DocumentID int
Declare @LoyaltyID nVarchar(256)
Declare @PartyID nvarchar(256)
Declare @Value float
Declare @Remarks nvarchar(256)
Declare @CrNoteID As Int
Declare @CrAccountID Int

Declare @DocDate Datetime
Declare @CRNoteType int
Declare @Prefix nvarchar(25)
Declare @DocPrefix nvarchar(50)
Declare @TRANDATE Datetime
Declare @PrintFlag integer

Set @DocDate = dbo.StripTimeFromDate(GetDate())
Set @CRNoteType = 9
Set @TRANDATE = dbo.StripTimeFromDate(GetDate())

SELECT @Prefix = Prefix FROM VoucherPrefix WHERE TranID = 'GIFT VOUCHER'

/* sp_Insert_CLOCreditNote */
--Begin Tran
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 70
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 70
--Commit Tran

Set @DocPrefix = @Prefix + Cast(@DocumentID as nvarchar(25))

Select @LoyaltyID = ly.LoyaltyID, @PartyID = clocr.CustomerID, @Value = clocr.Amount,
@Remarks = clocr.CLOType + '-' + SubString(DateName(mm, clocr.CLODate), 1, 3) + '-' + DateName(YYYY, clocr.CLODate),
@PrintFlag = isnull(clocr.PrintFlag,0)
From CLOCrNote clocr, Loyalty ly
Where clocr.CLOType = ly.Loyaltyname And
clocr.ID = @CLOCrID

Select @CrAccountID = AccountID From AccountsMaster Where AccountName Like 'Secondary Scheme Expense'

Insert Into CreditNote (DocumentID,
LoyaltyID,
CustomerID,
NoteValue,
DocumentDate,
Balance,
Memo,
GVCollectedOn,
flag)
Values
(@DocumentID,
@LoyaltyID,
@PartyID,
@Value,
@DocDate,
@Value,
@Remarks,
@DocDate,
1)

Select @CrNoteID = @@IDENTITY

Update CLOCrNote Set CreditID = @CrNoteID, ActivityCode = @Remarks, IsGenerated = 1
Where ID = @CLOCrID

IF @PrintFlag = 1
Begin
Insert Into tbl_mERP_CLOCreditPrint(CLOCreditID,CustomerID)
Select @CrNoteID, @PartyID
End

--Select @DocumentID, @CrNoteID, @CrAccountID

/* sp_Update_TransactionSerial */
Update CreditNote Set DocumentReference=@DocPrefix,DocSerialType="" Where CreditID=@CrNoteID
/* sp_updateGVNO */
Update CreditNote set GiftVoucherNo=DocumentReference where CreditID =@CrNoteID

--FRITFITC-678-Auto Adjust Credit Notes
--Type : 1 = CLO Credit Note DataPost to CrNoteDSType Table
exec sp_CrNoteDSType_DataPost @CrNoteID,1

/* sp_set_transaction_timestamp */
UPDATE SETUP SET TRANSACTIONDATE = @TRANDATE  WHERE @TRANDATE > TRANSACTIONDATE
UPDATE SETUP SET Operating_Date = @TRANDATE WHERE @TRANDATE > Operating_Date And
datediff(d,operating_date,@Trandate)=0

/* sp_acc_master_addaccount */
Update CreditNote set AccountID=@CrAccountID where CreditID=@CrNoteID

/* sp_acc_gj_creditnote */
Exec sp_acc_gj_creditnote @CrNoteID, Null

End
