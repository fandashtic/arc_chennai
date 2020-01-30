Create Procedure mERP_sp_Get_AdminAuthPass(@UserName nVarchar(255))  
As  
Begin  
-- Changes done for FMC migration
 Select 1, Password From ForumMessageClient..R1ATH_Client_Cfg_Details R1Ath, SetUp  
 Where R1Ath.CompanyID = SetUp.registeredOwner and R1Ath.UserID = @UserName  
 Union  
 Select 2, IsNull(Password,'') From Users Where UserName Like @UserName  
 and UserName Not In (Select UserID From ForumMessageClient..R1ATH_Client_Cfg_Details R1Ath, SetUp  
 Where R1Ath.CompanyID = SetUp.registeredOwner)  
End
