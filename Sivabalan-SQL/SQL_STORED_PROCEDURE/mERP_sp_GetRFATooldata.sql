
Create Procedure mERP_sp_GetRFATooldata(@Month  NVarchar(255))
as
Begin
	Declare @MonthDate as DateTime
	Set Dateformat DMY
	Set @MonthDate =  cast(('01/' + Cast(Left(@Month,2) as Nvarchar(10)) + '/' +  Cast(Right(@Month,4) as Nvarchar(10))) as DateTime)

	select SA.Cs_RecSchid SchemeCode,RFA.ActivityCode,RFA.Description,(Convert(Nvarchar(10),RFAPayout.PayoutPeriodFrom,103) + ' - ' + Convert(Nvarchar(10),RFAPayout.PayoutPeriodTo,103)) RFAPeriod,'Submitted' [Type],
	Sum(Isnull(RFA.RebateValue,0)) RFAValue,
	RFAXML.RFAID,RFAXML.XMLDocName,Convert(Nvarchar(10),RFA.SubmissionDate,103) SubmittedDate,
	(Case IsNull(RFAXML.Status,-1) When 0 Then 'Ready To Upload' When 128 Then 'Upload to Central' When 129 Then 'Ack Received' When -1 Then 'XML Not Generated' End) ACKStatus
	,Convert(Nvarchar(10),RFAXML.AcknowledgeDate,103) ACKDate
	from tbl_Merp_RFAXmlStatus RFAXML, tbl_mERP_RFAAbstract RFA, tbl_mERP_SchemePayoutPeriod RFAPayout, tbl_merp_schemeabstract SA

	Where month(RFAPayout.Payoutperiodto) = month(@MonthDate) and Year(RFAPayout.Payoutperiodto) = Year(@MonthDate)
	And substring (RFAXML.RFAID, 4,len(RFAXML.RFAID)) = RFA.RFADocID
	And RFA.Documentid = RFAPayout.Schemeid
	And RFAPayout.Active = 1
	And RFAPayout.Claimrfa = 1
	And RFAPayout.SchemeID = SA.SchemeID
	And month(RFA.Payoutto) = month(@MonthDate) and Year(RFA.Payoutto) = Year(@MonthDate)
	Group by SA.Cs_RecSchid,RFA.ActivityCode,RFA.Description,RFAPayout.PayoutPeriodFrom,RFAPayout.PayoutPeriodTo,RFAXML.RFAID,RFAXML.XMLDocName,Convert(Nvarchar(10),RFA.SubmissionDate,103),
	(Case IsNull(RFAXML.Status,-1) When 0 Then 'Ready To Upload' When 128 Then 'Upload to Central' When 129 Then 'Ack Received' When -1 Then 'XML Not Generated' End)
	,Convert(Nvarchar(10),RFAXML.AcknowledgeDate,103)
	Order by RFA.ActivityCode asc
End
