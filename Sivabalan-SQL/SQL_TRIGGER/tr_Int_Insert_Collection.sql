CREATE TRIGGER [tr_Int_Insert_Collection] ON dbo.[Collections]
FOR INSERT AS 
BEGIN 
	Insert Into Collection_Action (Collection_Action.CollectionID, Collection_Action.Integration_ID) 
		(Select DocumentID, 'FOR_' + Convert(varchar, DocumentID) from Inserted)
END
