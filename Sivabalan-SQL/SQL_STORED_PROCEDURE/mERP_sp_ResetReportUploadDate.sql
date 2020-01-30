Create Procedure mERP_sp_ResetReportUploadDate
as
Begin
Set DateFormat DMY
Declare @FSUDate DateTime
Declare @DailyFreqDt DateTime
Declare @MonthFreqDt DateTime
Declare @WeekFreqDt DateTime
Declare @PrevMthLstDt DateTime
Set @FSUDate = GetDate()
/**/
Select @DailyFreqDt = dbo.StripTimeFromDate(@FSUDate - 2)
Select @PrevMthLstDt = dbo.StripTimeFromDate(@FSUDate -Day(@FSUDate))
Select @MonthFreqDt = DateAdd(d, -(Day(@PrevMthLstDt)), @PrevMthLstDt)

Select @WeekFreqDt = dbo.StripTimeFromDate(Case When Day(@FSUDate) <= 7 Then DateAdd(d, -(Day(@PrevMthLstDt))+ 21, @PrevMthLstDt)
When (Day(@FSUDate) >= 8 and Day(@FSUDate) <= 14) Then  DateAdd(d, -(Day(@FSUDate)), @FSUDate)
When (Day(@FSUDate) >= 15 and Day(@FSUDate) <= 21) Then DateAdd(d, -(Day(@FSUDate))+ 7, @FSUDate)
When Day(@FSUDate) >=22 Then DateAdd(d, -(Day(@FSUDate))+ 14, @FSUDate) end)

Update Reports_To_UpLoad
Set LastUploadDate = (Case IsNull(Frequency,0) When 1 then @DailyFreqDt
When 2 then @MonthFreqDt
Else @WeekFreqDt End )
Where (IsNull(LastUploadDate,'')  = '' Or IsNull(LastUploadDate,'') > @FSUDate)
and Isnull(Frequency,0) >=1 and Isnull(Frequency,0) <=5

Update tbl_merp_OtherReportsUpload
Set LastUploadDate = (Case IsNull(Frequency,0) When 1 then @DailyFreqDt
When 2 then @MonthFreqDt
Else @WeekFreqDt End )
Where (IsNull(LastUploadDate,'')  = '' Or IsNull(LastUploadDate,'') > @FSUDate)
and Isnull(Frequency,0) >=1 and Isnull(Frequency,0) <=5
End
