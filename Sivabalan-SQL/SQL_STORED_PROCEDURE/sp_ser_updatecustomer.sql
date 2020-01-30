CREATE procedure sp_ser_updatecustomer(@CustomerID as nvarchar(30), @Active as int) as 
Declare @AccountID as int 
Update Customer Set Active = @Active, @AccountID = AccountID Where CustomerID = @CustomerID 
Update AccountsMaster Set Active = @Active Where AccountID = @AccountID 
Select @@RowCount 



