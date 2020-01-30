


create procedure sp_acc_getcollectiondenomination(@collectionid integer)
as
select Denomination from Collections
where DocumentID =@collectionid






