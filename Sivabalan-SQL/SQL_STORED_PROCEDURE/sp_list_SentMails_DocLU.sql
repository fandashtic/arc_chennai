Create Procedure sp_list_SentMails_DocLU (@FromDoc int,
				    @ToDoc int)
As
Select ID, DocPrefix + Cast(DocumentID as nvarchar), CreationDate, Subject 
From MailMessage
Where DocumentID Between @FromDoc And @ToDoc
