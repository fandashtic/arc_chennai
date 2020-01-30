Create Procedure sp_get_ReceivedMailInfo (@MailID int)
As
Select CreationDate, 
Case IsNull(Sender, '')
When '' then
ForumID
Else
Sender
End,
Subject,
Message From ReceivedMail Where ID = @MailID