CREATE procedure sp_ser_getjcminissuedate (@jobCardID as int)
as 
Select Min(IssueDate) IssueDate from IssueAbstract where JobCardId = @JobCardID


