CREATE Procedure sp_AutoGenerate_SplSKUCreditNote(@CustomerID nvarchar(256),@Value float,@InvoiceDate DateTime )
AS
Begin
Declare @DocumentID int
Declare @Remarks nvarchar(256)
Declare @CrNoteID As Int
Declare @CrAccountID Int

Declare @DocDate Datetime
Declare @Prefix nvarchar(25)
Declare @DocPrefix nvarchar(50)
Declare @TRANDATE Datetime

Set dateformat dmy
SELECT @InvoiceDate=dbo.stripdatefromtime(@InvoiceDate)

Set @DocDate = dbo.StripTimeFromDate(GetDate())
Set @TRANDATE = dbo.StripTimeFromDate(GetDate())
Set @Remarks = 'Post Tax Discount'

SELECT @Prefix = Prefix FROM VoucherPrefix WHERE TranID = 'CREDIT NOTE'

--Begin Tran
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 10
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 10
--Commit Tran

Set @DocPrefix = @Prefix + Cast(@DocumentID as nvarchar(25))

--Select @CrAccountID = AccountID From AccountsMaster Where AccountName Like 'Sales Discount'
Select @CrAccountID = Max(AccountID) From SpecialSKUAccounts Where AccountType = 2

Insert Into CreditNote (DocumentID,
CustomerID,
NoteValue,
DocumentDate,
Balance,
Memo,
GVCollectedOn,
FreeSKUFlag)
Values
(@DocumentID,
@CustomerID,
@Value,
@InvoiceDate,
@Value,
@Remarks,
@DocDate,
1)

Select @CrNoteID = @@IDENTITY

Update CreditNote Set DocumentReference=@DocPrefix,DocSerialType="" Where CreditID=@CrNoteID

/* sp_set_transaction_timestamp */
UPDATE SETUP SET TRANSACTIONDATE = @TRANDATE  WHERE @TRANDATE > TRANSACTIONDATE
UPDATE SETUP SET Operating_Date = @TRANDATE WHERE @TRANDATE > Operating_Date And
datediff(d,operating_date,@Trandate)=0

/* sp_acc_master_addaccount */
Update CreditNote set AccountID=@CrAccountID where CreditID=@CrNoteID

/* sp_acc_gj_creditnote */
Exec sp_acc_gj_creditnote @CrNoteID, Null

Select @CrNoteID

End
