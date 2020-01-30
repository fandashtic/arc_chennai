Create Procedure sp_CheckConfig_Inv as
Begin
Select Isnull(Flag,0) Flag from tbl_mERP_ConfigAbstract 
Where ScreenName ='CASHPOPUP'
End
