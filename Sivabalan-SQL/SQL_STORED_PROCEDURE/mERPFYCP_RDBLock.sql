--------------------------------------------------- mERPRDBLock --------------------------------------------------------
Create Procedure mERPFYCP_RDBLock( @szDbName as nvarchar(100) ) as
Declare @Sql Varchar(200)
Select @Sql = 'Alter Database ' + @szDbName + ' Set Multi_User'
Exec (@Sql)
--mERPRDBLock 'Minerva_KIK059_2007'

