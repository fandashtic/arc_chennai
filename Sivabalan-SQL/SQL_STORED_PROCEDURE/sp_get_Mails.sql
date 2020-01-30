Create Procedure sp_get_Mails (@Read int)
As
Select DocumentID, CreationDate, Case IsNull(Sender, '')
When '' then
ForumID
Else
Sender
End,
Subject,
Message,
ID, DocumentDate From ReceivedMail Where IsNull(Status, 0) = @Read