CREATE procedure sp_ser_rpt_TimeDiscrepancyDetail(@Item nVarchar(255))
as
Declare @ParamSep nVarchar(2),@tmpStr nVarchar(255),@Pos as Int
Declare @JobCardID Int, @Item_SpecValue nVarchar(50)
Set @ParamSep = Char(2)

Set @tmpStr = @Item
--JobCard ID Extraction
Set @Pos = CHARINDEX(@ParamSep,@tmpStr,1)
Set @JobCardID = Cast(SubString(@tmpStr, 1, @Pos - 1) as Int)
--Item specification1  Extraction
Set @Item_SpecValue = SubString(@tmpStr, @Pos + 1, len(@Item))

Select TA.TaskID,"Task ID"=TA.TaskID,"Task Description"=TM.Description,"Assign To"=PM.PersonnelName,
"Task Status"=(Case isNull(TA.TaskStatus,0) when 0 then 'Task not Assigned' --to display relevant status of task
					when 1 then 'Assigned'
					when 2 then 'Closed'
					else ''
					end),
"Start Work"=(Case isNull(TA.Startwork,0) when 0 then 'No'
					when 1 then 'Yes'
					else ''
					end),
"Start Date" = TA.StartDate,"Start Time"=dbo.sp_ser_StripTimeFromDate(TA.StartTime),
"End Date" = TA.EndDate,"End Time"=dbo.sp_ser_StripTimeFromDate(TA.EndTime)
from JobCardTaskAllocation TA
Inner Join TaskMaster TM on TA.TaskID=TM.TaskID and
--to neglect task cancelled, rework and reassigned
(isNull(TA.TaskStatus,0)<>3 and isNull(TA.TaskStatus,0)<>4 and isNull(TA.TaskStatus,0)<>5)
Left Outer Join PersonnelMaster PM on TA.PersonnelID=PM.PersonnelID
where TA.JobCardID=@JobCardID and TA.Product_Specification1=@Item_SpecValue

