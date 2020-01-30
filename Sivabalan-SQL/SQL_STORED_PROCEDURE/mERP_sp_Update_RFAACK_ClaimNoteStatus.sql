Create Procedure mERP_sp_Update_RFAACK_ClaimNoteStatus(@documentId nVarchar(255))
As 
Begin
  Declare @DocId int
  Declare @DocReference int
  Select @DocId  = Substring(@documentID, 4, Len(@documentID))
  Declare RFACursor cursor for
  Select DocReference from tbl_merp_RFAAbstract where RFADocID = IsNull(@DocID,0)
  Open RFACursor
  Fetch From RFACursor Into @DocReference
  While @@Fetch_Status = 0
  Begin
	Update ClaimsNote Set ClaimRFA = 2 where ClaimID = @DocReference
	Fetch Next From RFACursor Into @DocReference
  End
  Close RFACursor
  DeAllocate RFACursor
End
