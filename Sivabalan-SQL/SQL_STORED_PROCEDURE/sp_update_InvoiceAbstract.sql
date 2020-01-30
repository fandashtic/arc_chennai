CREATE procedure sp_update_InvoiceAbstract(            
@Inv_Type int,             
@Inv_Date datetime,                
@Customer nvarchar(15),             
@UserName nvarchar(50),             
@GrossValue Decimal(18,6),             
@DisPer Decimal(18,6),                
@DisValue Decimal(18,6),             
@NetValue Decimal(18,6),             
@Address nvarchar(255),             
@FLAGS int,             
@ReferredBY int,                
@PaymentMode int,             
@PayInfo nvarchar(255),            
@AmountRecd Decimal(18,6) = 0,                 
@Memo nvarchar(255) = N'',             
@Status int = 0,             
@SalesmanID int = 0,                
@RoundOff Decimal(18,6),            
@skip int=1,            
@ServiceCharge nvarchar(255)=N'',          
@TaxOnMRP Decimal(18,6) = 0,          
@InvSchemeID Integer = 0, @InvSchemeDisc Decimal(18,6) = 0, @InvSchemeVal Decimal(18,6) = 0,  
@Balance decimal(18,6)=0,
@VatTaxAmount decimal(18,6)=0
,@OperatingYear nvarchar(50)
,@OldInvID int)                  
             
as            

Declare @FromStateCode int
Declare @ToStateCode int
Declare @GSTIN nvarchar(30)
Declare @GSTFlag int
Declare @GSTDocID int
Declare @GSTFullDocID nvarchar(250)
Declare @GSTVoucherPrefix nvarchar(50)
Declare @Year as nvarchar(20)

Select @Year = Cast(Substring(@OperatingYear,3,3) as nvarchar) + Cast(Substring(@OperatingYear,8,2) as nvarchar)

Select Top 1 @FromStateCode = isnull(ShippingStateID,0) From Setup
Select @ToStateCode = isnull(BillingStateID,0), @GSTIN = GSTIN From Customer Where CustomerID = @Customer
Select @GSTFlag = isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'
    
DECLARE @DocumentID int                
IF(@Skip=1)              
Begin                
	Begin Tran                
	UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 4                
	SELECT @DocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 4

	IF @GSTFlag = 1
	Begin
--		UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 101
--		Select @GSTDocID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 101
--		Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'GST_INVOICE'
--		Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar(10))


		UPDATE GSTDocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 101 and OperatingYear = @OperatingYear
		Select @GSTDocID = DocumentID - 1 FROM GSTDocumentNumbers WHERE DocType = 101 and OperatingYear = @OperatingYear
		Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'GST_INVOICE'
		Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar(10))
	End                
	Commit Tran                
End              
Else              
Begin              
	Begin Tran                
	--UPDATE DocumentNumbers SET DocumentID = DocumentID - 1 WHERE DocType = 4                
	SELECT @DocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 4                

	IF @GSTFlag = 1
	Begin		
--		Select @GSTDocID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 101
--		Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'GST_INVOICE'
--		Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @OperatingYear + '/' + Cast(@GSTDocID as nvarchar(10))

		Select @GSTDocID = GSTDocID, @GSTFullDocID = GSTFullDocID From InvoiceAbstract Where InvoiceID = @OldInvID
	End
	Commit Tran               
 End              

IF(@ServiceCharge<>N'')            
	Insert Into InvoiceAbstract (InvoiceType, InvoiceDate, CustomerID, UserName,                 
	GrossValue, DiscountPercentage, DiscountValue, NetValue, CreationTime, Status,                 
	DocumentID, BillingAddress, Flags, ReferredBY, PaymentMode, PaymentDetails, AmountRecd,                
	ShippingAddress, SalesmanID, RoundOffAmount,ServiceCharge, TaxOnMrp, SchemeID, SchemeDiscountPercentage,SchemeDiscountAmount,
	ClaimedAmount, ClaimedAlready,Balance,VatTaxAmount, TaxDiscountFlag,FromStateCode,ToStateCode,GSTIN,GSTFlag,GSTDocID,GSTFullDocID)                 
	values (@Inv_Type, @Inv_Date, @Customer, @UserName, @GrossValue, @DisPer, @DisValue,                 
	@NetValue,  getdate(), @Status, @DocumentID, @Address, @FLAGS, @ReferredBY,                 
	@PaymentMode, @PayInfo, @AmountRecd, @Memo, @SalesmanID, @RoundOff,@ServiceCharge, @TaxOnMrp, @InvSchemeID, @InvSchemeDisc,
	@InvSchemeVal, 0, 0,@Balance, @VatTaxAmount, @Flags,@FromStateCode,@ToStateCode,@GSTIN,@GSTFlag,@GSTDocID,@GSTFullDocID)                
Else            
	Insert Into InvoiceAbstract (InvoiceType, InvoiceDate, CustomerID, UserName,                 
	GrossValue, DiscountPercentage, DiscountValue, NetValue, CreationTime, Status,                 
	DocumentID, BillingAddress, Flags, ReferredBY, PaymentMode, PaymentDetails, AmountRecd,                
	ShippingAddress, SalesmanID, RoundOffAmount, TaxOnMrp, SchemeID, SchemeDiscountPercentage, SchemeDiscountAmount,
	ClaimedAmount, ClaimedAlready,Balance,VatTaxAmount, TaxDiscountFlag,FromStateCode,ToStateCode,GSTIN,GSTFlag,GSTDocID,GSTFullDocID)                 
	values (@Inv_Type, @Inv_Date, @Customer, @UserName, @GrossValue, @DisPer, @DisValue,                 
	@NetValue,  getdate(), @Status, @DocumentID, @Address, @FLAGS, @ReferredBY,                 
	@PaymentMode, @PayInfo, @AmountRecd, @Memo, @SalesmanID, @RoundOff,@TaxOnMrp, @InvSchemeID, @InvSchemeDisc, @InvSchemeVal,
	0, 0,@Balance,@VatTaxAmount, @Flags,@FromStateCode,@ToStateCode,@GSTIN,@GSTFlag,@GSTDocID,@GSTFullDocID)                
                
SELECT @@IDENTITY, @DocumentID 

