
CREATE Procedure sp_acc_fixedaccounts  
As  
Select AccountID,AccountName,AccountsMaster.GroupID,GroupName from   
Accountsmaster,AccountGroup where AccountsMaster.GroupID=AccountGroup.GroupID  and AccountsMaster.Fixed=1
order by AccountID  


