CREATE Procedure sp_acc_master_addaccount(@MasterType Int,   
      @GroupId Int,  
      @Name nvarchar(255),  
      @NoteID Int=0,  
      @BankCode nvarchar(50) = N'')  
As  
DECLARE @CUSTOMER INT  
DECLARE @VENDOR INT  
DECLARE @BANK INT  
DECLARE @DEBIT INT  
DECLARE @CREDIT INT  
DECLARE @BRANCHOFFICE INT  
DECLARE @PERSONNAL INT  
  
SET @CUSTOMER =1  
SET @VENDOR=2  
SET @BANK=3  
SET @DEBIT=4  
SET @CREDIT=5  
SET @BRANCHOFFICE=6  
SET @PERSONNAL = 7  
  
If @MasterType=@CUSTOMER  
Begin  
 /* Insertion of customer account into the AccountMaster table. */  
 Execute sp_acc_insertaccountsforexistingmasters @Name,@GroupID,1  
 /* Updation of new AccounID into the Customer table. */   
 update customer set AccountID=@@Identity where Company_Name=@Name  
End  
Else If @MasterType=@VENDOR  
Begin  
 Execute sp_acc_insertaccountsforexistingmasters @Name,@GroupID,1  
 update Vendors set AccountID=@@Identity where Vendor_Name=@Name  
End  
Else If @MasterType=@Bank  
Begin  
 Execute sp_acc_insertaccountsforexistingmasters @Name,@GroupID,1  
 update Bank set AccountID=@@Identity  
 where Account_Number=@Name and BankCode = @BankCode  
End  
Else If @MasterType=@DEBIT  
Begin  
 Update DebitNote set AccountID=@GroupID where DebitID=@NoteID  
End  
Else If @MasterType=@CREDIT  
Begin  
 Update CreditNote set AccountID=@GroupID where CreditID=@NoteID  
End  
Else If @MasterType=@BRANCHOFFICE  
Begin  
 Execute sp_acc_insertaccountsforexistingmasters @Name,@GroupID,1  
 update WareHouse set AccountID=@@Identity where WareHouse_Name=@Name  
End  
Else If @MasterType=@PERSONNAL  
Begin  
 Execute sp_acc_insertaccountsforexistingmasters @Name,@GroupID,1  
 update PersonnelMaster set AccountID=@@Identity where PersonnelName = @Name  
End 
