CREATE Procedure sp_ser_CheckIssuesandTaskStatus(@JobCardID as Int,
@SerialNosandQty as nVarchar(4000), @TaskSerialNos as nVarchar(4000))
as  
Declare @Delimeter Char(2)
Declare @ReturnedIssuesCnt Int, @CancelledIssuesCnt Int
Declare @NewTaskCnt Int, @CancelledTaskCnt Int
Declare @Status as nVarchar(255)
Set @Delimeter = Char(15)

select @ReturnedIssuesCnt=0,@CancelledIssuesCnt=0,@NewTaskCnt = 0,@CancelledTaskCnt = 0

/*It will get number of new added tasks 
after opening jobcard for service invoice in user machine*/
select @NewTaskCnt = Count(*) from JobCardTaskAllocation where JobCardID = @JobCardID
and isNull(TaskStatus,0) in (0,1,2) and
SerialNo not in (Select Cast(ItemValue as Int) from dbo.sp_ser_SplitIn2Rows(@TaskSerialNos,@Delimeter))

/*It will get number of new cancelled or reworked tasks 
after opening jobcard for service invoice in local user machine*/
Select  @CancelledTaskCnt = Count(*) from dbo.sp_ser_SplitIn2Rows(@TaskSerialNos,@Delimeter)
where Cast(ItemValue as Int) not in (select SerialNo from JobCardTaskAllocation where JobCardID = @JobCardID
and isNull(TaskStatus,0) in (0,1,2))

If @CancelledTaskCnt <> 0 
Set @Status = 'Task has been either Cancelled or Reworked for this job card'
else if @NewTaskCnt <> 0
Set @Status = 'New Task has been added for this job card'

if isNull(@Status,'') = ''
begin 
	/*It will return if any spares has been returned as saleable
	after opening jobcard for service invoice in user machine*/
	Select @Status = 'Spares have been returned as saleable'  from IssueDetail ISD 
	Inner Join (select Cast(Left(ItemValue,CharIndex(Char(16),ItemValue)-1) as Int) as "SerialNo", 
	Cast(substring(ItemValue,CharIndex(Char(16),ItemValue)+1,Len(ItemValue)) as Int) as "Qty" 
	from dbo.sp_ser_SplitIn2Rows(@SerialNosandQty,@Delimeter)) as RecData
	On ISD.SerialNo = RecData.SerialNo
	Inner Join IssueAbstract ISA On ISA.IssueID = ISD.IssueID
	where(isNull(IssuedQty, 0)-isNull(ReturnedQty,0)) <> RecData.Qty
	and isNull(ISA.Status,0) & (192 | 32) not in (192,32)
end

if isNull(@Status,'') = ''
begin
	/*It will return if any spares has been added
	after opening jobcard for service invoice in user machine*/
	select  @ReturnedIssuesCnt  = Count(*) from IssueAbstract ISA
	Inner Join IssueDetail ISD on ISA.IssueID = ISD.IssueID
	where JobCardID = @JobCardID and isNull(ISA.Status,0) & (192 | 32) not in (192,32)
	and (isNull(IssuedQty,0)-isNull(ReturnedQty,0)) <> 0 and ISD.SerialNo  Not in 
	(select Cast(Left(ItemValue,CharIndex(Char(16),ItemValue)-1) as Int) from dbo.sp_ser_SplitIn2Rows(@SerialNosandQty,@Delimeter))
	
	/*It will return if any spares has been cancelled or amended
	after opening jobcard for service invoice in user machine*/
	select @CancelledIssuesCnt = Count(*) from dbo.sp_ser_SplitIn2Rows(@SerialNosandQty,@Delimeter)
	where Cast(Left(ItemValue,CharIndex(Char(16),ItemValue)-1) as Int) Not In
	(select  ISD.SerialNo from IssueAbstract ISA
	Inner Join IssueDetail ISD on ISA.IssueID = ISD.IssueID
	where JobCardID = @JobCardID and isNull(ISA.Status,0) & (192 | 32) not in (192,32)
	and (isNull(IssuedQty,0)-isNull(ReturnedQty,0)) <> 0)

	if @ReturnedIssuesCnt  <> 0 or @CancelledIssuesCnt <> 0
		Set @Status = 'New spares have been issued for this job card' 
end
Select isNull(@Status,'') as "Status"
		
