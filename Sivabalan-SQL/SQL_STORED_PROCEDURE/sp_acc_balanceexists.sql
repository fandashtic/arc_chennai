


CREATE procedure sp_acc_balanceexists(@accountid integer)
as
Declare @openingbalance decimal(18,6)
Declare @status integer
select @openingbalance = isnull([OpeningBalance],0) from AccountsMaster
where [AccountID]= @accountid and isnull(Active,0)=1

if @openingbalance > 0
begin
	set @status =1
end
else
begin
	set @status =0
end

if exists(Select top 1 TransactionID from GeneralJournal where AccountID=@accountid)
begin
	set @status =1
end
select isnull(@status,0)












