Create Procedure sp_Get_ValidRFAReason
(@ReasonDesc nVarchar(255))
As
Begin
    if @ReasonDesc <> ''
    begin
		Declare @ReasonID as Int
		Select  @ReasonID  = ReasonID From tbl_mERP_RFASubmission_Reason Where Reason = @ReasonDesc
		Select isNull(@ReasonID,0)
	end
	else
	begin
		select * from tbl_mERP_RFASubmission_Reason 	   
	end
End

