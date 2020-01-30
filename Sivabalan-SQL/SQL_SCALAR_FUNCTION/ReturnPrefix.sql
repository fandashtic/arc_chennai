
CREATE function ReturnPrefix(@documenttype integer)
returns nvarchar(10)
as

begin
DECLARE @prefix nvarchar(10) 

DECLARE @JOURNALINVOICE INTEGER
DECLARE @JOURNALBILL INTEGER
DECLARE @JOURNALSALESRETURN INTEGER
DECLARE @JOURNALPURCHASERETURN INTEGER
DECLARE @JOURNALCOLLECTIONS INTEGER
DECLARE @JOURNALPAYMENTS INTEGER
DECLARE @JOURNALDEBITNOTE INTEGER
DECLARE @JOURNALCREDITNOTE INTEGER

DECLARE @JOURNALAPV INTEGER
DECLARE @JOURNALARV INTEGER
DECLARE @JOURNALOTHERPAYMENTS INTEGER
DECLARE @JOURNALOTHERRECEIPTS INTEGER


SET @JOURNALINVOICE =28
SET @JOURNALBILL =30
SET @JOURNALSALESRETURN =29
SET @JOURNALPURCHASERETURN =31
SET @JOURNALCOLLECTIONS =32
SET @JOURNALPAYMENTS =33
SET @JOURNALDEBITNOTE =34
SET @JOURNALCREDITNOTE =35


SET @JOURNALAPV = 60
SET @JOURNALARV = 61
SET @JOURNALOTHERPAYMENTS = 62
SET @JOURNALOTHERRECEIPTS = 63

if @documenttype = @JOURNALINVOICE or @documenttype = @JOURNALSALESRETURN  
begin
	select @prefix = Prefix from voucherprefix
	where TranID = 'INVOICE'
end
else if @documenttype = @JOURNALBILL
begin
	select @prefix = Prefix from voucherprefix
	where TranID = 'BILL'
end
else if @documenttype = @JOURNALPURCHASERETURN 
begin
	select @prefix = Prefix from voucherprefix
	where TranID = 'STOCK ADJUSTMENT PURCHASE RETURN'
end
else if @documenttype = @JOURNALCOLLECTIONS 
begin
	select @prefix = Prefix from voucherprefix
	where TranID = 'COLLECTIONS'
end
else if @documenttype = @JOURNALPAYMENTS 
begin
	select @prefix = Prefix from voucherprefix
	where TranID = 'PAYMENTS'
end
else if @documenttype = @JOURNALDEBITNOTE 
begin
	select @prefix = Prefix from voucherprefix
	where TranID = 'DEBIT NOTE'
end
else if @documenttype = @JOURNALCREDITNOTE
begin
	select @prefix = Prefix from voucherprefix
	where TranID = 'CREDIT NOTE'
end
else if @documenttype = @JOURNALAPV
begin
	select @prefix = Prefix from voucherprefix
	where TranID = 'ACCOUNTS PAYABLE VOUCHER'
end
else if @documenttype = @JOURNALARV
begin
	select @prefix = Prefix from voucherprefix
	where TranID = 'ACCOUNTS RECEIVABLE VOUCHER'
end
else if @documenttype = @JOURNALOTHERPAYMENTS
begin
	select @prefix = Prefix from voucherprefix
	where TranID = 'FA PAYMENTS'
end
else if @documenttype = @JOURNALOTHERRECEIPTS
begin
	select @prefix = Prefix from voucherprefix
	where TranID = 'FA COLLECTIONS'
end
return @prefix
end









