Create Procedure mERP_Sp_ProcessReceiveAbstract
As

Select RCA.ID, RCA.MenuName, RCA.Flag, "MenuValid" = ( Case when IsNull(CA.ScreenName,'') <> '' then 'yes' else 'No' end),
"FlagValid" = ( Case When ( RCA.Flag = 0 Or RCA.Flag = 1) then 'yes' else 'No' end), 
IsNull(CA.ScreenCode, '') As ScreenCode
From tbl_mERP_RecConfigAbstract RCA Left Outer join  tbl_mERP_ConfigAbstract CA
On RCA.MenuName = CA.ScreenName
Where Status = 0 and IsNull(RCA.MenuName,'') <> 'TAXBEFOREDISCOUNT' and  IsNull(RCA.MenuName,'') <> 'GSTaxEnabled'


IF (Select isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenName = 'GSTaxEnabled') = 0
Begin
	IF(Select isnull(Flag,0) From tbl_mERP_RecConfigAbstract Where MenuName = 'GSTaxEnabled' and Status = 0) = 1
		Update tbl_mERP_RecConfigAbstract Set Status = 3 Where MenuName = 'GSTaxEnabled' and Status = 0
	Else
		Update tbl_mERP_RecConfigAbstract Set Status = 64 Where MenuName = 'GSTaxEnabled' and Status = 0
End
Else
	IF Exists(Select 'x' From tbl_mERP_RecConfigAbstract Where MenuName = 'GSTaxEnabled' and Status = 0)
		Update tbl_mERP_RecConfigAbstract Set Status = 64 Where MenuName = 'GSTaxEnabled' and Status = 0

