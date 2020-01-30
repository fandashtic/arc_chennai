Create Procedure mERPFYCP_get_MailCount ( @yearenddate datetime )
As
Select Count(*) From ReceivedMail Where IsNull(Status, 0) = 0 and DocumentDate <= @yearenddate
