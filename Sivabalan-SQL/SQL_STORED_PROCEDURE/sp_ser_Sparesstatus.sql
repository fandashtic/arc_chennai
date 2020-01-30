CREATE Procedure sp_ser_Sparesstatus(@Jobcardid int, @ItemCode nvarchar(50),            
@Itemspec1 nvarchar(50),@TaskID nvarchar(50))                                      
AS                                      
declare @Status as nvarchar(50)                          
declare @Status1 as int          

Select @Status1 =  count(*) 
From Jobcardspares
where Jobcardid = @JobCardId and Jobcardspares.product_code = @ItemCode
and Product_Specification1 = @Itemspec1 and Jobcardspares.TaskId = @Taskid
and Isnull(sparestatus, 0) <> 2

Select @Status1, Status = Count(*) 
From JobCardSpares
where JobCardSpares.Jobcardid = @JobCardId and JobCardSpares.product_code = @ItemCode
and JobCardSpares.Product_Specification1 = @Itemspec1 and JobCardSpares.TaskId = @Taskid
and Isnull(JobCardSpares.Sparestatus, 0) = 1 

