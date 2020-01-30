CREATE procedure sp_ser_rpt_TaskStatusDatewiseAbstract(@Fromdate datetime,@Todate datetime,@Status nVarchar(50)='%')
as
Declare @ParamSep nVarchar(2)
Declare @Stat nVarchar(50),@Mode Int

set @ParamSep = Char(2)
set @Stat = LOWER(@Status)

if @Stat='not assigned'
	Set @Mode = 0
else if @Stat='assigned'
	Set @Mode = 1
else if @Stat='closed'
	Set @Mode = 2
else if @Stat='cancelled'
	Set @Mode = 3
else if @Stat='%'
	Set @Mode = 6


select Cast(TA.JobCardID as nVarchar(20))+ @ParamSep + TA.TaskID + @ParamSep + TA.Product_specification1 + @ParamSep + Cast(TA.SerialNo as nVarchar(20)),TA.TaskID,
"Task Description"=TM.Description,
"Status" = (Case @Mode when 1 then 'Assigned' --Case for only task assigned
					else (Case isNull(TA.TaskStatus,0) when 0 then 'Task Not Assigned'
					  when 1 then 'Assigned'
					  when 2 then 'Closed'
					  when 3 then 'Cancelled'
					  else ''
					end)
					end),
"Assigned To" = isNull(PM.PersonnelName,''),
"Start Work" = 	(Case isNull(TA.StartWork,0) when 0 then 'No'
						 when 1 then  'Yes'
						 else ''
						end),
"Start Date" = StartDate,
"Start Time" = isnull(dbo.sp_ser_StripTimeFromDate(Starttime),''),
"End Date" = EndDate,
"End Time" = isnull(dbo.sp_ser_StripTimeFromDate(Endtime),'')
from JobCardTaskAllocation TA
inner join JobCardAbstract JCA on JCA.JobCardID=TA.JobCardID
and (IsNull(JCA.Status, 0) & 192) = 0 
inner join TaskMaster TM on TA.TaskID=TM.TaskID
Left Outer Join PersonnelMaster PM on TA.PersonnelID=PM.PersonnelID
-- To retrieve Task not assigned information
where ( ( @Mode = 0 OR @Mode = 6 ) AND isNull( TA.TaskStatus,0 ) = 0 and JCA.JobCardDate between @FromDate AND @ToDate ) 
 -- To retrieve Task assigned and Closed on date given
OR ( ( @Mode = 1 OR @Mode = 6 ) AND ( isNull( TA.TaskStatus,0 ) = 1 or ( isNull(TA.TaskStatus,0) = 2 ) ) AND ( TA.StartDate between @FromDate AND @ToDate OR ( TA.StartDate is NULL AND JCA.JobCardDate between @FromDate AND @ToDate ) ) )
 --To retrieve Task closed information
OR ( ( @Mode = 2  OR @Mode = 6) AND isNull( TA.TaskStatus,0 ) = 2 AND TA.EndDate BETWEEN @FromDate AND @ToDate )
 --To retrieve Task Cancelled information
OR ( ( @Mode = 3 OR @Mode = 6) AND isNull( TA.TaskStatus,0 ) = 3 AND ( TA.StartDate BETWEEN @FromDate AND @ToDate OR ( TA.StartDate is NULL AND JCA.JobCardDate between @FromDate AND @ToDate ) ) )


