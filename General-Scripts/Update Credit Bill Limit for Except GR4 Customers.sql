---select * from CustomerCreditLimit
---select * from CustomerCreditLimit_Backup_18_Feb_2020
--select * from Customer Where Active = 1
---select * from ProductCategoryGroupAbstract Where OCGType = 1
IF Exists(select top 1 1 from sys.objects where name = 'CustomerCreditLimit_Backup_18_Feb_2020')
begin
	drop table CustomerCreditLimit_Backup_18_Feb_2020	
end
GO
select * into CustomerCreditLimit_Backup_18_Feb_2020 From CustomerCreditLimit
GO
INSERT INTO CustomerCreditLimit (CustomerID,GroupID,CreditTermDays,CreditLimit,NoOfBills)
select C.CustomerID, G.GroupId, -1, 0, 1
from Customer C WITH (NOLOCK)
,ProductCategoryGroupAbstract G  WITH (NOLOCK)
where C.CustomerID NOT IN (select distinct CustomerID from CustomerCreditLimit WITH (NOLOCK))
AND OCGType = 1
GO


