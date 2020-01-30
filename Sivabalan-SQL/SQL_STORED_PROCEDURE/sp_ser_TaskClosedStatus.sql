CREATE procedure sp_ser_TaskClosedStatus(@SerialNo Int)
As

select "Status" = (Case isNull(JCTA.TaskStatus,0)
		when 2 then 'closed'
		when 5 then 'made as rework'
		else ''
		end )
	from Jobcardtaskallocation JCTA
	where SerialNo = @SerialNo

