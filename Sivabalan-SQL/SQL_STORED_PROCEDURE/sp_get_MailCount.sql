Create Procedure sp_get_MailCount
As
Select Count(*) From ReceivedMail Where IsNull(Status, 0) = 0
