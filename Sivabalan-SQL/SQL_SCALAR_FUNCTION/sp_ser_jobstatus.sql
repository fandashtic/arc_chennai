CREATE Function sp_ser_jobstatus(@jobcardID int) returns nvarchar(100)
as
Begin
declare @Fullyopen int
declare @FullyAssinged int
declare @FullyClosed int
declare @FullyCancelled int
declare @Status varchar(100)


select @Fullyopen = count(Taskstatus) from jobcardtaskallocation
where jobcardtaskallocation.jobcardid = @jobcardid
and TaskStatus = 0

select @FullyAssinged =  count(Taskstatus) from jobcardtaskallocation
where jobcardtaskallocation.jobcardid = @jobcardid
and TaskStatus = 1

select  @FullyClosed = count(Taskstatus) from jobcardtaskallocation
where jobcardtaskallocation.jobcardid = @jobcardid
and TaskStatus = 2

select @FullyCancelled =  count(Taskstatus) from jobcardtaskallocation
where jobcardtaskallocation.jobcardid = @jobcardid
and TaskStatus = 3

if @Fullyopen <> 0 and @FullyAssinged = 0 and @FullyClosed = 0 
Begin 
  set @Status = 'Fully Open'
End
else if @Fullyopen > 0 and (@FullyAssinged <> 0 or @Fullyclosed > 0 or @FullyCancelled > 0) 
Begin
  set @Status = 'Partially Assigned'
End 
else if (@FullyAssinged <> 0 or @FullyClosed <> 0 ) --and @FullyCancelled <> 0 
Begin
  set @Status = 'Fully Assigned'
End  
/*else if @FullyCancelled = 0  or (@Fullyopen = 0 and @FullyAssinged = 0 and @FullyClosed = 0) 
Begin 
  set @Status = 'Task Not yet Assinged'
End*/
else if @Fullyopen = 0 and @FullyAssinged = 0 and @FullyClosed = 0 and @FullyCancelled <> 0 
Begin 
  set @Status = 'Fully Cancelled'
End
 return @Status 
End











