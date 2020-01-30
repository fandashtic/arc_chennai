CREATE procedure sp_ser_TaskStartedStatus(@SerialNo Int,@Mode int,@PersonnelName nVarchar(255)=NULL,@Date nVarchar(50)=NULL,@Time nVarchar(50)=NULL)  --1 = Task Allocation, 2 = Close Task
As
Declare @lPerssonelName nVarchar(255)


select "Status" = (Case isNull(JCTA.TaskStatus,0)
		when 1 then (Case @Mode
						when 2 then 
							Case isNull(JCTA.Startwork,0)
							when 0 then 'Work has not been started'
							else '' end 
						when 1 then isNull('Task is already assigned to ' + NullIF(NullIF(IsNull((select personnelName from 
						PersonnelMaster where PersonnelID = JCTA.Personnelid and @PersonnelName is Not Null),''),@PersonnelName),''),'')
					else '' end)
		when 2 then 
			Case @Mode
			when 1 then 'Task is already assigned and closed'
			else ''
			end
		else coalesce((select (Case 
					 when IsNull(I_JCTA.TaskStatus,0) = 2 then ''
					 when IsNull(JCTA.TaskStatus,0) = 4 then 'Reassigned '
					 when IsNull(JCTA.TaskStatus,0) = 5 then 'Reworked '
					 end)
					+
					(Case IsNull(I_JCTA.TaskStatus,0)
					when 0 then 'Task is pending'
					when 1 then 'Task has been assigned to ' + Isnull(PM.Personnelname, 'personnel') + 
							(case IsNull(I_JCTA.Startwork, 0) 
							when 0 then ' and the work has not been started' 
							else ''
							end)
					when 2 then (Case IsNull(JCTA.TaskStatus,0)
								when 3 then 'Task is cancelled'
								when 4 then 'Task has been reassigned'
								when 5 then 'Task is made as rework'
								end)
					end)
						from JobCardTaskAllocation I_JCTA
						Left Outer Join PersonnelMaster PM on I_JCTA.PersonnelID = PM.PersonnelID
						where JCTA.Jobcardid = I_JCTA.JobCardID and IsNull(I_JCTA.TaskStatus,0) In (0,1,2)
						and JCTA.Product_Code= I_JCTA.Product_Code and JCTA.TaskID = I_JCTA.TaskID
						and JCTA.Product_specification1 = I_JCTA.Product_specification1),'Task is cancelled')
		end ),
		"PasswordFlag"= (Case @Mode
						When 1 then 
							Case
							when (StartDate is not Null and 
							(StartDate <> @Date or StartTime <> @Time)) 
							or (StartDate is not Null and @Date is Null)
							or (StartTime is not Null and @Time is Null) then 'Yes'
							else 'No'
							end
						when 2 then 
							Case
							when (Startdate >= @Date and StartTime > @Time) then 'EndTime cannot be less than the Start time '
							when (EndDate is not Null and 
							(EndDate <> @Date  or EndTime <> @Time)) 
							or (EndDate is not Null and @Date is Null)
							or (EndTime is not Null and @Time is Null) then 'Yes'
							else 'No'
							end
						else ''
		end),
		StartTime
	from Jobcardtaskallocation JCTA
	where IsNull(JCTA.TaskStatus,0) In (1,2,3,4,5)
 	and SerialNo = @SerialNo

