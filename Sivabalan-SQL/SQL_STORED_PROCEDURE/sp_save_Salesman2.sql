create procedure sp_save_Salesman2 (@SalesmanName nvarchar(255))  
as  
Insert into Salesman2(SalesmanName) Values (@SalesmanName)  
select @@Identity  
