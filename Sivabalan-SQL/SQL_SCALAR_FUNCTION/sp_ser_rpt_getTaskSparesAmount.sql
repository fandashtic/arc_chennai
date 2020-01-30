CREATE Function sp_ser_rpt_getTaskSparesAmount         
(@EstimationID as int, @Itemspec1 as nvarchar(255), @Type as Int, @ServiceID as nvarchar(15),         
@Mode int)        
Returns decimal(18,6)        
as            
Begin        
declare @Amount as decimal(18,6)        
If @Type = 2 and @Mode = 1 /* Task = 2 for Task */        
Begin       
	select @Amount = sum(EstimationDetail.Netvalue) from Estimationdetail          
	where EstimationID = @Estimationid   
	and Product_specification1 = @Itemspec1  
	and TaskID = @ServiceID  and Type = @Type and Isnull(Taskid,'') <> '' and Isnull(sparecode,'') = ''  
	group by Taskid, type                                         
End        
Else if  @Type = 2 and @Mode = 2/* Task = 2 for Task */      
Begin     
	select @Amount = sum(EstimationDetail.Netvalue) from Estimationdetail        
	where EstimationID = @Estimationid
	and Product_specification1 = @Itemspec1
	and TaskID = @ServiceID  and Type = 2 and Isnull(sparecode,'') <> '' 
	group by Taskid, type                                       
End      
Return @Amount      
end    



