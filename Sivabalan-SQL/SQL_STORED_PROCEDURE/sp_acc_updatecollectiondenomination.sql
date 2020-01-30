


create procedure sp_acc_updatecollectiondenomination(@collectionid integer,@denominations nvarchar(2000))
as
update Collections
set Denomination = @denominations
where DocumentID = @collectionid





