CREATE procedure sp_acc_UpgradeCashCustomer  
As  
DECLARE @DEBTORSGROUP 	INT,@Active Int  
DECLARE @CustomerName 	nvarchar(260)
DECLARE @CustomerID  	nvarchar(30)

SET @DEBTORSGROUP=22  
SET @Active=1  


Declare GetCashCustomer Cursor 
For
select CustomerID,Company_Name from Customer 
where customercategory = 3 and isnull(AccountID,0) = 0
Open GetCashCustomer
Fetch from GetCashCustomer into @CustomerID , @CustomerName
While @@FETCH_STATUS = 0 
Begin
	/* Insertion of customer account into the AccountMaster table. */  
	Execute sp_acc_insertaccountsforexistingmasters @CustomerName,@DEBTORSGROUP,@Active  
	/* Updation of new AccounID into the Customer table. */   
	update customer set AccountID=@@Identity where customerID=@CustomerID  
	Fetch Next from GetCashCustomer into @CustomerID , @CustomerName
End  

Close GetCashCustomer
Deallocate GetCashCustomer


