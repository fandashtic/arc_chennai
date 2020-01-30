Create Procedure sp_get_MailInfo (@MailID int)
As
Select CustomerID, VendorID, Message, CreationDate, DocPrefix + Cast(DocumentID As nvarchar),
Subject From MailMessage Where ID = @MailID

