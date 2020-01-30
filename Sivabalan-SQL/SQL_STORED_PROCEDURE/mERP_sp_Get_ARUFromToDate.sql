CREATE Procedure mERP_sp_Get_ARUFromToDate (@RepID int,@FromDate DateTime, @ToDate DateTime)
As
Set DateFormat DMY
Declare @FreQuency Int
Declare @DayOfMonthWeek Int
Declare @ARUFromDate DateTime
Declare @ARUToDate DateTime

IF Exists (Select 'x' From Reports_To_Upload Where ReportDataID = @RepID)
Select @FreQuency = IsNull(Frequency,0), @DayOfMonthWeek = IsNull(DayOfMonthWeek,0) From Reports_To_Upload Where ReportDataID = @RepID
Else
Select @FreQuency = IsNull(Frequency,0), @DayOfMonthWeek = IsNull(DayOfMonthWeek,0) From tbl_mERP_OtherReportsUpload Where ReportDataID = @RepID

if @RepID = 1160 -- For Unable to send TMD Daily SPM report Back date Report from Report Viewer.
Begin
set @FromDate = @ToDate
End

If @FreQuency = 1 --Daily
Begin
Set @ARUFromDate = @FromDate
Set @ARUToDate = @FromDate
End
Else If @FreQuency = 2 --Monthly
Begin
Set @ARUFromDate = Cast((Cast(@DayOfMonthWeek as nVarChar) + '-' + Cast(Month(@FromDate) As nVarChar) + '-' + Cast(Year(@FromDate) As nVarChar)) As DateTime)
Set @ARUToDate = DateAdd(d,-1,DateAdd(m,1,@ARUFromDate))
End
Else If @FreQuency = 3 --Weekly
Begin
Set @FromDate = DateAdd(d,(@DayOfMonthWeek - DatePart(dw,@FromDate)),@FromDate)
Set @ARUFromDate = Cast((Cast(Day(@FromDate) as nVarChar) + '-' + Cast(Month(@FromDate) As nVarChar) + '-' + Cast(Year(@FromDate) As nVarChar)) As DateTime)
Set @ARUToDate = DateAdd(d,-1,DateAdd(d,7,@FromDate))
End
Else If @FreQuency = 4 --Customised Weekly
Begin

Set @FromDate = Cast((Cast((Case
When Day(@FromDate) Between 1 and 7 Then 1
When Day(@FromDate) Between 8 and 14 Then 8
When Day(@FromDate) Between 15 and 21 Then 15 Else 22 End) As nVarchar) + '-' + Cast(Month(@FromDate) As nVarChar) + '-' +  Cast(Year(@FromDate) As nVarChar)) As DateTime)

Set @ARUFromDate = @FromDate

Set @ARUToDate = Cast((Cast((Case
When Day(@ARUFromDate) = 1 Then 7
When Day(@ARUFromDate) = 8 Then 14
When Day(@ARUFromDate) = 15 Then 21
Else Day(dbo.Get_Last_DayoftheMonth(@ARUFromDate)) End) As nVarChar) + '-' + Cast(Month(@ARUFromDate) As nVarChar) + '-' + Cast(Year(@ARUFromDate) As nVarChar))  As DateTime)

End
Else If @FreQuency = 5 --Cumulative Weekly Report
Begin
-- @ToDate

Set @ToDate = Cast((Cast((Case
When Day(@ToDate) Between 1 and 7 Then 7
When Day(@ToDate) Between 8 and 14 Then 14
When Day(@ToDate) Between 15 and 21 Then 21
Else Day(dbo.Get_Last_DayoftheMonth(@ToDate)) End) As nVarchar) + '-' +
Cast(Month(@ToDate) As nVarChar) + '-' +  Cast(Year(@ToDate) As nVarChar)) As DateTime)

Set @ARUToDate = @ToDate

Set @ARUFromDate = Cast((Cast(1  As nVarChar) + '-' + Cast(Month(@ARUToDate) As nVarChar) + '-' + Cast(Year(@ARUToDate) As nVarChar))  As DateTime)

End
Else -- Unknown
Begin
Set @ARUFromDate = @FromDate
Set @ARUToDate = @FromDate
End

Select "From Date" = @ARUFromDate, "To Date" = @ARUToDate

