CREATE procedure sp_acc_updatebranchname(@BranchID nvarchar(50))
as 
Declare @AccountID integer,@WareHouse_Name nvarchar(256)

select @AccountID=AccountID,@WareHouse_Name = WareHouse_Name 
from WareHouse where [WareHouseID]=@BranchID

update AccountsMaster Set AccountName = @WareHouse_Name
where AccountID = @AccountID




