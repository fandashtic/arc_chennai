Create Procedure Sp_Han_IsValid_SRReason
(
@Return_Type int,
@ReasonID int
)
As
Begin

If @Return_Type = 1
Begin
	Select Reason_Type_ID From ReasonMaster Where Reason_SubType = 1 and Reason_Type_ID = @ReasonID
End

Else If @Return_Type = 2	
Begin
	Select Reason_Type_ID From ReasonMaster Where Reason_SubType = 2 and Reason_Type_ID = @ReasonID
End

End
