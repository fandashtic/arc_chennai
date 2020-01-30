Create function sp_mERP_getCollectionDocRefForTally
(@CollectionID int,@DocumentID int) Returns nvarchar(250)
AS 
BEGIN
Declare @ColID nvarchar(250)
if not exists(Select * from Collectiondetail where DocumentID=@DocumentID and DocumentType=3)
	Select @ColID= Rtrim(cast(col.DocumentID AS Varchar(10)))+'-'+col.FullDocId from collections col where col.documentid=@CollectionID
Else
	Select @ColID = Rtrim(cast(col.DocumentID AS Varchar(10)))+'-'+col.FullDocId from collections col
	Where Col.DocumentID =@DocumentID
Return @ColID
END
