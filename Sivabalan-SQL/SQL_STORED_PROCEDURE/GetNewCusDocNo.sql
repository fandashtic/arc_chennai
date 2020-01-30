CREATE procedure GetNewCusDocNo
As
Declare @DocumentID int
Begin Tran
Update DocumentNumbers Set DocumentID = DocumentID + 1 Where DocType = 32
Select @DocumentID = DocumentID - 1 From DocumentNumbers where DocType =32 
Commit Tran
Select @DocumentID

