CREATE Procedure sp_ser_PersonnelDetail (@personnelID varchar(30)) 
as
Declare @Prefix nvarchar(15)
select @Prefix = Prefix from VoucherPrefix where [TranID]='JOBCARD'

Select 'PersonnelID' = PersonnelMaster.PersonnelID, 'PersonnelName' = Personnelname,
IsNull(J.TaskID, 'Task Not Assigned') 'TaskID', isnull([Description], '') 'Description', 
J.StartDate, J.StartTime, J.Startwork,
isnull(J.CardID, '') 'JobCardID', J.JobcardDate, personnelmaster.Active, 
(Case when Isnull(J.TaskID, '') = '' then '0' else 1 end) Flag
from personnelmaster
left Outer Join (Select Jobcardtaskallocation.PersonnelID 'ID', TaskMaster.TaskID , [Description], StartDate, 
	StartTime, (isnull(@Prefix, '') +  isnull(cast(Jobcardabstract.DocumentID as varchar(15)), '')) 'CardID', 
	JobcardDate, (case Isnull(Startwork, 0) when 0 then 'No' else 'Yes' end) 'Startwork'
	from Jobcardtaskallocation 
	Inner Join JobCardabstract On JobCardabstract.JobcardID = Jobcardtaskallocation.JobCardID
	Inner Join TaskMaster On TaskMaster.TaskID = Jobcardtaskallocation.TaskID
	Where isnull(Jobcardtaskallocation.taskstatus,0) = 1 and 
	Jobcardtaskallocation.PersonnelID = (Case Isnull(@personnelID, '') when '' then Jobcardtaskallocation.PersonnelID else
	Isnull(@personnelID, '') end)) as J On ID = PersonnelMaster.PersonnelID
Where 
PersonnelMaster.PersonnelID = (Case Isnull(@personnelID, '') when '' then PersonnelMaster.PersonnelID else 
Isnull(@personnelID, '') end) Order by Flag, 2 asc, 5 desc


