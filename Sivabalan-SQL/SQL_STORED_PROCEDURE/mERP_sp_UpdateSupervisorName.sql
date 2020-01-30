CREATE Procedure mERP_sp_UpdateSupervisorName (@ID nvarchar(10),@NewName nvarchar(128))      
As
Update Salesman2 Set salesmanName = @NewName    
Where SalesmanId = @ID      
