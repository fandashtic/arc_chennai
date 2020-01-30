CREATE PROCEDURE mERP_sp_Update_Custaudit(@CustomerID nvarchar(20))
As
Begin
IF Not Exists(Select * from Customer_audit where CustomerID = @CustomerID)
Insert into Customer_audit
Select CustomerID, 1, CreationDate, GetDate() from Customer     -- 1 is For Active Modification
where Customerid= @CustomerID
ELSE
Update Customer_audit set Modified = GetDate() where Customerid= @CustomerID
END
