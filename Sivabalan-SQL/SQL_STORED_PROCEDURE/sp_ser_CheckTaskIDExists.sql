CREATE procedure sp_ser_CheckTaskIDExists(@JobCardID int,@TaskID nvarchar(255),@ProductCode nvarchar(15),                    
@Item_spec1 nvarchar(255))
As                                
	select serialNo from JobCardTaskAllocation
	where TaskID = @TaskID and JobCardID = @JobCardID
	and isNull(TaskStatus,0) in (0,1,2)
	and Product_code = @ProductCode and Product_Specification1 = @Item_spec1
