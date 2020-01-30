Create Procedure sp_list_SentMails (@FromDate datetime,
				    @ToDate datetime)
As
Select ID, DocPrefix + Cast(DocumentID as nvarchar), CreationDate, Subject 
From MailMessage
Where CreationDate Between @FromDate And @ToDate

