Create Procedure mERP_SP_GetDnDRFADocIDS
As
Begin
	Select DandDID From DandDInvAbstract Where isNull(Status,0)  = 0
End
