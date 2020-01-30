CREATE Procedure sp_acc_master_updateaccount(@MasterType Int,   
      @GroupId Int,  
      @Name nVarchar(255),  
      @Active Int,  
      @BankCode nvarchar(50)=N'')  
As  
DECLARE @CUSTOMER INT  
DECLARE @VENDOR INT  
DECLARE @BANK INT  
Declare @AccountID Int  
DECLARE @BRANCHOFFICE INT  
DECLARE @PERSONNAL INT  
  
SET @CUSTOMER =1  
SET @VENDOR=2  
SET @BANK=3  
SET @BRANCHOFFICE=6  
SET @PERSONNAL = 7  
  
If @MasterType=@CUSTOMER  
Begin  
 Select @AccountID=AccountID from customer where Company_name=@Name  
 /* Updation into the AccountsMaster table. */   
 update AccountsMaster set GroupID=@GroupID, Active=@Active where AccountID=@AccountID  
End  
Else If @MasterType=@VENDOR  
Begin  
 Select @AccountID=AccountID from vendors where vendor_name=@Name  
 /* Updation into the AccountsMaster table. */   
 update AccountsMaster set GroupID=@GroupID, Active=@Active where AccountID=@AccountID  
End  
Else If @MasterType=@Bank  
Begin  
 Select @AccountID=AccountID from Bank  
 where Account_Number=@Name and BankCode = @BankCode  
 /* Updation into the AccountsMaster table. */   
 update AccountsMaster set GroupID=@GroupID, Active=@Active where AccountID=@AccountID  
End  
Else If @MasterType=@BRANCHOFFICE  
Begin  
 Select @AccountID=AccountID from WareHouse where WareHouse_Name=@Name  
 /* Updation into the AccountsMaster table. */   
 update AccountsMaster set GroupID=@GroupID, Active=@Active where AccountID=@AccountID  
End  
Else If @MasterType=@PERSONNAL  
Begin  
 Select @AccountID = AccountID from PersonnelMaster where PersonnelName=@Name  
 /* Updation into the AccountsMaster table. */   
 update AccountsMaster set GroupID=@GroupID, Active=@Active where AccountID=@AccountID  
End
