CREATE Procedure sp_acc_Insert_BounceNote(@CollectionID INT,@NoteID INT,@Type INT)  
As  
Insert Into BounceNote (CollectionID,NoteID,Type)  
Values (@CollectionID,@NoteID,@Type)
