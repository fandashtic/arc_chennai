CREATE Procedure sp_acc_checkaccountstatus(@accountid int)  
as  
Declare @status Int  
Declare @CUSTOMER Int  
Declare @VENDOR Int  
Declare @BANKACCOUNT Int  
Declare @BRANCH Int  
Declare @PERSONNAL INT  
  
Set @status = 0  
Set @CUSTOMER = 1  
Set @VENDOR = 2  
Set @BANKACCOUNT = 3  
Set @BRANCH = 4  
Set @PERSONNAL = 7  
  
If exists(Select AccountID from Customer where Isnull(AccountID,0) = @accountid)  
Begin  
 Set @status = @CUSTOMER  
End   
If exists(Select AccountID from Vendors where Isnull(AccountID,0) = @accountid)  
Begin  
 Set @status = @VENDOR  
End     
If exists(Select AccountID from Bank where Isnull(AccountID,0) = @accountid)  
Begin  
 Set @status = @BANKACCOUNT  
End    
If exists(Select AccountID from WareHouse where Isnull(AccountID,0) = @accountid)  
Begin  
 Set @status = @BRANCH  
End     
If Exists(Select * from dbo.SysObjects Where ID = Object_ID(N'[dbo].[PersonnelMaster]') And OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	Begin
		If exists(Select AccountID from PersonnelMaster where Isnull(AccountID,0) = @accountid)  
		Begin  
		 Set @status = @PERSONNAL  
		End     
	End
Select @status
