CREATE Procedure sp_ser_CheckJobCardStatus(@DocumentID as int,@Mode int = 1)--1 = JobCardID and 2 = IssueID
as  
	
	if @Mode = 1
		Select "Status" = (case isNull(Status,0) & (64 | 32 | 128) --64 = Cancelled and 32 = Invoiced
				when 64 then 'Cancelled'
                when 128 then 'Amended'
				when 32 then  'Invoiced'
				else ''
				end)
		from JobCardAbstract where JobCardID = @DocumentID
	else if @Mode = 2 
		Select "Status" = (case isNull(JCA.Status,0) & (64 | 32 | 128) --64 = Cancelled and 32 = Invoiced
				when 64 then 'Cancelled'
                when 128 then 'Amended'
				when 32 then  'Invoiced'
				else ''
				end)
		from JobCardAbstract JCA
		Inner Join IssueAbstract IA on JCA.JobCardID = IA.JobCardID
		where IA.IssueID = @DocumentID
	
