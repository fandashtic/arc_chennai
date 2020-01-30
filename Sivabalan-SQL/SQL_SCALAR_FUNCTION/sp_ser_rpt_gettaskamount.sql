CREATE Function sp_ser_rpt_gettaskamount
(@EstimationID as int, @Itemspec1 as nvarchar(255), @Type as Int, @ServiceID as nvarchar(15), 
@Mode as int)
Returns decimal(18,6)
as
/* 
	@Type -- Service Type 
	@ServiceID -- Either JobID or TaskID 
*/ 

Begin
declare @Amount as decimal(18,6)

	 If @Type = 2 /* Task = 2 for Task */
        Begin 
		select @Amount = sum(Netvalue)  from Estimationdetail  
		where EstimationID = @EstimationID
		and Product_specification1 = @Itemspec1
		and TaskID = @ServiceID
		and (Case When @Mode = 1 then TaskID 
		when (@Mode = 2 and (IsNull(sparecode,'') <> '')) then TaskID 
		else '' end)  = TaskID
		and (Case When @Mode = 2 then sparecode else '' end) = Sparecode
		group by TaskID
	End
 	else If @Type = 1 --/* Type = 1 for Job */
	Begin
		select @Amount = sum(Netvalue)  from Estimationdetail  
		where EstimationID = @EstimationID
		and Product_specification1 = @Itemspec1
		and JobID = @ServiceID
		and (Case When @Mode = 1 then TaskID 
		when (@Mode = 2 and (IsNull(sparecode,'') <> '')) then TaskID 
		else '' end)  = TaskID
		and (Case When @Mode = 2 then sparecode else '' end) = Sparecode
		group by jobid
	end 
Return @Amount
End




