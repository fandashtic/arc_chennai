Create Procedure dbo.Sp_CheckMonthEnd (@GivenFromdate DateTime, @GivenTodate DateTime)
As
Begin
Set DateFormat DMY
Declare @CurrentMonthEndDate as DateTime
Declare @PreviousMonthEndDate as DateTime
Declare @FromDate as DateTime
Declare @ToDate as DateTime
Declare @PMMonth as Nvarchar(255)

Set @CurrentMonthEndDate = DateAdd(day,-1,DateAdd(Month,+1,Cast(('01/'+ cast(Month(@GivenTodate) as Nvarchar) + '/' + cast(Year(@GivenTodate) as Nvarchar)) as dateTime)))
Set @PreviousMonthEndDate = DateAdd(day,-1,Cast(('01/'+ cast(Month(@GivenTodate) as Nvarchar) + '/' + cast(Year(@GivenTodate) as Nvarchar)) as dateTime))

If dbo.stripdatefromtime(@CurrentMonthEndDate) Between dbo.stripdatefromtime(@GivenFromdate) and dbo.stripdatefromtime(@GivenTodate)
Begin
Select 1,dbo.stripdatefromtime((Cast(('01/'+ cast(Month(@CurrentMonthEndDate) as Nvarchar) + '/' + cast(Year(@CurrentMonthEndDate) as Nvarchar)) as dateTime))) [FromDate], dbo.stripdatefromtime(@CurrentMonthEndDate) [ToDate]
Goto OUT
End

Else If dbo.stripdatefromtime(@GivenFromdate) <= dbo.stripdatefromtime(@PreviousMonthEndDate)
Begin
Select 1,dbo.stripdatefromtime((Cast(('01/'+ cast(Month(@PreviousMonthEndDate) as Nvarchar) + '/' + cast(Year(@PreviousMonthEndDate) as Nvarchar)) as dateTime))) [FromDate], dbo.stripdatefromtime(@PreviousMonthEndDate) [ToDate]
Goto OUT
End
Else If dbo.stripdatefromtime(@GivenFromdate) > dbo.stripdatefromtime(@PreviousMonthEndDate)
Begin

Set @PMMonth = (select Left(DateName(Month,@PreviousMonthEndDate),3)+ '-' +  Cast(Year(@PreviousMonthEndDate) as Nvarchar(10)))
If Not Exists (select * from PM_DS_Data Where PMMonth = @PMMonth)
Begin
Select 1,dbo.stripdatefromtime((Cast(('01/'+ cast(Month(@PreviousMonthEndDate) as Nvarchar) + '/' + cast(Year(@PreviousMonthEndDate) as Nvarchar)) as dateTime))) [FromDate], dbo.stripdatefromtime(@PreviousMonthEndDate) [ToDate]
Goto OUT
End
Else
Begin
Select 0,Null [FromDate], Null [ToDate]
End
End
Else
Begin
Select 0,Null [FromDate], Null [ToDate]
End
OUT:
End
