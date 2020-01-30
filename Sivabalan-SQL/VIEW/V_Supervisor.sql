Create View [dbo].[V_Supervisor]
([Supervisor_ID], [Supervisor_Name], [Address], [Phone], [Active])
as 
Select 
SalesmanID as Supervisor_ID,
SalesmanName as Supervisor_Name,
Isnull(Address,'') as [Address], 
isnull(MobileNo,'') as [Phone],
Active From Salesman2
