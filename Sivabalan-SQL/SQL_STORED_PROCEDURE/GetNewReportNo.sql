Create Procedure GetNewReportNo
As
Declare @DocumentID int
Begin Tran
Update DocumentNumbers Set DocumentID = DocumentID + 1 Where DocType = 26
Select @DocumentID = DocumentID - 1 From DocumentNumbers Where DocType = 26
Commit Tran
Select @DocumentID
