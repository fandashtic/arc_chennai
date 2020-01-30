CREATE Procedure sp_acc_ImportWareHouse(@WareHouseName Varchar(100),@WareHouseID nVarchar(50))
As
DECLARE @WARESHOUSEGROUP INT,@Active INT
SET @WARESHOUSEGROUP = 35
SET @Active = 1

/* Insertion of BranchAccount Into the AccountMaster table */
Execute sp_acc_InsertAccountsForExistingMasters @WareHouseName,@WARESHOUSEGROUP,@Active
/* Updation of new AccounID into the Customer table. */	
Update WareHouse Set AccountID = @@IDENTITY Where WareHouseID = @WareHouseID
