CREATE procedure sp_acc_loadchequeinfo(@accountid int,@paymenttype int)
as
Declare @user nvarchar(50)
Declare @paymentmode nvarchar(50)
Declare @prefix nvarchar(10)

Declare @CHEQUE int
Declare @CREDITCARD int
Declare @COUPON int

Set @CHEQUE = 2
Set @CREDITCARD = 3
Set @COUPON = 4

select @prefix = Prefix from VoucherPrefix
where TranID = N'INVOICE'

select @user = UserName,@paymentmode = Value
from AccountsMaster,PaymentMode 
where AccountID = @accountid 
and PaymentMode.Mode = AccountsMaster.RetailPaymentMode
and PaymentMode.PaymentType =@paymenttype

set @paymentmode = rtrim(@paymentmode)
set @paymentmode = ltrim(@paymentmode)

if @paymenttype = @CHEQUE
begin
	select 'InvoiceID'= @prefix + cast(DocumentID as nvarchar(10)) ,InvoiceDate,
	'DocumentID' = InvoiceID,PaymentDetails,'PaymentMode'= @paymentmode from InvoiceAbstract 
	where UserName = @user and InvoiceType = 2 and (IsNull(Status,0) & 64) = 0 and (IsNull(Status,0) & 128) = 0 and     
	InvoiceID not in (select DocumentReference from ContraDetail,ContraAbstract 
	where DocumentType =1 and PaymentType = @CHEQUE and FromAccountID = @accountid
	and Isnull(Status,0)<>192 and ContraDetail.ContraID = ContraAbstract.ContraID)
	and PaymentDetails like N'%' + @paymentmode + N'%'
	--(select CollectionDetail.DocumentID from CollectionDetail,Collections 
	--where CollectionDetail.DocumentType =4 and Isnull(Status,0)<> 192 and CollectionDetail.CollectionID = Collections.DocumentID)   
end
else if @paymenttype = @CREDITCARD
begin
	select 'InvoiceID'= @prefix + cast(DocumentID as nvarchar(10)) ,InvoiceDate,
	'DocumentID' = InvoiceID,PaymentDetails,'PaymentMode'= @paymentmode from InvoiceAbstract 
	where UserName = @user and InvoiceType = 2 and (IsNull(Status,0) & 64) = 0 and (IsNull(Status,0) & 128) = 0 and
	InvoiceID not in (select DocumentReference from ContraDetail,ContraAbstract 
	where DocumentType =1 and PaymentType = @CREDITCARD and FromAccountID = @accountid
	and Isnull(Status,0)<>192 and ContraDetail.ContraID = ContraAbstract.ContraID)   
	and PaymentDetails like N'%' + @paymentmode + N'%'
end
else if @paymenttype = @COUPON
begin
	select 'InvoiceID'= @prefix + cast(DocumentID as nvarchar(10)) ,InvoiceDate,
	'DocumentID' = InvoiceID,PaymentDetails,'PaymentMode'= @paymentmode from InvoiceAbstract 
	where UserName = @user and InvoiceType = 2 and (IsNull(Status,0) & 64) = 0 and (IsNull(Status,0) & 128) = 0 and
	InvoiceID not in (select DocumentReference from ContraDetail,ContraAbstract 
	where DocumentType =1 and PaymentType = @COUPON and FromAccountID = @accountid 
	and Isnull(Status,0)<>192 and ContraDetail.ContraID = ContraAbstract.ContraID)   
	and PaymentDetails like N'%' + @paymentmode + N'%'
end
