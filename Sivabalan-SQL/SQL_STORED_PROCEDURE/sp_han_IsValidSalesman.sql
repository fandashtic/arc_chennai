CREATE Procedure sp_han_IsValidSalesman(@SalesmanID nVarchar(15))  
As  
Select  SalesmanID from Salesman Where SalesmanID = @SalesmanID  

