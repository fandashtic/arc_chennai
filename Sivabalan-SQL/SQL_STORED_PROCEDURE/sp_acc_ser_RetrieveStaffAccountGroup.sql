CREATE Procedure sp_acc_ser_RetrieveStaffAccountGroup(@StaffID nVarchar(255))  
As  
Declare @AccountID Integer  
Select AccountGroup.GroupID,AccountGroup.GroupName from PersonnelMaster,AccountsMaster,AccountGroup  
Where PersonnelID = @StaffID and PersonnelMaster.AccountID = AccountsMaster.AccountID  
And AccountsMaster.GroupID = AccountGroup.GroupID
