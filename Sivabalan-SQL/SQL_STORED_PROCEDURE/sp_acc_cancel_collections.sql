CREATE Procedure sp_acc_cancel_collections (@CollectionID int,@Denomination nvarchar(50))
as 

update collections set Denomination = @Denomination ,status = (isnull(status,0) | 192) where collections.documentid = @collectionid






