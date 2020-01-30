create Procedure sp_get_SrvceInvItemPerPg
As
BEGIn
DECLARE @ItemCnt int

If Exists (Select 'x' from tbl_mERP_ConfigAbstract where ScreenCode = 'SrvInvItemPerPg' and Flag = 1 )
Begin
Select @ItemCnt = Value from tbl_mERP_ConfigDetail where ScreenCode = 'SrvInvItemPerPg'

If (Isnull(@ItemCnt,0) <= 0 ) --or (@ItemCnt > 25))
Select @ItemCnt = 20
End
Else
Select @ItemCnt = 20


--Select @ItemCnt
Return @ItemCnt
END
