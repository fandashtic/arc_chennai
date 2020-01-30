CREATE Procedure sp_ser_CheckIssueStatus(@IssueID as int)
as  
	
		Select "Status" = 'cancelled' from IssueAbstract where IssueID = @IssueID and (isNull(Status,0) & 192) = 192
