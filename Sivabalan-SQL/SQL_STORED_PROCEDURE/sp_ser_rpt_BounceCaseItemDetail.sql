CREATE procedure [dbo].[sp_ser_rpt_BounceCaseItemDetail](@ID nvarchar(255))      
As        
Declare @Prefix nvarchar(15)                                      
                                      
Select @Prefix = Prefix From VoucherPrefix Where TranID = 'JOBCARD'                              
Select  JobCardAbstract.JobCardId,   
'JobCardID' = @Prefix + Cast(JobCardAbstract.DocumentID as nvarchar(15)),                                        
'JobCard Date' = JobCardAbstract.JobCardDate,  
IsNull(JobCardDetail.TaskId,'') TaskID,  
'Task Description' = [Description],   
'JobCardId Bounced' = @Prefix + Cast(S.DocumentID as nvarchar(15)),                                                 
'JobCard Date Bounced' = S.JobCardDate,               
'BounceCase Reason' = IsNull(JobCardDetail.BounceCase_Reason,'')
From JobCardDetail ,JobCardAbstract ,TaskMaster,JobCardAbstract S   
Where  JobCardAbstract.JobCardId = JobCardDetail.JobCardId   
And JobCardDetail.Type = 2 
And IsNull(JobCardDetail.SpareCode, '') = '' 
And (IsNull(JobCardDetail.TaskType,0) = 1)  
And JobCardDetail.JobCardId_Bounced *=S.JobCardId  
And JobCardDetail.Product_Specification1 = @ID  
And TaskMaster.Taskid = JobCardDetail.Taskid  
And (IsNull(JobCardAbstract.Status, 0) & 192) = 0
