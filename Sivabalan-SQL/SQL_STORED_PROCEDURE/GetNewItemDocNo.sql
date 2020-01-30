Create Procedure GetNewItemDocNo
As
Declare @DocumentID int
Begin Tran
Update DocumentNumbers Set DocumentID = DocumentID + 1 Where DocType = 29
Select @DocumentID = DocumentID - 1 From DocumentNumbers where DocType = 29
Commit Tran
Select @DocumentID
