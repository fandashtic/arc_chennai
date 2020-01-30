
Create Procedure mERP_sp_UpdateRFAACKDetail ( @AbsID int, @Tranname nVarchar(100), @documentId nVarchar(255))
As
Begin

	Declare @DocId int
	Declare @DocReference int
	Create Table #tmpClaims (ClaimID Int)

	Insert Into tbl_mERP_RecdRFAckDetail ( RFAAbsID, TranName, RFADocumentID)
	Values (@AbsID, @Tranname, @documentId)

	Select @DocId  = Substring(@documentID, 4, Len(@documentID))
	
	Declare RFACursor cursor for
		Select DocReference from tbl_merp_RFAAbstract where RFADocID = IsNull(@DocID,0)
	Open RFACursor
	Fetch From RFACursor Into @DocReference
	While @@Fetch_Status = 0
	Begin
		Update ClaimsNote Set ClaimRFA = 2 where ClaimID = @DocReference
		Insert Into #tmpClaims Values(@DocReference)
		Fetch Next From RFACursor Into @DocReference
	End
	Close RFACursor
	DeAllocate RFACursor
	Update tbl_MERP_RFAXMLStatus Set Status = 129  where RFAID =  @documentId
	Update tbl_mERP_RecdRFAckAbstract Set Status = 1 where ID = @AbsID
	Update tbl_mERP_RecdRFAckDetail Set Status = 1 where RFADocumentID = @documentId

	Select ClaimID From #tmpClaims

End
