Create Procedure mERP_sp_VajraServiceLog(@FromDate DATETIME,@ToDate DATETIME)
As
Set DateFormat dmy
Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)



Select @Fromdate = dbo.StripTimeFromDate(@Fromdate),@ToDate= dbo.StripTimeFromDate(@ToDate)

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
Select Top 1 @WDCode = RegisteredOwner From Setup

If @CompaniesToUploadCode='ITC001'
Set @WDDest= @WDCode
Else
Begin
Set @WDDest= @WDCode
Set @WDCode= @CompaniesToUploadCode
End

Select 1 as 'Serial',@WDCode as 'WDCode',@WDDest as 'WDDest',@Fromdate as 'FromDate',@ToDate as 'ToDate',
Isnull(SERIAL_NO,'') as'SERIAL_NO',
Isnull(DIST_CD,'') as 'DIST_CD',
Isnull(DE_NAME,'') as 'DE_NAME',
Isnull(DE_DESC,'') as 'DE_DESC',
Isnull(LATE_TXN_DT,NULL) as 'LATE_TXN_DT',
Isnull(LATE_TXN_YEAR,'')as 'LATE_TXN_YEAR',
Isnull(LATE_TXN_MONTH,'') as 'LATE_TXN_MONTH',
--Isnull(START_DT,NULL) as 'START_DT',
Convert(nVarchar(10),START_DT,103) + N' ' + Convert(nVarchar(8),START_DT,108) as 'START_DT',
--Isnull(END_DT,NULL) as 'END_DT',
Convert(nVarchar(10),END_DT,103) + N' ' + Convert(nVarchar(8),END_DT,108) as 'END_DT',
Isnull(RESULT,'') as 'RESULT',
Isnull(REMARK,'') as 'REMARK',
Convert(nVarchar(10),UploadDateTime,103) + N' ' + Convert(nVarchar(8),UploadDateTime,108) as 'UploadDateTime' from SYS_DE_LOG
where dbo.StripTimeFromDate(UploadDateTime) between @Fromdate and  @ToDate

