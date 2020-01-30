
CREATE Procedure sp_acc_importCustomer(@CustomerName nvarchar(50),@CustomerID nvarchar(15))
As
DECLARE @DEBTORSGROUP INT,@Active Int
SET @DEBTORSGROUP=22
SET @Active=1

/* Insertion of customer account into the AccountMaster table. */
Execute sp_acc_insertaccountsforexistingmasters @CustomerName,@DEBTORSGROUP,@Active
/* Updation of new AccounID into the Customer table. */	
update customer set AccountID=@@Identity where customerID=@CustomerID





