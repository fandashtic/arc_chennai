Create Procedure sp_Get_ValidReasonID
(@ReasonDesc nVarchar(255),
 @Reason_SubType Int)
As
Begin
	Declare @ReasonID as Int
	Select  @ReasonID  = Reason_Type_ID From ReasonMaster Where Screen_Applicable = 'Stock Conversion to Damage' And
	Reason_Description = @ReasonDesc And Reason_SubType = (Case @Reason_SubType When 0 Then 3 Else 4 End)
	Select isNull(@ReasonID,0)
End

