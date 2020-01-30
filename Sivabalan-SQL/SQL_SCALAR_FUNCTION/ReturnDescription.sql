CREATE function ReturnDescription(@documenttype integer)
returns nvarchar(50)
as

begin
DECLARE @description nvarchar(50) 

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

DECLARE @JOURNALOTHERDEBITNOTE INTEGER
DECLARE @JOURNALOTHERCREDITNOTE INTEGER
DECLARE @MANUALJOURNAL_NEWREFERENCE INTEGER
DECLARE @CLAIMS INTEGER


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

SET @JOURNALOTHERDEBITNOTE = 79
SET @JOURNALOTHERCREDITNOTE = 80
SET @MANUALJOURNAL_NEWREFERENCE  = 81
SET @CLAIMS = 82

if @documenttype = @JOURNALINVOICE 
begin
	set @description = 'Invoice' 
end

else if  @documenttype = @JOURNALSALESRETURN  
begin
	set @description = 'Sales Return' 
end

else if @documenttype = @JOURNALBILL
begin
	set @description = 'Bill' 
end

else if @documenttype = @JOURNALPURCHASERETURN 
begin
	set @description = 'Purchase Return' 
end

else if @documenttype = @JOURNALCOLLECTIONS 
begin
	set @description = 'Collections' 
end

else if @documenttype = @JOURNALPAYMENTS 
begin
	set @description = 'Payments' 
end

else if @documenttype = @JOURNALDEBITNOTE 
begin
	set @description = 'Debit Note' 
end

else if @documenttype = @JOURNALCREDITNOTE
begin
	set @description = 'Credit Note' 
end
else if @documenttype = @JOURNALAPV
begin
	set @description = 'APV'
end
else if @documenttype = @JOURNALARV
begin
	set @description = 'ARV'
end
else if @documenttype = @JOURNALOTHERPAYMENTS
begin
	set @description = 'Other Payments'
end
else if @documenttype = @JOURNALOTHERRECEIPTS
begin
	set @description = 'Other Receipts'
end
else if @documenttype = @JOURNALOTHERDEBITNOTE 
begin
	set @description = 'Other Debit Note' 
end

else if @documenttype = @JOURNALOTHERCREDITNOTE
begin
	set @description = 'Other Credit Note' 
end
else if @documenttype = @MANUALJOURNAL_NEWREFERENCE
begin
	set @description = 'Manual Journal New Reference' 
end
else if @documenttype = @CLAIMS
begin
	set @description = 'Claims Note' 
end
return dbo.LookupDictionaryItem(@description,default)
end


