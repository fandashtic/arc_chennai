CREATE procedure sp_acc_checkapvadjusted(@APVID int)
as
Declare @Adjusted int
Set @Adjusted = 0

Select @Adjusted = 1 from
APVAbstract where DocumentID = @APVID
and isnull(Status,0) <> 192
and AmountApproved = Balance

select 'Adjusted'= @Adjusted


