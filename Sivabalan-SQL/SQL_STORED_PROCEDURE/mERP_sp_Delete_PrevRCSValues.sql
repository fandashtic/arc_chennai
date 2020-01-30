CREATE Procedure mERP_sp_Delete_PrevRCSValues (@RCSPos int)                          
As                          
Begin
Delete from Cust_TMD_Master Where TMDCtlPos = @RCSPos
--Delete from Cust_TMD_Details Where TMDCtlPos = @RCSPos
End

