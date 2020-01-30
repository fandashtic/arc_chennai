CREATE procedure sp_acc_updateactualbankdate(@documentid int,@actualbankdate datetime,
@type int)
as
Declare @COLLECTIONS int
Declare @BOUNCECHEQUE int

Set @COLLECTIONS = 13
Set @BOUNCECHEQUE = 15

if @type = @COLLECTIONS 
begin
	Update GeneralJournal
	Set ActualBankDate = @actualbankdate,
	BRSCheck = 1
	where DocumentReference = @documentid
	and DocumentType = @COLLECTIONS
end
else if @type = @BOUNCECHEQUE
begin
	Update GeneralJournal
	Set ActualBankDate = @actualbankdate,
	BRSCheck = 1
	where DocumentReference = @documentid
	and DocumentType = @BOUNCECHEQUE
end






