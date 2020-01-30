Create Procedure mERP_Sp_ProcessReceiveAbstract_Tax
As
Select RCA.ID, RCA.MenuName, RCA.Flag, "MenuValid" = ( Case when IsNull(CA.ScreenName,'') <> '' then 'yes' else 'No' end),
"FlagValid" = ( Case When ( RCA.Flag = 0 Or RCA.Flag = 1) then 'yes' else 'No' end), 
IsNull(CA.ScreenCode, '') As ScreenCode
From tbl_mERP_RecConfigAbstract RCA Left Outer join  tbl_mERP_ConfigAbstract CA
On RCA.MenuName = CA.ScreenName
Where Status = 0 and IsNull(RCA.MenuName,'') = 'TAXBEFOREDISCOUNT'
