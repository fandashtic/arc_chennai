Create Procedure Sp_Recd_CustomerwiseMerchandise
As
Begin
Select Count(*) from tbl_merp_RecdCustomerwiseMerchandise Where Isnull(RecFlag,0) = 0
Update tbl_merp_RecdCustomerwiseMerchandise Set RecFlag = 1 Where Isnull(RecFlag,0) = 0
End
