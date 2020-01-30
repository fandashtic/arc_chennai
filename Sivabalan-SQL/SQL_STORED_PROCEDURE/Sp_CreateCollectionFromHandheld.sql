Create Procedure Sp_CreateCollectionFromHandheld @SalesmanID int,@LogID int = 0
AS
BEGIN
BEGIN TRY

Declare @WriteOff_Validation as nVarchar(500)
Declare @Coll_Disc_PymtDate_Validation as nVarchar(500)
Declare @Allow_Coll_Fulladjust as nVarchar(500)

Declare @ColPrefix nvarchar(50)
Declare @InvPrefix nvarchar(50)
Declare @Flag int

Declare @AbsEntry int
Declare @DetEntry int
Set @AbsEntry = 0
Set @DetEntry = 0

Create Table #tmpCollection
(
HHColID Int Identity(1,1)
,SerialNO nVarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS
,DocumentID Int
,CollectionDate DateTime
,AmtCollected Decimal(18,6)
,PaymentMode nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
,ChequeNumber nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
,ChequeDate DateTime
,CustomerID nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS
,SalesManID Int
,BeatID Int
,BankCode nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
,BranchCode nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
,CollectionFlag Int
,Discount Decimal(18,6)
,SerialNoCount Int
,Rejected Int
)

IF Not Exists(Select 'x' From SysObjects Where Name = 'HandHeldCollProcessLog' and XType = 'U')
BEGIN
Create Table HandHeldCollProcessLog(
Collection_Serial nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS Null,
AbstractInsert int,
DetailInsert int,
CreationDate DateTime NOT NULL Default GetDate()
)

End

IF Not Exists(Select 'x' From SysObjects Where Name = 'HandHeldCollProcessTrace' and XType = 'U')
BEGIN
Create Table HandHeldCollProcessTrace
(
InsType Int
,CreationDate DateTime NOT NULL Default GetDate()
,SerialNO nVarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS
,DocumentID Int
,CollectionDate DateTime
,AmtCollected Decimal(18,6)
,PaymentMode nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
,ChequeNumber nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
,ChequeDate DateTime
,CustomerID nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS
,SalesManID Int
,BeatID Int
,BankCode nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
,BranchCode nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
,CollectionFlag Int
,Discount Decimal(18,6)
,SerialNoCount Int
,Rejected Int
)
End

-- To get voucher prefix
Create Table #Prefix(PrefixName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, TransName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
insert into #Prefix(PrefixName)
Exec sp_get_VoucherPrefix 'COLLECTIONS'
Update #Prefix Set TransName = 'COLLECTIONS' Where isnull(TransName,'') = ''
Select @ColPrefix = PrefixName From #Prefix Where TransName = 'COLLECTIONS'

Create Table #tmpCollectionSerial (SerialNO nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)

insert into #Prefix(PrefixName)
Exec sp_get_VoucherPrefix 'INVOICE'
Update #Prefix Set TransName = 'INVOICE' Where isnull(TransName,'') = ''
Select @InvPrefix = PrefixName From #Prefix Where TransName = 'INVOICE'

Declare @VoucherPrefix nvarchar(255)
Set dateformat dmy
Declare @DayCloseDate Datetime
Select @DayCloseDate=dbo.StripDateFromTime(LastInventoryUpload) from Setup

Create Table #tmpSalesman(Cnt int, SalesmanName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, BeatName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

-- Full Payment validation based on tblTools table value
Select Top 1 @WriteOff_Validation = Tool_Value From tblTools Where Tool_ID = 1
Select Top 1 @Coll_Disc_PymtDate_Validation = Tool_Value From tblTools Where Tool_ID = 2
Select Top 1 @Allow_Coll_Fulladjust = Tool_Value From tblTools Where Tool_ID = 3

Insert Into #tmpCollection
(SerialNO,DocumentID,CollectionDate,AmtCollected,PaymentMode,ChequeNumber,ChequeDate
,CustomerID,SalesManID,BeatID,BankCode,BranchCode,CollectionFlag,Discount,SerialNoCount,Rejected)
Select
"SerialNO" = IsNull(COLD.[Collection_Serial],'')
,"DocumentID" = IsNull(COLD.[AgainstBillNo],0)
,"CollectionDate" = COLD.[CollectionDate]
,"AmtCollected" = IsNull(COLD.[AmountCollected],0)
,"PaymentMode" = IsNull(COLD.[CollectionType],0)
,"ChequeNumber" = IsNull(COLD.[CheqNo_DDNo],'')
,"ChequeDate" = COLD.[CheqDate_DDDate]
,"CustomerID" = IsNull(COLD.[CustomerID],'')
,"SalesManID"=  IsNull(COLD.[SalesManID],0)
,"BeatID"=  IsNull(COLD.[BeatID],0)
,"BankCode" = IsNull(COLD.[BankCode],'')
,"BranchCode" = IsNull(COLD.[BranchCode],'')
,"CollectionFlag" = IsNull(COLD.[CollectionFlag],0)
,"Discount" = IsNull(COLD.[DisCount],0)
,"SerialNoCount" = (Select Count(Collection_Serial) From Collection_Details Where Collection_Serial = COLD.[Collection_Serial])
,"Rejected" = 0
--Into #tmpCollection
From Collection_Details COLD WITH (NOLOCK)
Where IsNull(COLD.[Processed],0) = 0  and SalesManID = @SalesmanID

Insert Into HandHeldCollProcessTrace (InsType,SerialNO,DocumentID,CollectionDate,AmtCollected,PaymentMode,ChequeNumber,ChequeDate,CustomerID
,SalesManID,BeatID,BankCode,BranchCode,CollectionFlag,Discount,SerialNoCount,Rejected)
Select 1,SerialNO,DocumentID,CollectionDate,AmtCollected,PaymentMode,ChequeNumber,ChequeDate,CustomerID
,SalesManID,BeatID,BankCode,BranchCode,CollectionFlag,Discount,SerialNoCount,Rejected
From #tmpCollection

--With HHColl_Duplicate as
--   (Select SerialNO , Row_Number() Over(Partition By SerialNO Order By SerialNO) RowNumber From #tmpCollection)
--Delete From HHColl_Duplicate Where RowNumber<>1

--Alter Table #tmpCollection Add Rejected Int

Create Table #DaycloseConfig(InvConfigValue int,FAConfigValue int)
Insert into #DaycloseConfig(InvConfigValue,FAConfigValue)
Exec mERP_GetCloseDay_Config


Declare @OriginalCollection INT
Declare @BankID int
Declare @CardHolder nvarchar(256)
Declare @CreditCardNumber nvarchar(20)
Declare @CustomerServiceCharge decimal(18,6)
Declare @ProviderServiceCharge decimal(18,6)
Declare @PaymentModeID int

Set @OriginalCollection = 0
Set @BankID = 0
Set @CardHolder = ''
Set @CreditCardNumber = ''
Set @CustomerServiceCharge = 0
Set @ProviderServiceCharge = 0
Set @PaymentModeID = 0

Declare @InvConfigValue int

Declare @SerialNo nvarchar(100)
Declare @DocumentID nvarchar(100)
Declare @CollectionDate Datetime
Declare @AmtCollected Decimal(18,6)
Declare @PaymentMode int
Declare @PaymentMode1 nvarchar(100)
Declare @ChequeNumber nvarchar(100)
Declare @ChequeDate Datetime
Declare @CustomerID nvarchar(30)
--Declare @SalesmanID int
Declare @BeatID int
Declare @BankCode nvarchar(100)
Declare @BranchCode nvarchar(100)
Declare @CollectionFlag int
Declare @Discount Decimal(18,6)
Declare @SerialNoCount int
Declare @DocRefError nvarchar(200)
Declare @Error nvarchar(2000)

Declare @DocType int
Declare @FullyAdjust int
Declare @INVWriteoffAmt Decimal(18,6)

Declare @AmendmentFlag int
Declare @AmendmentDocID nVarchar(50)
Declare @UpdDocID nvarchar(50)
DECLARE @UpdBeatID int
Declare @ColIdentity int

Declare @Customer_Status as nVarchar(50)
Declare @SalesmanName as nvarchar(100)
Declare @BeatName as nvarchar(100)
Declare @Writeoff as Decimal(18,6)
Declare @ExtraCol as Decimal(18,6)
Declare @AdjustedAmt as Decimal(18,6)
Declare @DocRef as nvarchar(100)
Declare @ChequeMode as nvarchar(50)

Declare @InvID int
Declare @INVDocid INT
Declare @InvDocRef nvarchar(100)
Declare @InvDate Datetime
Declare @InvCustID nvarchar(30)
Declare @InvNetvalue Decimal(18,6)
Declare @INVPaymentDate Datetime
Declare @INVErrStatus int
Declare @INVBalance Decimal(18,6)
Declare @InvStatus int

Declare @StripCollectionDate Datetime
Declare @UpdDocumentID int
Declare @DiscWriteoff Decimal(18,6)
Declare @InvPrefixDoc nvarchar(100)
Declare @DiscPerc Decimal(18,6)
Declare @WarningMessage nvarchar(500)

Declare @GSTFlag int
Declare @GSTFullDocID nvarchar(255)

Set @AmendmentFlag = 0
Set @AmendmentDocID = ''
Set @Writeoff = 0
Set @GSTFlag = 0
Set @GSTFullDocID = ''

Declare @ColTranType int
Set @ColTranType = 11
Set @Writeoff = 0

Select Top 1 @Writeoff = isnull(Value, 0) From HH_Collection Where Description = 'WRITEOFFAMOUNT'

--Declare xCollections Cursor For Select SerialNo, DocumentID, CollectionDate, AmtCollected, PaymentMode, ChequeNumber,
--	ChequeDate, CustomerID, BeatID, BankCode, BranchCode, CollectionFlag, Discount, SerialNoCount From #tmpCollection
--Open xCollections
--Fetch from xCollections into @SerialNo, @DocumentID, @CollectionDate, @AmtCollected, @PaymentMode1, @ChequeNumber,
--	@ChequeDate, @CustomerID, @BeatID, @BankCode, @BranchCode, @CollectionFlag, @Discount, @SerialNoCount
--While @@FETCH_STATUS = 0

Declare @Row Int
Declare @RowCnt Int
Set @RowCnt = 0
Set @Row = 1
Select @RowCnt = Max(HHColID) From #tmpCollection
IF ISNULL(@RowCnt,0) > 0
Begin
While @Row < = @RowCnt
BEGIN

Select @SerialNo=SerialNo, @DocumentID=DocumentID, @CollectionDate=CollectionDate, @AmtCollected=AmtCollected
, @PaymentMode1=PaymentMode, @ChequeNumber=ChequeNumber,@ChequeDate=ChequeDate, @CustomerID=CustomerID, @BeatID=BeatID,
@BankCode=BankCode, @BranchCode=BranchCode, @CollectionFlag=CollectionFlag, @Discount=Discount, @SerialNoCount=SerialNoCount
From #tmpCollection Where HHColID = @Row

Set @INVWriteoffAmt = 0
Set @FullyAdjust = 0
Set @ColIdentity = 0
Set @WarningMessage = ''
Set @DocRefError = ''
Set @Error = ''
Set @DocType = ''

Set @DocRefError = 'AgainstBillNo ' + @DocumentID + '(Collection SerialNo ' + @SerialNo + ') '
Set @StripCollectionDate = dbo.Striptimefromdate(@CollectionDate)
Set @DocType =  @CollectionFlag

IF @PaymentMode1 = 1 OR @PaymentMode1 = 2
Set @PaymentMode = @PaymentMode1
ELSE
Set @PaymentMode = 0

IF isnull(@SerialNoCount, 0) > 1
BEGIN
Set @Error= @DocRefError + 'is not unique in staging table [COLLECTION_DETAILS].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

ELSE IF isnull(@SerialNo,'') = ''
BEGIN
Set @Error= @DocRefError + 'has invalid collection serial number.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
ELSE If isnull(@CollectionDate,'') = ''
BEGIN
Set @Error= @DocRefError + 'has empty collection date.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
ELSE If @CollectionFlag <=0 OR @CollectionFlag > 3
BEGIN
Set @Error= @DocRefError + 'has invalid collection flag [' + Cast(@CollectionFlag as nvarchar(10))  + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

ELSE If @PaymentMode1 <=0 OR @PaymentMode1 > 3
BEGIN
Set @Error= @DocRefError + 'has invalid payment mode [' + Cast(@PaymentMode1 As nVarChar) + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
ELSE If @AmtCollected < 0
BEGIN
Set @Error= @DocRefError + 'has invalid collection amount [' + cast(@AmtCollected as nvarchar(30))  + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
ELSE If @Discount < 0
BEGIN
Set @Error= @DocRefError + 'has discount amount [' + Cast(@Discount as nvarchar(30))  + '] less than zero.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

IF Exists(Select 'X' From Collections Where DocReference = @SerialNo)
BEGIN
Set @Error= 'Collection SerialNo (' + @SerialNo + ') is already exist in collections.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

--Select Top 1 @InvConfigValue=InvConfigValue from #DaycloseConfig
Select Top 1 @InvConfigValue=FAConfigValue from #DaycloseConfig

/* BackDated SO Validation*/
Declare @TranDate4CollDate DateTime
Set @TranDate4CollDate = dbo.StripDateFromTime(@CollectionDate)
If (Select count(*) from dbo.fn_HasAdminPassword_Collection(@SerialNo,@TranDate4CollDate,@InvConfigValue) where ErrorNumber=0)>=1
BEGIN
Select @Error= ErrorDescription from dbo.fn_HasAdminPassword_Collection(@SerialNo,@TranDate4CollDate,@InvConfigValue) where ErrorNumber=0
if (@Error <>'')
BEGIN
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
END

/*Customer ID Validation*/
If isnull(@CustomerID,'') = ''
BEGIN
Set @Error= @DocRefError + '- CustomerID is empty.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

Select @Customer_Status  = Case When IsNull(CustomerCategory ,0) >=4 then 'has invalid customer category for ' else '' end
From Customer Where CustomerID = @CustomerID
Set @Customer_Status = IsNull(@Customer_Status,'has invalid ')
If isnull(@Customer_Status,'') <> ''
BEGIN
Set @Error= @DocRefError + @Customer_Status + 'CustomerID [' + @CustomerID + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

/*Salesman ID Validation*/
If isnull(@SalesmanID,0) <= 0
BEGIN
Set @Error= @DocRefError + '- SalesmanID is empty.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
IF Not Exists(Select  SalesmanID from Salesman Where SalesmanID = @SalesmanID)
BEGIN
Set @Error= @DocRefError + 'has invalid' + 'SalesmanID [' + Cast(@SalesmanID as nvarchar(10)) + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

/*Beat ID Validation*/
If isnull(@BeatID,0) <= 0
BEGIN
Set @Error= @DocRefError + '- BeatID is empty.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
IF Not Exists(Select  BeatId from Beat Where BeatId = @BeatID)
BEGIN
Set @Error= @DocRefError + 'has invalid' + 'BeatID [' + Cast(@BeatID as nvarchar(10)) + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

Insert Into #tmpSalesman(Cnt, SalesmanName, BeatName)
Exec sp_han_IsValidSalesmanBeat @BeatID, @SalesmanID

IF Exists(Select 'x' From #tmpSalesman Where isnull(Cnt,0) = 0)
BEGIN
Select @SalesmanName = SalesmanName, @BeatName = BeatName From #tmpSalesman Where isnull(Cnt,0) = 0
Set @Error= @DocRefError + 'Salesman [' + @SalesmanName + '] is not defined to Beat [' + @BeatName + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

IF @CollectionFlag = 1
BEGIN
IF (@Discount > 0 and @Discount > @Writeoff) and @WriteOff_Validation = '1'
BEGIN
Set @Error= @DocRefError + '- Discount amount [' + Cast(@Discount as nvarchar(30)) + '] is greater than writeoff amount [' + Cast(@Writeoff as nvarchar(30)) + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
ELSE IF isnull(@DocumentID,'') = '' OR isnumeric(@DocumentID) = 0
BEGIN
Select @Error = Case When isnull(@DocumentID,'') = '' Then  ' - AgainstBillNo is empty.'
When @DocumentID = 0 Then  '- Invalid AgainstBillNo [' + @DocumentID + '].' End

Set @Error= 'Collection SerialNo ' + @SerialNo + @Error
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
ELSE IF NOT (@DocumentID > cast(0 as nvarchar(100)) and  isnumeric(@DocumentID) = 1)
BEGIN
Set @Error= @DocRefError + '- InvoiceID [' + @DocumentID + '] not found.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

Select @InvID = INA.[InvoiceID],@INVDocid = INA.[DocumentID]
,@InvDocRef = INA.[DocReference],@InvDate = INA.[InvoiceDate]
,@InvCustID =IsNull(INA.[CustomerID],''),@InvNetvalue = IsNull(INA.[NetValue],0)
,@INVPaymentDate = INA.[PaymentDate]
,@INVErrStatus = Case IsNull(COLD.[CollectionFlag],0)
When 1 then Case when IsNull(INA.[CustomerID],'') <> IsNull(COLD.[CustomerID],'')
then -1 when dbo.StripDateFromTime(COLD.CollectionDate) < dbo.StripDateFromTime(INA.InvoiceDate) then -2
when dbo.StripDateFromTime(COLD.CollectionDate) > dbo.StripDateFromTime (INA.PaymentDate) then 1 else 0 end
else 0 end
,@INVBalance = IsNull(INA.Balance,0),@InvStatus = IsNull(INA.[Status],0)
,@GSTFlag = isnull(GSTFlag,0)
,@GSTFullDocID = isnull(GSTFullDocID,'')
From Collection_Details COLD
Inner Join InvoiceAbstract INA ON COLD.[AgainstBillNO] = INA.[InvoiceID] AND COLD.[Processed] = 0
and INA.InvoiceID = Cast(@DocumentID as Int) and INA.[InvoiceType] in (1,3) And COLD.[Collection_Serial] = @SerialNo

IF Isnull(@InvID,0) >= 0
BEGIN
IF @INVErrStatus = -1
BEGIN
Set @Error= @DocRefError + '- Collection CustomerID [' + @CustomerID + '] does not match Invoice CustomerID [' + @InvCustID + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
ELSE IF @Discount > @InvNetvalue
BEGIN
Set @Error= @DocRefError + '- Discount amount [' + Cast(@Discount as nvarchar(30)) + '] is greater than InvoiceAmount [' + Cast(@InvNetvalue as nvarchar(30)) + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
ELSE IF @Discount > 0 and @INVErrStatus = 1 and @Coll_Disc_PymtDate_Validation = '1'
BEGIN
Set @Error= @DocRefError + '- Collection date [' + Cast(@StripCollectionDate as nvarchar(50)) + '] exceeds payment date [' + Cast(@INVPaymentDate as nvarchar(50)) + ']. So discount is not allowed.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
ELSE IF (@InvStatus & 64) = 64
BEGIN
Set @DocType = 3
Set @Error= @DocRefError + '- InvoiceID [' + @DocumentID + '] is already cancelled. So advance collection will be created.'
Set @WarningMessage = @Error
END
ELSE IF (@InvStatus & 128) = 128 and (@InvStatus & 192) <> 192
BEGIN
Set @DocType = 3
Set @Error= @DocRefError + '- InvoiceID [' + @DocumentID + '] is amended. So advance collection will be created.'
Set @WarningMessage = @Error
END
ELSE IF @INVBalance <= 0 OR @InvNetvalue <= 0
BEGIN
Set @DocType = 3
Set @Error= @DocRefError + '- InvoiceID [' + @DocumentID + '] is already fully adjusted. So advance collection will be created.'
Set @WarningMessage = @Error
END

IF @DocType = 1
BEGIN
Declare @ColWriteoff Decimal(18,6)
Set @ColWriteoff = @INVBalance - (@AmtCollected + @Discount)
Select @INVWriteoffAmt = dbo.Fn_Get_WriteoffAmt_Decimal(@ColWriteoff)

IF @AmtCollected = (@INVBalance - @INVWriteoffAmt) and @Discount <= 0
BEGIN
IF @WriteOff_Validation = '1' and @INVWriteoffAmt > @Writeoff
BEGIN
Set @Error= @DocRefError + '- Decimal WriteOff amount [' + Cast(@INVWriteoffAmt as nvarchar(30)) + '] is greater than writeoff amount set in a tools option[' + Cast(@Writeoff as nvarchar(30)) + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
Set @FullyAdjust = 1
END

IF (@Discount > 0 and (@Discount + @INVWriteoffAmt) >  @Writeoff) and @WriteOff_Validation = '1'
BEGIN
Set @Error= @DocRefError + '- Discount(Decimal WriteOff) amount [' + Cast(@Discount + @INVWriteoffAmt as nvarchar(30))  + '] is greater than writeoff amount [' + Cast(@Writeoff as nvarchar(30)) + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

IF @Discount > 0 and (@AmtCollected < (@INVBalance - (@INVWriteoffAmt + @Discount))) and @Allow_Coll_Fulladjust = '1'
BEGIN
Set @Error= @DocRefError + 'has Discount(Decimal WriteOff) amount [' + Cast(@Discount + @INVWriteoffAmt as nvarchar(30))  + '] and Collection amount [' + Cast(@AmtCollected as nvarchar(30)) + '] is less than (balance[' + Cast(@INVBalance as nvarchar(30)) + '] - discount[' + Cast(@Discount as nvarchar(30)) + ']) amount.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

IF @AmtCollected > (@INVBalance - @Discount)
BEGIN
Set @AdjustedAmt = @INVBalance - @Discount
Set @ExtraCol = @AmtCollected - @AdjustedAmt

Set @Error= @DocRefError + '- Collected amount [' + Cast(@AmtCollected as nvarchar(30))  + '] exceeds balance [' + Cast(@AdjustedAmt as nvarchar(30)) + '](after discount) of invoice. So remaining amount will be made as advanced collection.'
Set @WarningMessage = @Error
Set @FullyAdjust = 1
END
ELSE
BEGIN
Set @AdjustedAmt = @AmtCollected
IF @Discount > 0 and (@Allow_Coll_Fulladjust = '1' or @AmtCollected = ((@INVBalance - @INVWriteoffAmt) - @Discount))
Set @FullyAdjust = 1
IF @FullyAdjust = 0
BEGIN
Set @INVWriteoffAmt = 0
END
Set @ExtraCol = 0
END

END
END
ELSE
BEGIN
Set @Error= @DocRefError + '- InvoiceID [' + @DocumentID + '] is not found.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

END
Set @INVBalance = 0

IF @DocType <> 1
BEGIN
Set @INVDocid = 0
Set @InvDate = Null
Set @INVPaymentDate = Null
Set @InvNetvalue = 0
Set @Discount = 0
Set @DocRef = @SerialNo
Set @ExtraCol = @AmtCollected
END
ELSE
Set @DocRef = @SerialNo

IF @PaymentMode = 1 or @PaymentMode = 2
BEGIN
IF @PaymentMode = 1
Set @ChequeMode = 'Cheque'
ELSE
Set @ChequeMode = 'DD'

IF isnull(@ChequeDate,'') = ''
BEGIN
Set @Error= @DocRefError + '- ' + @ChequeMode + ' date is empty.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

IF isnull(@BankCode,'') = ''
BEGIN
Set @Error= @DocRefError + '- Bank code is empty.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

IF isnull(@BranchCode,'') = ''
BEGIN
Set @Error= @DocRefError + '- Branch code is empty.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

IF isnumeric(@ChequeNumber) = 0
BEGIN
Set @Error= @DocRefError + 'has empty ' + @ChequeMode + ' number.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

IF  CharIndex('.', @DocumentID, 1) > 0
BEGIN
Set @Error= @DocRefError + 'Invalid ' + @ChequeMode + ' number.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

IF NOT (@ChequeNumber > cast(0 as nvarchar(100)) and  isnumeric(@ChequeNumber) = 1)
BEGIN
Set @Error= @DocRefError + 'has invalid ' + @ChequeMode + ' number [' + @ChequeNumber + '].'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END

IF @PaymentMode = 1
BEGIN
IF (Select dbo.Fn_Cheque_Expired(@ChequeDate,@CollectionDate)) = 1
BEGIN
Set @Error= @DocRefError + '- Expired cheque [Date ' + Cast(@ChequeDate As nVarChar)+ '] is not allowed.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
END
ELSE
BEGIN
IF dbo.Striptimefromdate(@ChequeDate) > @StripCollectionDate
BEGIN
Set @Error= @DocRefError + '- DD date [' + Cast(@ChequeDate As nVarChar) + '] is greater than Collection date [' + Cast(@StripCollectionDate As nVarChar) + ']. Post-Dated DD is not allowed.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
END

--Bank Check
Declare @BankStatus nVarchar(50)
Declare @BankErr nVarchar(100)

Select @BankStatus = Case When Count(BankCode) = 0 then 'invalid bank code [' +
(Case When @BankCode = '' then 'empty' else @BankCode end) + '].' else '' end
From BankMaster Where BankCode = @BankCode
IF isNull(@BankStatus,'') = ''
Select @BankStatus = Case When Count(BranchCode) = 0 then 'invalid branch code [' +
(Case When @BranchCode = '' then 'empty' else @BranchCode end)   + '].' else '' end
From BranchMaster Where BranchCode = @BranchCode and BankCode = @BankCode

Select @BankErr = IsNull(@BankStatus,'')

IF isnull(@BankErr,'') <> ''
BEGIN
Set @Error= @DocRefError + 'has ' + @BankErr
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
END
END
ELSE
BEGIN
Set @BankCode = ''
Set @BranchCode = ''
Set @ChequeDate = @StripCollectionDate
Set @ChequeNumber = ''
END

If Not exists(select * From Collections where DocReference =@DocRef)
Begin
If (Select count(*) From Collections where DocReference =@DocRef) = 0
Begin
IF Not Exists(Select 'x' From #tmpCollectionSerial Where SerialNO = @SerialNo)
Begin
Begin Tran

Set @AbsEntry = 0
Set @DetEntry = 0

If @BeatID Is Null
Select @UpdBeatID = ISNULL(BeatID, 0) from Beat_Salesman where CustomerID = @CustomerID
Else
Set @UpdBeatID = @BeatID

If @AmendmentFlag = 0
Begin

Select @UpdDocID = DocumentID from DocumentNumbers where Doctype = 12
Update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 12

SET @UpdDocID = @ColPrefix + @UpdDocID
End
Else
Begin
SET @UpdDocID = @AmendmentDocID
End





--if not exists(select * from Collections where DocReference =@DocRef)
--begin
Insert Into Collections(FullDocID, DocumentDate, Value, Balance, PaymentMode, ChequeNumber, ChequeDate, ChequeDetails,
CustomerID, SalesmanID, BankCode, BranchCode, BeatID, DocReference, OriginalCollection, BankID,
CardHolder, CreditCardNumber, CustomerServiceCharge, ProviderServiceCharge,PaymentModeID)
Values (@UpdDocID, @CollectionDate, @AmtCollected, @ExtraCol, @PaymentMode, @ChequeNumber, @ChequeDate, Null,
@CustomerID, @SalesmanID, @BankCode, @BranchCode, @UpdBeatID, @DocRef, @OriginalCollection, @BankID,
@CardHolder, @CreditCardNumber, @CustomerServiceCharge, @ProviderServiceCharge, @PaymentModeID)

--end

--		IF @@ERROR <> 0
--		BEGIN
--			ROLLBACK TRAN
--			Set @Error= @DocRefError + '- Unable to update collections.'
--			Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
--			exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
--			Goto NextCollection
--		END

Select @ColIdentity = @@IDENTITY
If @ColIdentity > 0
Begin
Set @AbsEntry = 1
Exec sp_Update_TransactionSerial @ColTranType, '', @ColIdentity, @UpdDocID

IF @DocType = 1
BEGIN
IF @Allow_Coll_Fulladjust = '1'
Set @Flag = 0
Else
Set @Flag = 1

IF @GSTFlag = 0
Set @InvPrefixDoc = @InvPrefix + Cast(@INVDocid as nvarchar(20))
Else
Set @InvPrefixDoc = @GSTFullDocID

Set @DiscWriteoff = @Discount + @INVWriteoffAmt
Set @DiscPerc = ((@Discount * 100) / @InvNetvalue)
Set @UpdDocumentID = Cast(@DocumentID as int)

Exec sp_insert_CollectionDetail @ColIdentity, @UpdDocumentID, 4, @InvDate, @INVPaymentDate, @AdjustedAmt
,@InvPrefixDoc, @InvNetvalue, 0, @FullyAdjust, @DiscWriteoff, @InvDocRef, @DiscPerc, @Flag
Set @DetEntry = 1
Exec sp_Update_DocAdj_CollAmt @ColIdentity

END

IF @StripCollectionDate < dbo.Striptimefromdate(Getdate())
BEGIN
Exec sp_acc_gj_collections @ColIdentity, @CollectionDate
END
ELSE
Exec sp_acc_gj_collections @ColIdentity, Null


If (Select Top 1 TransactionDate  from Setup ) < @CollectionDate And @CollectionDate <= GETDATE()
exec sp_set_transaction_timestamp @CollectionDate
Else
Begin
Declare @SysDate DateTime
Set @SysDate = GETDATE()
exec sp_set_transaction_timestamp @SysDate
End

Declare @ColStatus int
Create Table #UpdateCollection(ColStatus int)
insert into #UpdateCollection(ColStatus)
Exec sp_han_update_ProcessedCollection @SerialNo, 1, @ColIdentity
Select Top 1 @ColStatus=ColStatus from #UpdateCollection
Drop Table #UpdateCollection

If @ColStatus <> 1
BEGIN
Set @Error=@DocRefError + '- Unable to update collections.'
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
--GOTO NextCollection
END

Insert Into HandHeldCollProcessLog (Collection_Serial,AbstractInsert,DetailInsert) Values(@DocRef,@AbsEntry ,@DetEntry)

IF isnull(@WarningMessage,'') <> ''
BEGIN
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Processed',@WarningMessage,@SalesmanID
END

Insert Into #tmpCollectionSerial (SerialNO) Values (@SerialNo)

End
Else --If @ColIdentity > 0
Begin
Set @Error= 'Collection SerialNo (' + @SerialNo + ') is unable to insert in collections.'
BEGIN TRAN
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
End

Commit Tran
End
Else --IF Not Exists(Select 'x' From #tmpCollectionSerial Where SerialNO = @SerialNo)
Begin
Set @Error= 'Collection SerialNo (' + @SerialNo + ') is already available. in collections'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
End
End
Else  --If (Select count(*) From Collections where DocReference =@DocRef) = 0
Begin
Set @Error= 'Collection SerialNo (' + @SerialNo + ') is already available in collections.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
End
End
Else --if not exists(select * from Collections where DocReference =@DocRef)
Begin
Set @Error= 'Collection SerialNo (' + @SerialNo + ') is already Exist. in collections.'
BEGIN TRAN
Exec sp_han_update_ProcessedCollection @SerialNo, 2, 0
Update #tmpCollection Set Rejected=1 where SerialNo=@SerialNo
exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto NextCollection
End
NextCollection:

Delete From #tmpSalesman

Set @Row = @Row + 1

--Fetch Next from xCollections into @SerialNo, @DocumentID, @CollectionDate, @AmtCollected, @PaymentMode1, @ChequeNumber,
--@ChequeDate, @CustomerID, @BeatID, @BankCode, @BranchCode, @CollectionFlag, @Discount, @SerialNoCount
END
--Close xCollections
--Deallocate xCollections
End
Insert Into HandHeldCollProcessTrace (InsType,SerialNO,DocumentID,CollectionDate,AmtCollected,PaymentMode,ChequeNumber,ChequeDate,CustomerID
,SalesManID,BeatID,BankCode,BranchCode,CollectionFlag,Discount,SerialNoCount,Rejected)
Select 2,SerialNO,DocumentID,CollectionDate,AmtCollected,PaymentMode,ChequeNumber,ChequeDate,CustomerID
,SalesManID,BeatID,BankCode,BranchCode,CollectionFlag,Discount,SerialNoCount,Rejected
From #tmpCollection

Drop Table #Prefix
Drop Table #tmpSalesman
Drop Table #tmpCollection
Drop Table #DaycloseConfig
Drop Table #tmpCollectionSerial

END TRY
BEGIN CATCH
Declare @ErrorNo nvarchar(2000)
Set @ErrorNo=@@Error
If @@TRANCOUNT >0
BEGIN
ROLLBACK TRAN
END
--Deadlock Error
If @ErrorNo='1205'
Exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted','Deadlocked... Application will retry to process',@SalesmanID
If @ErrorNo<>'1205'
BEGIN
Declare @err nvarchar(4000)
Set @err='Error Executing the procedure: '+cast(@ErrorNo as nvarchar(2000))
Update Collection_Details Set Processed=2 Where Collection_Serial=@SerialNo
Exec sp_han_InsertErrorlog @SerialNo,2,'Information','Aborted',@err,@SalesmanID
END
END CATCH
END
