Create Procedure mERP_SP_GetRFADocIDS
As
Begin
	select Distinct(RFADocID) from tbl_mERP_RFAAbstract where isnull(status,0)  = 0 And IsNull(RFADocID,0) <> 0
	And RFADocID Not In ( Select Replace(RFAID, 'RFA','') from  tbl_merp_RFAXMLStatus where IsNull(Status,0) Not In (0,128,129))
End
