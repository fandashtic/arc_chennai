Create Procedure Sp_Recd_Merchandise
As
Begin
Select Count(*) from tbl_merp_RecdMerchandise Where Isnull(RecFlag,0) = 0
Update tbl_merp_RecdMerchandise Set RecFlag = 1 Where Isnull(RecFlag,0) = 0
End
