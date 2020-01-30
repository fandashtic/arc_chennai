
create procedure sp_get_creditterm(@Credit_ID as int) as
select Description, Type, Value from CreditTerm where CreditID = @Credit_ID

