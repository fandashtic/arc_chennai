CREATE procedure sp_ser_servicecustomer
as
Select CustomerID, Company_Name, AccountsMaster.AccountID,AccountsMaster.AccountName from AccountsMaster 
Inner Join customer on AccountsMaster.AccountID = customer.AccountID and 
(customer.CustomerCategory = 4 and customer.Active = 0)


