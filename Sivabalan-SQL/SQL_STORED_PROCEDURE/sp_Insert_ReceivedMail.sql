CREATE procedure sp_Insert_ReceivedMail (@ForumID nvarchar(20),
					@Subject nvarchar(100),
					@Message nvarchar(3000),
					@DocumentID nvarchar(50),
					@DocDate datetime)
As
Declare @Sender nvarchar(20)

Select @Sender = CustomerID From Customer Where AlternateCode = @ForumID
Select @Sender = VendorID From Vendors Where AlternateCode = @ForumID

Insert into ReceivedMail(Sender, Subject, Message, DocumentID, DocumentDate, ForumID)
Values (@Sender, @Subject, @Message, @DocumentID, @DocDate, @ForumID)





