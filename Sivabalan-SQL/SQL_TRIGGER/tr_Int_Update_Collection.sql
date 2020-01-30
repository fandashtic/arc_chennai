CREATE TRIGGER [tr_Int_Update_Collection] ON dbo.[Collections]
FOR Update AS 
Begin
  Declare @Status int
  Declare @CollectionID int	

 Select @status = Status, @CollectionID = DocumentID from Inserted 

 If Exists (select * from Collection_Action where CollectionID  = @CollectionID and IsProcessed = 0 )
  Begin
	Delete from  Collection_Action Where CollectionID = @CollectionID and @status & 128 <> 0
  End	
 Else
  Begin
	Update 	Collection_Action Set Collection_Action.IsModified = 1, 
		Collection_Action.IsProcessed = 0 
	from Inserted where Collection_Action.CollectionID = @CollectionID
  End		
End
