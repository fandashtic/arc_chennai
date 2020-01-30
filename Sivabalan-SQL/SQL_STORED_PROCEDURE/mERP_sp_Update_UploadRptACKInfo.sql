Create Procedure mERP_sp_Update_UploadRptACKInfo(@XMLFileName nVarchar(510), @StatusDesc nVarchar(50), @AckDate Datetime)  
As  
Declare @Status Int
Declare @DocType as nvarchar(50)
Declare @RFADocNumber as nvarchar(50)
Declare @Delimiter as Char(1)
Declare @ReportID Int
Declare @ResetDate DateTIme
Set @Delimiter = N'-'
Set @Status = 0
Set @RFADocNumber = N''
SET DATEFORMAT DMY
/* The AckDate is updated w.r.t the WDsystem DB Server Date*/
Select @AckDate = Getdate()

/*Get Doc Type*/
Select * into #tmpDocSplitup from dbo.sp_splitin2rows_withID(@XMLFileName, @Delimiter)
Select @DocType = ItemValue from #tmpDocSplitup Where RowID = 4 

/*Set the status*/  
Set @Status = Case @StatusDesc When N'RECEIVED' Then 128  
                               When N'PROCESSED' Then 132  
                               When N'FAILED'   Then 192  
                               Else 192 End /*Considered as Rejected*/  
  
    /* Start - Update the acknowledgment received status*/  
If @DocType = N'RFA'
Begin
		Update RFA Set RFA.Status = 129, RFA.AckStatus = RFA.AckStatus | @Status , RFA.AcknowledgeDate = @AckDate  
		From tbl_Merp_RFAXmlStatus RFA  Where IsNull(RFA.XMLDocName,'') = @XMLFileName  

		/*Update Claimsnote When RFA is process at Portal*/
		If @Status & 132 = 132
		Begin
			Select @RFADocNumber = ItemValue from #tmpDocSplitup Where RowID = 5 
			Exec mERP_sp_Update_RFAACK_ClaimNoteStatus @RFADocNumber
		End
		--RFA REGenerate and RESend

		If @Status & 192 = 192
		Begin
			Update tbl_mERP_RFAAbstract Set Status = 0 Where RFADOCID = (Select Top 1 cast(Replace(RFAID,'RFA','') as Integer) from tbl_Merp_RFAXmlStatus Where Isnull(XMLDocName,'') = @XMLFileName)
			Delete from tbl_Merp_RFAXmlStatus Where Isnull(XMLDocName,'') = @XMLFileName
		End
End
Else 
Begin
	Update URT Set URT.Status = URT.Status | 128 , URT.AcknowledgeDate = @AckDate, URT.ACKStatus = URT.ACKStatus | @Status   
	From tbl_merp_UploadReportTracker URT  
	Where URT.XMLDocName = @XMLFileName
	--RESET Last Upload Date
	--If (@Status & 192 =192)
	/*BELOW LOGIC IS NTO WORKING AND HENCE WE ARE FOLLOWING THE NEW LOGIC */
--	Begin
--	Select @ReportID=ReportID,@ResetDate=dateAdd(d,-1,ReportFromDate) From tbl_merp_UploadReportTracker 
--	Where (Isnull(Ackstatus,0) & 64 = 64 OR Isnull(Ackstatus,0) & 192 = 192 OR Isnull(Ackstatus,0) & 256 = 256)
--	And Isnull(ARUMode,0) = 0 And Isnull(XMLDocName,'') = @XMLFileName
--	--Order By ReportID Asc
--	If (@ReportID > 0)
--		Begin
--			If (@DocType='EPM' or @DocType ='PLR')
--				Update tbl_mERP_OtherReportsUpload set LastUploadDate=@ResetDate where ReportID=@ReportID and XMLReportCode=@DocType
--			else
--				Update Reports_To_Upload set LastUploadDate=@ResetDate where ReportID=@ReportID and XMLReportCode=@DocType			
--			Set @ReportID = 0
--		End
--	End
	/* NEW LOGIC */
	If exists(select 'x' From tbl_merp_UploadReportTracker Where 
	(Isnull(Ackstatus,0) & 64 = 64 OR Isnull(Ackstatus,0) & 192 = 192 OR Isnull(Ackstatus,0) & 256 = 256) And 
	Isnull(ARUMode,0) = 0 And 
	Isnull(XMLDocName,'') = @XMLFileName)
	BEGIN
		/*CHECK ALREADY REPORT IS RESENT */
		If not exists(Select 'x' from Reports_to_Resend where isnull(XMLDocname,'')=@XMLFileName and ISNULL(status,0) =1)
		BEGIN
			/* By default status will be zero*/
			insert into Reports_to_Resend(ReportDocid,XMLDocname,status)
			Select ReportDocid,isnull(XMLDocname,''),0
			From tbl_merp_UploadReportTracker 
			Where (Isnull(Ackstatus,0) & 64 = 64 OR Isnull(Ackstatus,0) & 192 = 192 OR Isnull(Ackstatus,0) & 256 = 256)
			And Isnull(ARUMode,0) = 0 And Isnull(XMLDocName,'') = @XMLFileName
		END
	END
	/* If RESENT DOCUMENT IS PROCESSED*/
	if exists(select 'x' From tbl_merp_UploadReportTracker where 
	Isnull(Ackstatus,0) & 128 = 128 and 
	Isnull(Ackstatus,0) & 132 = 132 and 
	Isnull(ARUMode,0) = 0 And 
	Isnull(XMLDocName,'') = @XMLFileName)
	BEGIN
		if exists(Select 'x' from Reports_to_Resend where Isnull(XMLDocName,'') = @XMLFileName and ISNULL(status,0) =0)
		BEGIN
			update Reports_to_Resend set status= 1 where Isnull(XMLDocName,'') = @XMLFileName and ISNULL(status,0) =0
		END
	END
	Drop table #tmpDocSplitup
	/* Failed to upload reports should be resent (From the past 1 month)*/
	Create Table #tmpFailedReports(ReportDocid int,XMLDocname nvarchar(510))
	Insert into #tmpFailedReports (ReportDocid,XMLDocname) 
	Select distinct ReportDocid,isnull(XMLDocname,'') from tbl_merp_UploadReportTracker 
	where status=129 and 
	ackstatus = 256 and 
	Isnull(ARUMode,0) = 0 And 
	ReportDocID not in (select distinct ReportDocID from Reports_to_Resend) And
	reporttodate >=DATEADD(m,-2,DATEADD(mm, DATEDIFF(m,0,getdate()), 0))
	insert into Reports_to_Resend(ReportDocid,XMLDocname,status)
	Select ReportDocid,XMLDocname,0 from #tmpFailedReports
	Drop Table #tmpFailedReports
End
