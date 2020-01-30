Create Procedure mERP_sp_UpdateResendReport @Flag int=0,@HiddenReport int=0
AS
BEGIN
	/* Flag will be zero if SP is invoked from Day End Reports exe else 1 if from ARU*/
	If @Flag=0
	BEGIN
		Update reports_to_resend set status=1 where ReportDocid in (
		select distinct T.ReportDocId from tbl_merp_UploadReportTracker T,Reports_to_upload RU Where 
		T.ReportID=RU.ReportId and 
		isnull(T.ReportType,0)=1 And
		isnull(T.ARUMode,0)=0 And isnull(RU.Frequency,0)=1 And RU.ReportName <> 'Sales Data' And
		(Isnull(Ackstatus,0) & 64 = 64 OR Isnull(Ackstatus,0) & 192 = 192 OR Isnull(Ackstatus,0) & 256 = 256)) and status=0
		if @HiddenReport=1 
		Begin
			Update reports_to_resend set status=1 where ReportDocid in (
			select distinct T.ReportDocId from tbl_merp_UploadReportTracker T,tbl_mERP_OtherReportsUpload RU Where 
			T.ReportID=RU.ReportId and 
			isnull(T.ARUMode,0)=0 And
			isnull(T.ReportType,0)=2 And
			(Isnull(Ackstatus,0) & 64 = 64 OR Isnull(Ackstatus,0) & 192 = 192 OR Isnull(Ackstatus,0) & 256 = 256)) and status=0
		End 
	END
	ELSE If @Flag=1
	BEGIN
		Update reports_to_resend set status=1 where ReportDocid in (
		select distinct T.ReportDocId from tbl_merp_UploadReportTracker T,Reports_to_upload RU Where 
		T.ReportID=RU.ReportId and 
		isnull(T.ReportType,0)=1 And
		isnull(T.ARUMode,0)=0 And (isnull(RU.Frequency,0)<>1 OR RU.ReportName ='Sales Data') And 
		(Isnull(Ackstatus,0) & 64 = 64 OR Isnull(Ackstatus,0) & 192 = 192 OR Isnull(Ackstatus,0) & 256 = 256)) and status=0
		if @HiddenReport=1 
		Begin
			Update reports_to_resend set status=1 where ReportDocid in (
			select distinct T.ReportDocId from tbl_merp_UploadReportTracker T,tbl_mERP_OtherReportsUpload RU Where 
			T.ReportID=RU.ReportId and 
			isnull(T.ReportType,0)=2 And
			isnull(T.ARUMode,0)=0 And
			(Isnull(Ackstatus,0) & 64 = 64 OR Isnull(Ackstatus,0) & 192 = 192 OR Isnull(Ackstatus,0) & 256 = 256)) and status=0
		End 
	END
END
