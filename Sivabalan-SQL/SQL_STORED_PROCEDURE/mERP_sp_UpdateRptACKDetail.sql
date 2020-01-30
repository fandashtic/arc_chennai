Create Procedure mERP_sp_UpdateRptACKDetail ( @AbsID int, @Tranname nVarchar(100), @documentId Int)
As
Begin

	Declare @AckDate as Datetime
	Declare @DocId int
	Declare @DocReference int
	Create Table #tmpClaims (ClaimID Int)

	Insert Into tbl_mERP_RecdRptAckDetail ( RptAbsID, TranName, RptDocumentID)
	Values (@AbsID, @Tranname, @documentId)


	Select @AckDate = ReceivedDate From tbl_mERP_RecdRptAckAbstract Where ID = @AbsID


	/* Update the acknowledgment received status start*/
	Update tbl_merp_UploadReportTracker Set AcknowledgeDate = @AckDate , Status = 129 
	Where ReportDocNumber = @documentId

	Update tblXML Set tblXML.Status = 129
	From tbl_mERP_UploadReportXMLTracker tblXML, tbl_merp_UploadReportTracker RPT
	Where RPT.ReportDocNumber = @documentId
	And RPT.ReportDocID = tblXML.ReportDocID 
	/* Update  the acknowledgemnt received status end*/


	/* Update the received status start*/
	Update tbl_mERP_RecdRptAckAbstract Set Status = 1 where ID = @AbsID
	Update tbl_mERP_RecdRptAckDetail Set Status = 1 where RptAbsID = @AbsID
	/* Update the received status End*/


End
